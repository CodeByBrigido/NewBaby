import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/baby_profile.dart';
import '../../services/session_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Apagar a conta e tudo o que foi guardado sobre ela.
///
/// Existe por dois motivos, e os dois pesam: a Google Play exige que todo
/// aplicativo com conta ofereça a exclusão de dentro do próprio aplicativo, e
/// desinstalar não apaga nada — sem esta tela, o cadastro da criança e o texto
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

  Future<void> _delete() async {
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;

    final bool confirmed = await confirm(
      context,
      title: S.deleteAccountTitle,
      message: S.deleteAccountBody,
      confirmLabel: S.deleteAccount,
    );
    if (!confirmed) return;

    setState(() => _working = true);
    final BabyProfile? profile = ref.read(profileProvider).value;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.deleteAccount),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          SoftCard(child: Text(S.deleteAccountBody, style: text.bodyMedium)),
          const SizedBox(height: 28),
          const SectionHeader(title: S.deleteAccountDriveQuestion),
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
          const SizedBox(height: 16),
          const InfoNote(
            message:
                'Mesmo mandando para a lixeira, os arquivos são seus e estão '
                'no seu Drive: o aplicativo nunca teve uma cópia deles.',
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _working ? null : _delete,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
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
            color: selected ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: text.titleSmall),
                const SizedBox(height: 3),
                Text(subtitle, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
