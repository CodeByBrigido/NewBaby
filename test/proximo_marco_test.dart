import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';

/// O próximo marco de idade, e quanto falta para ele.
///
/// É o que o cartão da tela inicial anuncia. Marco é a mesma coisa que a
/// linha do tempo marca quando alguém rola até o dia: se as duas contas
/// divergirem, o cartão promete um dia que o histórico não celebra.
void main() {
  final DateTime nascimento = DateTime(2026, 11, 2);

  ProximoMarco? marco(DateTime dia) =>
      CapsulePulse.proximoMarcoDe(nascimento, dia);

  group('quando o marco é hoje', () {
    test('o dia do mês redondo conta como hoje, e não como o próximo', () {
      // Aos dois meses, em 2 de janeiro. Se a busca começasse amanhã, o
      // cartão pularia justamente o dia que interessa.
      final ProximoMarco? m = marco(DateTime(2027, 1, 2));
      expect(m?.rotulo, '2 meses');
      expect(m?.diasAte, 0);
      expect(m?.ehHoje, isTrue);
    });

    test('o aniversário também', () {
      final ProximoMarco? m = marco(DateTime(2027, 11, 2));
      expect(m?.rotulo, '1 ano');
      expect(m?.diasAte, 0);
    });
  });

  group('quanto falta', () {
    test('um dia antes do mês redondo', () {
      final ProximoMarco? m = marco(DateTime(2027, 1, 1));
      expect(m?.rotulo, '2 meses');
      expect(m?.diasAte, 1);
    });

    test('logo depois de um marco, aponta para o seguinte', () {
      // Em 3 de janeiro a criança tem 62 dias, e o próximo marco é a nona
      // semana, no dia seguinte. Eu tinha escrito "3 meses" aqui: dentro dos
      // três primeiros meses as semanas chegam antes dos meses, e é essa a
      // graça delas.
      final ProximoMarco? m = marco(DateTime(2027, 1, 3));
      expect(m?.rotulo, '9 semanas');
      expect(m?.quando, DateTime(2027, 1, 4));
      expect(m?.diasAte, 1);
    });

    test('passada a fase das semanas, o próximo é o mês', () {
      final ProximoMarco? m = marco(DateTime(2027, 5, 10));
      expect(m?.rotulo, '7 meses');
      expect(m?.quando, DateTime(2027, 6, 2));
    });
  });

  group('as semanas dos três primeiros meses', () {
    test('no começo da vida, o próximo marco é uma semana', () {
      // Semanas só valem nos primeiros três meses, e ali elas são o marco
      // que chega antes do mês.
      final ProximoMarco? m = marco(DateTime(2026, 11, 3));
      expect(m?.rotulo, '1 semana');
      expect(m?.diasAte, 6);
    });

    test('passados os três meses, a semana some e sobra o mês', () {
      // "208 semanas" não diria nada a ninguém, e a regra para de contá-las.
      final ProximoMarco? m = marco(DateTime(2028, 5, 10));
      expect(m?.rotulo, contains('meses'));
    });
  });

  group('as bordas', () {
    test('no próprio dia do nascimento, o marco é a primeira semana', () {
      // O nascimento não é data redonda: `dataRedondaEm` exige pelo menos um
      // dia de vida.
      final ProximoMarco? m = marco(nascimento);
      expect(m?.rotulo, '1 semana');
      expect(m?.diasAte, 7);
    });

    test('o mês redondo cai no último dia quando o dia não existe', () {
      // Nascido em 31 de dezembro, o marco dos 14 meses cairia em 31 de
      // fevereiro. A data é grudada no último dia do mês, senão o marco
      // sumiria justamente nos meses curtos.
      //
      // A data escolhida é depois dos três primeiros meses de propósito:
      // antes disso as semanas chegam primeiro e escondem o caso.
      final ProximoMarco? m = CapsulePulse.proximoMarcoDe(
        DateTime(2026, 12, 31),
        DateTime(2028, 2, 20),
      );
      expect(m?.rotulo, '14 meses');
      expect(m?.quando, DateTime(2028, 2, 29));
    });

    test('sempre acha alguma coisa dentro do teto da varredura', () {
      // O maior intervalo entre dois marcos é de um mês para o outro. Se
      // algum dia isto falhar, é sinal de que a regra mudou.
      for (int d = 0; d < 800; d += 37) {
        final DateTime dia = nascimento.add(Duration(days: d));
        expect(marco(dia), isNotNull, reason: '$dia');
        expect(marco(dia)!.diasAte, lessThanOrEqualTo(31), reason: '$dia');
      }
    });
  });
}
