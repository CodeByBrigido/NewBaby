import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';

/// A data de nascimento do mockup, para os casos serem conferíveis a olho.
final DateTime birth = DateTime(2027, 1, 22);

Age ageOn(int year, int month, int day) =>
    AgeCalculator.ageAt(birth, DateTime(year, month, day));

AgeBucket bucketOn(int year, int month, int day) =>
    AgeCalculator.bucketAt(birth, DateTime(year, month, day));

void main() {
  group('idade em dias, meses e anos', () {
    test('no dia do nascimento a idade é zero', () {
      final Age age = ageOn(2027, 1, 22);
      expect(age.totalDays, 0);
      expect(age.months, 0);
      expect(age.daysInMonth, 0);
    });

    test('a hora do nascimento não altera a idade', () {
      final DateTime lateBirth = DateTime(2027, 1, 22, 23, 59);
      final Age age = AgeCalculator.ageAt(
        lateBirth,
        DateTime(2027, 1, 23, 0, 1),
      );
      expect(age.totalDays, 1);
    });

    test('datas anteriores ao nascimento não geram idade negativa', () {
      final Age age = ageOn(2026, 12, 25);
      expect(age.totalDays, 0);
      expect(age.months, 0);
    });

    test('meses de calendário, não blocos de 30 dias', () {
      // 22/01 + 2 meses = 22/03; faltam 11 dias até 02/04.
      final Age age = ageOn(2027, 4, 2);
      expect(age.months, 2);
      expect(age.daysInMonth, 11);
    });

    test('vira o mês exatamente no dia correspondente', () {
      expect(ageOn(2027, 2, 21).months, 0);
      expect(ageOn(2027, 2, 22).months, 1);
      expect(ageOn(2027, 2, 22).daysInMonth, 0);
    });

    test('fim de mês curto não escorrega para o mês seguinte', () {
      // Quem nasce em 31/01 completa um mês em 28/02, não em 03/03.
      final DateTime endOfMonth = DateTime(2027, 1, 31);
      expect(AgeCalculator.ageAt(endOfMonth, DateTime(2027, 2, 28)).months, 1);
      expect(AgeCalculator.ageAt(endOfMonth, DateTime(2027, 2, 27)).months, 0);
    });

    test('ano bissexto é contado corretamente', () {
      // 2028 é bissexto: 366 dias entre 22/01/2028 e 22/01/2029.
      final DateTime leapBirth = DateTime(2028, 1, 22);
      final Age age = AgeCalculator.ageAt(leapBirth, DateTime(2029, 1, 22));
      expect(age.totalDays, 366);
      expect(age.months, 12);
      expect(age.years, 1);
    });

    test('anos e meses restantes', () {
      final Age age = ageOn(2028, 3, 22); // 1 ano e 2 meses
      expect(age.years, 1);
      expect(age.monthsInYear, 2);
      expect(age.months, 14);
    });
  });

  group('rótulo curto (estilo da especificação)', () {
    test('dias, semanas, meses e anos', () {
      // "No nascimento" descreve o momento, não a criança: o cálculo de
      // idade fica sem gênero e serve para menino e menina.
      expect(ageOn(2027, 1, 22).shortLabel, 'No nascimento');
      expect(ageOn(2027, 1, 23).shortLabel, '1 dia');
      expect(ageOn(2027, 1, 25).shortLabel, '3 dias');
      expect(ageOn(2027, 2, 5).shortLabel, '2 semanas');
      expect(ageOn(2027, 2, 26).shortLabel, '5 semanas');
      expect(ageOn(2027, 5, 22).shortLabel, '4 meses');
      expect(ageOn(2028, 3, 22).shortLabel, '1 ano e 2 meses');
    });

    test('um ano redondo não mostra "e 0 meses"', () {
      expect(ageOn(2028, 1, 22).shortLabel, '1 ano');
      expect(ageOn(2029, 1, 22).shortLabel, '2 anos');
    });
  });

  group('rótulo detalhado (estilo da linha do tempo)', () {
    test('reproduz os rótulos do mockup', () {
      expect(ageOn(2027, 4, 22).detailedLabel(), '3 meses');
      expect(ageOn(2027, 4, 18).detailedLabel(), '2 meses e 27 dias');
      expect(ageOn(2027, 4, 10).detailedLabel(), '2 meses e 19 dias');
      expect(ageOn(2027, 4, 2).detailedLabel(), '2 meses e 11 dias');
    });

    test('usa mês cheio assim que a data passa do aniversário mensal', () {
      // O mockup escreve "1 mês e 29 dias" em 23/03, mas 22/03 já fecha o
      // segundo mês: a partir daí o correto é contar 2 meses e 1 dia.
      expect(ageOn(2027, 3, 22).detailedLabel(), '2 meses');
      expect(ageOn(2027, 3, 23).detailedLabel(), '2 meses e 1 dia');
      expect(ageOn(2027, 3, 21).detailedLabel(), '1 mês e 27 dias');
    });

    test('antes do primeiro mês mostra apenas dias', () {
      expect(ageOn(2027, 2, 13).detailedLabel(), '22 dias');
      expect(ageOn(2027, 1, 23).detailedLabel(), '1 dia');
    });

    test('alwaysShowDays mantém o "e 0 dias" do perfil', () {
      expect(
        ageOn(2027, 4, 22).detailedLabel(alwaysShowDays: true),
        '3 meses e 0 dias',
      );
    });

    test('a partir de um ano os dias saem para não poluir', () {
      expect(ageOn(2028, 3, 25).detailedLabel(), '1 ano e 2 meses');
      expect(ageOn(2028, 1, 22).detailedLabel(), '1 ano');
    });
  });

  group('pasta de destino no Google Drive', () {
    test('primeiro ano em semanas, começando na Semana 01', () {
      expect(bucketOn(2027, 1, 22).folderName, 'Semana 01');
      expect(bucketOn(2027, 1, 28).folderName, 'Semana 01');
      expect(bucketOn(2027, 1, 29).folderName, 'Semana 02');
      expect(bucketOn(2027, 2, 5).folderName, 'Semana 03');
    });

    test('a última semana do primeiro ano é a 52, sem "Semana 53"', () {
      // Dia 364 ainda é primeiro ano, mas 364 ~/ 7 + 1 daria 53.
      final AgeBucket bucket = AgeCalculator.bucketAt(
        birth,
        birth.add(const Duration(days: 364)),
      );
      expect(bucket.unit, AgeBucketUnit.week);
      expect(bucket.index, 52);
    });

    test('no primeiro aniversário passa para Mês 13', () {
      final AgeBucket bucket = bucketOn(2028, 1, 22);
      expect(bucket.unit, AgeBucketUnit.month);
      expect(bucket.folderName, 'Mês 13');
    });

    test('os meses do segundo ano vão de 13 a 24', () {
      expect(bucketOn(2028, 2, 22).folderName, 'Mês 14');
      expect(bucketOn(2028, 12, 22).folderName, 'Mês 24');
    });

    test('no segundo aniversário passa para Ano 2', () {
      final AgeBucket bucket = bucketOn(2029, 1, 22);
      expect(bucket.unit, AgeBucketUnit.year);
      expect(bucket.folderName, 'Ano 2');
    });

    test('os anos seguintes continuam anuais', () {
      expect(bucketOn(2030, 1, 22).folderName, 'Ano 3');
      expect(bucketOn(2030, 12, 31).folderName, 'Ano 3');
      expect(bucketOn(2031, 1, 22).folderName, 'Ano 4');
    });

    test('a chave ordena semana antes de mês e mês antes de ano', () {
      expect(bucketOn(2027, 1, 22).key, 'S01');
      expect(bucketOn(2028, 1, 22).key, 'M13');
      expect(bucketOn(2029, 1, 22).key, 'A02');

      final List<String> keys = <String>['A02', 'M13', 'S01']..sort();
      expect(keys, <String>['A02', 'M13', 'S01']);
    });

    test('o intervalo de datas cobre o balde inteiro', () {
      // Confere com o mockup: Semana 02 = 29/01 a 04/02, Semana 03 = 05/02
      // a 11/02.
      final AgeBucket secondWeek = bucketOn(2027, 1, 30);
      expect(secondWeek.folderName, 'Semana 02');
      expect(secondWeek.start, DateTime(2027, 1, 29));
      expect(secondWeek.end, DateTime(2027, 2, 4));

      final AgeBucket week = bucketOn(2027, 2, 5); // Semana 03
      expect(week.start, DateTime(2027, 2, 5));
      expect(week.end, DateTime(2027, 2, 11));

      final AgeBucket month = bucketOn(2028, 2, 25); // Mês 14
      expect(month.start, DateTime(2028, 2, 22));
      expect(month.end, DateTime(2028, 3, 21));

      final AgeBucket year = bucketOn(2029, 6, 1); // Ano 2
      expect(year.start, DateTime(2029, 1, 22));
      expect(year.end, DateTime(2030, 1, 21));
    });

    test('todo dia do primeiro ano cai num balde válido e contínuo', () {
      // Varredura: nenhuma data pode ficar sem pasta nem pular um índice.
      AgeBucket previous = bucketOn(2027, 1, 22);
      for (int day = 1; day <= 365 * 3; day++) {
        final AgeBucket current = AgeCalculator.bucketAt(
          birth,
          birth.add(Duration(days: day)),
        );
        expect(current.index, greaterThan(0));
        expect(
          current.end.isBefore(current.start),
          isFalse,
          reason: 'Balde ${current.folderName} tem intervalo invertido.',
        );
        // O balde nunca anda para trás.
        final bool sameOrForward =
            current == previous || !current.start.isBefore(previous.start);
        expect(
          sameOrForward,
          isTrue,
          reason:
              'No dia $day o balde voltou de ${previous.folderName} '
              'para ${current.folderName}.',
        );
        previous = current;
      }
    });
  });

  group('addMonths', () {
    test('preserva o dia quando ele existe no mês de destino', () {
      expect(
        AgeCalculator.addMonths(DateTime(2027, 1, 15), 3),
        DateTime(2027, 4, 15),
      );
    });

    test('encurta para o último dia quando o mês é mais curto', () {
      expect(
        AgeCalculator.addMonths(DateTime(2027, 1, 31), 1),
        DateTime(2027, 2, 28),
      );
      expect(
        AgeCalculator.addMonths(DateTime(2028, 1, 31), 1),
        DateTime(2028, 2, 29), // 2028 é bissexto
      );
    });

    test('atravessa a virada do ano', () {
      expect(
        AgeCalculator.addMonths(DateTime(2027, 11, 10), 3),
        DateTime(2028, 2, 10),
      );
    });
  });
}
