import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/special_date.dart';

/// As datas móveis do calendário brasileiro.
///
/// Conferidas contra o calendário de verdade, ano a ano. Um erro aqui não
/// derruba nada: só faz o aplicativo lembrar do primeiro Natal na data
/// errada, e data errada é pior que data nenhuma, porque estraga a
/// confiança em tudo o mais que ele diz.
void main() {
  group('Páscoa', () {
    test('bate com o calendário', () {
      final Map<int, DateTime> conhecidas = <int, DateTime>{
        2024: DateTime(2024, 3, 31),
        2025: DateTime(2025, 4, 20),
        2026: DateTime(2026, 4, 5),
        2027: DateTime(2027, 3, 28),
        2028: DateTime(2028, 4, 16),
        2029: DateTime(2029, 4, 1),
        2030: DateTime(2030, 4, 21),
        2038: DateTime(2038, 4, 25),
      };
      conhecidas.forEach((int ano, DateTime dia) {
        expect(SpecialDate.pascoa.inYear(ano), dia, reason: 'Páscoa de $ano');
      });
    });

    test('cai sempre num domingo', () {
      for (int ano = 2026; ano <= 2060; ano++) {
        expect(
          SpecialDate.pascoa.inYear(ano).weekday,
          DateTime.sunday,
          reason: 'Páscoa de $ano',
        );
      }
    });
  });

  group('Carnaval', () {
    test('é a terça 47 dias antes da Páscoa', () {
      expect(SpecialDate.carnaval.inYear(2026), DateTime(2026, 2, 17));
      expect(SpecialDate.carnaval.inYear(2027), DateTime(2027, 2, 9));
      expect(SpecialDate.carnaval.inYear(2028), DateTime(2028, 2, 29));
    });

    test('cai sempre numa terça', () {
      for (int ano = 2026; ano <= 2060; ano++) {
        expect(
          SpecialDate.carnaval.inYear(ano).weekday,
          DateTime.tuesday,
          reason: 'Carnaval de $ano',
        );
      }
    });
  });

  group('segundo domingo', () {
    test('Dia das Mães', () {
      expect(SpecialDate.diaDasMaes.inYear(2026), DateTime(2026, 5, 10));
      expect(SpecialDate.diaDasMaes.inYear(2027), DateTime(2027, 5, 9));
      expect(SpecialDate.diaDasMaes.inYear(2028), DateTime(2028, 5, 14));
    });

    test('Dia dos Pais', () {
      expect(SpecialDate.diaDosPais.inYear(2026), DateTime(2026, 8, 9));
      expect(SpecialDate.diaDosPais.inYear(2027), DateTime(2027, 8, 8));
    });

    test('sempre no segundo domingo, nunca no primeiro nem no terceiro', () {
      for (int ano = 2026; ano <= 2060; ano++) {
        final DateTime maes = SpecialDate.diaDasMaes.inYear(ano);
        expect(maes.weekday, DateTime.sunday);
        expect(
          maes.day,
          inInclusiveRange(8, 14),
          reason: 'O segundo domingo cai sempre entre 8 e 14. Ano $ano.',
        );
      }
    });
  });

  group('datas fixas', () {
    test('Natal e Ano Novo não se movem', () {
      expect(SpecialDate.natal.inYear(2026), DateTime(2026, 12, 25));
      expect(SpecialDate.anoNovo.inYear(2026), DateTime(2026, 1, 1));
    });
  });

  group('a próxima ocorrência', () {
    test('inclui o próprio dia', () {
      expect(
        SpecialDate.natal.nextFrom(DateTime(2026, 12, 25)),
        DateTime(2026, 12, 25),
      );
    });

    test('passa para o ano seguinte depois da data', () {
      expect(
        SpecialDate.natal.nextFrom(DateTime(2026, 12, 26)),
        DateTime(2027, 12, 25),
      );
    });

    test('a hora do dia não desloca a conta', () {
      expect(
        SpecialDate.natal.nextFrom(DateTime(2026, 12, 25, 23, 59)),
        DateTime(2026, 12, 25),
      );
    });

    test('funciona para as datas móveis também', () {
      // Depois do Carnaval de 2026 (17/02), o próximo é o de 2027 (09/02).
      expect(
        SpecialDate.carnaval.nextFrom(DateTime(2026, 3, 1)),
        DateTime(2027, 2, 9),
      );
    });
  });
}
