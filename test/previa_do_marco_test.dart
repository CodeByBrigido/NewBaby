@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/features/home/proximo_marco.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
import 'package:meu_bebe/models/entry.dart';

import 'fonte_de_verdade.dart';

/// O cartão do próximo marco, nos três temas.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
    await carregarIconesDoMaterial();
  });

  for (final (String nome, BabyGender? sexo) in <(String, BabyGender?)>[
    ('menina', BabyGender.girl),
    ('menino', BabyGender.boy),
    ('sem-sexo', null),
  ]) {
    testWidgets('previa do marco, $nome', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 480);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(AppPalette.of(sexo)),
          home: Scaffold(
            backgroundColor: AppPalette.of(sexo).background,
            body: Padding(
              padding: const EdgeInsets.all(Space.x16),
              child: CartaoDoProximoMarco(
                genero: sexo,
                pulse: CapsulePulse.from(
                  profile: BabyProfile(
                    name: 'Maria',
                    birth: DateTime(2026, 11, 2),
                    gender: sexo,
                  ),
                  entries: const <Entry>[],
                  now: DateTime(2028, 8, 21),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CartaoDoProximoMarco),
        matchesGoldenFile('previa/marco-$nome.png'),
      );
    });
  }
}
