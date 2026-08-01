import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/gendered.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final String? email = ref.watch(authServiceProvider).email;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.profile),
        automaticallyImplyLeading: false,
        leading: embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.timeline),
              ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: <Widget>[
                Center(child: BabyAvatar(profile: profile, radius: 44)),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
                const SizedBox(height: 24),
                SoftCard(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _Fact(
                          label: S.birthDate,
                          value: Fmt.date(profile.birth),
                        ),
                      ),
                      Container(width: 1, height: 34, color: AppColors.divider),
                      Expanded(
                        child: _Fact(
                          label: S.currentAge,
                          value: profile.ageNow().detailedLabel(
                            alwaysShowDays: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _Tile(
                  icon: Icons.person_outline,
                  title: G.of(profile.gender).babyInfo,
                  onTap: () => context.push(Routes.babyInfo),
                ),
                if (email != null)
                  _Tile(
                    icon: Icons.account_circle_outlined,
                    title: S.googleAccount,
                    subtitle: email,
                    onTap: null,
                  ),
                _Tile(
                  icon: Icons.settings_outlined,
                  title: S.settings,
                  onTap: () => context.push(Routes.settings),
                ),
                _Tile(
                  icon: Icons.info_outline,
                  title: S.about,
                  onTap: () => context.push(Routes.about),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => _signOut(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(S.signOut),
                ),
              ],
            ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await confirm(
      context,
      title: S.signOutConfirmTitle,
      message: S.signOutConfirmBody,
      confirmLabel: S.signOut,
    );
    if (!confirmed) return;
    await ref.read(authServiceProvider).signOut();
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text(label, style: text.labelSmall, textAlign: TextAlign.center),
        const SizedBox(height: 5),
        Text(value, style: text.titleSmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
