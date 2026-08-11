import 'package:flutter/material.dart';

import '../../core/l10n/privacy_policy.dart';
import '../../core/l10n/strings.dart';
import 'documento.dart';

/// A política de privacidade, dentro do aplicativo.
///
/// O texto vem de [privacyPolicy], que viaja no pacote: quem está decidindo
/// se confia o registro de um filho a um aplicativo consegue ler os termos
/// sem rede, e lê os termos daquela versão, não os que estiverem no ar hoje.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TelaDeDocumento(
      titulo: S.privacyPolicy,
      data: privacyPolicyDate,
      secoes: privacyPolicy,
    );
  }
}
