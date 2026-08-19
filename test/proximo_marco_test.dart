import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';

/// O próximo marco de desenvolvimento, e quanto falta para ele.
///
/// É o que o cartão da tela inicial anuncia. **Não é toda data redonda**, e a
/// diferença é o ponto: a linha do tempo marca todo mês, porque rolando o
/// histórico "22 meses" ajuda a se situar, mas um cartão que olha para a
/// frente e anuncia "22 meses, daqui a 12 dias" não anuncia nada. O que
/// acontece todo mês deixa de ser marco.
///
/// A lista é a que os pais usam para falar da criança: três meses, seis
/// meses, e daí em diante ano a ano.
void main() {
  final DateTime nascimento = DateTime(2026, 11, 2);

  ProximoMarco? marco(DateTime dia) =>
      CapsulePulse.proximoMarcoDe(nascimento, dia);

  group('a lista de marcos', () {
    test('é a que o pai usa para falar da criança', () {
      // A sequência inteira, do nascimento aos seis anos, lida um a um.
      final List<String> encontrados = <String>[];
      DateTime dia = nascimento;
      while (encontrados.length < 8) {
        final ProximoMarco m = marco(dia)!;
        encontrados.add(m.rotulo);
        dia = m.quando.add(const Duration(days: 1));
      }

      expect(encontrados, <String>[
        '3 meses',
        '6 meses',
        '1 ano',
        '2 anos',
        '3 anos',
        '4 anos',
        '5 anos',
        '6 anos',
      ]);
    });

    test('nenhum mês avulso entra no meio', () {
      // O defeito relatado: o cartão anunciava "22 meses, daqui a 12 dias".
      // Depois do primeiro ano só existem aniversários.
      DateTime dia = nascimento;
      for (int i = 0; i < 12; i++) {
        final ProximoMarco m = marco(dia)!;
        if (m.rotulo.contains('mes')) {
          expect(
            <String>['3 meses', '6 meses'],
            contains(m.rotulo),
            reason: 'Mês avulso virou marco: ${m.rotulo}',
          );
        }
        dia = m.quando.add(const Duration(days: 1));
      }
    });

    test('semana nenhuma é marco', () {
      // Elas continuam na linha do tempo, onde uma semana ainda é muita
      // coisa. Aqui, "1 semana, daqui a 6 dias" era ruído.
      for (int d = 0; d < 120; d++) {
        final ProximoMarco m = marco(nascimento.add(Duration(days: d)))!;
        expect(m.rotulo, isNot(contains('semana')), reason: 'dia $d');
      }
    });
  });

  group('quando o marco é hoje', () {
    test('o próprio dia conta como hoje, e não como o próximo', () {
      // Se a busca começasse amanhã, o cartão pularia o dia que interessa.
      final ProximoMarco? m = marco(DateTime(2027, 2, 2));
      expect(m?.rotulo, '3 meses');
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
    test('um dia antes dos três meses', () {
      final ProximoMarco? m = marco(DateTime(2027, 2, 1));
      expect(m?.rotulo, '3 meses');
      expect(m?.diasAte, 1);
    });

    test('logo depois de um marco, aponta para o seguinte', () {
      final ProximoMarco? m = marco(DateTime(2027, 2, 3));
      expect(m?.rotulo, '6 meses');
      expect(m?.quando, DateTime(2027, 5, 2));
    });

    test('passado o meio ano, o próximo é o aniversário', () {
      // Entre os seis meses e o primeiro ano não há nada, de propósito.
      final ProximoMarco? m = marco(DateTime(2027, 8, 10));
      expect(m?.rotulo, '1 ano');
      expect(m?.quando, DateTime(2027, 11, 2));
    });
  });

  group('as bordas', () {
    test('no próprio dia do nascimento, o marco é o dos três meses', () {
      // O nascimento não é marco: apontar para o próprio dia e dizer "é
      // hoje" não acrescenta nada a quem está com a criança no colo.
      final ProximoMarco? m = marco(nascimento);
      expect(m?.rotulo, '3 meses');
      expect(m?.quando, DateTime(2027, 2, 2));
    });

    test('o mês do marco cai no último dia quando o dia não existe', () {
      // Nascida em 30 de novembro, os três meses cairiam em 30 de fevereiro.
      // A data gruda no último dia do mês, senão o marco sumiria.
      final ProximoMarco? m = CapsulePulse.proximoMarcoDe(
        DateTime(2026, 11, 30),
        DateTime(2027, 2, 20),
      );
      expect(m?.rotulo, '3 meses');
      expect(m?.quando, DateTime(2027, 2, 28));
    });

    test('sempre acha um marco, por muitos anos que passem', () {
      for (int d = 0; d < 4000; d += 61) {
        final DateTime dia = nascimento.add(Duration(days: d));
        expect(marco(dia), isNotNull, reason: '$dia');
      }
    });

    test('a data do marco nunca é anterior a hoje', () {
      for (int d = 0; d < 2000; d += 13) {
        final DateTime dia = nascimento.add(Duration(days: d));
        final ProximoMarco m = marco(dia)!;
        expect(m.diasAte, greaterThanOrEqualTo(0), reason: '$dia');
      }
    });
  });

  group('o cartão nunca promete um dia que o histórico não celebra', () {
    test('todo marco é também uma data redonda da linha do tempo', () {
      // A regra que sustenta as duas telas. O cartão anuncia menos que a
      // linha do tempo marca, e isso é de propósito; o que não pode é
      // anunciar um dia que ela depois ignora.
      DateTime dia = nascimento;
      for (int i = 0; i < 10; i++) {
        final ProximoMarco m = marco(dia)!;
        expect(
          CapsulePulse.dataRedondaEm(nascimento, m.quando),
          m.rotulo,
          reason: 'O marco ${m.rotulo} não é data redonda em ${m.quando}',
        );
        dia = m.quando.add(const Duration(days: 1));
      }
    });
  });

  group('o rótulo', () {
    test('concorda em número', () {
      expect(CapsulePulse.rotuloDoMarco(3), '3 meses');
      expect(CapsulePulse.rotuloDoMarco(12), '1 ano');
      expect(CapsulePulse.rotuloDoMarco(24), '2 anos');
      expect(CapsulePulse.rotuloDoMarco(120), '10 anos');
    });
  });
}
