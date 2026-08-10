import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/day_summary.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/entrada_na_rolagem.dart';
import '../common/esqueleto.dart';
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
              color: _filter == null ? null : context.cores.primary,
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
        loading: () => const EsqueletoDaLinhaDoTempo(),
        error: (Object error, _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: S.genericError,
          message: '$error',
        ),
        data: (List<Entry> all) {
          // O cadastro chega por outro caminho que as entradas, e pode
          // demorar um instante a mais. Mostrar o mesmo esqueleto evita a
          // troca de bolinha por esqueleto por conteúdo, que são três
          // desenhos diferentes para uma espera só.
          if (profile == null) return const EsqueletoDaLinhaDoTempo();
          final List<Entry> visible = _filter == null
              ? all
              : all.where((Entry e) => e.type == _filter).toList();

          if (visible.isEmpty) {
            return EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: _filter == null ? S.timelineEmptyTitle : S.noItemsYet,
              message: _filter == null
                  ? Copy.of(profile).timelineEmptyBody
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
            const SizedBox(height: Space.x16),
            Text(S.filterTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: Space.x8),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text(S.filterAll),
              selected: _filter == null,
              onTap: () => Navigator.of(context).pop(),
            ),
            for (final EntryType type in EntryType.values)
              if (type != EntryType.birth)
                ListTile(
                  leading: Icon(type.icon, color: type.accent(context)),
                  title: Text(type.label),
                  selected: _filter == type,
                  onTap: () => Navigator.of(context).pop(type),
                ),
            const SizedBox(height: Space.x12),
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
      padding: const EdgeInsets.fromLTRB(0, Space.x8, 0, Space.scrollEnd),
      itemCount: days.length + (showHeader ? 2 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (showHeader) {
          if (index == 0) return _BabyHeader(profile: profile);
          if (index == 1) return const UploadBanner();
          index -= 2;
        }
        final DateTime day = days[index];
        return EntradaNaRolagem(
          indice: index,
          child: _DayGroup(
            day: day,
            entries: byDay[day]!,
            profile: profile,
            isLast: index == days.length - 1,
          ),
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
      padding: const EdgeInsets.fromLTRB(
        Space.x16,
        Space.x8,
        Space.x16,
        Space.x16,
      ),
      child: Container(
        padding: const EdgeInsets.all(Space.x16),
        decoration: BoxDecoration(
          color: context.cores.primarySoft,
          borderRadius: Radii.cardR,
        ),
        child: Row(
          children: <Widget>[
            BabyAvatar(profile: profile, radius: 24),
            const SizedBox(width: Space.x16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(profile.name, style: text.titleMedium),
                  const SizedBox(height: Space.x4),
                  Text(
                    Fmt.longDate(profile.birth),
                    style: text.bodySmall?.copyWith(
                      color: context.cores.primaryDark,
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
///
/// Dia cheio começa recolhido, mostrando só o resumo. O limite não é
/// enfeite: um aniversário com trinta fotos, aberto, empurra o resto do mês
/// para fora da tela, e quem está folheando a infância inteira perde o fio.
///
/// Dia curto nunca recolhe. Esconder duas fotos atrás de um toque seria
/// trocar a memória por um menu, que é exatamente o que este aplicativo não
/// quer ser.
class _DayGroup extends StatefulWidget {
  const _DayGroup({
    required this.day,
    required this.entries,
    required this.profile,
    required this.isLast,
  });

  /// Acima disto, o dia abre recolhido.
  static const int limiteParaRecolher = 4;

  final DateTime day;
  final List<Entry> entries;
  final BabyProfile profile;
  final bool isLast;

  @override
  State<_DayGroup> createState() => _DayGroupState();
}

class _DayGroupState extends State<_DayGroup> {
  late bool _aberto = widget.entries.length <= _DayGroup.limiteParaRecolher;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Age age = widget.profile.ageAt(widget.day);
    final bool podeRecolher =
        widget.entries.length > _DayGroup.limiteParaRecolher;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(left: Space.x16, top: Space.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Fmt.timelineDay(widget.day),
                    style: text.labelMedium?.copyWith(
                      color: context.cores.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Space.x4),
                  Text(
                    age.detailedLabel(),
                    style: text.labelSmall?.copyWith(
                      color: context.cores.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Rail(isLast: widget.isLast),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: Space.x16,
                bottom: Space.x20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (podeRecolher)
                    _DaySummary(
                      resumo: summarizeDay(widget.entries),
                      aberto: _aberto,
                      onTap: () => setState(() => _aberto = !_aberto),
                    ),
                  if (_aberto)
                    for (final Entry entry in widget.entries) ...<Widget>[
                      if (entry != widget.entries.first || podeRecolher)
                        const SizedBox(height: Space.x12),
                      TimelineCard(entry: entry),
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

/// A linha que resume o dia e abre ou fecha os cartões.
class _DaySummary extends StatelessWidget {
  const _DaySummary({
    required this.resumo,
    required this.aberto,
    required this.onTap,
  });

  final String resumo;
  final bool aberto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cores.surfaceMuted,
      borderRadius: Radii.fieldR,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.fieldR,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.x16,
            vertical: Space.x12,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  resumo,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context.cores.textPrimary,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: aberto ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: context.cores.textSecondary,
                ),
              ),
            ],
          ),
        ),
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
          const SizedBox(height: Space.x4),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: context.cores.primary,
              shape: BoxShape.circle,
            ),
          ),
          if (!isLast)
            Expanded(
              child: VerticalDivider(
                width: 1,
                thickness: 1.5,
                color: context.cores.primarySoft,
              ),
            ),
        ],
      ),
    );
  }
}
