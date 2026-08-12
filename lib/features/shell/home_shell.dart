import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/baby_profile.dart';
import '../../state/providers.dart';
import '../home/home_screen.dart';
import '../inspirations/inspirations_screen.dart';
import '../profile/profile_screen.dart';
import '../timeline/timeline_screen.dart';
import 'add_sheet.dart';
import 'app_drawer.dart';

/// Casca do aplicativo: barra inferior, menu lateral e o botão + central.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // A permissão de notificar é pedida aqui, e não na abertura: esta tela
    // só aparece depois de a cápsula existir, e é aí que a pergunta faz
    // sentido para quem responde.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(reminderSettingsProvider.notifier).ensureAsked());
    });
  }

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    TimelineScreen(),
    SizedBox.shrink(), // lugar do botão +, nunca exibido
    InspirationsScreen(embedded: true),
    ProfileScreen(embedded: true),
  ];

  void _onDestination(int index) {
    if (index == 2) {
      showAddSheet(context);
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final BabyProfile? profile = ref.watch(profileProvider).value;

    return Scaffold(
      key: ref.watch(shellScaffoldKeyProvider),
      drawer: const AppDrawer(),
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddSheet(context),
        backgroundColor: context.cores.primaryStrong,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        index: _index,
        onSelected: _onDestination,
        babyName: profile?.firstName,
        novidades: ref.watch(unreadInspirationsProvider),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.onSelected,
    this.babyName,
    this.novidades = 0,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final String? babyName;

  /// Quantas inspirações ativas ainda não foram abertas.
  final int novidades;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: context.cores.surface,
      elevation: 0,
      height: 68,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        children: <Widget>[
          _BarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: S.home,
            selected: index == 0,
            onTap: () => onSelected(0),
          ),
          _BarItem(
            icon: Icons.timeline_outlined,
            selectedIcon: Icons.timeline_rounded,
            label: S.timeline,
            selected: index == 1,
            onTap: () => onSelected(1),
          ),
          const Expanded(child: SizedBox.shrink()),
          _BarItem(
            icon: Icons.lightbulb_outline,
            selectedIcon: Icons.lightbulb,
            label: 'Inspirações',
            selected: index == 3,
            badge: novidades,
            onTap: () => onSelected(3),
          ),
          _BarItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person_rounded,
            label: S.profile,
            selected: index == 4,
            onTap: () => onSelected(4),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Quantidade a mostrar no pontinho. Zero não desenha nada: selo
  /// permanente vira decoração e some da percepção.
  final int badge;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? context.cores.primary
        : context.cores.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(selected ? selectedIcon : icon, size: 24, color: color),
                if (badge > 0)
                  Positioned(
                    top: -3,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.x4,
                        vertical: Space.x4,
                      ),
                      decoration: BoxDecoration(
                        color: context.cores.primary,
                        borderRadius: Radii.cardR,
                        border: Border.all(
                          color: context.cores.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          fontSize: 9,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Space.x4),
            // Centralizado, e com as duas linhas previstas. "Linha do Tempo"
            // não cabe em uma linha no espaço que sobra ao lado do botão de
            // adicionar, e sem `textAlign` as duas linhas encostavam à
            // esquerda enquanto o ícone ficava no meio: o rótulo parecia
            // torto em relação ao próprio ícone.
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                // Entrelinha curta para as duas linhas caberem na altura da
                // barra sem empurrar o ícone para cima.
                height: 1.1,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
