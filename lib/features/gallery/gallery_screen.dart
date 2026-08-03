import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';

/// Um balde de idade já resolvido para exibição: quantos arquivos tem, a
/// capa e o intervalo de datas.
class BucketSummary {
  const BucketSummary({
    required this.bucket,
    required this.entries,
    required this.fileCount,
  });

  final AgeBucket bucket;
  final List<Entry> entries;
  final int fileCount;

  EntryFile? get cover =>
      entries.firstWhereOrNull((Entry e) => e.coverFile != null)?.coverFile;
}

/// Agrupa as entradas de um tipo nos baldes de idade da unidade escolhida.
///
/// Uma foto tirada na `Semana 07` também pertence ao `Mês 02` e ao `Ano 0`;
/// as abas simplesmente mudam a lente sobre o mesmo acervo.
List<BucketSummary> groupIntoBuckets({
  required List<Entry> entries,
  required BabyProfile profile,
  required AgeBucketUnit unit,
}) {
  final Map<String, List<Entry>> grouped = <String, List<Entry>>{};
  final Map<String, AgeBucket> buckets = <String, AgeBucket>{};

  for (final Entry entry in entries) {
    final AgeBucket bucket = _bucketFor(profile, entry.date, unit);
    grouped.putIfAbsent(bucket.key, () => <Entry>[]).add(entry);
    buckets[bucket.key] = bucket;
  }

  final List<BucketSummary> result = grouped.entries
      .map(
        (MapEntry<String, List<Entry>> e) => BucketSummary(
          bucket: buckets[e.key]!,
          entries: e.value,
          fileCount: e.value.fold(
            0,
            (int sum, Entry entry) =>
                sum + (entry.hasFiles ? entry.files.length : 0),
          ),
        ),
      )
      .toList();

  // Do mais recente para o mais antigo, como o resto do aplicativo.
  result.sort(
    (BucketSummary a, BucketSummary b) =>
        b.bucket.start.compareTo(a.bucket.start),
  );
  return result;
}

/// Reprojeta a data na unidade pedida pela aba.
AgeBucket _bucketFor(BabyProfile profile, DateTime date, AgeBucketUnit unit) {
  final DateTime birth = profile.birthDay;
  final Age age = AgeCalculator.ageAt(birth, date);

  switch (unit) {
    case AgeBucketUnit.week:
      final int index = (age.totalDays ~/ 7) + 1;
      final DateTime start = birth.add(Duration(days: (index - 1) * 7));
      return AgeBucket(
        unit: AgeBucketUnit.week,
        index: index,
        start: start,
        end: start.add(const Duration(days: 6)),
      );
    case AgeBucketUnit.month:
      final int index = age.months + 1;
      return AgeBucket(
        unit: AgeBucketUnit.month,
        index: index,
        start: AgeCalculator.addMonths(birth, index - 1),
        end: AgeCalculator.addMonths(
          birth,
          index,
        ).subtract(const Duration(days: 1)),
      );
    case AgeBucketUnit.year:
      final int index = age.years;
      return AgeBucket(
        unit: AgeBucketUnit.year,
        index: index,
        start: AgeCalculator.addMonths(birth, index * 12),
        end: AgeCalculator.addMonths(
          birth,
          (index + 1) * 12,
        ).subtract(const Duration(days: 1)),
      );
  }
}

/// Tela de Fotos ou de Vídeos: abas Semanas · Meses · Anos.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({required this.type, super.key});

  final EntryType type;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  AgeBucketUnit _unit = AgeBucketUnit.week;

  @override
  Widget build(BuildContext context) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<Entry> entries = ref.watch(entriesOfTypeProvider(widget.type));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                _UnitTabs(
                  unit: _unit,
                  onChanged: (AgeBucketUnit unit) =>
                      setState(() => _unit = unit),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? EmptyState(
                          icon: widget.type.icon,
                          title: S.noItemsYet,
                          message: widget.type == EntryType.photo
                              ? 'Toque no + para adicionar as primeiras fotos.'
                              : 'Toque no + para adicionar o primeiro vídeo.',
                        )
                      : _BucketList(
                          type: widget.type,
                          buckets: groupIntoBuckets(
                            entries: entries,
                            profile: profile,
                            unit: _unit,
                          ),
                        ),
                ),
                if (widget.type == EntryType.photo)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      S.photosOptimizedNote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _UnitTabs extends StatelessWidget {
  const _UnitTabs({required this.unit, required this.onChanged});

  final AgeBucketUnit unit;
  final ValueChanged<AgeBucketUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    const Map<AgeBucketUnit, String> labels = <AgeBucketUnit, String>{
      AgeBucketUnit.week: S.weeks,
      AgeBucketUnit.month: S.months,
      AgeBucketUnit.year: S.years,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.cores.surfaceMuted,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: <Widget>[
            for (final MapEntry<AgeBucketUnit, String> item in labels.entries)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(item.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: unit == item.key
                          ? context.cores.primarySoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: unit == item.key
                            ? context.cores.primaryDark
                            : context.cores.textSecondary,
                        fontWeight: unit == item.key
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BucketList extends StatelessWidget {
  const _BucketList({required this.type, required this.buckets});

  final EntryType type;
  final List<BucketSummary> buckets;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: buckets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final BucketSummary summary = buckets[index];
        final EntryFile? cover = summary.cover;

        return SoftCard(
          padding: const EdgeInsets.all(10),
          onTap: () => context.push(
            Routes.bucket(
              type == EntryType.photo ? 'fotos' : 'videos',
              summary.bucket.key,
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: cover == null
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: type.soft(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(type.icon, color: type.accent(context)),
                      )
                    : DriveThumbnail(
                        file: cover,
                        borderRadius: BorderRadius.circular(14),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(summary.bucket.folderName, style: text.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      Fmt.dateRange(summary.bucket.start, summary.bucket.end),
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type == EntryType.photo
                          ? Fmt.count(summary.fileCount, 'foto', 'fotos')
                          : Fmt.count(summary.fileCount, 'vídeo', 'vídeos'),
                      style: text.labelSmall?.copyWith(
                        color: context.cores.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: context.cores.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }
}
