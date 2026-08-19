import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/inspiration.dart';
import '../../state/providers.dart';
import '../shell/add_sheet.dart';
import 'capa_da_postagem.dart';

/// O texto longo de uma inspiração.
///
/// Sem tempo de leitura, sem contador, sem rolagem infinita: a página é para
/// ser lida em dois minutos e fechada. Se ela virar um lugar onde a pessoa
/// passa tempo, o aplicativo passou a competir pela atenção que era para
/// estar na criança.
///
/// A capa é desenhada em código (veja [InspirationArt]) e as leituras
/// relacionadas no fim são poucas e só entre as que valem hoje. O botão que
/// fica flutuando o tempo todo é o de registrar, não o de ler mais.
class InspirationArticleScreen extends ConsumerStatefulWidget {
  const InspirationArticleScreen({required this.active, super.key});

  final ActiveInspiration active;

  @override
  ConsumerState<InspirationArticleScreen> createState() =>
      _InspirationArticleScreenState();
}

class _InspirationArticleScreenState
    extends ConsumerState<InspirationArticleScreen> {
  @override
  void initState() {
    super.initState();
    // Abrir já conta como lido: o selo de novidade existe para avisar que
    // chegou algo, não para cobrar leitura até o fim.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(readInspirationsProvider.notifier)
          .markRead(widget.active.inspiration.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Inspiration i = widget.active.inspiration;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(i.kind.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x20,
          Space.x8,
          Space.x20,
          Space.scrollEnd,
        ),
        children: <Widget>[
          CapaDaPostagem(inspiration: i, height: 200),
          const SizedBox(height: Space.x20),
          if (widget.active.daysLeft case final int dias)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.x12),
              child: _Countdown(dias: dias, data: widget.active.deadline!),
            ),
          Text(i.title, style: text.headlineSmall),
          const SizedBox(height: Space.x12),
          // A abertura é o mesmo corpo de texto do resto, separada só pela
          // cor. Ela vinha em `bodyLarge` enquanto o miolo vinha em
          // `bodyMedium`, e como a escala usa peso 400 num e 500 no outro, o
          // primeiro parágrafo parecia escrito noutra fonte.
          Text(
            i.summary,
            style: text.bodyLarge?.copyWith(color: context.cores.textSecondary),
          ),
          const SizedBox(height: Space.x8),

          for (final InspirationSection s in i.sections) ...<Widget>[
            const SizedBox(height: Space.x24),
            // 20/700, e não 14/600: o tópico vinha do mesmo tamanho do corpo
            // e com meio passo de peso a mais, então não separava assunto
            // nenhum. Uma postagem longa se lê pelos títulos antes de se ler
            // pelas frases.
            Text(s.title, style: text.titleLarge),
            if (s.body.isNotEmpty) ...<Widget>[
              const SizedBox(height: Space.x8),
              Text(s.body, style: text.bodyLarge),
            ],
            if (s.bullets.isNotEmpty) const SizedBox(height: Space.x12),
            for (final String item in s.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.x8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                        top: Space.x8,
                        right: Space.x12,
                      ),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.cores.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: Text(item, style: text.bodyLarge)),
                  ],
                ),
              ),
          ],

          _Related(atual: widget.active),
        ],
      ),
      floatingActionButton: i.suggests == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.dias, required this.data});

  final int dias;
  final DateTime data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x12,
        vertical: Space.x8,
      ),
      decoration: BoxDecoration(
        color: context.cores.primarySoft,
        borderRadius: Radii.pillR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.event, size: 16, color: context.cores.primaryDark),
          const SizedBox(width: Space.x8),
          Flexible(
            child: Text(
              dias == 0
                  ? S.todayWithDate(Fmt.dayMonth(data))
                  : dias == 1
                  ? S.tomorrowWithDate(Fmt.dayMonth(data))
                  : S.daysLeftWithDate(dias, Fmt.dayMonth(data)),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.cores.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Outras leituras, no fim do artigo.
///
/// Só entre as que valem hoje: sugerir algo de daqui a dois anos seria pior
/// que não sugerir nada. E o botão de registrar continua flutuando por cima,
/// porque o próximo passo desejado ainda é fechar o aplicativo e ir viver.
class _Related extends ConsumerWidget {
  const _Related({required this.atual});

  final ActiveInspiration atual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ActiveInspiration> ativas =
        ref.watch(inspirationsProvider).value ?? const <ActiveInspiration>[];
    final List<ActiveInspiration> outras = relatedTo(atual, ativas);
    if (outras.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: Space.x32),
        Divider(color: context.cores.divider),
        const SizedBox(height: Space.x16),
        // "Para ler depois" tratava a lista como uma pilha de pendências.
        // Estas são postagens do mesmo assunto, e o convite é continuar
        // lendo agora, não guardar para um depois que não chega.
        // Do mesmo tamanho dos tópicos do texto: é o último título da
        // página, e deixá-lo menor que os de cima faria a postagem terminar
        // em outra hierarquia da que ela usou o tempo todo.
        Text(
          'Postagens parecidas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: Space.x12),
        for (final ActiveInspiration a in outras) _RelatedTile(active: a),
      ],
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.active});

  final ActiveInspiration active;

  @override
  Widget build(BuildContext context) {
    final Inspiration i = active.inspiration;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x8),
      child: Material(
        color: context.cores.surfaceMuted,
        borderRadius: Radii.fieldR,
        child: InkWell(
          borderRadius: Radii.fieldR,
          // `pushReplacement`: ler cinco artigos seguidos não deve deixar
          // cinco telas empilhadas atrás. Voltar sai da leitura, em vez de
          // desfazer a trilha inteira.
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => InspirationArticleScreen(active: active),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Space.x12),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 64,
                  child: CapaDaPostagem(inspiration: i, height: 48),
                ),
                const SizedBox(width: Space.x12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        i.kind.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.cores.textSecondary,
                        ),
                      ),
                      const SizedBox(height: Space.x4),
                      Text(
                        i.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: context.cores.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
