import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/entry.dart';
import '../../services/thumbnail_service.dart';
import '../../state/providers.dart';

/// Miniatura de um arquivo do Drive.
///
/// Tenta, nesta ordem: o arquivo original ainda no aparelho (aparece na
/// hora, mesmo antes do upload terminar), a miniatura em cache, e só então
/// a miniatura do Drive. É essa cascata que faz a linha do tempo abrir sem
/// telas de carregamento.
class DriveThumbnail extends ConsumerStatefulWidget {
  const DriveThumbnail({
    required this.file,
    super.key,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final EntryFile file;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  ConsumerState<DriveThumbnail> createState() => _DriveThumbnailState();
}

class _DriveThumbnailState extends ConsumerState<DriveThumbnail> {
  Future<File?>? _future;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(DriveThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.driveId != widget.file.driveId ||
        oldWidget.file.localPath != widget.file.localPath) {
      _resolve();
    }
  }

  void _resolve() {
    final String? localPath = widget.file.localPath;
    if (localPath != null) {
      final File local = File(localPath);
      if (local.existsSync()) {
        _future = Future<File?>.value(local);
        return;
      }
    }
    if (widget.file.driveId.isEmpty) {
      _future = Future<File?>.value(null);
      return;
    }
    final ThumbnailStore thumbnails = ref.read(thumbnailServiceProvider);
    _future = thumbnails.resolve(widget.file.driveId);
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = FutureBuilder<File?>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
        final File? file = snapshot.data;
        if (file == null) {
          return _Placeholder(
            loading: snapshot.connectionState == ConnectionState.waiting,
            isVideo: widget.file.isVideo,
          );
        }
        return Image.file(
          file,
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) =>
              _Placeholder(loading: false, isVideo: widget.file.isVideo),
        );
      },
    );

    final BorderRadius? radius = widget.borderRadius;
    if (radius == null) return image;
    return ClipRRect(borderRadius: radius, child: image);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.loading, required this.isVideo});

  final bool loading;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isVideo ? Icons.movie_outlined : Icons.image_outlined,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
      ),
    );
  }
}

/// Imagem em tamanho cheio, buscada direto do Drive com autenticação.
class DriveFullImage extends ConsumerStatefulWidget {
  const DriveFullImage({required this.file, super.key});

  final EntryFile file;

  @override
  ConsumerState<DriveFullImage> createState() => _DriveFullImageState();
}

class _DriveFullImageState extends ConsumerState<DriveFullImage> {
  late Future<File> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<File> _load() async {
    final String? localPath = widget.file.localPath;
    if (localPath != null) {
      final File local = File(localPath);
      if (await local.exists()) return local;
    }
    return ref.read(memoryRepositoryProvider).localCopy(widget.file);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não foi possível abrir esta imagem.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final File? file = snapshot.data;
        if (file == null) {
          // Enquanto baixa, a miniatura já preenche a tela - nunca um vazio.
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              DriveThumbnail(file: widget.file, fit: BoxFit.contain),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        return InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(child: Image.file(file, fit: BoxFit.contain)),
        );
      },
    );
  }
}
