import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';
import 'growth_editor_sheet.dart';

/// Histórico de peso e altura, do mais recente ao nascimento.
class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Entry> records = ref.watch(growthRecordsProvider);
    final BabyProfile? profile = ref.watch(profileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.growth),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showGrowthEditor(context),
          ),
        ],
      ),
      body: records.isEmpty
          ? EmptyState(
              icon: Icons.monitor_heart_outlined,
              title: S.growthEmptyTitle,
              message: S.growthEmptyBody,
              action: FilledButton(
                onPressed: () => showGrowthEditor(context),
                child: const Text(S.addGrowth),
              ),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Space.x16,
                      Space.x8,
                      Space.x16,
                      Space.x16,
                    ),
                    itemCount: records.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Space.x12),
                    itemBuilder: (BuildContext context, int index) =>
                        _GrowthTile(entry: records[index], profile: profile),
                  ),
                ),
                if (records.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.x16,
                      0,
                      Space.x16,
                      Space.x20,
                    ),
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.push(Routes.growthChart),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.cores.primarySoft,
                        foregroundColor: context.cores.primaryDark,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.show_chart, size: 20),
                      label: const Text(S.viewChart),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _GrowthTile extends StatelessWidget {
  const _GrowthTile({required this.entry, required this.profile});

  final Entry entry;
  final BabyProfile? profile;

  @override
  Widget build(BuildContext context) {
    final GrowthData growth = entry.growth!;
    final TextTheme text = Theme.of(context).textTheme;
    final bool isBirth = entry.type == EntryType.birth;

    return SoftCard(
      padding: const EdgeInsets.all(Space.x12),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 52,
            height: 52,
            child: entry.coverFile != null
                ? DriveThumbnail(
                    file: entry.coverFile!,
                    borderRadius: Radii.fieldR,
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.cores.growthSoft,
                      borderRadius: Radii.fieldR,
                    ),
                    child: Icon(
                      Icons.monitor_heart_outlined,
                      color: context.cores.growth,
                      size: 22,
                    ),
                  ),
          ),
          const SizedBox(width: Space.x16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(Fmt.date(entry.date), style: text.titleSmall),
                const SizedBox(height: Space.x4),
                Text(
                  // No nascimento, "Nascimento" diz mais que "Recém-nascida".
                  isBirth
                      ? S.birth
                      : profile?.ageAt(entry.date).detailedLabel() ?? '',
                  style: text.labelSmall?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _Measure(
                icon: Icons.monitor_weight_outlined,
                value: Fmt.weight(growth.weightGrams),
              ),
              const SizedBox(height: Space.x4),
              _Measure(
                icon: Icons.straighten,
                value: Fmt.height(growth.heightCm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Measure extends StatelessWidget {
  const _Measure({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: context.cores.textSecondary),
        const SizedBox(width: Space.x4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.cores.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
