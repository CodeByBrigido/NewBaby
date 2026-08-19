@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/shell/add_sheet.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/state/providers.dart';

import 'fonte_de_verdade.dart';

/// O portão do Premium, como ele chega aos olhos.
///
/// Duas imagens: a folha de adicionar com os cadeados, e o convite que o toque
/// abre. São as duas telas novas desta fase, e as duas em que a decisão de
/// produto vira palavra escrita para alguém ler.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
    await carregarIconesDoMaterial();
  });

  for (final (String nome, BabyGender? sexo) in <(String, BabyGender?)>[
    ('menina', BabyGender.girl),
    ('menino', BabyGender.boy),
  ]) {
    testWidgets('previa do portao, $nome', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(
              (Ref _) => Stream<BabyProfile?>.value(
                BabyProfile(
                  name: sexo == BabyGender.boy ? 'Pedro' : 'Maria',
                  birth: DateTime(2026, 11, 2),
                  gender: sexo,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.build(AppPalette.of(sexo)),
            home: Scaffold(
              backgroundColor: AppPalette.of(sexo).background,
              body: Builder(
                builder: (BuildContext context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showAddSheet(context),
                    child: const Text('mais'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('mais'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('previa/folha-trancada-$nome.png'),
      );

      // O toque na carta fecha a folha e abre o convite.
      await tester.tap(find.text(S.addLetter));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('previa/convite-premium-$nome.png'),
      );
    });
  }
}
