import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/terms_of_use.dart';
import 'documento.dart';

/// Os termos de uso, dentro do aplicativo.
///
/// Como a política de privacidade, o texto vem no pacote: quem está decidindo
/// se confia o registro de um filho a um aplicativo consegue ler os termos
/// sem rede, e lê os termos daquela versão, não os que estiverem no ar hoje.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TelaDeDocumento(
      titulo: S.termsOfUse,
      data: termsOfUseDate,
      secoes: termsOfUse,
    );
  }
}
