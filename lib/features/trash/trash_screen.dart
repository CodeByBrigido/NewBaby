import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';

/// Itens excluídos. Nada some de verdade sem passar por aqui.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Entry>> trash = ref.watch(trashProvider);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.trash),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: trash.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: S.genericError,
          message: '$error',
        ),
        data: (List<Entry> entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.delete_outline,
              title: S.trashEmptyTitle,
              message: S.trashEmptyBody,
            );
          }

          return Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  Space.x16,
                  0,
                  Space.x16,
                  Space.x12,
                ),
                child: InfoNote(message: S.trashNote),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    Space.x16,
                    0,
                    Space.x16,
                    Space.x24,
                  ),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Space.x12),
                  itemBuilder: (BuildContext context, int index) {
                    final Entry entry = entries[index];
                    return SoftCard(
                      padding: const EdgeInsets.all(Space.x12),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: entry.coverFile != null
                                ? DriveThumbnail(
                                    file: entry.coverFile!,
                                    borderRadius: Radii.mediaR,
                                  )
                                : CategoryBadge(type: entry.type, size: 48),
                          ),
                          const SizedBox(width: Space.x12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  entry.headline,
                                  style: text.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: Space.x4),
                                Text(
                                  'Excluído em '
                                  '${Fmt.date(entry.deletedAt ?? entry.date)}',
                                  style: text.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: S.restore,
                            icon: const Icon(Icons.restore, size: 20),
                            onPressed: () => _restore(context, ref, entry),
                          ),
                          IconButton(
                            tooltip: S.deleteForever,
                            icon: const Icon(
                              Icons.delete_forever_outlined,
                              size: 20,
                              color: AppPalette.danger,
                            ),
                            onPressed: () => _purge(context, ref, entry),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    Entry entry,
  ) async {
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    await ref.read(memoryRepositoryProvider).restore(uid, entry);
    if (context.mounted) showMessage(context, 'Item restaurado.');
  }

  Future<void> _purge(BuildContext context, WidgetRef ref, Entry entry) async {
    final bool confirmed = await confirm(
      context,
      title: S.deleteForever,
      message: S.deleteForeverConfirmBody,
      confirmLabel: S.deleteForever,
    );
    if (!confirmed) return;

    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    await ref.read(memoryRepositoryProvider).deleteForever(uid, entry);
    if (context.mounted) showMessage(context, 'Item excluído.');
  }
}
