import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/age_calculator.dart';
import '../../models/entry.dart';
import '../../services/memory_repository.dart';
import '../../state/providers.dart';

/// Para onde a janela leva quando o envio termina.
///
/// Cada tipo de memória mora num lugar diferente, e o botão precisa dizer o
/// nome do lugar certo: "Ver a pasta" numa carta não quer dizer nada.
@immutable
class _Destino {
  const _Destino({required this.rotulo, required this.rota});

  final String rotulo;
  final String rota;
}

/// Acompanha um envio do começo ao fim, e termina apontando para onde foi.
///
/// Antes disto o envio avisava por uma tarja que sumia sozinha em seis
/// segundos. Ela dizia que o envio começou e nunca dizia que terminou, então
/// quem mandava alguma coisa e trocava de tela não descobria se deu certo, e
/// principalmente não descobria **onde** aquilo foi parar. Numa cápsula
/// organizada por idade, esse "onde" é metade da informação.
///
/// Recebe uma lista de memórias, e não uma só, porque documento é enviado um
/// por arquivo: três documentos são três memórias, e uma janela por arquivo
/// seguraria o envio do próximo até alguém fechar a anterior.
class EnvioEmAndamento extends ConsumerStatefulWidget {
  const EnvioEmAndamento({
    required this.entries,
    required this.bucket,
    super.key,
  });

  final List<Entry> entries;

  /// A pasta de idade onde a memória vai ficar, calculada antes do envio.
  final AgeBucket bucket;

  @override
  ConsumerState<EnvioEmAndamento> createState() => _EnvioEmAndamentoState();
}

class _EnvioEmAndamentoState extends ConsumerState<EnvioEmAndamento> {
  /// O que o fluxo de progresso já contou sobre cada memória.
  final Map<String, UploadProgress> _progresso = <String, UploadProgress>{};

  EntryType get _tipo => widget.entries.first.type;

  @override
  Widget build(BuildContext context) {
    ref.listen(uploadProgressProvider, (_, AsyncValue<UploadProgress> valor) {
      final UploadProgress? p = valor.value;
      if (p == null) return;
      if (!widget.entries.any((Entry e) => e.id == p.entryId)) return;
      setState(() => _progresso[p.entryId] = p);
    });

    // O fluxo conta o que acontece a partir de agora; a lista conta o que já
    // aconteceu. Sem a segunda, um envio que termina antes de a janela abrir
    // deixaria ela girando para sempre.
    final List<Entry> daLista =
        ref.watch(entriesProvider).value ?? const <Entry>[];
    final List<UploadStatus> estados = <UploadStatus>[
      for (final Entry e in widget.entries)
        _progresso[e.id]?.status ??
            daLista
                .where((Entry atual) => atual.id == e.id)
                .map((Entry atual) => atual.uploadStatus)
                .firstOrNull ??
            UploadStatus.optimizing,
    ];

    final bool falhou = estados.any(
      (UploadStatus s) => s == UploadStatus.failed,
    );
    final bool pronto =
        !falhou && estados.every((UploadStatus s) => s == UploadStatus.ready);

    final String? erro = falhou
        ? (_progresso.values
                  .where((UploadProgress p) => p.status == UploadStatus.failed)
                  .map((UploadProgress p) => p.message)
                  .firstOrNull ??
              daLista
                  .where(
                    (Entry e) =>
                        widget.entries.any((Entry w) => w.id == e.id) &&
                        e.uploadStatus == UploadStatus.failed,
                  )
                  .map((Entry e) => e.errorMessage)
                  .firstOrNull)
        : null;

    final int concluidos = estados
        .where((UploadStatus s) => s == UploadStatus.ready)
        .length;

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
            LinearProgressIndicator(
              value: widget.entries.length == 1
                  ? _progresso[widget.entries.first.id]?.fraction
                  : concluidos / widget.entries.length,
            ),
            const SizedBox(height: Space.x16),
          ],
          Text(falhou ? (erro ?? S.genericError) : _onde(pronto: pronto)),
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
            if (pronto)
              if (_destino() case final _Destino d) ...<Widget>[
                const SizedBox(width: Space.x12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(d.rota);
                    },
                    // Centralizado porque o rótulo quebra em duas linhas.
                    //
                    // "Ver o documento" não cabe numa linha só dentro de dois
                    // terços da janela, e um `Text` de duas linhas alinha à
                    // esquerda por padrão. O botão ficava com o texto encostado
                    // numa borda e vazio na outra, parecendo desalinhado com
                    // ele mesmo.
                    child: Text(d.rotulo, textAlign: TextAlign.center),
                  ),
                ),
              ],
          ],
        ),
      ],
    );
  }

  /// A frase que diz onde a memória ficou, no tempo certo.
  String _onde({required bool pronto}) {
    final Copy g = Copy.of(ref.watch(profileProvider).value);
    final String verbo = pronto ? 'Está guardado' : 'Vai ficar guardado';

    // "no Google Drive da sua filha", e não "na sua conta do Google Drive".
    // A conta é da criança desde o primeiro dia, e esta é a frase que a
    // pessoa lê no instante em que a memória vai para lá.
    final String conta = 'no Google Drive ${g.ofTheChild}';

    // Carta e documento não entram em pasta de idade, então citar uma semana
    // ali seria mentira.
    if (!_tipo.bucketsByAge) {
      return pronto ? 'Está guardado $conta.' : 'Vai ser guardado $conta.';
    }
    final String artigo = widget.bucket.unit == AgeBucketUnit.week
        ? 'na'
        : 'no';
    return '$verbo $artigo ${widget.bucket.folderName}'
        '${pronto ? ", $conta." : "."}';
  }

  /// Para onde o botão leva, ou `null` quando não há tela para aquilo.
  _Destino? _destino() {
    switch (_tipo) {
      case EntryType.photo:
        return _Destino(
          rotulo: 'Ver a pasta',
          rota: Routes.bucket('fotos', widget.bucket.key),
        );
      case EntryType.video:
        return _Destino(
          rotulo: 'Ver a pasta',
          rota: Routes.bucket('videos', widget.bucket.key),
        );
      case EntryType.drawing:
        return const _Destino(rotulo: 'Ver o desenho', rota: Routes.drawings);
      case EntryType.document:
        // Um documento abre direto; vários abrem a lista, porque não há uma
        // tela que mostre três de uma vez.
        return widget.entries.length == 1
            ? _Destino(
                rotulo: 'Ver o documento',
                rota: Routes.document(widget.entries.first.id),
              )
            : const _Destino(
                rotulo: 'Ver os documentos',
                rota: Routes.documents,
              );
      case EntryType.letter:
      case EntryType.growth:
      case EntryType.birth:
        return null;
    }
  }
}

/// Abre a janela do envio.
///
/// Não devolve nada: fechar não cancela, e quem chamou não tem o que fazer
/// com o desfecho além do que a própria janela já mostra.
Future<void> mostrarEnvio(
  BuildContext context, {
  required List<Entry> entries,
  required AgeBucket bucket,
}) {
  if (entries.isEmpty) return Future<void>.value();
  return showDialog<void>(
    context: context,
    // Sem fechar tocando fora: a janela é a única coisa que conta onde a
    // memória foi parar, e fechá-la sem querer perde essa informação.
    barrierDismissible: false,
    builder: (BuildContext context) =>
        EnvioEmAndamento(entries: entries, bucket: bucket),
  );
}
