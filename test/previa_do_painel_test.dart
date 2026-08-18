@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/features/home/painel_do_bebe.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';

import 'fonte_de_verdade.dart';

/// O painel novo do topo da tela inicial, nos três temas.
///
/// **O que é real aqui:** o `PainelDoBebe` de verdade, o mesmo que a tela
/// monta, com a paleta, a tipografia e o fundo desenhado em código.
///
/// **O que é encenação:** a foto, que sem rede não chega do Drive: no lugar
/// dela o avatar cai nas iniciais, que é o que o aplicativo mostra enquanto a
/// foto não existe.
///
/// Roda à mão:
/// `flutter test --run-skipped --update-goldens test/previa_do_painel_test.dart`
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
    await carregarIconesDoMaterial();
  });

  for (final (String nome, BabyGender? sexo, String crianca)
      in <(String, BabyGender?, String)>[
        ('menina', BabyGender.girl, 'Maria'),
        ('menino', BabyGender.boy, 'Pedro'),
        ('sem-sexo', null, 'Alex'),
      ]) {
    testWidgets('previa do painel, $nome', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1080);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final BabyProfile perfil = BabyProfile(
        name: crianca,
        birth: DateTime(2026, 11, 2),
        gender: sexo,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.build(AppPalette.of(sexo)),
            home: Scaffold(
              backgroundColor: AppPalette.of(sexo).background,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(Space.x16),
                    child: PainelDoBebe(
                      profile: perfil,
                      idade: AgeCalculator.ageAt(
                        perfil.birth,
                        DateTime(2028, 8, 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PainelDoBebe),
        matchesGoldenFile('previa/painel-$nome.png'),
      );
    });
  }
}
