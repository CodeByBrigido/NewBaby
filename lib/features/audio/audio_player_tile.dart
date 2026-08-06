import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';

/// Toca um áudio guardado, sem sair do aplicativo.
///
/// Sair para outro aplicativo quebraria a ideia toda: a pessoa está
/// folheando uma vida, não abrindo arquivos.
class AudioPlayerTile extends ConsumerStatefulWidget {
  const AudioPlayerTile({required this.file, super.key});

  final EntryFile file;

  @override
  ConsumerState<AudioPlayerTile> createState() => _AudioPlayerTileState();
}

class _AudioPlayerTileState extends ConsumerState<AudioPlayerTile> {
  final AudioPlayer _player = AudioPlayer();

  bool _carregando = false;
  bool _pronto = false;
  String? _erro;

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  /// Baixa o arquivo do Drive na primeira vez e deixa o tocador pronto.
  ///
  /// Só ao tocar, nunca ao desenhar a lista: um dia com dez áudios baixaria
  /// dez arquivos que ninguém pediu.
  Future<void> _preparar() async {
    if (_pronto || _carregando) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final File arquivo = await ref
          .read(memoryRepositoryProvider)
          .localCopy(widget.file);
      await _player.setFilePath(arquivo.path);
      if (!mounted) return;
      setState(() {
        _pronto = true;
        _carregando = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = userMessage(e, context: 'baixar o áudio');
      });
    }
  }

  Future<void> _alternar() async {
    await _preparar();
    if (!_pronto) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      // Terminada a reprodução, a posição fica no fim; sem isto o segundo
      // toque não tocaria nada.
      if (_player.position >= (_player.duration ?? Duration.zero)) {
        await _player.seek(Duration.zero);
      }
      unawaited(_player.play());
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cores.audioSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (BuildContext context, AsyncSnapshot<PlayerState> snap) {
          final bool tocando = snap.data?.playing ?? false;
          return Row(
            children: <Widget>[
              IconButton(
                onPressed: _carregando ? null : _alternar,
                icon: _carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(tocando ? Icons.pause_circle : Icons.play_circle),
                iconSize: 34,
                color: context.cores.audio,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_erro != null)
                      Text(
                        _erro!,
                        style: text.bodySmall?.copyWith(
                          color: AppPalette.danger,
                        ),
                      )
                    else
                      _Progresso(player: _player, pronto: _pronto),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Progresso extends StatelessWidget {
  const _Progresso({required this.player, required this.pronto});

  final AudioPlayer player;
  final bool pronto;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (BuildContext context, AsyncSnapshot<Duration> snap) {
        final Duration total = player.duration ?? Duration.zero;
        final Duration atual = snap.data ?? Duration.zero;
        final double fracao = total.inMilliseconds == 0
            ? 0
            : (atual.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fracao,
                minHeight: 4,
                backgroundColor: context.cores.surface,
                color: context.cores.audio,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pronto
                  ? '${Fmt.duration(atual)} / ${Fmt.duration(total)}'
                  : 'Toque para ouvir',
              style: text.labelSmall?.copyWith(
                color: context.cores.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
