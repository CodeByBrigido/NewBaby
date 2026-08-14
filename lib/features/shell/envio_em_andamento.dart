import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/age_calculator.dart';
import '../../models/entry.dart';
import '../../services/memory_repository.dart';
import '../../state/providers.dart';

/// Acompanha um envio do começo ao fim, e termina apontando para a pasta.
///
/// Antes disto o envio avisava por uma tarja que sumia sozinha em seis
/// segundos. Ela dizia que o envio começou e nunca dizia que terminou, então
/// quem mandava uma foto e trocava de tela não descobria se deu certo, e
/// principalmente não descobria **onde** a foto foi parar. Numa cápsula
/// organizada por idade, esse "onde" é metade da informação.
///
/// A janela fica aberta durante o envio e continua aberta no fim, com o
/// caminho para a pasta. Fechar é do lado, e fechar não cancela nada: o
/// envio já terminou quando o botão aparece.
class EnvioEmAndamento extends ConsumerStatefulWidget {
  const EnvioEmAndamento({
    required this.entry,
    required this.bucket,
    super.key,
  });

  final Entry entry;

  /// A pasta de idade onde a memória vai ficar, calculada antes do envio.
  final AgeBucket bucket;

  @override
  ConsumerState<EnvioEmAndamento> createState() => _EnvioEmAndamentoState();
}

class _EnvioEmAndamentoState extends ConsumerState<EnvioEmAndamento> {
  UploadStatus _status = UploadStatus.optimizing;
  String? _erro;
  double? _fracao;

  @override
  Widget build(BuildContext context) {
    // O progresso chega pelo mesmo fluxo que a linha do tempo escuta. Se a
    // janela abrir depois de o envio já ter acabado, o `Entry` observado
    // abaixo é quem conta o desfecho: sem isso, um envio rápido demais
    // deixaria a janela girando para sempre.
    ref.listen(uploadProgressProvider, (_, AsyncValue<UploadProgress> valor) {
      final UploadProgress? p = valor.value;
      if (p == null || p.entryId != widget.entry.id) return;
      setState(() {
        _status = p.status;
        _erro = p.message;
        _fracao = p.fraction;
      });
    });

    final Entry? atual = ref
        .watch(entriesProvider)
        .value
        ?.where((Entry e) => e.id == widget.entry.id)
        .firstOrNull;
    if (atual != null && !atual.uploadStatus.isBusy) {
      _status = atual.uploadStatus;
      _erro ??= atual.errorMessage;
    }

    final bool pronto = _status == UploadStatus.ready;
    final bool falhou = _status == UploadStatus.failed;

    // Só foto e vídeo têm tela de pasta. Carta, desenho e documento vivem em
    // listas próprias, e um botão "Ver a pasta" ali prometeria uma tela que
    // não existe.
    final String? galeria = switch (widget.entry.type) {
      EntryType.photo => 'fotos',
      EntryType.video => 'videos',
      _ => null,
    };

    return AlertDialog(
      title: Text(
        pronto
            ? 'Guardado'
            : falhou
            ? S.uploadFailed
            : 'Guardando...',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!pronto && !falhou) ...<Widget>[
            LinearProgressIndicator(value: _fracao),
            const SizedBox(height: Space.x16),
          ],
          Text(
            falhou
                ? (_erro ?? S.genericError)
                : pronto
                ? 'Está guardado ${_artigo(widget.bucket)} '
                      '${widget.bucket.folderName}, na sua conta do Google '
                      'Drive.'
                : 'Vai ficar guardado ${_artigo(widget.bucket)} '
                      '${widget.bucket.folderName}.',
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        Space.x24,
        Space.x8,
        Space.x24,
        Space.x20,
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ),
            if (pronto && galeria != null) ...<Widget>[
              const SizedBox(width: Space.x12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(Routes.bucket(galeria, widget.bucket.key));
                  },
                  child: const Text('Ver a pasta'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  static String _artigo(AgeBucket b) =>
      b.unit == AgeBucketUnit.week ? 'na' : 'no';
}

/// Abre a janela do envio.
///
/// Não devolve nada: fechar não cancela, e quem chamou não tem o que fazer
/// com o desfecho além do que a própria janela já mostra.
Future<void> mostrarEnvio(
  BuildContext context, {
  required Entry entry,
  required AgeBucket bucket,
}) {
  return showDialog<void>(
    context: context,
    // Sem fechar tocando fora: a janela é a única coisa que conta onde a
    // memória foi parar, e fechá-la sem querer perde essa informação.
    barrierDismissible: false,
    builder: (BuildContext context) =>
        EnvioEmAndamento(entry: entry, bucket: bucket),
  );
}
