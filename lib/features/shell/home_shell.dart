import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/baby_profile.dart';
import '../../state/providers.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
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

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    TimelineScreen(),
    SizedBox.shrink(), // lugar do botão +, nunca exibido
    SearchScreen(embedded: true),
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
        backgroundColor: AppColors.primary,
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
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.onSelected,
    this.babyName,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final String? babyName;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
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
            icon: Icons.search_outlined,
            selectedIcon: Icons.search_rounded,
            label: S.search,
            selected: index == 3,
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
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? AppColors.primary
        : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(selected ? selectedIcon : icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
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

/// Barra superior comum às telas internas.
AppBar simpleAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool showBack = true,
}) {
  return AppBar(
    title: Text(title),
    leading: showBack
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(Routes.timeline),
          )
        : null,
    actions: actions,
  );
}
