import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
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
      color: context.cores.surfaceMuted,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isVideo ? Icons.movie_outlined : Icons.image_outlined,
                color: context.cores.textSecondary.withValues(alpha: 0.5),
              ),
      ),
    );
  }
}

/// Imagem em tamanho cheio.
///
/// Para quem é dono, o arquivo vem do Drive. Para quem foi convidado, vem do
/// Firestore - e vem **para dentro do aplicativo**, não para o navegador.
class DriveFullImage extends ConsumerStatefulWidget {
  const DriveFullImage({required this.file, super.key, this.entryId});

  final EntryFile file;

  /// A entrada dona, quando conhecida. Só serve para consertar o acervo
  /// antigo: sem ela, a foto ainda abre normalmente.
  final String? entryId;

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
    final File baixado = await ref
        .read(memoryRepositoryProvider)
        .localCopy(widget.file);

    // Conserta o acervo antigo de graça: o arquivo acabou de ser baixado
    // para aparecer na tela, então gerar as cópias reduzidas a partir dele
    // não custa nem uma ida à rede a mais. Toda foto anterior a esta versão
    // ganha as cópias na primeira vez que quem é dono a abre.
    final String? uid = ref.read(uidProvider);
    if (uid != null && widget.entryId != null) {
      unawaited(
        ref
            .read(memoryRepositoryProvider)
            .backfillImages(
              uid: uid,
              entryId: widget.entryId!,
              file: widget.file,
              local: baixado,
            ),
      );
    }
    return baixado;
  }

  @override
  Widget build(BuildContext context) {
    // Quem foi convidado não baixa do Drive: o escopo `drive.file` não
    // alcança arquivo que este aplicativo não criou neste aparelho. A imagem
    // vem do Firestore, **dentro do aplicativo** - mandar a família para
    // fora para ver uma foto contradiz o que a cápsula é.
    if (ref.watch(isReadOnlyProvider)) {
      return _ImagemDaFamilia(file: widget.file);
    }

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

/// A foto em tela cheia para quem foi convidado, vinda do Firestore.
///
/// Enquanto a imagem maior chega, a miniatura já ocupa a tela: nunca um
/// retângulo preto. É a mesma ideia da linha do tempo de quem é dono, e pelo
/// mesmo motivo - esperar olhando para o vazio faz o aplicativo parecer
/// quebrado.
class _ImagemDaFamilia extends ConsumerStatefulWidget {
  const _ImagemDaFamilia({required this.file});

  final EntryFile file;

  @override
  ConsumerState<_ImagemDaFamilia> createState() => _ImagemDaFamiliaState();
}

class _ImagemDaFamiliaState extends ConsumerState<_ImagemDaFamilia> {
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    final String? uid = ref.read(capsuleOwnerProvider);
    _future = uid == null || widget.file.driveId.isEmpty
        ? Future<Uint8List?>.value(null)
        : ref
              .read(firestoreServiceProvider)
              .loadDisplayImage(uid, widget.file.driveId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
        final Uint8List? bytes = snapshot.data;
        if (bytes == null) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              DriveThumbnail(file: widget.file, fit: BoxFit.contain),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        return InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
        );
      },
    );
  }
}
