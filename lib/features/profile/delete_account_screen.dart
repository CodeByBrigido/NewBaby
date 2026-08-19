import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/baby_profile.dart';
import '../../services/session_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Apagar a conta e tudo o que foi guardado sobre ela.
///
/// Existe por dois motivos, e os dois pesam: a Google Play exige que todo
/// aplicativo com conta ofereça a exclusão de dentro do próprio aplicativo, e
/// desinstalar não apaga nada - sem esta tela, o cadastro da criança e o texto
/// das cartas ficariam no servidor para sempre.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  DriveDisposal _disposal = DriveDisposal.keep;
  bool _working = false;

  /// O cadastro chega de cima, de quem o observa no `build`.
  ///
  /// Não é `ref.read` aqui dentro: um `StreamProvider` sem ninguém ouvindo
  /// não tem valor, e um cadastro nulo neste ponto significaria um aviso sem
  /// nome e, pior, a pasta do Drive escapando da lixeira por falta do id.
  Future<void> _delete(BabyProfile? profile) async {
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;

    final Copy copy = Copy.of(profile);

    // Nada é apagado antes desta resposta. O aviso diz o nome da criança e
    // abre pela frase que mais importa, para não ser o tipo de caixa que se
    // fecha no automático.
    final bool confirmed = await confirm(
      context,
      title: copy.deleteConfirmTitle,
      message: copy.deleteConfirmBody,
      confirmLabel: copy.deleteConfirmAction,
    );
    if (!confirmed) return;

    setState(() => _working = true);
    try {
      await ref
          .read(sessionServiceProvider)
          .deleteEverything(uid: uid, profile: profile, disposal: _disposal);
      // Com a sessão encerrada, o redirecionamento do roteador leva sozinho
      // para a tela de login.
      if (mounted) showMessage(context, S.deleteAccountDone);
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _working = false);
        showMessage(context, userMessage(e, context: 'Apagar conta'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final BabyProfile? profile = ref.watch(profileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.deleteAccount),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _working
              ? null
              : () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.profile),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x16,
          Space.x8,
          Space.x16,
          Space.x32,
        ),
        children: <Widget>[
          SoftCard(child: Text(S.deleteAccountBody, style: text.bodyMedium)),
          const SizedBox(height: Space.x8),
          // O texto do cartão é o resumo. Quem quiser o detalhe, item por
          // item, do que é apagado e do que não é, lê aqui antes de tocar
          // no botão vermelho, e não depois de ele já ter sido tocado.
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _working
                  ? null
                  : () => context.push(Routes.accountDeletion),
              child: Text(S.accountDeletionTitle),
            ),
          ),
          const SizedBox(height: Space.x12),
          SectionHeader(title: S.deleteAccountDriveQuestion),
          SoftCard(
            child: Column(
              children: <Widget>[
                _Choice(
                  value: DriveDisposal.keep,
                  group: _disposal,
                  title: S.deleteAccountKeepDrive,
                  subtitle: S.deleteAccountKeepDriveHint,
                  onChanged: _working ? null : _select,
                ),
                const Divider(height: 24),
                _Choice(
                  value: DriveDisposal.trash,
                  group: _disposal,
                  title: S.deleteAccountTrashDrive,
                  subtitle: S.deleteAccountTrashDriveHint,
                  onChanged: _working ? null : _select,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.x16),
          InfoNote(message: S.deleteDriveNote, icon: Icons.lock_outline),
          const SizedBox(height: Space.x32),
          FilledButton(
            onPressed: _working ? null : () => _delete(profile),
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.danger,
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(_working ? S.deleteAccountWorking : S.deleteAccount),
          ),
        ],
      ),
    );
  }

  void _select(DriveDisposal value) => setState(() => _disposal = value);
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.value,
    required this.group,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final DriveDisposal value;
  final DriveDisposal group;
  final String title;
  final String subtitle;
  final ValueChanged<DriveDisposal>? onChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool selected = value == group;
    final VoidCallback? tap = onChanged == null
        ? null
        : () => onChanged!(value);

    return InkWell(
      onTap: tap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected
                ? context.cores.primary
                : context.cores.textSecondary,
            size: 22,
          ),
          const SizedBox(width: Space.x16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: text.titleSmall),
                const SizedBox(height: Space.x4),
                Text(subtitle, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
