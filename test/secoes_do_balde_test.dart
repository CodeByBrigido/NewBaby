import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/core/utils/secoes_do_balde.dart';

/// As divisões internas de uma pasta de idade.
///
/// A contagem é relativa à pasta, e é aí que mora o erro fácil: dentro do
/// `Mês 14` a primeira semana é a `Semana 1`, e não a `Semana 57`. Quem
/// abriu a pasta do mês está pensando naquele mês.
void main() {
  final DateTime nascimento = DateTime(2027, 1, 22);

  AgeBucket baldeDe(DateTime quando) =>
      AgeCalculator.bucketAt(nascimento, quando);

  List<SecaoDoBalde<DateTime>> secoes(AgeBucket balde, List<DateTime> datas) =>
      secoesDoBalde<DateTime>(
        balde: balde,
        itens: datas,
        quando: (DateTime d) => d,
      );

  group('a pasta de semana', () {
    test('não se divide', () {
      // Sete dias não têm o que separar, e títulos ali só entrariam entre
      // fotos vizinhas.
      final AgeBucket balde = baldeDe(DateTime(2027, 2, 10));
      expect(balde.unit, AgeBucketUnit.week);

      final List<SecaoDoBalde<DateTime>> r = secoes(balde, <DateTime>[
        DateTime(2027, 2, 10),
        DateTime(2027, 2, 12),
      ]);
      expect(r, hasLength(1));
      expect(r.single.titulo, isEmpty);
      expect(r.single.itens, hasLength(2));
    });
  });

  group('a pasta de mês', () {
    late AgeBucket mes;

    setUp(() {
      // Aos 12 meses completos a criança vive o 13º mês.
      mes = baldeDe(DateTime(2028, 1, 25));
      expect(mes.unit, AgeBucketUnit.month);
    });

    test('divide por semana daquele mês, começando em 1', () {
      final List<SecaoDoBalde<DateTime>> r = secoes(mes, <DateTime>[
        mes.start,
        mes.start.add(const Duration(days: 3)),
        mes.start.add(const Duration(days: 8)),
        mes.start.add(const Duration(days: 15)),
      ]);

      expect(r.map((SecaoDoBalde<DateTime> s) => s.titulo), <String>[
        'Semana 1',
        'Semana 2',
        'Semana 3',
      ]);
      expect(r.first.itens, hasLength(2));
    });

    test('a contagem é da pasta, e não da vida inteira', () {
      // O erro fácil: usar o índice global da semana e escrever "Semana 57"
      // dentro do Mês 13.
      final List<SecaoDoBalde<DateTime>> r = secoes(mes, <DateTime>[mes.start]);
      expect(r.single.titulo, 'Semana 1');
    });

    test('semana sem nada não vira seção vazia', () {
      // Uma semana em que ninguém registrou não é informação, é buraco.
      final List<SecaoDoBalde<DateTime>> r = secoes(mes, <DateTime>[
        mes.start,
        mes.start.add(const Duration(days: 21)),
      ]);
      expect(r.map((SecaoDoBalde<DateTime> s) => s.titulo), <String>[
        'Semana 1',
        'Semana 4',
      ]);
    });

    test('as seções saem em ordem, mesmo com o conteúdo embaralhado', () {
      final List<SecaoDoBalde<DateTime>> r = secoes(mes, <DateTime>[
        mes.start.add(const Duration(days: 15)),
        mes.start,
        mes.start.add(const Duration(days: 8)),
      ]);
      expect(r.map((SecaoDoBalde<DateTime> s) => s.titulo), <String>[
        'Semana 1',
        'Semana 2',
        'Semana 3',
      ]);
    });
  });

  group('a pasta de ano', () {
    late AgeBucket ano;

    setUp(() {
      ano = baldeDe(DateTime(2030, 6, 10));
      expect(ano.unit, AgeBucketUnit.year);
    });

    test('divide por mês daquele ano, começando em 1', () {
      final List<SecaoDoBalde<DateTime>> r = secoes(ano, <DateTime>[
        ano.start,
        AgeCalculator.addMonths(ano.start, 1),
        AgeCalculator.addMonths(ano.start, 5),
      ]);
      expect(r.map((SecaoDoBalde<DateTime> s) => s.titulo), <String>[
        'Mês 1',
        'Mês 2',
        'Mês 6',
      ]);
    });

    test('o mês vira o seguinte só depois do mesmo dia', () {
      // Um mês de vida não é trinta dias: vira no dia do aniversário mensal.
      final DateTime umDiaAntes = AgeCalculator.addMonths(
        ano.start,
        1,
      ).subtract(const Duration(days: 1));
      final List<SecaoDoBalde<DateTime>> r = secoes(ano, <DateTime>[
        umDiaAntes,
      ]);
      expect(r.single.titulo, 'Mês 1');
    });
  });

  group('as bordas', () {
    test('sem itens, nenhuma seção', () {
      final AgeBucket mes = baldeDe(DateTime(2028, 1, 25));
      expect(secoes(mes, <DateTime>[]), isEmpty);
    });

    test(
      'data anterior à pasta cai na primeira seção, e não numa negativa',
      () {
        // Acontece de verdade: a data de uma memória pode ser corrigida à mão
        // depois de o arquivo já estar guardado, e o balde antigo continua
        // sendo o dono do arquivo no Drive.
        final AgeBucket mes = baldeDe(DateTime(2028, 1, 25));
        final List<SecaoDoBalde<DateTime>> r = secoes(mes, <DateTime>[
          mes.start.subtract(const Duration(days: 40)),
        ]);
        expect(r.single.titulo, 'Semana 1');
      },
    );

    test('data posterior à pasta não derruba nada', () {
      final AgeBucket mes = baldeDe(DateTime(2028, 1, 25));
      final List<SecaoDoBalde<DateTime>> r = secoes(mes, <DateTime>[
        mes.end.add(const Duration(days: 90)),
      ]);
      expect(r, hasLength(1));
      expect(r.single.titulo, startsWith('Semana '));
    });
  });
}
