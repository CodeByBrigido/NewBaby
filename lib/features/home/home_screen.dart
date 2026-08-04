import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../../models/capsule_pulse.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';
import '../moments/moments_screen.dart';
import '../shell/add_sheet.dart';
import '../timeline/upload_banner.dart';
import 'pulse_cards.dart';

/// Início: um resumo caloroso, com as últimas memórias e os atalhos.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<Entry> entries =
        ref.watch(entriesProvider).value ?? const <Entry>[];

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final Copy copy = Copy.of(profile);
    final CapsulePulse pulse = CapsulePulse.from(
      profile: profile,
      entries: entries,
    );

    final List<Entry> recentPhotos = entries
        .where(
          (Entry e) =>
              (e.type == EntryType.photo || e.type == EntryType.drawing) &&
              e.hasFiles,
        )
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.appName),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () =>
              ref.read(shellScaffoldKeyProvider).currentState?.openDrawer(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.insert_chart_outlined),
            onPressed: () => context.push(Routes.stats),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: <Widget>[
          _Hero(profile: profile, pulse: pulse, copy: copy),
          const SizedBox(height: 14),
          PulseCards(pulse: pulse, copy: copy),
          const SizedBox(height: 16),
          NextSuggestion(copy: copy),
          FilledButton.icon(
            onPressed: () => showAddSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Registrar momento'),
          ),
          const SizedBox(height: 8),
          const UploadBanner(),
          const SectionHeader(title: 'Atalhos'),
          _Shortcuts(),
          const SizedBox(height: 24),
          if (recentPhotos.isNotEmpty) ...<Widget>[
            SectionHeader(
              title: 'Fotos recentes',
              trailing: TextButton(
                onPressed: () => context.push(Routes.photos),
                child: const Text('Ver todas'),
              ),
            ),
            _RecentGrid(entries: recentPhotos),
            const SizedBox(height: 24),
          ],
          if (entries.isEmpty)
            EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: S.timelineEmptyTitle,
              message: copy.timelineEmptyBody,
            ),
        ],
      ),
    );
  }
}

/// O cabeçalho: quem, quantos anos, e desde quando.
///
/// A frase é a mesma que alguém diria em voz alta ao ser perguntado, e é
/// por isso que a idade vem grande e o resto vem pequeno.
class _Hero extends StatelessWidget {
  const _Hero({required this.profile, required this.pulse, required this.copy});

  final BabyProfile profile;
  final CapsulePulse pulse;
  final Copy copy;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[context.cores.primarySoft, context.cores.accentSoft],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${Fmt.greeting(DateTime.now())}!',
                  style: text.bodyMedium?.copyWith(
                    color: context.cores.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Hoje ${copy.theName} está com', style: text.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  pulse.age.detailedLabel(alwaysShowDays: true),
                  style: text.headlineSmall?.copyWith(
                    color: context.cores.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nasceu em ${Fmt.longDate(profile.birth)}',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          BabyAvatar(profile: profile, radius: 34),
        ],
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<(EntryType, String)> items = <(EntryType, String)>[
      (EntryType.photo, Routes.photos),
      (EntryType.video, Routes.videos),
      (EntryType.letter, Routes.letters),
      (EntryType.drawing, Routes.drawings),
      (EntryType.document, Routes.documents),
      (EntryType.growth, Routes.growth),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: <Widget>[
        for (final (EntryType type, String route) in items)
          Material(
            color: type.soft(context),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => context.push(route),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(type.icon, color: type.accent(context), size: 26),
                  const SizedBox(height: 8),
                  Text(
                    type.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.cores.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentGrid extends StatelessWidget {
  const _RecentGrid({required this.entries});

  final List<Entry> entries;

  @override
  Widget build(BuildContext context) {
    final List<(Entry, EntryFile)> tiles = <(Entry, EntryFile)>[
      for (final Entry entry in entries)
        if (entry.coverFile != null) (entry, entry.coverFile!),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: <Widget>[
        for (final (Entry entry, EntryFile file) in tiles)
          GestureDetector(
            onTap: () => context.push(Routes.entry(entry.id)),
            child: DriveThumbnail(
              file: file,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
      ],
    );
  }
}
