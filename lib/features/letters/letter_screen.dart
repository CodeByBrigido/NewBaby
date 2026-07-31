import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
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
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: <Widget>[
          const Center(
            child: CategoryBadge(
              type: EntryType.letter,
              size: 64,
              iconSize: 30,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            letter.title ?? S.letters,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Fmt.longDate(letter.date),
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
          if (profile != null) ...<Widget>[
            const SizedBox(height: 12),
            Center(child: AgeChip(age: profile.ageAt(letter.date))),
          ],
          const SizedBox(height: 28),
          Text(
            letter.description ?? '',
            style: text.bodyLarge?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 40),
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
        ? AppColors.danger
        : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
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
