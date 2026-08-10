import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
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
          padding: const EdgeInsets.fromLTRB(
            Space.x16,
            Space.x8,
            Space.x16,
            Space.x32,
          ),
          children: <Widget>[
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: Space.x12,
              mainAxisSpacing: Space.x12,
              childAspectRatio: 1.5,
              children: <Widget>[
                for (final EntryType type in tiles)
                  _CountTile(type: type, count: stats.count(type)),
              ],
            ),
            const SizedBox(height: Space.x20),
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
                    Icon(
                      Icons.cloud_off_outlined,
                      color: context.cores.textSecondary,
                    ),
                    const SizedBox(width: Space.x12),
                    Expanded(
                      child: Text(
                        'Não foi possível ler o espaço do Google Drive.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              data: (DriveQuota data) =>
                  _StorageCard(quota: data, capsuleBytes: stats.totalBytes),
            ),
            const SizedBox(height: Space.x16),
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
              const SizedBox(width: Space.x12),
              Expanded(
                child: Text(
                  type.label,
                  style: text.labelMedium?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.x12),
          Text('$count', style: text.headlineSmall),
        ],
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.quota, required this.capsuleBytes});

  final DriveQuota quota;

  /// Soma dos arquivos que o próprio aplicativo enviou, vinda do índice.
  ///
  /// É calculada com o que já está em memória, sem perguntar nada ao Drive.
  final int capsuleBytes;

  @override
  Widget build(BuildContext context) {
    final int? limit = quota.limitBytes;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Bar(
            label: S.capsuleStorage,
            value: Fmt.bytes(capsuleBytes),
            fraction: limit == null || limit <= 0
                ? null
                : (capsuleBytes / limit).clamp(0.0, 1.0),
            color: context.cores.primary,
          ),
          const Divider(height: 28),
          _Bar(
            label: S.driveStorage,
            value: limit == null
                ? Fmt.bytes(quota.usedBytes)
                : '${Fmt.bytes(quota.usedBytes)} ${S.storageOf} '
                      '${Fmt.bytes(limit)}',
            fraction: quota.fraction,
            color: context.cores.textSecondary,
          ),
          const SizedBox(height: Space.x12),
          // Este número é da conta Google inteira. Dizer isso na tela evita
          // que alguém leia "8 GB usados" como se fosse a cápsula ocupando
          // tudo aquilo - e deixa claro que o aplicativo só conhece o total,
          // nunca o que há nos outros arquivos.
          Text(
            S.driveStorageNote,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String value;
  final double? fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final double? f = fraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: text.titleSmall),
            if (f != null)
              Text(
                '${(f * 100).toStringAsFixed(f < 0.1 ? 1 : 0)}%',
                style: text.labelSmall,
              ),
          ],
        ),
        const SizedBox(height: Space.x8),
        Text(value, style: text.bodyMedium),
        const SizedBox(height: Space.x12),
        ClipRRect(
          borderRadius: Radii.pillR,
          child: LinearProgressIndicator(
            value: f ?? 0,
            minHeight: 8,
            backgroundColor: context.cores.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
