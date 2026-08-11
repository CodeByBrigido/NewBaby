import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/account_deletion.dart';
import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../state/providers.dart';
import 'documento.dart';

/// O que acontece quando a conta é apagada, por extenso.
///
/// A tela de apagar (`DeleteAccountScreen`) é a ação, e ela é curta de
/// propósito: quem chega lá já decidiu. Esta é a leitura de quem ainda não
/// decidiu, e ela precisa existir **antes** do botão vermelho, não depois.
///
/// É o mesmo texto da página pública que o Google Play exige, e mora dentro
/// do aplicativo pelo mesmo motivo da política: ninguém deveria precisar de
/// rede, nem de sair do aplicativo, para saber o que perde ao apagar a conta.
class AccountDeletionScreen extends ConsumerWidget {
  const AccountDeletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sem sessão, esta tela é lida da tela de entrada por quem ainda está
    // decidindo se cria a conta. Oferecer ali um botão de apagar seria
    // oferecer apagar uma conta que não existe.
    final bool comSessao = ref.watch(uidProvider) != null;

    return TelaDeDocumento(
      titulo: S.accountDeletionTitle,
      data: deletionPageDate,
      secoes: accountDeletionPage,
      abaixoDoTexto: comSessao
          ? Padding(
              padding: const EdgeInsets.only(top: Space.x8),
              child: FilledButton(
                onPressed: () => context.push(Routes.deleteAccount),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.danger,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(S.goToDeleteAccount),
              ),
            )
          : null,
    );
  }
}
