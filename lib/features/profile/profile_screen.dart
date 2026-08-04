import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
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
    final bool leitura = ref.watch(isReadOnlyProvider);

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
                      Container(
                        width: 1,
                        height: 34,
                        color: context.cores.divider,
                      ),
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
                if (!leitura)
                  _Tile(
                    icon: Icons.person_outline,
                    title: Copy.of(profile).babyInfo,
                    onTap: () => context.push(Routes.babyInfo),
                  ),
                if (!leitura)
                  _Tile(
                    icon: Icons.favorite_outline,
                    title: 'Quem mais pode ver',
                    subtitle: _quemMaisVe(ref),
                    onTap: () => context.push(Routes.share),
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
                    foregroundColor: AppPalette.danger,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(S.signOut),
                ),
                const SizedBox(height: 4),
                // Quem foi convidado não tem conta para apagar aqui: a
                // cápsula não é dela, e o botão de apagar tudo apontaria para
                // dados que não são dela. O que ela pode fazer é sair.
                TextButton(
                  onPressed: leitura
                      ? () => _sairDaCapsula(context, ref)
                      : () => context.push(Routes.deleteAccount),
                  style: TextButton.styleFrom(
                    foregroundColor: context.cores.textSecondary,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: Text(
                    leitura ? 'Sair desta cápsula' : S.deleteAccount,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
    );
  }

  /// Uma linha curta dizendo quantas pessoas já entraram.
  String? _quemMaisVe(WidgetRef ref) {
    final int quantos = ref.watch(familyMembersProvider).value?.length ?? 0;
    if (quantos == 0) return 'Ninguém ainda';
    return Fmt.count(quantos, 'pessoa', 'pessoas');
  }

  Future<void> _sairDaCapsula(BuildContext context, WidgetRef ref) async {
    final bool ok = await confirm(
      context,
      title: 'Sair desta cápsula?',
      message:
          'Você deixa de acompanhar as memórias. Nada é apagado, e quem te '
          'convidou pode te chamar de novo quando quiser.',
      confirmLabel: 'Sair',
    );
    if (!ok) return;
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    await ref.read(firestoreServiceProvider).removeFamilyAccess(uid);
    await ref.read(sessionServiceProvider).signOut();
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await confirm(
      context,
      title: S.signOutConfirmTitle,
      message: S.signOutConfirmBody,
      confirmLabel: S.signOut,
    );
    if (!confirmed) return;
    // Pelo SessionService, e não pelo AuthService: sair também apaga as
    // miniaturas, os downloads, as buscas recentes e agenda o descarte do
    // cache do Firestore.
    await ref.read(sessionServiceProvider).signOut();
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
