import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../../models/capsule_pulse.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';
import '../moments/moments_screen.dart';
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
          _Hero(profile: profile, pulse: pulse, copy: copy),
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

/// O cabeçalho: quem, e quantos anos.
///
/// A frase é a mesma que alguém diria em voz alta ao ser perguntado, e é
/// por isso que a idade vem grande e o resto vem pequeno.
///
/// A data de nascimento saiu daqui. Nenhum pai ou mãe precisa ser lembrado
/// dela todo dia, ao abrir o aplicativo, e repetir o que a pessoa sabe de
/// cor gasta a linha mais visível da tela com informação nenhuma. Ela
/// continua no cadastro, que é onde se procura um dado, e não onde se
/// tropeça nele.
class _Hero extends StatelessWidget {
  const _Hero({required this.profile, required this.pulse, required this.copy});

  final BabyProfile profile;
  final CapsulePulse pulse;
  final Copy copy;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(Space.x20),
      decoration: BoxDecoration(
        // Uma cor com nome, e não um gradiente entre dois tons pálidos.
        // Ela é escura o bastante para exigir os tons `onHero`: os de texto
        // do resto do aplicativo não passam no contraste em cima dela.
        color: context.cores.heroFill,
        borderRadius: Radii.cardR,
      ),
      // Duas colunas, cada uma centralizada por inteiro na própria coluna:
      // na altura e também na largura. Com o texto encostado à esquerda, a
      // coluna dele ocupava a largura toda e sobrava um vão enorme antes da
      // foto; centralizado, o texto se aproxima dela sozinho.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${Fmt.greeting(DateTime.now())}!',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: context.cores.onHeroSoft,
                  ),
                ),
                const SizedBox(height: Space.x12),
                Text(
                  'Hoje ${copy.theName} está com',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: context.cores.onHeroSoft,
                  ),
                ),
                const SizedBox(height: Space.x4),
                // A idade quebrada onde a frase permite, e não onde couber.
                //
                // Aqui ela vem grande, e `1 ano, 9 meses e 14 dias` não cabe
                // numa linha. A quebra automática caía no pior lugar
                // possível, separando o número da unidade: a linha de cima
                // terminava em "14" e a de baixo começava em "dias".
                Text(
                  pulse.age.detailedLines(alwaysShowDays: true).join('\n'),
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    color: context.cores.onHero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.x16),
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
