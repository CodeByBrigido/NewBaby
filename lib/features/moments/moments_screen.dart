import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/baby_profile.dart';
import '../../models/suggestion.dart';
import '../../models/suggestion_progress.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../shell/add_sheet.dart';

/// Momentos importantes: o que talvez valha a pena guardar agora.
///
/// Tudo aqui é convite, nunca constatação. O aplicativo não sabe se a
/// criança já sorriu, e escrever "o primeiro sorriso foi" seria inventar a
/// memória de outra pessoa. Ele pergunta, e quem responde é quem viveu.
class MomentsScreen extends ConsumerWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<ActiveSuggestion> ativas = ref.watch(activeSuggestionsProvider);
    final Copy copy = Copy.of(profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Momentos importantes')),
      body: ativas.isEmpty
          ? EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'Nada pendente por aqui',
              message: profile == null
                  ? 'As sugestões aparecem conforme a idade e o calendário.'
                  : 'As sugestões voltam conforme ${copy.theName} cresce e as '
                        'datas do ano se aproximam.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x12,
                Space.x16,
                Space.scrollEnd,
              ),
              itemCount: ativas.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.x12),
              itemBuilder: (BuildContext context, int index) =>
                  SuggestionCard(active: ativas[index], copy: copy),
            ),
    );
  }
}

/// Um cartão de sugestão, com o checklist quando houver.
class SuggestionCard extends ConsumerWidget {
  const SuggestionCard({
    required this.active,
    required this.copy,
    super.key,
    this.compact = false,
  });

  final ActiveSuggestion active;
  final Copy copy;

  /// Na tela inicial o cartão vem sem checklist, para não roubar a tela.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Suggestion s = active.suggestion;
    final TextTheme text = Theme.of(context).textTheme;
    final String nota = s.noteFor(copy.ofName);

    return Container(
      padding: const EdgeInsets.all(Space.x16),
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: Radii.cardR,
        border: Border.all(color: context.cores.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(Space.x8),
                decoration: BoxDecoration(
                  color: context.cores.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  s.hasChecklist
                      ? Icons.checklist_rtl
                      : Icons.auto_awesome_outlined,
                  size: 20,
                  color: context.cores.primary,
                ),
              ),
              const SizedBox(width: Space.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Só na tela inicial, e é ela que faz o cartão fazer
                    // sentido ali. Na tela de Momentos a barra do topo já
                    // diz o que é isto; na inicial o cartão aparecia sem
                    // apresentação nenhuma, entre a idade e o acervo, e
                    // "O primeiro corte de cabelo" sozinho não diz se é um
                    // aviso, uma cobrança ou algo que já aconteceu.
                    if (compact) ...<Widget>[
                      Text(
                        'Momento para registrar',
                        style: text.labelSmall?.copyWith(
                          color: context.cores.textSecondary,
                        ),
                      ),
                      const SizedBox(height: Space.x4),
                    ],
                    Text(s.title, style: text.titleSmall),
                    if (active.daysLeft case final int dias) ...<Widget>[
                      const SizedBox(height: Space.x4),
                      Text(
                        dias == 0
                            ? 'É hoje'
                            : dias == 1
                            ? 'Falta 1 dia'
                            : 'Faltam $dias dias',
                        style: text.labelMedium?.copyWith(
                          color: context.cores.primaryDark,
                        ),
                      ),
                    ],
                    if (nota.isNotEmpty) ...<Widget>[
                      const SizedBox(height: Space.x8),
                      Text(nota, style: text.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (s.hasChecklist && !compact) ...<Widget>[
            const SizedBox(height: Space.x8),
            for (final String item in s.checklist)
              _ChecklistLine(
                item: item,
                checked: active.checked.contains(item),
                onChanged: (bool marcado) => _toggle(ref, item, marcado),
              ),
          ],

          const SizedBox(height: Space.x8),
          // Os dois botões dividem a linha, e cada um dentro de um
          // `Expanded`. Não é gosto de layout: o tema dá aos botões
          // `minimumSize: Size.fromHeight(...)`, que é `Size(infinito,
          // altura)`, e um botão de largura mínima infinita solto numa `Row`
          // não consegue ser medido. O "Registrar" falhava no layout e não
          // era pintado, então na tela sobrava só o "Agora não" e o cartão
          // virava uma cobrança sem saída. Em compilação de depuração isso
          // grita; no APK instalado a asserção não roda e o botão só some.
          //
          // `Expanded` dá largura fixa ao botão, e aí o mínimo infinito é
          // limitado pela linha em vez de ser passado adiante.
          //
          // A altura é a compacta, e os dois usam a mesma. Antes o
          // "Registrar" vinha com os 56 do tema e o "Agora não" com 48, então
          // além de altos eles eram desiguais: dois botões lado a lado com
          // alturas diferentes é o tipo de coisa que ninguém sabe nomear e
          // todo mundo percebe.
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () => _resolve(ref, dismissed: true),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(Sizes.buttonCompact),
                  ),
                  child: const Text('Agora não'),
                ),
              ),
              const SizedBox(width: Space.x12),
              Expanded(
                flex: 2,
                child: FilledButton.tonal(
                  onPressed: () => showAddSheet(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(Sizes.buttonCompact),
                  ),
                  child: const Text('Registrar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref, String item, bool marcado) {
    final Set<String> novos = <String>{...active.checked};
    if (marcado) {
      novos.add(item);
    } else {
      novos.remove(item);
    }
    return _save(ref, (SuggestionProgress p) => p.copyWith(checked: novos));
  }

  Future<void> _resolve(WidgetRef ref, {required bool dismissed}) => _save(
    ref,
    (SuggestionProgress p) =>
        p.copyWith(dismissed: dismissed, done: !dismissed),
  );

  Future<void> _save(
    WidgetRef ref,
    SuggestionProgress Function(SuggestionProgress) change,
  ) async {
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    final SuggestionProgress atual =
        ref.read(suggestionProgressProvider).value?[active.suggestion.id] ??
        const SuggestionProgress();
    await ref
        .read(firestoreServiceProvider)
        .saveSuggestion(uid, active.suggestion.id, change(atual));
  }
}

class _ChecklistLine extends StatelessWidget {
  const _ChecklistLine({
    required this.item,
    required this.checked,
    required this.onChanged,
  });

  final String item;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: Radii.fieldR,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.x4),
        child: Row(
          children: <Widget>[
            Icon(
              checked ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: checked
                  ? context.cores.primary
                  : context.cores.textSecondary,
            ),
            const SizedBox(width: Space.x12),
            Expanded(
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: checked
                      ? context.cores.textSecondary
                      : context.cores.textPrimary,
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma faixa curta na tela inicial, com a sugestão mais urgente.
///
/// Uma só, de propósito: a Home já tem bastante coisa, e uma lista de
/// pendências ali vira cobrança. O resto vive na tela de momentos.
class NextSuggestion extends ConsumerWidget {
  const NextSuggestion({required this.copy, super.key});

  final Copy copy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ActiveSuggestion> ativas = ref.watch(activeSuggestionsProvider);
    if (ativas.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x8),
      child: SuggestionCard(active: ativas.first, copy: copy, compact: true),
    );
  }
}
