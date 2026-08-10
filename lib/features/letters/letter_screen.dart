import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Leitura de uma carta: papel branco, texto grande, sem distração.
class LetterScreen extends ConsumerWidget {
  const LetterScreen({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Entry? letter = ref
        .watch(entriesProvider)
        .value
        ?.firstWhereOrNull((Entry e) => e.id == entryId);
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final TextTheme text = Theme.of(context).textTheme;

    if (letter == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const EmptyState(
          icon: Icons.mail_outline,
          title: 'Carta não encontrada',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.letters),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x20,
          Space.x8,
          Space.x20,
          Space.x32,
        ),
        children: <Widget>[
          const Center(
            child: CategoryBadge(
              type: EntryType.letter,
              size: 64,
              iconSize: 30,
            ),
          ),
          const SizedBox(height: Space.x24),
          Text(
            letter.title ?? S.letters,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: Space.x8),
          Text(
            Fmt.longDate(letter.date),
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
          if (profile != null) ...<Widget>[
            const SizedBox(height: Space.x12),
            Center(child: AgeChip(age: profile.ageAt(letter.date))),
          ],
          const SizedBox(height: Space.x24),

          // O texto ganha uma folha, e não fica solto no fundo da tela. Uma
          // carta é o único conteúdo do aplicativo que se lê de ponta a
          // ponta, e a folha faz duas coisas: dá a margem interna que a
          // leitura longa precisa e separa o que a criança escreveu do que é
          // interface. Fundo branco sobre o fundo quente do aplicativo, com o
          // contorno de 1 px do Design System.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.x20,
              vertical: Space.x24,
            ),
            decoration: BoxDecoration(
              color: context.cores.surface,
              borderRadius: Radii.cardR,
              border: Border.all(color: context.cores.border),
              boxShadow: Shadows.level1,
            ),
            child: SelectableText(
              letter.description ?? '',
              // 1,7 de entrelinha, acima do 1,5 do corpo comum: é texto para
              // ler devagar, não para varrer.
              style: text.bodyLarge?.copyWith(height: 1.7),
            ),
          ),
          const SizedBox(height: Space.x40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _Action(
                icon: Icons.edit_outlined,
                label: S.edit,
                onTap: () => context.push(Routes.editLetter(letter.id)),
              ),
              _Action(
                icon: Icons.ios_share,
                label: S.share,
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        '${letter.title ?? S.letters}\n\n'
                        '${letter.description ?? ''}',
                  ),
                ),
              ),
              _Action(
                icon: Icons.delete_outline,
                label: S.delete,
                destructive: true,
                onTap: () => _delete(context, ref, letter),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Entry letter,
  ) async {
    final bool confirmed = await confirm(
      context,
      title: S.deleteConfirmTitle,
      message: S.deleteConfirmBody,
      confirmLabel: S.delete,
    );
    if (!confirmed) return;

    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    await ref.read(memoryRepositoryProvider).moveToTrash(uid, letter);
    if (context.mounted) context.pop();
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color color = destructive
        ? AppPalette.danger
        : context.cores.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: Radii.fieldR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.x16,
          vertical: Space.x12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 22),
            const SizedBox(height: Space.x8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
