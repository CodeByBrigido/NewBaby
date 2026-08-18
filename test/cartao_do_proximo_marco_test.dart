import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/home/proximo_marco.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
import 'package:meu_bebe/models/entry.dart';

import 'fonte_de_verdade.dart';

/// O cartão que anuncia o próximo marco de idade.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
  });

  Future<void> montar(
    WidgetTester tester, {
    required DateTime nascimento,
    required DateTime hoje,
    BabyGender? sexo = BabyGender.girl,
  }) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final CapsulePulse pulse = CapsulePulse.from(
      profile: BabyProfile(name: 'Maria', birth: nascimento, gender: sexo),
      entries: const <Entry>[],
      now: hoje,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(AppPalette.of(sexo)),
        home: Scaffold(
          body: CartaoDoProximoMarco(pulse: pulse, genero: sexo),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('o que o cartão diz', () {
    testWidgets('o marco e quantos dias faltam', (WidgetTester tester) async {
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 8, 21),
      );

      expect(find.text('PRÓXIMO MARCO'), findsOneWidget);
      expect(find.text('1 ano e 10 meses'), findsNothing);
      expect(find.textContaining('Daqui a'), findsOneWidget);
    });

    testWidgets('o singular do dia', (WidgetTester tester) async {
      // Véspera dos dois anos.
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 11, 1),
      );

      expect(find.text('2 anos'), findsOneWidget);
      expect(find.text('Daqui a 1 dia'), findsOneWidget);
    });

    testWidgets('o plural do dia', (WidgetTester tester) async {
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 10, 30),
      );
      expect(find.text('Daqui a 3 dias'), findsOneWidget);
    });

    testWidgets('no próprio dia, não conta dias nenhum', (
      WidgetTester tester,
    ) async {
      // "Daqui a 0 dias" seria uma frase que ninguém diz em voz alta.
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 11, 2),
      );

      expect(find.text('2 anos'), findsOneWidget);
      expect(find.text('É hoje!'), findsOneWidget);
      expect(find.textContaining('Daqui'), findsNothing);
    });
  });

  group('o bolo', () {
    testWidgets('aparece nos três temas, sem quebrar', (
      WidgetTester tester,
    ) async {
      for (final BabyGender? sexo in <BabyGender?>[
        BabyGender.girl,
        BabyGender.boy,
        null,
      ]) {
        await montar(
          tester,
          nascimento: DateTime(2026, 11, 2),
          hoje: DateTime(2028, 8, 21),
          sexo: sexo,
        );
        expect(find.byType(BoloDeAniversario), findsOneWidget, reason: '$sexo');
        expect(tester.takeException(), isNull, reason: '$sexo');
      }
    });
  });

  group('a arte do bolo', () {
    test('cada sexo aponta para o seu arquivo', () {
      // Os nomes são o contrato com quem vai soltar os PNG na pasta: se
      // mudarem aqui sem mudar lá, o cartão volta calado para o desenho.
      expect(
        BoloDeAniversario.arteDe(BabyGender.girl),
        'assets/marcos/bolo-menina.png',
      );
      expect(
        BoloDeAniversario.arteDe(BabyGender.boy),
        'assets/marcos/bolo-menino.png',
      );
    });

    test('sem sexo informado não há arquivo, e o desenho fica', () {
      // Escolher um dos dois seria atribuir à criança um sexo que ninguém
      // informou.
      expect(BoloDeAniversario.arteDe(null), isNull);
    });
  });

  group('as bordas', () {
    testWidgets('num telefone estreito continua inteiro', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 3, 1200);
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 8, 21),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('recém-nascido tem marco, e ele é de semana', (
      WidgetTester tester,
    ) async {
      // O primeiro marco da vida chega em uma semana, e não daqui a um mês.
      await montar(
        tester,
        nascimento: DateTime(2028, 8, 20),
        hoje: DateTime(2028, 8, 21),
      );
      expect(find.text('1 semana'), findsOneWidget);
      expect(find.text('Daqui a 6 dias'), findsOneWidget);
    });
  });
}
