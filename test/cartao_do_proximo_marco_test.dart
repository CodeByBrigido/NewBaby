import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
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

  group('a contagem fala a língua do aplicativo', () {
    tearDown(() => definirTextos(textosPt));

    testWidgets('em inglês o "Daqui a" não sobra', (WidgetTester tester) async {
      // A frase inteira vive na tabela de idioma, e não só a contagem, porque
      // o português põe o "Daqui a" antes e o inglês põe o "from now" depois.
      // Montá-la no ponto de uso deixava o cartão dizendo "Daqui a 73 days".
      definirTextos(textosEn);
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 8, 21),
      );

      expect(find.text('NEXT MILESTONE'), findsOneWidget);
      expect(find.textContaining('Daqui'), findsNothing);
      expect(find.textContaining('from now'), findsOneWidget);
    });

    test('cada língua monta a frase na ordem dela', () {
      expect(textosPt.faltamDias(73), 'Daqui a 73 dias');
      expect(textosEn.faltamDias(73), '73 days from now');
      expect(textosPt.faltamDias(1), 'Daqui a 1 dia');
      expect(textosEn.faltamDias(1), '1 day from now');
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

    testWidgets('com arte, o bolo aparece solto, sem caixa atrás', (
      WidgetTester tester,
    ) async {
      // É assim que o modelo enviado mostra: o bolo pousado no cartão, sem
      // moldura. A caixa colorida existe só para o desenho de reserva, cujos
      // andares creme sumiriam no branco.
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 8, 21),
      );

      // O `Image.asset` é a raiz quando há arte declarada. Sem arquivo na
      // pasta ele cai no `errorBuilder`, e aí sim aparece o Container.
      expect(
        find.descendant(
          of: find.byType(BoloDeAniversario),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
    });

    testWidgets('sem sexo, o desenho de reserva vem com a base suave', (
      WidgetTester tester,
    ) async {
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 8, 21),
        sexo: null,
      );

      expect(
        find.descendant(
          of: find.byType(BoloDeAniversario),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
      expect(
        find.descendant(
          of: find.byType(BoloDeAniversario),
          matching: find.byType(Image),
        ),
        findsNothing,
      );
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

    testWidgets('recém-nascido já aponta para os três meses', (
      WidgetTester tester,
    ) async {
      // O primeiro marco da vida é o dos três meses. As semanas continuam na
      // linha do tempo, onde uma semana ainda é muita coisa, mas anunciá-las
      // aqui enchia o cartão de aviso a cada seis dias.
      await montar(
        tester,
        nascimento: DateTime(2028, 8, 20),
        hoje: DateTime(2028, 8, 21),
      );
      expect(find.text('3 meses'), findsOneWidget);
      expect(find.textContaining('Daqui a'), findsOneWidget);
    });

    testWidgets('depois do primeiro ano, nenhum mês avulso aparece', (
      WidgetTester tester,
    ) async {
      // O defeito relatado, preso na tela: aos 21 meses e meio o cartão
      // dizia "22 meses, daqui a 12 dias". Agora aponta para os dois anos.
      await montar(
        tester,
        nascimento: DateTime(2026, 11, 2),
        hoje: DateTime(2028, 8, 21),
      );
      expect(find.text('2 anos'), findsOneWidget);
      expect(find.textContaining('meses'), findsNothing);
    });
  });
}
