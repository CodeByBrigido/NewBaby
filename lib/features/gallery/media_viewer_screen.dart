import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Visualizador em tela cheia, com deslize entre os arquivos.
class MediaViewerScreen extends ConsumerStatefulWidget {
  const MediaViewerScreen({
    required this.files,
    required this.entries,
    required this.initialIndex,
    super.key,
  });

  final List<EntryFile> files;
  final List<Entry> entries;
  final int initialIndex;

  @override
  ConsumerState<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends ConsumerState<MediaViewerScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final EntryFile file = widget.files[_index];
    showMessage(context, 'Preparando para compartilhar...');
    try {
      final File local = await ref
          .read(memoryRepositoryProvider)
          .localCopy(file);
      if (!mounted) return;
      await ExternalActivity.run(
        () => SharePlus.instance.share(
          ShareParams(files: <XFile>[XFile(local.path)]),
        ),
      );
    } on Exception catch (e) {
      if (mounted) {
        showMessage(context, userMessage(e, context: 'Compartilhar'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final Entry entry = widget.entries[_index];
    final EntryFile file = widget.files[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          profile == null
              ? Fmt.date(entry.date)
              : profile.ageAt(entry.date).detailedLabel(),
          style: const TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.ios_share), onPressed: _share),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.files.length,
              onPageChanged: (int i) => setState(() => _index = i),
              itemBuilder: (BuildContext context, int index) {
                final EntryFile current = widget.files[index];
                return current.isVideo
                    ? DriveVideoPlayer(file: current)
                    : DriveFullImage(file: current);
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Fmt.longDate(entry.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (entry.description != null &&
                    entry.description!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    entry.description!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
                if (file.isVideo) ...<Widget>[
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          S.videoOptimizedNote,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Player de um vídeo guardado no Drive.
///
/// O arquivo é baixado para o cache antes de tocar: streaming autenticado
/// direto do Drive é instável em rede móvel, e o vídeo já está em 720p.
class DriveVideoPlayer extends ConsumerStatefulWidget {
  const DriveVideoPlayer({required this.file, super.key});

  final EntryFile file;

  @override
  ConsumerState<DriveVideoPlayer> createState() => _DriveVideoPlayerState();
}

class _DriveVideoPlayerState extends ConsumerState<DriveVideoPlayer> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final String? localPath = widget.file.localPath;
      File source;
      if (localPath != null && File(localPath).existsSync()) {
        source = File(localPath);
      } else {
        source = await ref
            .read(memoryRepositoryProvider)
            .localCopy(widget.file);
      }

      final VideoPlayerController controller = VideoPlayerController.file(
        source,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      await controller.play();
    } on Exception catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível abrir este vídeo.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final VideoPlayerController? controller = _controller;
    if (controller == null) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DriveThumbnail(file: widget.file, fit: BoxFit.contain),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(controller),
            GestureDetector(
              onTap: () => setState(
                () => controller.value.isPlaying
                    ? controller.pause()
                    : controller.play(),
              ),
              child: AnimatedOpacity(
                opacity: controller.value.isPlaying ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.primary,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
