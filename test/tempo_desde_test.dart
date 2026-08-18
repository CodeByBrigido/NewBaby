import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/utils/formatters.dart';

/// Quanto tempo faz que algo não é registrado.
///
/// É o número que a lista "Faz um tempo" mostra ao lado de cada tipo. A
/// escada é dia até 30, depois mês até 12, depois ano, e o que erra fácil
/// aqui são as três viradas e o singular de cada unidade.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final DateTime hoje = DateTime(2028, 8, 18);

  String faz(int dias) =>
      Fmt.tempoDesde(hoje.subtract(Duration(days: dias)), agora: hoje);

  group('os dias', () {
    test('no próprio dia, não faz tempo nenhum', () {
      expect(faz(0), 'hoje');
    });

    test('o singular do dia', () {
      expect(faz(1), '1 dia');
    });

    test('o plural a partir de dois', () {
      expect(faz(2), '2 dias');
      expect(faz(23), '23 dias');
    });

    test('trinta dias ainda é dia', () {
      // O limite pedido: até 30 conta em dias.
      expect(faz(30), '30 dias');
    });
  });

  group('os meses', () {
    test('passando de trinta, vira mês', () {
      expect(faz(31), '1 mês');
    });

    test('o plural do mês', () {
      expect(faz(70), '2 meses');
    });

    test('nunca aparece "0 meses" logo depois de "30 dias"', () {
      // A virada é onde a conta de calendário poderia devolver zero. Se um
      // dia isso acontecer, a lista mostraria um degrau para trás.
      for (int d = 28; d <= 40; d++) {
        expect(faz(d), isNot(contains('0 mes')), reason: '$d dias');
      }
    });

    test('onze meses ainda é mês', () {
      expect(Fmt.tempoDesde(DateTime(2027, 9, 18), agora: hoje), '11 meses');
    });
  });

  group('os anos', () {
    test('doze meses viram um ano', () {
      expect(Fmt.tempoDesde(DateTime(2027, 8, 18), agora: hoje), '1 ano');
    });

    test('o plural do ano', () {
      expect(Fmt.tempoDesde(DateTime(2025, 8, 18), agora: hoje), '3 anos');
    });

    test('um dia antes de completar o ano, ainda são onze meses', () {
      // A borda que decide entre "11 meses" e "1 ano".
      expect(Fmt.tempoDesde(DateTime(2027, 8, 19), agora: hoje), '11 meses');
    });
  });

  group('o calendário, e não blocos de trinta dias', () {
    test('quem registrou em 31 de janeiro faz um mês em 28 de fevereiro', () {
      // Com divisão por trinta, este caso mostraria "28 dias" até março.
      expect(
        Fmt.tempoDesde(DateTime(2027, 1, 31), agora: DateTime(2027, 2, 28)),
        '28 dias',
      );
      expect(
        Fmt.tempoDesde(DateTime(2027, 1, 31), agora: DateTime(2027, 3, 3)),
        '1 mês',
      );
    });

    test('quem registrou em 29 de fevereiro completa o ano em 28', () {
      // Fevereiro não tem 29 todo ano, e o aniversário cai no último dia do
      // mês. É a mesma regra que o aplicativo inteiro usa para idade, e é
      // por isso que 28/02/2029 já é um ano, e não onze meses: eu tinha
      // escrito o contrário aqui, e o teste é que estava errado.
      expect(
        Fmt.tempoDesde(DateTime(2028, 2, 29), agora: DateTime(2029, 2, 27)),
        '11 meses',
      );
      expect(
        Fmt.tempoDesde(DateTime(2028, 2, 29), agora: DateTime(2029, 2, 28)),
        '1 ano',
      );
    });
  });

  group('a hora do dia não conta', () {
    test('registrado ontem à noite continua sendo um dia', () {
      expect(
        Fmt.tempoDesde(
          DateTime(2028, 8, 17, 23, 50),
          agora: DateTime(2028, 8, 18, 0, 10),
        ),
        '1 dia',
      );
    });
  });
}
