import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Entry> documents = ref.watch(
      entriesOfTypeProvider(EntryType.document),
    );
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.documents),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: documents.isEmpty
          ? const EmptyState(
              icon: Icons.description_outlined,
              title: 'Nenhum documento ainda',
              message:
                  'Certidão, carteira de vacinação, passaporte — tudo em um '
                  'lugar só.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: documents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final Entry entry = documents[index];
                final EntryFile? file = entry.coverFile;

                return SoftCard(
                  onTap: () => context.push(Routes.document(entry.id)),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.documentSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          file?.extensionLabel ?? 'DOC',
                          style: text.labelSmall?.copyWith(
                            color: AppColors.document,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              entry.title ?? file?.name ?? S.documents,
                              style: text.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              <String>[
                                Fmt.date(entry.date),
                                if (file != null && file.sizeBytes > 0)
                                  Fmt.bytes(file.sizeBytes),
                              ].join(' · '),
                              style: text.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      if (entry.uploadStatus.isBusy)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
