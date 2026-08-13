import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/hero_da_midia.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Visualizador em tela cheia, com deslize entre os arquivos.
class MediaViewerScreen extends ConsumerStatefulWidget {
  const MediaViewerScreen({
    required this.files,
    required this.entries,
    required this.initialIndex,
    required this.origemDoVoo,
    super.key,
  });

  final List<EntryFile> files;
  final List<Entry> entries;
  final int initialIndex;

  /// Qual tela abriu esta, para o voo da miniatura achar o par.
  ///
  /// Vem de quem abre, e não de uma constante daqui, porque as abas ficam
  /// montadas ao mesmo tempo e a mesma foto pode existir em duas telas.
  final String origemDoVoo;

  @override
  ConsumerState<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends ConsumerState<MediaViewerScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  /// Enquanto a foto está ampliada, o deslize entre fotos para.
  ///
  /// Sem isto, arrastar para ver o canto da foto vira trocar de foto: o
  /// `PageView` fica com o gesto horizontal e a ampliação não serve de nada.
  bool _ampliada = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Manda a memória para a lixeira, com confirmação.
  ///
  /// Existe aqui, e não só na tela de detalhe, porque é aqui que a pessoa
  /// descobre que enviou a foto errada: ela abre a foto para olhar, vê que é
  /// do trabalho, e quer sumir com ela naquele instante.
  Future<void> _apagar(Entry entry) async {
    final bool ok = await confirm(
      context,
      title: S.deleteConfirmTitle,
      message: S.deleteConfirmBody,
      confirmLabel: S.delete,
    );
    if (!ok || !mounted) return;

    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    try {
      await ref.read(memoryRepositoryProvider).moveToTrash(uid, entry);
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) showMessage(context, userMessage(e, context: S.delete));
    }
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
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: S.delete,
            onPressed: () => _apagar(entry),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.files.length,
              // Ampliada, a foto fica com o gesto para si.
              physics: _ampliada
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              onPageChanged: (int i) => setState(() {
                _index = i;
                // Trocar de foto começa do tamanho normal: a próxima não
                // herda a ampliação da anterior.
                _ampliada = false;
              }),
              itemBuilder: (BuildContext context, int index) {
                final EntryFile current = widget.files[index];
                if (current.isVideo) return DriveVideoPlayer(file: current);
                // Só a página aberta entra no voo. As vizinhas o `PageView`
                // já construiu, e duas etiquetas iguais na mesma árvore
                // derrubam a tela.
                final Widget imagem = DriveFullImage(file: current);
                final Widget comVoo = index == _index
                    ? HeroDaMidia(
                        origem: widget.origemDoVoo,
                        file: current,
                        child: imagem,
                      )
                    : imagem;
                return FotoAmpliavel(
                  // Uma chave por arquivo: sem ela, deslizar reaproveitaria
                  // o estado da foto anterior e a nova abriria ampliada.
                  key: ValueKey<String>(current.driveId),
                  onZoom: (bool ampliada) {
                    if (index == _index && ampliada != _ampliada) {
                      setState(() => _ampliada = ampliada);
                    }
                  },
                  child: comVoo,
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(
              Space.x20,
              Space.x12,
              Space.x20,
              Space.x24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Fmt.longDate(entry.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (entry.description != null &&
                    entry.description!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Space.x8),
                  Text(
                    entry.description!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
                if (file.isVideo) ...<Widget>[
                  const SizedBox(height: Space.x12),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: Space.x8),
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
/// direto do Drive é instável em rede móvel, e o vídeo já está em 540p.
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
          padding: EdgeInsets.all(Space.x24),
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
              colors: VideoProgressColors(
                playedColor: context.cores.primary,
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

/// Uma foto que dá para ampliar com dois dedos e com dois toques.
///
/// O visualizador não tinha zoom nenhum. O que existia era um `PageView` com
/// a imagem dentro, e o `PageView` fica com o gesto horizontal para si: por
/// isso abrir os dois dedos "às vezes funcionava", quando o movimento saía
/// vertical o bastante para ele não reclamar.
///
/// Duas coisas resolvem isso juntas, e nenhuma sozinha:
///
/// * o `InteractiveViewer`, que é quem amplia de verdade; e
/// * travar o deslize entre fotos enquanto está ampliado, senão arrastar
///   para ver o canto da foto vira trocar de foto.
///
/// O toque duplo existe porque é como se amplia uma foto em qualquer outro
/// aplicativo, e porque dois dedos numa foto que ocupa a tela inteira é um
/// gesto que escorrega.
class FotoAmpliavel extends StatefulWidget {
  const FotoAmpliavel({required this.child, required this.onZoom, super.key});

  final Widget child;

  /// Avisa quem está por fora que a foto saiu do tamanho normal, para o
  /// deslize entre fotos parar enquanto isso durar.
  final ValueChanged<bool> onZoom;

  @override
  State<FotoAmpliavel> createState() => _FotoAmpliavelState();
}

class _FotoAmpliavelState extends State<FotoAmpliavel>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformacao = TransformationController();
  late final AnimationController _animacao = AnimationController(
    vsync: this,
    duration: Motion.slide,
  );
  Animation<Matrix4>? _voo;

  /// Onde a pessoa tocou duas vezes, para a ampliação ir para lá em vez de
  /// para o centro da tela.
  TapDownDetails? _ultimoToque;

  static const double _ampliacao = 2.5;

  @override
  void initState() {
    super.initState();
    _transformacao.addListener(_avisar);
    _animacao.addListener(() {
      final Animation<Matrix4>? voo = _voo;
      if (voo != null) _transformacao.value = voo.value;
    });
  }

  @override
  void dispose() {
    _transformacao
      ..removeListener(_avisar)
      ..dispose();
    _animacao.dispose();
    super.dispose();
  }

  bool _ampliado = false;

  void _avisar() {
    // A escala é o primeiro valor da matriz.
    final bool agora = _transformacao.value.getMaxScaleOnAxis() > 1.01;
    if (agora == _ampliado) return;
    _ampliado = agora;
    widget.onZoom(agora);
  }

  void _alternar() {
    final bool voltando = _transformacao.value.getMaxScaleOnAxis() > 1.01;
    final Matrix4 destino;

    if (voltando) {
      destino = Matrix4.identity();
    } else {
      final Offset ponto = _ultimoToque?.localPosition ?? Offset.zero;
      // Leva o ponto tocado para onde ele estava, já ampliado: sem isto a
      // foto salta para o centro e a pessoa perde de vista o que queria ver.
      destino = Matrix4.identity()
        ..translateByDouble(
          -ponto.dx * (_ampliacao - 1),
          -ponto.dy * (_ampliacao - 1),
          0,
          1,
        )
        ..scaleByDouble(_ampliacao, _ampliacao, _ampliacao, 1);
    }

    _voo = Matrix4Tween(
      begin: _transformacao.value,
      end: destino,
    ).animate(CurvedAnimation(parent: _animacao, curve: Curves.easeOutCubic));
    _animacao.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (TapDownDetails d) => _ultimoToque = d,
      onDoubleTap: _alternar,
      child: InteractiveViewer(
        transformationController: _transformacao,
        minScale: 1,
        maxScale: 5,
        // Sem recorte: a foto ampliada pode passar da borda enquanto a
        // pessoa arrasta, e cortar isso faz a imagem piscar nas laterais.
        clipBehavior: Clip.none,
        child: widget.child,
      ),
    );
  }
}
