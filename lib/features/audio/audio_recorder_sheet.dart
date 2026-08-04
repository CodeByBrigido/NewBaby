import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../services/lock_service.dart';

/// Grava a voz de quem está com a criança.
///
/// É o formato mais denso que este aplicativo guarda. Uma foto mostra como
/// ela era; trinta segundos da mãe dizendo "hoje você deu o primeiro passo"
/// devolvem quem ela era, e a voz é a primeira coisa que a memória perde.
///
/// Devolve o caminho do arquivo gravado, ou `null` se a pessoa desistiu.
Future<String?> showAudioRecorder(BuildContext context) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    builder: (BuildContext context) => const _RecorderSheet(),
  );
}

/// Cinco minutos é bastante para um recado e ainda cabe no Drive sem pesar.
/// Passando disso, a gravação para sozinha, em vez de rodar esquecida no
/// bolso e virar meia hora de nada.
const Duration _limite = Duration(minutes: 5);

class _RecorderSheet extends StatefulWidget {
  const _RecorderSheet();

  @override
  State<_RecorderSheet> createState() => _RecorderSheetState();
}

class _RecorderSheetState extends State<_RecorderSheet> {
  final AudioRecorder _recorder = AudioRecorder();

  Timer? _relogio;
  Duration _decorrido = Duration.zero;
  bool _gravando = false;
  String? _caminho;
  String? _erro;

  @override
  void dispose() {
    _relogio?.cancel();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _iniciar() async {
    setState(() => _erro = null);
    try {
      // A caixa de permissão do sistema tira o aplicativo do primeiro plano.
      // Sem esta guarda, a trava biométrica dispararia no meio da gravação.
      final bool permitido = await ExternalActivity.run(
        () => _recorder.hasPermission(),
      );
      if (!permitido) {
        setState(
          () => _erro =
              'Sem acesso ao microfone não dá para gravar. A permissão pode '
              'ser liberada nos ajustes do aparelho.',
        );
        return;
      }

      final Directory dir = await getTemporaryDirectory();
      final String destino = p.join(
        dir.path,
        'voz_${Fmt.fileStamp(DateTime.now())}.m4a',
      );

      // AAC em contêiner MP4: toca em qualquer aparelho e em qualquer
      // computador, hoje e daqui a vinte anos. Formato exótico envelhece mal,
      // e este acervo precisa continuar legível.
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 96000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: destino,
      );

      setState(() {
        _gravando = true;
        _decorrido = Duration.zero;
        _caminho = null;
      });
      _relogio = Timer.periodic(const Duration(seconds: 1), (Timer _) {
        if (!mounted) return;
        setState(() => _decorrido += const Duration(seconds: 1));
        if (_decorrido >= _limite) unawaited(_parar());
      });
    } on Object catch (e) {
      setState(() => _erro = userMessage(e));
    }
  }

  Future<void> _parar() async {
    _relogio?.cancel();
    try {
      final String? caminho = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _gravando = false;
        _caminho = caminho;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _gravando = false;
        _erro = userMessage(e);
      });
    }
  }

  Future<void> _descartar() async {
    final String? caminho = _caminho;
    setState(() {
      _caminho = null;
      _decorrido = Duration.zero;
    });
    if (caminho == null) return;
    // A gravação descartada é do próprio aplicativo, na pasta temporária:
    // apagar aqui é seguro e evita deixar voz esquecida no aparelho.
    try {
      final File arquivo = File(caminho);
      if (arquivo.existsSync()) await arquivo.delete();
    } on Object {
      // Não conseguir apagar o temporário não é motivo para travar a tela.
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool temGravacao = _caminho != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Gravar um áudio', style: text.titleMedium),
            const SizedBox(height: 6),
            Text(
              temGravacao
                  ? 'Guarde, ou grave de novo.'
                  : 'A voz é o que mais se perde com o tempo.',
              style: text.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            _Pulse(gravando: _gravando),
            const SizedBox(height: 16),
            Text(
              Fmt.duration(_decorrido),
              style: text.headlineSmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                color: _gravando
                    ? context.cores.primary
                    : context.cores.textPrimary,
              ),
            ),

            if (_erro != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                _erro!,
                style: text.bodySmall?.copyWith(color: AppPalette.danger),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 28),
            if (temGravacao)
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await _descartar();
                        await _iniciar();
                      },
                      child: const Text('Gravar de novo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_caminho),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: _gravando ? _parar : _iniciar,
                icon: Icon(_gravando ? Icons.stop : Icons.mic),
                label: Text(_gravando ? 'Parar' : 'Começar a gravar'),
              ),

            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                if (_gravando) await _parar();
                await _descartar();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um círculo que pulsa enquanto grava, para não restar dúvida de que o
/// microfone está aberto.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.gravando});

  final bool gravando;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.gravando) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_Pulse old) {
    super.didUpdateWidget(old);
    if (widget.gravando && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.gravando && _c.isAnimating) {
      _c
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? child) {
        final double escala = 1 + _c.value * 0.18;
        return Transform.scale(
          scale: escala,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: widget.gravando
                  ? context.cores.primarySoft
                  : context.cores.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic,
              size: 40,
              color: widget.gravando
                  ? context.cores.primary
                  : context.cores.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
