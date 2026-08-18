import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../premium/porta_do_premium.dart';

class LettersScreen extends ConsumerWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Entry> letters = ref.watch(
      entriesOfTypeProvider(EntryType.letter),
    );
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.letters),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (await liberadoParaCriar(context, profile, EntryType.letter) &&
              context.mounted) {
            context.push(Routes.newLetter);
          }
        },
        backgroundColor: context.cores.primaryStrong,
        foregroundColor: Colors.white,
        icon: Icon(
          podeCriar(profile, EntryType.letter)
              ? Icons.edit_outlined
              : Icons.lock_outline,
        ),
        label: const Text('Escrever'),
      ),
      body: letters.isEmpty
          ? EmptyState(
              icon: Icons.mail_outline,
              title: 'Nenhuma carta ainda',
              message: Copy.of(profile).lettersEmptyBody,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x8,
                Space.x16,
                Space.scrollEnd,
              ),
              itemCount: letters.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.x12),
              itemBuilder: (BuildContext context, int index) {
                final Entry letter = letters[index];
                return SoftCard(
                  onTap: () => context.push(Routes.letter(letter.id)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const CategoryBadge(type: EntryType.letter),
                      const SizedBox(width: Space.x16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              letter.title ?? S.letters,
                              style: text.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Space.x4),
                            Text(
                              Fmt.longDate(letter.date),
                              style: text.labelSmall,
                            ),
                            if (letter.description != null) ...<Widget>[
                              const SizedBox(height: Space.x8),
                              Text(
                                letter.description!,
                                style: text.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (profile != null) ...<Widget>[
                              const SizedBox(height: Space.x12),
                              AgeChip(
                                age: profile.ageAt(letter.date),
                                compact: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
