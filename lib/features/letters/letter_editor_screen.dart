import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/limits.dart';
import '../../core/router/app_router.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Escrever ou editar uma carta. Só dois campos: título e mensagem.
///
/// Não pergunta a data.
///
/// A carta é do dia em que foi escrita, e pronto. Foto e vídeo precisam de
/// data porque chegam de anos atrás, com a hora gravada dentro do arquivo;
/// carta nasce agora, na hora em que alguém senta para escrever. Perguntar
/// transformava o ato de escrever numa ficha a preencher.
class LetterEditorScreen extends ConsumerStatefulWidget {
  const LetterEditorScreen({super.key, this.entryId});

  /// `null` cria uma carta nova.
  final String? entryId;

  @override
  ConsumerState<LetterEditorScreen> createState() => _LetterEditorScreenState();
}

/// Quanto da tela o campo da mensagem ocupa quando ainda está vazio.
///
/// Ele ia até o fim da tela, e uma folha em branco desse tamanho é o que
/// faz a pessoa fechar sem escrever. Pela metade, o campo continua sendo o
/// maior elemento da tela e ainda sobra lugar para mostrar por onde começar.
///
/// O campo cresce sozinho conforme a carta cresce: isto é o começo, não o
/// teto. O limite de caracteres não mudou.
const double _fracaoDaTela = 0.42;

/// A entrelinha da carta, mais folgada que a do corpo comum: é texto para
/// ler devagar. A mesma da tela de leitura.
const double _entrelinhaDaCarta = 1.6;

/// O campo depois de receber um começo pronto, na posição do cursor.
///
/// Substituir o texto inteiro seria mais simples e apagaria a carta de quem
/// tocou por curiosidade depois de já ter escrito. Por isso o começo entra
/// onde o cursor está, o que já estava escrito continua lá, e o cursor para
/// no fim do começo, que é onde a pessoa vai continuar.
///
/// É função de topo, e não método da tela, para o teste exercitar esta
/// conta e não uma cópia dela: uma cópia passaria verde para sempre,
/// inclusive no dia em que a tela mudasse de ideia.
@visibleForTesting
TextEditingValue comComeco(TextEditingValue atual, String comeco) {
  final bool temCursor = atual.selection.isValid;
  final int inicio = temCursor ? atual.selection.start : atual.text.length;
  final int fim = temCursor ? atual.selection.end : atual.text.length;

  final String antes = atual.text.substring(0, inicio);
  final String depois = atual.text.substring(fim);
  // Um parágrafo de distância do que já estava escrito, para o começo não
  // grudar no fim da frase anterior.
  final String separador =
      antes.isEmpty || antes.endsWith('\n') || antes.endsWith(' ')
      ? ''
      : '\n\n';

  return TextEditingValue(
    text: '$antes$separador$comeco$depois',
    selection: TextSelection.collapsed(
      offset: antes.length + separador.length + comeco.length,
    ),
  );
}

