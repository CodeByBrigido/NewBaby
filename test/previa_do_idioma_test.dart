@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/features/home/proximo_marco.dart';
import 'package:meu_bebe/features/profile/settings_screen.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/state/idioma_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fonte_de_verdade.dart';

/// As duas telas desta rodada: o cartão do marco com a regra nova, e a
/// escolha de idioma nas Configurações.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
    await carregarIconesDoMaterial();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('previa do marco com a regra nova', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Aos 21 meses e meio: onde o cartão dizia "22 meses, daqui a 12 dias".
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(AppPalette.girl),
        home: Scaffold(
          backgroundColor: AppPalette.girl.background,
          body: Padding(
            padding: const EdgeInsets.all(Space.x16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final DateTime hoje in <DateTime>[
                  DateTime(2028, 8, 21),
                  DateTime(2027, 1, 10),
                ]) ...<Widget>[
                  CartaoDoProximoMarco(
                    genero: BabyGender.girl,
                    pulse: CapsulePulse.from(
                      profile: BabyProfile(
                        name: 'Maria',
                        birth: DateTime(2026, 11, 2),
                        gender: BabyGender.girl,
                      ),
                      entries: const <Entry>[],
                      now: hoje,
                    ),
                  ),
                  const SizedBox(height: Space.x16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('previa/marco-desenvolvimento.png'),
    );
  });

  testWidgets('previa da escolha de idioma', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: _Raiz()));
    await tester.pumpAndSettle();
    await _rolarAteOIdioma(tester);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('previa/idioma.png'),
    );
  });

  testWidgets('previa do menu de idioma aberto', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: _Raiz()));
    await tester.pumpAndSettle();
    await _rolarAteOIdioma(tester);

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('previa/idioma-aberto.png'),
    );
  });
}

/// Leva a seção de idioma para o alto da tela.
///
/// A seção é a terceira da lista, e sem rolar a prévia sairia mostrando
/// otimização de fotos. Rola até o cabeçalho e recua um pouco, para o título
/// da seção aparecer junto com o cartão.
Future<void> _rolarAteOIdioma(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.byIcon(Icons.translate), 200);
  await tester.pumpAndSettle();
  await tester.drag(find.byType(ListView), const Offset(0, 120));
  await tester.pumpAndSettle();
}

/// A tela de Configurações de verdade, com a ligação do idioma da raiz.
///
/// A prévia antiga redesenhava a seção à mão, por medo de a tela depender de
/// biometria e notificações. Ela não depende: os provedores desses serviços
/// falham em silêncio no teste e a tela desenha assim mesmo. Desenhar a tela
/// real é o que impede a prévia de virar retrato de uma versão que não
/// existe mais, que foi exatamente o que aconteceu com a anterior.
class _Raiz extends ConsumerWidget {
  const _Raiz();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Idioma idioma = ref.watch(idiomaProvider);
    definirTextos(textosPara(idioma.codigo));

    return MaterialApp(
      theme: AppTheme.build(AppPalette.girl),
      home: const SettingsScreen(),
    );
  }
}
