import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/mosaico.dart';

/// A conta do mosaico do acervo.
///
/// Cada foto mantém a própria proporção e o que se ajusta é a altura da
/// linha. É o desenho do Google Fotos, e o que ele resolve é real: numa
/// grade de quadrados iguais toda paisagem vira um pedaço do meio.
///
/// Testar isto como função pura é o ponto. Layout decidido dentro do `build`
/// só se confere olhando a tela, e olhar a tela é justamente o que não dá
/// para automatizar: dá para ver que ficou torto, não para provar que a
/// última linha de todo mês tem a altura certa.
void main() {
  /// Um item com data e proporção, que é tudo de que a conta precisa.
  ({DateTime quando, double prop}) foto(
    int ano,
    int mes,
    int dia, [
    double prop = 1,
  ]) => (quando: DateTime(ano, mes, dia), prop: prop);

  List<MesDoMosaico<({DateTime quando, double prop})>> montar(
    List<({DateTime quando, double prop})> itens, {
    double largura = 360,
    double alturaAlvo = 120,
    double espaco = 2,
  }) => mosaico<({DateTime quando, double prop})>(
    itens: itens,
    quando: (({DateTime quando, double prop}) i) => i.quando,
    proporcao: (({DateTime quando, double prop}) i) => i.prop,
    largura: largura,
    alturaAlvo: alturaAlvo,
    espaco: espaco,
  );

  group('o agrupamento por mês', () {
    test('separa meses diferentes', () {
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[
          foto(2027, 7, 20),
          foto(2027, 7, 2),
          foto(2027, 6, 30),
        ].cast(),
      );

      expect(r, hasLength(2));
      expect(r.first.mes, DateTime(2027, 7));
      expect(r.first.quantos, 2);
      expect(r.last.mes, DateTime(2027, 6));
    });

    test('o mesmo mês de anos diferentes não se junta', () {
      // O erro que agruparia julho de 2027 com julho de 2028. Num acervo que
      // atravessa décadas isso não é hipótese: é o segundo ano de uso.
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[foto(2028, 7, 5), foto(2027, 7, 5)].cast(),
      );

      expect(r, hasLength(2));
      expect(r.first.mes.year, 2028);
      expect(r.last.mes.year, 2027);
    });

    test('vem do mais recente para o mais antigo, mesmo desordenado', () {
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[foto(2027, 3, 1), foto(2027, 9, 1), foto(2027, 6, 1)].cast(),
      );

      expect(r.map((MesDoMosaico<Object?> m) => m.mes.month), <int>[9, 6, 3]);
    });

    test('sem itens, nenhum mês', () {
      expect(montar(<Object?>[].cast()), isEmpty);
    });
  });

  group('as linhas justificadas', () {
    test('uma linha cheia ocupa a largura exata', () {
      // A propriedade que define "justificado": somando as larguras e os
      // espaços entre elas, dá a largura disponível. Sem isto sobra ou falta
      // uma faixa na direita, e ela salta aos olhos porque se repete em toda
      // linha.
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[for (int i = 0; i < 12; i++) foto(2027, 7, 20)].cast(),
        largura: 360,
        alturaAlvo: 100,
        espaco: 2,
      );

      final List<LinhaDoMosaico<Object?>> linhas = r.single.linhas;
      expect(
        linhas.length,
        greaterThan(1),
        reason: 'precisa haver linha cheia',
      );

      // A última é a exceção conhecida, então fica de fora.
      for (final LinhaDoMosaico<Object?> linha in linhas.take(
        linhas.length - 1,
      )) {
        final double soma =
            linha.ladrilhos.fold<double>(
              0,
              (double s, LadrilhoDoMosaico<Object?> l) => s + l.largura,
            ) +
            2 * (linha.ladrilhos.length - 1);
        expect(soma, closeTo(360, 0.01));
      }
    });

    test('a linha nunca inclui um item que a afasta do alvo', () {
      // A invariante da quebra, e ela não é um número: entre fechar a linha
      // com o item que a derruba abaixo do alvo e fechar sem ele, ficando
      // acima, ganha a que erra menos.
      //
      // Foi este teste que pegou a primeira versão da conta, que fechava
      // sempre com o item dentro. Com três paisagens numa tela estreita a
      // linha caía a dois terços da altura pedida, e a diferença para a
      // linha de cima ficava gritante.
      //
      // Uma faixa fixa de altura não serviria: com fotos perto do limite de
      // 2,5 de proporção, duas por linha a 81 px é mesmo o melhor corte
      // disponível numa tela de 360. O que se pode exigir é a escolha, não
      // um valor.
      const double largura = 360;
      const double alvo = 110;
      const double espaco = 2;

      for (final double prop in <double>[0.5, 0.8, 1.0, 1.5, 2.2, 2.5]) {
        final List<MesDoMosaico<Object?>> r = montar(
          <Object?>[
            for (int i = 0; i < 20; i++) foto(2027, 7, 20, prop),
          ].cast(),
          largura: largura,
          alturaAlvo: alvo,
          espaco: espaco,
        );

        final List<LinhaDoMosaico<Object?>> linhas = r.single.linhas;
        for (final LinhaDoMosaico<Object?> linha in linhas.take(
          linhas.length - 1,
        )) {
          final int n = linha.ladrilhos.length;
          if (n < 2) continue;

          // A altura que esta mesma linha teria com um item a menos.
          final double semUltimo =
              (largura - espaco * (n - 2)) / (prop * (n - 1));

          expect(
            (linha.altura - alvo).abs(),
            lessThanOrEqualTo((semUltimo - alvo).abs() + 0.001),
            reason:
                'proporção $prop: a linha ficou em ${linha.altura} quando '
                'sem o último item ficaria em $semUltimo, mais perto de $alvo',
          );
        }
      }
    });

    test('a última linha não estica', () {
      // Uma foto sozinha no fim do mês viraria um pôster de largura inteira.
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[for (int i = 0; i < 5; i++) foto(2027, 7, 20)].cast(),
        largura: 360,
        alturaAlvo: 100,
      );

      final LinhaDoMosaico<Object?> ultima = r.single.linhas.last;
      expect(ultima.altura, 100);
    });

    test('uma foto só no mês fica no tamanho de miniatura', () {
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[foto(2027, 7, 20, 1.6)].cast(),
        alturaAlvo: 120,
      );

      final LadrilhoDoMosaico<Object?> unico =
          r.single.linhas.single.ladrilhos.single;
      expect(unico.altura, 120);
      expect(unico.largura, closeTo(192, 0.01));
      expect(unico.largura, lessThan(360), reason: 'não pode virar pôster');
    });

    test('nenhum ladrilho é mais largo que a tela', () {
      // Vale para toda linha, inclusive a última: um ladrilho mais largo que
      // a tela é recorte garantido, e num acervo de memórias recortar é
      // perder pedaço de foto.
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[
          for (int i = 0; i < 30; i++) foto(2027, 7, 20, 0.5 + i % 5 * 0.4),
        ].cast(),
        largura: 360,
      );

      for (final LinhaDoMosaico<Object?> linha in r.single.linhas) {
        for (final LadrilhoDoMosaico<Object?> l in linha.ladrilhos) {
          expect(l.largura, lessThanOrEqualTo(360.01));
        }
      }
    });

    test('todo item entra em exatamente uma linha', () {
      // A conta quebra linhas dentro de um laço, e é fácil perder o último
      // item ao fechar a linha. Aqui a soma tem de bater com a entrada.
      final List<MesDoMosaico<Object?>> r = montar(
        <Object?>[for (int i = 0; i < 23; i++) foto(2027, 7, 20, 1.3)].cast(),
      );

      final int total = r.single.linhas.fold<int>(
        0,
        (int s, LinhaDoMosaico<Object?> l) => s + l.ladrilhos.length,
      );
      expect(total, 23);
      expect(r.single.quantos, 23);
    });
  });

  group('a proporção de uma foto', () {
    test('sem dimensão gravada, quadrada', () {
      // O acervo antigo tem fotos enviadas antes de o aplicativo gravar
      // largura e altura. Elas não podem derrubar a conta.
      expect(proporcaoSegura(null, null), 1);
      expect(proporcaoSegura(0, 100), 1);
      expect(proporcaoSegura(100, 0), 1);
    });

    test('paisagem e retrato comuns passam intactos', () {
      expect(proporcaoSegura(1600, 1200), closeTo(4 / 3, 0.001));
      expect(proporcaoSegura(1200, 1600), closeTo(3 / 4, 0.001));
    });

    test('panorama e foto muito alta são contidos', () {
      // Um panorama de 6:1 sozinho preencheria a linha inteira e ficaria com
      // uma faixa de altura ridícula.
      expect(proporcaoSegura(6000, 1000), 2.5);
      expect(proporcaoSegura(1000, 6000), 0.5);
    });
  });

  group('as bordas', () {
    test('largura zero não trava nem devolve lixo', () {
      expect(montar(<Object?>[foto(2027, 7, 1)].cast(), largura: 0), isEmpty);
    });

    test('a entrada não é reordenada no lugar', () {
      // A lista vem de um provedor do Riverpod, e ordenar no lugar mexeria
      // no que outras telas estão lendo.
      final List<({DateTime quando, double prop})> entrada =
          <({DateTime quando, double prop})>[
            foto(2027, 1, 1),
            foto(2027, 9, 1),
          ];
      montar(entrada);
      expect(entrada.first.quando.month, 1);
    });
  });

  group('o mês que está na tela', () {
    // As faixas são medidas antes de desenhar, porque a lista é preguiçosa:
    // só existe o que está na tela, então perguntar a posição de um mês que
    // ainda não foi desenhado não tem resposta.
    final List<FaixaDeMes> faixas = <FaixaDeMes>[
      FaixaDeMes(mes: DateTime(2027, 9), inicio: 0, altura: 300),
      FaixaDeMes(mes: DateTime(2027, 8), inicio: 300, altura: 500),
      FaixaDeMes(mes: DateTime(2027, 7), inicio: 800, altura: 200),
    ];

    test('no topo, o primeiro mês', () {
      expect(mesEm(faixas, 0), DateTime(2027, 9));
    });

    test('no meio de uma faixa, o mês dela', () {
      expect(mesEm(faixas, 450), DateTime(2027, 8));
    });

    test('na fronteira, já vale o mês de baixo', () {
      // O cabeçalho encostou no topo da tela: é dele que a bolha fala.
      expect(mesEm(faixas, 300), DateTime(2027, 8));
      expect(mesEm(faixas, 800), DateTime(2027, 7));
    });

    test('esticando a lista para cima, a bolha não apaga', () {
      // Rolagem elástica passa dos dois lados, e uma bolha que some ao
      // esticar pisca sem motivo com o dedo ainda na tela.
      expect(mesEm(faixas, -80), DateTime(2027, 9));
    });

    test('esticando para baixo, continua no último', () {
      expect(mesEm(faixas, 5000), DateTime(2027, 7));
    });

    test('sem faixas, ninguém', () {
      expect(mesEm(<FaixaDeMes>[], 0), isNull);
    });

    test('um erro de ponto flutuante não faz o mês piscar', () {
      // A soma das alturas acumula erro ao longo de dezenas de meses. Sem
      // tolerância, o mês trocaria um pixel antes ou depois da linha.
      expect(mesEm(faixas, 299.9), DateTime(2027, 8));
    });
  });
}