class _LetterEditorScreenState extends ConsumerState<LetterEditorScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _message = TextEditingController();
  final FocusNode _focoDaMensagem = FocusNode();
  bool _loaded = false;
  bool _saving = false;

  void _comecarCom(String comeco) {
    final TextEditingValue novo = comComeco(_message.value, comeco);
    if (novo.text.length > Limits.description) return;
    _message.value = novo;
    _focoDaMensagem.requestFocus();
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    _focoDaMensagem.dispose();
    super.dispose();
  }

  Entry? get _existing {
    final String? id = widget.entryId;
    if (id == null) return null;
    return ref
        .watch(entriesProvider)
        .value
        ?.firstWhereOrNull((Entry e) => e.id == id);
  }

  Future<void> _save() async {
    final String title = _title.text.trim();
    final String message = _message.text.trim();
    if (title.isEmpty && message.isEmpty) {
      showMessage(context, 'Escreva alguma coisa antes de salvar.');
      return;
    }

    final String? uid = ref.read(uidProvider);
    final BabyProfile? profile = ref.read(profileProvider).value;
    if (uid == null || profile == null) return;

    setState(() => _saving = true);
    try {
      final Entry? existing = _existing;
      if (existing == null) {
        await ref
            .read(memoryRepositoryProvider)
            .addLetter(
              uid: uid,
              profile: profile,
              title: title.isEmpty ? 'Carta' : title,
              message: message,
            );
      } else {
        await ref
            .read(memoryRepositoryProvider)
            .updateDetails(
              uid,
              existing,
              title: title.isEmpty ? 'Carta' : title,
              description: message,
              // Sem o perfil a edição não alcança o Drive, e o `.txt` lá
              // fora fica com a versão antiga da carta.
              profile: profile,
            );
      }
      if (mounted) {
        context.canPop() ? context.pop() : context.go(Routes.letters);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, userMessage(e, context: 'Salvar carta'));
      }
    }
  }

  /// Quantas linhas o campo abre, para ele começar com meia tela.
  ///
  /// Vem da altura do aparelho, e não de um número fixo de linhas: a mesma
  /// contagem que ocupa metade de um celular pequeno passa longe disso num
  /// aparelho grande. Os limites existem para os extremos, como a tela
  /// dividida, onde a conta devolveria duas linhas.
  int _linhasIniciais(BuildContext context) {
    final TextStyle corpo = Theme.of(context).textTheme.bodyLarge!;
    final double alturaDaLinha = corpo.fontSize! * _entrelinhaDaCarta;
    final double disponivel = MediaQuery.sizeOf(context).height * _fracaoDaTela;
    return (disponivel / alturaDaLinha).round().clamp(6, 20);
  }

  @override
  Widget build(BuildContext context) {
    final Entry? existing = _existing;
    if (existing != null && !_loaded) {
      _title.text = existing.title ?? '';
      _message.text = existing.description ?? '';
      _loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'Nova carta' : 'Editar carta'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.letters),
        ),
        actions: <Widget>[
          TextButton(onPressed: _saving ? null : _save, child: Text(S.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.x20),
        children: <Widget>[
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            maxLength: Limits.title,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(
              counterText: '',
              labelText: S.titleField,
              hintText: Copy.of(ref.watch(profileProvider).value).letterHint,
            ),
          ),
          const SizedBox(height: Space.x16),
          TextField(
            controller: _message,
            focusNode: _focoDaMensagem,
            textCapitalization: TextCapitalization.sentences,
            maxLength: Limits.description,
            // `minLines` em vez de `expands`: o campo abre com meia tela e
            // cresce junto com a carta, em vez de ser uma caixa fixa que
            // rola por dentro de uma tela que já rola.
            minLines: _linhasIniciais(context),
            maxLines: null,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: _entrelinhaDaCarta),
            decoration: InputDecoration(
              counterText: '',
              labelText: S.messageField,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: Space.x24),
          _ComoComecar(onEscolher: _comecarCom),
          const SizedBox(height: Space.x24),
          InfoNote(
            icon: Icons.lock_clock_outlined,
            message: Copy.of(ref.watch(profileProvider).value).letterKeepsafe,
          ),
        ],
      ),
    );
  }
}

/// Começos prontos, para quem travou na primeira frase.
///
/// Ficam embaixo do campo, e não dentro dele como dica: uma dica some no
/// primeiro toque, e é justamente depois de tocar que a pessoa percebe que
/// não sabe como começar.
class _ComoComecar extends StatelessWidget {
  const _ComoComecar({required this.onEscolher});

  final void Function(String) onEscolher;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.letterStartersTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Space.x12),
        Wrap(
          // Junto, e não espalhado: são sete rótulos curtos, e o respiro
          // largo fazia cada um parecer um botão separado em vez de uma
          // lista de opções para varrer com os olhos.
          spacing: Space.x4,
          runSpacing: Space.x4,
          children: <Widget>[
            for (final String comeco in S.letterStarters)
              ActionChip(
                // Sem as aspas e sem o espaço do fim, que servem ao texto
                // escrito e não ao rótulo.
                label: Text(comeco.trim()),
                onPressed: () => onEscolher(comeco),
                // O espaço entre os rótulos quase todo vinha daqui, e não do
                // `spacing` acima: por padrão o chip reserva 48 px de altura
                // de área de toque, o que empurrava cada linha para longe da
                // seguinte. Sem essa reserva, o respiro passa a ser o que
                // está escrito.
                //
                // A área de toque encolhe junto, e isso é aceitável só aqui:
                // são atalhos de escrita, não caminho obrigatório de nada, e
                // errar o alvo custa apagar uma frase.
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }
}
