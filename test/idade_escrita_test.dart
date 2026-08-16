import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';

/// Como a idade é escrita.
///
/// O defeito, visto na tela inicial: `1 ano e 9 meses e 14 dias`. Dois "e"
/// na mesma frase. Em português só a última parcela leva conjunção; as
/// anteriores se separam por vírgula.
///
/// Junto vinha um segundo problema, que é de layout mas nasce do texto: a
/// frase não cabia numa linha, e a quebra automática caía no pior lugar
/// possível, deixando `14` no fim de uma linha e `dias` no começo da outra.
void main() {
  final DateTime nascimento = DateTime(2026, 4, 10);

  Age idadeEm(DateTime quando) => AgeCalculator.ageAt(nascimento, quando);

  group('a conjunção', () {
    test('com três parcelas, só a última leva "e"', () {
      final String r = idadeEm(
        DateTime(2028, 1, 24),
      ).detailedLabel(alwaysShowDays: true);
      expect(r, '1 ano, 9 meses e 14 dias');
    });

    test('com duas parcelas, a vírgula não aparece', () {
      // O conserto não pode virar `1 ano, 9 meses`: com duas parcelas a
      // conjunção é o certo.
      expect(idadeEm(DateTime(2028, 1, 10)).detailedLabel(), '1 ano e 9 meses');
      expect(idadeEm(DateTime(2026, 5, 24)).detailedLabel(), '1 mês e 14 dias');
    });

    test('com uma parcela, nem uma nem outra', () {
      expect(idadeEm(DateTime(2026, 4, 13)).detailedLabel(), '3 dias');
      expect(idadeEm(DateTime(2026, 7, 10)).detailedLabel(), '3 meses');
    });

    test('nenhuma idade escreve dois "e"', () {
      // A varredura que o caso a caso não faz: dois anos de datas, dia a
      // dia, procurando a frase que deu origem a este teste.
      for (int dia = 0; dia < 800; dia++) {
        final Age idade = idadeEm(nascimento.add(Duration(days: dia)));
        for (final String frase in <String>[
          idade.shortLabel,
          idade.detailedLabel(),
          idade.detailedLabel(alwaysShowDays: true),
        ]) {
          expect(
            ' e '.allMatches(frase).length,
            lessThanOrEqualTo(1),
            reason: 'dois "e" em "$frase" (dia $dia)',
          );
        }
      }
    });
  });

  group('as duas linhas', () {
    test('os dias descem para a linha de baixo', () {
      expect(
        idadeEm(DateTime(2028, 1, 24)).detailedLines(alwaysShowDays: true),
        <String>['1 ano, 9 meses', 'e 14 dias'],
      );
    });

    test('lidas juntas, formam a frase certa', () {
      // É a única garantia que importa: a quebra não pode mudar o texto.
      for (int dia = 0; dia < 8000; dia += 37) {
        final Age idade = idadeEm(nascimento.add(Duration(days: dia)));
        expect(
          idade.detailedLines(alwaysShowDays: true).join(' '),
          idade.detailedLabel(alwaysShowDays: true),
          reason: 'dia $dia',
        );
      }
    });

    test('o que já cabe numa linha não é partido', () {
      // Partir `1 mês e 14 dias` criaria o problema que este método existe
      // para resolver.
      expect(
        idadeEm(DateTime(2026, 5, 24)).detailedLines(alwaysShowDays: true),
        hasLength(1),
      );
      expect(idadeEm(DateTime(2026, 4, 13)).detailedLines(), hasLength(1));
    });

    test('a primeira linha nunca termina em "e"', () {
      // Foi o erro que eu mesmo cometi ao escrever isto: fechar a linha de
      // cima com a conjunção reintroduz o `1 ano e 9 meses e 14 dias` na
      // leitura das duas juntas.
      for (int dia = 0; dia < 8000; dia += 13) {
        final List<String> linhas = idadeEm(
          nascimento.add(Duration(days: dia)),
        ).detailedLines(alwaysShowDays: true);
        if (linhas.length < 2) continue;
        expect(linhas.first, isNot(endsWith(' e')), reason: 'dia $dia');
        expect(linhas.last, startsWith('e '), reason: 'dia $dia');
      }
    });

    test('no nascimento não quebra nada', () {
      expect(idadeEm(nascimento).detailedLines(), <String>['No nascimento']);
    });
  });
}
