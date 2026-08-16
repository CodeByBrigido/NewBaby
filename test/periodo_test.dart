import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/utils/periodo.dart';

/// Os períodos da linha do tempo: ano, mês e semana.
///
/// A escolha troca a lente sobre o mesmo acervo, e o que erra fácil aqui são
/// as bordas do calendário: a semana que cruza a virada do mês, o janeiro de
/// dois anos diferentes, o domingo que pertence à semana anterior.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('o começo do período', () {
    test('o ano começa em primeiro de janeiro', () {
      expect(
        inicioDoPeriodo(DateTime(2027, 7, 20), Periodo.ano),
        DateTime(2027),
      );
    });

    test('o mês começa no dia um', () {
      expect(
        inicioDoPeriodo(DateTime(2027, 7, 20), Periodo.mes),
        DateTime(2027, 7),
      );
    });

    test('a semana começa na segunda', () {
      // 22/07/2027 é uma quinta. A segunda daquela semana é dia 19.
      expect(DateTime(2027, 7, 22).weekday, DateTime.thursday);
      expect(
        inicioDoPeriodo(DateTime(2027, 7, 22), Periodo.semana),
        DateTime(2027, 7, 19),
      );
    });

    test('o domingo pertence à semana que começou na segunda anterior', () {
      // O erro clássico, porque `DateTime.sunday` é 7 e não 0: sem cuidado,
      // o domingo vira o começo da semana seguinte e fica sozinho num
      // cabeçalho só dele.
      final DateTime domingo = DateTime(2027, 7, 25);
      expect(domingo.weekday, DateTime.sunday);
      expect(inicioDoPeriodo(domingo, Periodo.semana), DateTime(2027, 7, 19));
    });

    test('a hora do dia não muda o período', () {
      expect(
        inicioDoPeriodo(DateTime(2027, 7, 22, 23, 59), Periodo.semana),
        inicioDoPeriodo(DateTime(2027, 7, 22, 0, 1), Periodo.semana),
      );
    });
  });

  group('o texto do cabeçalho', () {
    test('o ano é só o número', () {
      expect(rotuloDoPeriodo(DateTime(2027), Periodo.ano), '2027');
    });

    test('o mês vem sempre com o ano', () {
      // "Maio" sozinho é a mesma palavra em vinte anos diferentes.
      expect(rotuloDoPeriodo(DateTime(2027, 5), Periodo.mes), 'Maio de 2027');
    });

    test('a semana mostra as duas pontas', () {
      expect(
        rotuloDoPeriodo(DateTime(2027, 7, 19), Periodo.semana),
        '19 a 25 de julho de 2027',
      );
    });

    test('a semana que cruza o mês diz os dois meses', () {
      // Sem isto a primeira data ficaria dizendo um mês que não é o dela.
      expect(
        rotuloDoPeriodo(DateTime(2027, 8, 30), Periodo.semana),
        '30 de agosto a 5 de setembro de 2027',
      );
    });
  });

  group('o fatiamento', () {
    List<FatiaDoTempo<DateTime>> fatiar(
      List<DateTime> datas,
      Periodo periodo,
    ) => fatiarPorPeriodo<DateTime>(
      itens: datas,
      quando: (DateTime d) => d,
      periodo: periodo,
    );

    test('junta o que cai no mesmo período', () {
      final List<FatiaDoTempo<DateTime>> r = fatiar(<DateTime>[
        DateTime(2027, 5, 2),
        DateTime(2027, 5, 28),
        DateTime(2027, 4, 30),
      ], Periodo.mes);

      expect(r, hasLength(2));
      expect(r.first.itens, hasLength(2));
      expect(r.first.rotulo, 'Maio de 2027');
    });

    test('o mesmo mês de anos diferentes não se junta', () {
      final List<FatiaDoTempo<DateTime>> r = fatiar(<DateTime>[
        DateTime(2028, 1, 5),
        DateTime(2027, 1, 5),
      ], Periodo.mes);
      expect(r, hasLength(2));
    });

    test('vem do mais recente para o mais antigo', () {
      final List<FatiaDoTempo<DateTime>> r = fatiar(<DateTime>[
        DateTime(2027, 3, 1),
        DateTime(2027, 9, 1),
        DateTime(2027, 6, 1),
      ], Periodo.mes);
      expect(r.map((FatiaDoTempo<DateTime> f) => f.inicio.month), <int>[
        9,
        6,
        3,
      ]);
    });

    test('dentro do período também, do mais recente para o mais antigo', () {
      final List<FatiaDoTempo<DateTime>> r = fatiar(<DateTime>[
        DateTime(2027, 5, 2),
        DateTime(2027, 5, 28),
        DateTime(2027, 5, 15),
      ], Periodo.mes);
      expect(r.single.itens.map((DateTime d) => d.day), <int>[28, 15, 2]);
    });

    test('trocar a lente reagrupa o mesmo acervo', () {
      // A propriedade que faz o menu valer a pena: nada some ao trocar de
      // período, só muda o tamanho da gaveta.
      final List<DateTime> datas = <DateTime>[
        DateTime(2027, 1, 5),
        DateTime(2027, 6, 20),
        DateTime(2027, 6, 22),
        DateTime(2028, 2, 3),
      ];

      for (final Periodo p in Periodo.values) {
        final int total = fatiar(
          datas,
          p,
        ).fold<int>(0, (int s, FatiaDoTempo<DateTime> f) => s + f.itens.length);
        expect(total, datas.length, reason: p.name);
      }

      expect(fatiar(datas, Periodo.ano), hasLength(2));
      expect(fatiar(datas, Periodo.mes), hasLength(3));
      // Quatro, e não três: 20/06 é domingo, então cai na semana que começou
      // em 14/06, separado do dia 22 que já é da semana seguinte. Escrevi
      // três aqui na primeira vez, e é exatamente o engano que a regra do
      // domingo existe para evitar.
      expect(fatiar(datas, Periodo.semana), hasLength(4));
    });

    test('sem itens, nenhuma fatia', () {
      expect(fatiar(<DateTime>[], Periodo.mes), isEmpty);
    });
  });
}
