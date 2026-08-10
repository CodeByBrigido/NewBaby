import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  /// Troca de conta do Google, e com ela de criança.
  ///
  /// A confirmação existe por causa da limpeza: trocar apaga o que estava
  /// guardado no aparelho, então a linha do tempo recarrega. Sem o aviso, a
  /// primeira troca parece que o aplicativo travou.
  Future<void> _switchAccount(BuildContext context, WidgetRef ref) async {
    final bool ok = await confirm(
      context,
      title: S.switchAccount,
      message: S.switchAccountHint,
      confirmLabel: S.switchAccountAction,
    );
    if (!ok || !context.mounted) return;

    try {
      await ref.read(sessionServiceProvider).switchAccount();
      if (context.mounted) context.go(Routes.timeline);
    } on Exception catch (e) {
      // Desistir no seletor do Google cai aqui, e não é erro: a pessoa
      // continua na conta em que estava, sem ter perdido nada.
      if (context.mounted) {
        showMessage(context, userMessage(e, context: S.switchAccount));
      }
    }
  }

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.switch_account_outlined),
            tooltip: S.switchAccount,
            onPressed: () => _switchAccount(context, ref),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x8,
                Space.x16,
                Space.scrollEnd,
              ),
              children: <Widget>[
                Center(child: BabyAvatar(profile: profile, radius: 44)),
                const SizedBox(height: Space.x16),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
                const SizedBox(height: Space.x24),
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
                const SizedBox(height: Space.x20),
                _Tile(
                  icon: Icons.person_outline,
                  title: Copy.of(profile).babyInfo,
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
                // Um item próprio, e não uma linha escondida dentro do
                // Sobre: quem procura política de privacidade procura por
                // esse nome, e obrigar a caçar é o oposto de transparência.
                _Tile(
                  icon: Icons.shield_outlined,
                  title: 'Política de privacidade',
                  onTap: () => context.push(Routes.privacy),
                ),
                const SizedBox(height: Space.x24),
                TextButton(
                  onPressed: () => _signOut(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: AppPalette.danger,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(S.signOut),
                ),
                const SizedBox(height: Space.x4),
                TextButton(
                  onPressed: () => context.push(Routes.deleteAccount),
                  style: TextButton.styleFrom(
                    foregroundColor: context.cores.textSecondary,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text(
                    S.deleteAccount,
                    style: TextStyle(fontSize: 13),
                  ),
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
        const SizedBox(height: Space.x4),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.x4),
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
