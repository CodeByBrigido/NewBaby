import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/gendered.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import 'timeline_card.dart';
import 'upload_banner.dart';

/// Tela principal: tudo em ordem cronológica, misturado numa linha só.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  EntryType? _filter;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Entry>> entries = ref.watch(entriesProvider);
    final BabyProfile? profile = ref.watch(profileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.timeline),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () =>
              ref.read(shellScaffoldKeyProvider).currentState?.openDrawer(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _filter == null ? Icons.filter_list : Icons.filter_list_alt,
              color: _filter == null ? null : AppColors.primary,
            ),
            onPressed: _showFilter,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(Routes.search),
          ),
        ],
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: S.genericError,
          message: '$error',
        ),
        data: (List<Entry> all) {
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Entry> visible = _filter == null
              ? all
              : all.where((Entry e) => e.type == _filter).toList();

          if (visible.isEmpty) {
            return EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: _filter == null ? S.timelineEmptyTitle : S.noItemsYet,
              message: _filter == null
                  ? G.of(profile.gender).timelineEmptyBody
                  : null,
            );
          }

          return TimelineList(entries: visible, profile: profile);
        },
      ),
    );
  }

  Future<void> _showFilter() async {
    final EntryType? selected = await showModalBottomSheet<EntryType?>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16),
            Text(S.filterTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text(S.filterAll),
              selected: _filter == null,
              onTap: () => Navigator.of(context).pop(),
            ),
            for (final EntryType type in EntryType.values)
              if (type != EntryType.birth)
                ListTile(
                  leading: Icon(type.icon, color: type.accent),
                  title: Text(type.label),
                  selected: _filter == type,
                  onTap: () => Navigator.of(context).pop(type),
                ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _filter = selected);
  }
}

/// A lista da linha do tempo, agrupada por dia e desenhada sobre um trilho.
///
/// Separada da tela para poder ser montada em testes sem Firebase.
class TimelineList extends StatelessWidget {
  const TimelineList({
    required this.entries,
    required this.profile,
    super.key,
    this.showHeader = true,
  });

  final List<Entry> entries;
  final BabyProfile profile;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    // As entradas já vêm ordenadas por data decrescente do Firestore.
    final Map<DateTime, List<Entry>> byDay = groupBy<Entry, DateTime>(
      entries,
      (Entry e) => AgeCalculator.dayOf(e.date),
    );
    final List<DateTime> days = byDay.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
      itemCount: days.length + (showHeader ? 2 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (showHeader) {
          if (index == 0) return _BabyHeader(profile: profile);
          if (index == 1) return const UploadBanner();
          index -= 2;
        }
        final DateTime day = days[index];
        return _DayGroup(
          day: day,
          entries: byDay[day]!,
          profile: profile,
          isLast: index == days.length - 1,
        );
      },
    );
  }
}

class _BabyHeader extends StatelessWidget {
  const _BabyHeader({required this.profile});

  final BabyProfile profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: <Widget>[
            BabyAvatar(profile: profile, radius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(profile.name, style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    Fmt.longDate(profile.birth),
                    style: text.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um dia da linha do tempo: a data e a idade à esquerda, os cartões à
/// direita, ligados pelo trilho vertical.
class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.entries,
    required this.profile,
    required this.isLast,
  });

  final DateTime day;
  final List<Entry> entries;
  final BabyProfile profile;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Age age = profile.ageAt(day);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Fmt.timelineDay(day),
                    style: text.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    age.detailedLabel(),
                    style: text.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Rail(isLast: isLast),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final Entry entry in entries) ...<Widget>[
                    TimelineCard(entry: entry),
                    if (entry != entries.last) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ponto e linha vertical que costuram os dias.
class _Rail extends StatelessWidget {
  const _Rail({required this.isLast});

  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 4),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          if (!isLast)
            const Expanded(
              child: VerticalDivider(
                width: 1,
                thickness: 1.5,
                color: AppColors.primarySoft,
              ),
            ),
        ],
      ),
    );
  }
}
