import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../../services/drive_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Quanto já foi guardado e quanto espaço isso ocupa no Drive.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MemoryStats stats = ref.watch(statsProvider);
    final AsyncValue<DriveQuota> quota = ref.watch(driveQuotaProvider);

    const List<EntryType> tiles = <EntryType>[
      EntryType.photo,
      EntryType.video,
      EntryType.letter,
      EntryType.drawing,
      EntryType.document,
      EntryType.growth,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.stats),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(driveQuotaProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: <Widget>[
                for (final EntryType type in tiles)
                  _CountTile(type: type, count: stats.count(type)),
              ],
            ),
            const SizedBox(height: 20),
            quota.when(
              loading: () => const SoftCard(
                child: SizedBox(
                  height: 64,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (Object error, _) => SoftCard(
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.cloud_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Não foi possível ler o espaço do Google Drive.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              data: (DriveQuota data) => _StorageCard(quota: data),
            ),
            const SizedBox(height: 16),
            const InfoNote(
              message: S.allFilesOptimizedNote,
              icon: Icons.cloud_done_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.type, required this.count});

  final EntryType type;
  final int count;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CategoryBadge(type: type, size: 32, iconSize: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  type.label,
                  style: text.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('$count', style: text.headlineSmall),
        ],
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.quota});

  final DriveQuota quota;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final double? fraction = quota.fraction;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.storageUsed, style: text.titleSmall),
          const SizedBox(height: 10),
          Text(
            quota.limitBytes == null
                ? Fmt.bytes(quota.usedBytes)
                : '${Fmt.bytes(quota.usedBytes)} ${S.storageOf} '
                      '${Fmt.bytes(quota.limitBytes!)}',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction ?? 0,
              minHeight: 8,
              backgroundColor: AppColors.primarySoft,
            ),
          ),
          if (fraction != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '${(fraction * 100).toStringAsFixed(0)}%',
              style: text.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
