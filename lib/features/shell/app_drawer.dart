import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/gendered.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/baby_profile.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Menu lateral com o atalho para cada categoria.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final String? email = ref.watch(authServiceProvider).email;
    final TextTheme text = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            _Header(profile: profile),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: <Widget>[
                  _Item(
                    icon: Icons.timeline_outlined,
                    label: S.timeline,
                    route: Routes.timeline,
                  ),
                  _Item(
                    icon: Icons.photo_outlined,
                    label: S.photos,
                    route: Routes.photos,
                  ),
                  _Item(
                    icon: Icons.videocam_outlined,
                    label: S.videos,
                    route: Routes.videos,
                  ),
                  _Item(
                    icon: Icons.mail_outline,
                    label: S.letters,
                    route: Routes.letters,
                  ),
                  _Item(
                    icon: Icons.brush_outlined,
                    label: S.drawings,
                    route: Routes.drawings,
                  ),
                  _Item(
                    icon: Icons.description_outlined,
                    label: S.documents,
                    route: Routes.documents,
                  ),
                  _Item(
                    icon: Icons.monitor_heart_outlined,
                    label: S.growth,
                    route: Routes.growth,
                  ),
                  _Item(
                    icon: Icons.insert_chart_outlined,
                    label: S.stats,
                    route: Routes.stats,
                  ),
                  const Divider(indent: 20, endIndent: 20, height: 24),
                  _Item(
                    icon: Icons.delete_outline,
                    label: S.trash,
                    route: Routes.trash,
                  ),
                  _Item(
                    icon: Icons.settings_outlined,
                    label: S.settings,
                    route: Routes.settings,
                  ),
                ],
              ),
            ),
            if (email != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${S.storedWithLove} ${profile?.firstName ?? G.neutral.yourBaby} 💜',
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
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

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final BabyProfile? profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      color: AppColors.primarySoft,
      child: Row(
        children: <Widget>[
          BabyAvatar(profile: profile, radius: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  profile?.name ?? S.appName,
                  style: text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (profile != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    profile!.ageNow().detailedLabel(alwaysShowDays: true),
                    style: text.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        Navigator.of(context).pop();
        if (route == Routes.timeline) {
          context.go(route);
        } else {
          context.push(route);
        }
      },
    );
  }
}
