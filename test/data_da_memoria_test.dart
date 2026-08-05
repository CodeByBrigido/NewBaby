import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/features/shell/add_sheet.dart';
import 'package:meu_bebe/models/baby_gender.dart';

/// Escolher quando a memória aconteceu, e não quando ela foi guardada.
///
/// Quem instala o aplicativo já tem anos de fotos no celular. Sem escolher a
/// data, tudo isso entra como se tivesse acontecido hoje: a idade fica
/// errada na linha do tempo e o arquivo vai parar na pasta errada do Drive.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('a hora do relógio acompanha o dia escolhido', () {
    test('o dia vem do seletor e a hora vem de agora', () {
      final DateTime escolhido = DateTime(2027, 4, 10);
      final DateTime agora = DateTime(2028, 9, 2, 14, 35, 7);

      expect(
        comHoraDoRelogio(escolhido, agora),
        DateTime(2027, 4, 10, 14, 35, 7),
      );
    });

    test('dois envios seguidos não geram o mesmo instante', () {
      // O nome do arquivo no Drive começa pela data e hora. Meia-noite fixa
      // faria um lote inteiro colidir e a ordem na pasta virar sorteio.
      final DateTime dia = DateTime(2027, 4, 10);
      final DateTime primeiro = comHoraDoRelogio(
        dia,
        DateTime(2028, 9, 2, 14, 35, 7),
      );
      final DateTime segundo = comHoraDoRelogio(
        dia,
        DateTime(2028, 9, 2, 14, 35, 9),
      );

      expect(primeiro, isNot(segundo));
      expect(segundo.isAfter(primeiro), isTrue);
    });

    test('a data escolhida cai no balde de idade daquele dia', () {
      // É o efeito que justifica a funcionalidade inteira: a pasta do Drive
      // sai da idade na data, não da data do envio.
      final DateTime nascimento = DateTime(2027, 1, 22);
      final DateTime quando = comHoraDoRelogio(
        DateTime(2027, 4, 10),
        DateTime(2028, 9, 2, 14, 35),
      );

      expect(
        AgeCalculator.bucketAt(nascimento, quando).folderName,
        'Semana 12',
      );
      // Sem escolher nada, a mesma foto iria para a pasta de hoje.
      expect(
        AgeCalculator.bucketAt(nascimento, DateTime(2028, 9, 2)).folderName,
        isNot('Semana 12'),
      );
    });
  });

  group('o aviso na folha de adicionar', () {
    Widget harness(DateTime quando, {VoidCallback? onReset}) => MaterialApp(
      theme: AppTheme.build(AppPalette.of(BabyGender.girl)),
      locale: const Locale('pt', 'BR'),
      home: Scaffold(
        body: DataDaMemoria(
          quando: quando,
          onTap: () {},
          onReset: onReset ?? () {},
        ),
      ),
    );

    testWidgets('no caminho normal não pede nada de ninguém', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness(DateTime.now()));

      expect(find.text('Aconteceu hoje'), findsOneWidget);
      // Nada para desfazer quando a data é a de hoje.
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('com data antiga, mostra a data por extenso', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness(DateTime(2027, 4, 10, 14, 35)));

      expect(find.text('10 de abril de 2027'), findsOneWidget);
      expect(
        find.text('Vale para tudo que você adicionar agora'),
        findsOneWidget,
      );
    });

    testWidgets('dá para voltar para hoje sem sair da folha', (
      WidgetTester tester,
    ) async {
      // Uma data antiga esquecida ligada é pior que não ter a função: as
      // próximas fotos entrariam caladas na idade errada.
      int voltas = 0;
      await tester.pumpWidget(
        harness(DateTime(2027, 4, 10), onReset: () => voltas++),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(voltas, 1);
    });
  });
}
