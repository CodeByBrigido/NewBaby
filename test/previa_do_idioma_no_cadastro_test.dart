@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/state/idioma_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fonte_de_verdade.dart';

/// A escolha de idioma como ela aparece no cadastro.
///
/// Está lá, e não só em Configurações, por causa do Drive: as pastas nascem
/// no fim do cadastro e guardam a língua com que nasceram para sempre.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await initializeDateFormatting('en');
    await carregarFonteDeVerdade();
    await carregarIconesDoMaterial();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() => definirTextos(textosPt));

  for (final (String nome, Textos lingua) in <(String, Textos)>[
    ('portugues', textosPt),
    ('ingles', textosEn),
  ]) {
    testWidgets('previa do idioma no cadastro, $nome', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1200);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      definirTextos(lingua);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.build(AppPalette.neutral),
            home: Scaffold(
              backgroundColor: AppPalette.neutral.background,
              body: const Padding(
                padding: EdgeInsets.all(Space.x24),
                child: _Amostra(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('previa/idioma-no-cadastro-$nome.png'),
      );
    });
  }
}

/// O bloco do cadastro, redesenhado aqui porque a tela inteira depende de
/// sessão e de Firebase, que não existem no teste.
class _Amostra extends ConsumerWidget {
  const _Amostra();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Idioma atual = ref.watch(idiomaProvider);
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.onboardingGreeting,
          textAlign: TextAlign.center,
          style: text.headlineMedium,
        ),
        const SizedBox(height: Space.block),
        Text(S.languageStepTitle, style: text.titleSmall),
        const SizedBox(height: Space.x12),
        Row(
          children: <Widget>[
            for (final Idioma idioma in Idioma.values) ...<Widget>[
              if (idioma != Idioma.values.first)
                const SizedBox(width: Space.x8),
              Expanded(
                child: Material(
                  color: idioma == atual
                      ? context.cores.primarySoft
                      : context.cores.surfaceMuted,
                  borderRadius: Radii.buttonR,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.x16),
                    child: Center(
                      child: Text(
                        idioma.nome,
                        style: text.titleSmall?.copyWith(
                          color: idioma == atual
                              ? context.cores.primaryDark
                              : context.cores.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Space.x12),
        Text(
          S.languageStepNote,
          style: text.bodySmall?.copyWith(color: context.cores.textSecondary),
        ),
        const SizedBox(height: Space.block),
        Text(S.fullName, style: text.bodyMedium),
        const SizedBox(height: Space.x8),
        Text(S.birthDate, style: text.bodyMedium),
        const SizedBox(height: Space.x8),
        Text(S.hospitalOptional, style: text.bodyMedium),
      ],
    );
  }
}
