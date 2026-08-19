import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/tokens.dart';

/// Limite do campo `titulo` nas regras do Firestore.
///
/// Repetido aqui de propósito: sem o corte na tela, escrever demais só falha
/// lá na gravação, com uma recusa de permissão que não explica nada.
const int limiteDoNome = 200;

/// Pergunta o nome com que o documento vai aparecer na lista.
///
/// Devolve o nome escolhido, ou `null` se a pessoa desistiu.
///
/// O nome de arquivo não serve como nome de documento. O seletor entrega
/// `IMG_20240412_093311.pdf` ou `Scan_0007.jpg`, e é isso que ficava na
/// lista: uma tela inteira de nomes que não dizem qual papel é qual. Quem
/// guarda uma certidão quer ler "Certidão de nascimento".
///
/// O arquivo no Drive continua com o nome original, e essa separação é
/// deliberada: lá o que importa é reconhecer o arquivo como ele foi enviado,
/// caso alguém abra a pasta daqui a vinte anos sem este aplicativo.
Future<String?> perguntarNomeDoDocumento(
  BuildContext context, {
  required String sugestao,
  String titulo = 'Nome do documento',
  String botao = 'Guardar',
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) =>
        _Dialogo(sugestao: sugestao, titulo: titulo, botao: botao),
  );
}

class _Dialogo extends StatefulWidget {
  const _Dialogo({
    required this.sugestao,
    required this.titulo,
    required this.botao,
  });

  final String sugestao;
  final String titulo;
  final String botao;

  @override
  State<_Dialogo> createState() => _DialogoState();
}

class _DialogoState extends State<_Dialogo> {
  late final TextEditingController _campo = TextEditingController(
    text: widget.sugestao,
  );

  @override
  void initState() {
    super.initState();
    // Tudo selecionado ao abrir: o nome do arquivo é sugestão, não ponto de
    // partida para edição. Quem quer trocar digita por cima; quem quer manter
    // só confirma. Sem isto, trocar o nome começa com um apagar longo.
    _campo.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _campo.text.length,
    );
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _confirmar() {
    final String nome = _campo.text.trim();
    if (nome.isEmpty) return;
    Navigator.of(context).pop(nome);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _campo,
        autofocus: true,
        maxLength: limiteDoNome,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _confirmar(),
        decoration: InputDecoration(
          labelText: S.documentNameQuestionFull,
          hintText: S.documentNameSuggestion,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        Space.x24,
        Space.x8,
        Space.x24,
        Space.x20,
      ),
      actions: <Widget>[
        // Os dois dentro de `Expanded`, como em toda linha de botões daqui:
        // o tema dá aos botões largura mínima infinita, e um botão assim
        // solto numa `Row` não consegue ser medido e não chega a ser pintado.
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: Space.x12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _confirmar,
                child: Text(widget.botao, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
