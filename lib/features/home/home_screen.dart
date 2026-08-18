import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../../models/capsule_pulse.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';
import '../moments/moments_screen.dart';
import '../timeline/upload_banner.dart';
import 'painel_do_bebe.dart';
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
          // A busca saiu da barra de baixo para dar lugar às Inspirações.
          // Fica na lupa, que é onde a mão procura por ela.
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: S.search,
            onPressed: () => context.push(Routes.search),
          ),
          IconButton(
            icon: const Icon(Icons.insert_chart_outlined),
            tooltip: S.stats,
            onPressed: () => context.push(Routes.stats),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x16,
          Space.x8,
          Space.x16,
          Space.scrollEnd,
        ),
        children: <Widget>[
          PainelDoBebe(profile: profile, idade: pulse.age),
          const SizedBox(height: Space.x16),
          // A folga de baixo é do próprio `PulseCards`, porque ele some
          // inteiro nos dias sem ocasião, que são quase todos.
          PulseCards(pulse: pulse, copy: copy),
          NextSuggestion(copy: copy),
          // Sem botão de registrar aqui: o "+" da barra de baixo está
          // sempre à mão, em todas as telas, e dois botões para a mesma
          // ação a poucos centímetros um do outro só ocupam espaço.
          const UploadBanner(),
          const SectionHeader(title: 'Acervo'),
          _Shortcuts(),
          const SizedBox(height: Space.x24),
          if (recentPhotos.isNotEmpty) ...<Widget>[
            SectionHeader(
              title: 'Fotos recentes',
              trailing: TextButton(
                onPressed: () => context.push(Routes.photos),
                child: const Text('Ver todas'),
              ),
            ),
            _RecentGrid(entries: recentPhotos),
            const SizedBox(height: Space.x24),
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
      crossAxisSpacing: Space.x12,
      mainAxisSpacing: Space.x12,
      childAspectRatio: 1.05,
      children: <Widget>[
        for (final (EntryType type, String route) in items)
          Material(
            color: type.soft(context),
            borderRadius: Radii.buttonR,
            child: InkWell(
              onTap: () => context.push(route),
              borderRadius: Radii.buttonR,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(type.icon, color: type.accent(context), size: 26),
                  const SizedBox(height: Space.x8),
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
      crossAxisSpacing: Space.x8,
      mainAxisSpacing: Space.x8,
      children: <Widget>[
        for (final (Entry entry, EntryFile file) in tiles)
          GestureDetector(
            onTap: () => context.push(Routes.entry(entry.id)),
            child: DriveThumbnail(file: file, borderRadius: Radii.fieldR),
          ),
      ],
    );
  }
}
