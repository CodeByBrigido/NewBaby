@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    tester.view.physicalSize = const Size(1080, 700);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: Scaffold(
            backgroundColor: AppPalette.girl.background,
            body: const Padding(
              padding: EdgeInsets.all(Space.x16),
              child: _AmostraDeIdioma(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('previa/idioma.png'),
    );
  });
}

/// A seção como ela aparece nas Configurações.
///
/// Redesenhada aqui em vez de montar a tela inteira porque a tela de
/// Configurações depende de serviços de aparelho (biometria, notificações)
/// que não existem no teste.
class _AmostraDeIdioma extends ConsumerWidget {
  const _AmostraDeIdioma();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Idioma atual = ref.watch(idiomaProvider);
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Idioma', style: text.titleMedium),
        const SizedBox(height: Space.x12),
        Container(
          padding: const EdgeInsets.all(Space.x16),
          decoration: BoxDecoration(
            color: context.cores.surface,
            borderRadius: Radii.cardR,
          ),
          child: Column(
            children: <Widget>[
              for (final Idioma idioma in Idioma.values) ...<Widget>[
                if (idioma != Idioma.values.first) const Divider(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(child: Text(idioma.nome, style: text.titleSmall)),
                    if (idioma == atual)
                      Icon(
                        Icons.check,
                        size: 20,
                        color: context.cores.primaryDark,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.x12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.translate, size: 18, color: context.cores.textSecondary),
            const SizedBox(width: Space.x12),
            Expanded(
              child: Text(
                'A escolha já fica guardada, mas a tradução ainda está sendo '
                'feita: por enquanto o aplicativo continua em português.',
                style: text.bodySmall?.copyWith(
                  color: context.cores.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
