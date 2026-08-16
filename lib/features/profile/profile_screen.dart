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
  /// Vai direto ao seletor do Google, sem aviso antes. O aviso existia para
  /// contar que a troca recarrega a linha do tempo, mas isso é uma espera de
  /// segundos que se explica sozinha, e nada se perde no caminho: desistir
  /// no seletor deixa tudo como estava, porque a limpeza só acontece depois
  /// de a entrada dar certo.
  Future<void> _switchAccount(BuildContext context, WidgetRef ref) async {
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
          _BotaoDeContas(onTap: () => _switchAccount(context, ref)),
          const SizedBox(width: Space.x8),
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
                Center(
                  child: _FotoDePerfil(
                    profile: profile,
                    onTap: () => context.push(Routes.profilePhoto),
                  ),
                ),
                const SizedBox(height: Space.x16),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
                // O email logo abaixo do nome, e não num item de lista com
                // seta. Ele não leva a lugar nenhum: é identificação, do
                // mesmo tipo que o nome, e um item tocável que não faz nada
                // é uma promessa que a tela não cumpre.
                if (email != null) ...<Widget>[
                  const SizedBox(height: Space.x4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: context.cores.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: Space.x24),
                SoftCard(
                  // Uma linha por dado, e não duas colunas.
                  //
                  // Em duas colunas cada dado ficava com metade do cartão, e
                  // metade não cabe a idade: "20 anos e 11 meses e 30 dias"
                  // quebrava em três linhas ao lado de uma data de uma linha
                  // só, com um divisor de 34 px fixos no meio que ficava bem
                  // mais curto que o texto. Aos poucos meses de vida ninguém
                  // via o problema; ele aparece sozinho conforme a criança
                  // cresce, que é justamente o horizonte deste aplicativo.
                  //
                  // Empilhado, cada dado tem a largura inteira do cartão e a
                  // idade cabe em duas linhas num telefone comum.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _Fact(label: S.birthDate, value: Fmt.date(profile.birth)),
                      const SizedBox(height: Space.x12),
                      Divider(height: 1, color: context.cores.divider),
                      const SizedBox(height: Space.x12),
                      _Fact(
                        label: S.currentAge,
                        value: profile.ageNow().detailedLabel(
                          alwaysShowDays: true,
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
                  title: S.privacyPolicy,
                  onTap: () => context.push(Routes.privacy),
                ),
                // O único caminho para apagar a conta, e é a leitura que vem
                // primeiro. O botão vermelho fica no fim dela, depois de a
                // pessoa ter lido o que perde.
                //
                // Havia também um atalho direto aqui embaixo, e ele era pior
                // que redundante: dois controles com nomes diferentes para a
                // mesma coisa, um deles pulando justamente a explicação que
                // o outro existe para dar.
                _Tile(
                  icon: Icons.delete_outline,
                  title: S.accountDeletionTitle,
                  onTap: () => context.push(Routes.accountDeletion),
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

/// A porta para as contas, no alto da tela de perfil.
///
/// Era um ícone sozinho, e ícone sozinho não conta que existe mais de uma
/// conta: quem tem dois filhos precisa descobrir isso, e descobrir sozinho
/// é o mesmo que não existir. Com a palavra escrita e a seta para baixo, o
/// controle diz o que é e diz que abre uma lista.
///
/// A seta é promessa de lista, e a lista que abre é a do próprio Google.
/// Veja [ProfileScreen._switchAccount]: não existe lista nossa de contas, e
/// isso é decisão, não falta. O aplicativo não tem como enumerar as contas
/// do aparelho (isso exigiria a permissão `GET_ACCOUNTS`, que a auditoria
/// do CI reprova) nem como abrir direto numa conta escolhida (o
/// `authenticate` do google_sign_in não recebe qual conta usar). Uma lista
/// nossa seria, então, uma cópia sempre desatualizada em que tocar num
/// nome não levaria àquele nome.
class _BotaoDeContas extends StatelessWidget {
  const _BotaoDeContas({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: S.switchAccount,
      child: Material(
        color: context.cores.primarySoft,
        borderRadius: Radii.pillR,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.pillR,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.x12,
              Space.x8,
              Space.x8,
              Space.x8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  S.accountsLabel,
                  style: text.labelMedium?.copyWith(
                    color: context.cores.primaryDark,
                    letterSpacing: 0.6,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: context.cores.primaryDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// O avatar com o convite para trocá-lo.
///
/// O selo da câmera existe porque um avatar tocável sem nenhuma marca é um
/// avatar que ninguém descobre que dá para tocar. Ele é pequeno e fica na
/// borda, para não competir com o rosto.
class _FotoDePerfil extends StatelessWidget {
  const _FotoDePerfil({required this.profile, required this.onTap});

  final BabyProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Trocar a foto de perfil',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          children: <Widget>[
            BabyAvatar(profile: profile, radius: 44),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(Space.x8),
                decoration: BoxDecoration(
                  // A variante forte, e não a de marca: o ícone em cima é
                  // branco, e o Design System exige o contraste maior aí.
                  color: context.cores.primaryStrong,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.cores.surface, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    // Rótulo à esquerda, valor encostado na borda direita do cartão. O valor
    // é o que se procura ao abrir o Perfil, e alinhado à direita ele tem a
    // largura toda que sobra do rótulo para quebrar quando precisar.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: text.labelSmall),
        const SizedBox(width: Space.x12),
        Expanded(
          child: Text(
            value,
            style: text.titleSmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.x4),
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
