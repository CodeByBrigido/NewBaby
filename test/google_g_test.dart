import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/features/common/google_g.dart';

/// A marca do Google, desenhada a partir dos caminhos oficiais.
///
/// A diretriz de identidade do Google proíbe redesenhar o símbolo, então o
/// que está no projeto é o `d` de cada `<path>` do arquivo dele, copiado sem
/// alteração. O que estes testes protegem é a leitura desses caminhos: um
/// erro no interpretador não lança exceção nenhuma, só entorta a marca, e
/// marca torta passa por revisão de código sem ninguém notar.
void main() {
  /// O retângulo que o caminho ocupa, que é o jeito de conferir a forma sem
  /// comparar pixel.
  Rect caixa(String d) => interpretarCaminhoSvg(d).getBounds();

  group('o interpretador de caminho', () {
    test('move e desenha linha, em absoluto', () {
      expect(caixa('M10 10L30 40'), const Rect.fromLTRB(10, 10, 30, 40));
    });

    test('minúsculo é relativo ao ponto de agora', () {
      // `l` anda a partir de onde parou; se fosse tratado como absoluto, a
      // caixa terminaria em 5,5 em vez de 15,15.
      expect(caixa('M10 10l5 5'), const Rect.fromLTRB(10, 10, 15, 15));
    });

    test('h e v andam num eixo só', () {
      expect(caixa('M0 0h20v10'), const Rect.fromLTRB(0, 0, 20, 10));
      expect(caixa('M5 5H25V15'), const Rect.fromLTRB(5, 5, 25, 15));
    });

    test('o fecho volta ao início', () {
      final Path p = interpretarCaminhoSvg('M0 0h10v10h-10z');
      expect(p.contains(const Offset(5, 5)), isTrue);
      expect(p.contains(const Offset(15, 5)), isFalse);
    });

    test('números colados e sem zero à esquerda são lidos', () {
      // Os caminhos do Google vêm assim: `.15`, `-.38`, `9.02`. Um leitor
      // ingênuo que separasse por espaço perderia metade dos valores.
      expect(caixa('M0 0l.5.5'), const Rect.fromLTRB(0, 0, 0.5, 0.5));
      expect(caixa('M1 1l-.5-.5'), const Rect.fromLTRB(0.5, 0.5, 1, 1));
    });

    test('vários pares no mesmo comando viram vários segmentos', () {
      expect(caixa('M0 0L10 0 10 10'), const Rect.fromLTRB(0, 0, 10, 10));
    });

    test('a curva suave reflete o controle anterior', () {
      // `s` sem reflexão desenharia uma curva diferente, e a barriga do "G"
      // sairia achatada. A caixa denuncia: com reflexão a curva sobe.
      final Rect comReflexao = caixa('M0 0c0 -10 10 -10 10 0s10 10 10 0');
      expect(comReflexao.top, lessThan(0));
      expect(comReflexao.right, closeTo(20, 0.01));
    });
  });

  group('a marca montada', () {
    test('são quatro partes, uma por cor oficial', () {
      // Se alguém acrescentar ou remover um caminho, a marca deixa de ser a
      // do Google, e é isso que a diretriz não permite.
      expect(GoogleG.partesParaTeste, hasLength(4));
      expect(
        GoogleG.partesParaTeste.map(((String, Color) p) => p.$2).toList(),
        <Color>[
          Color(0xFFEA4335),
          Color(0xFF4285F4),
          Color(0xFFFBBC05),
          Color(0xFF34A853),
        ],
      );
    });

    test('cada parte cabe no quadro de 48 que o Google declara', () {
      // Um caminho que estoure o quadro seria sinal de cópia truncada: o
      // desenho apareceria cortado no aplicativo.
      for (final (String d, Color cor) in GoogleG.partesParaTeste) {
        final Rect r = caixa(d);
        expect(r.left, greaterThanOrEqualTo(-0.01), reason: '$cor');
        expect(r.top, greaterThanOrEqualTo(-0.01), reason: '$cor');
        expect(r.right, lessThanOrEqualTo(48.01), reason: '$cor');
        expect(r.bottom, lessThanOrEqualTo(48.01), reason: '$cor');
      }
    });

    test('as quatro juntas ocupam o quadro que o Google desenhou', () {
      // A marca vai de 0 a 46,98 na horizontal e de 0 a 48 na vertical. A
      // coluna que falta à direita não é erro de cópia: o arquivo do Google
      // tem um quinto caminho, `fill="none"`, que existe só para dar 48 de
      // largura ao SVG. Ele não é desenhado, e por isso não está aqui.
      //
      // Se alguma das quatro partes sumisse, a união encolheria, e a marca
      // apareceria incompleta sem erro nenhum.
      Rect uniao = caixa(GoogleG.partesParaTeste.first.$1);
      for (final (String d, Color _) in GoogleG.partesParaTeste.skip(1)) {
        uniao = uniao.expandToInclude(caixa(d));
      }
      expect(uniao.left, closeTo(0, 0.1));
      expect(uniao.top, closeTo(0, 0.1));
      expect(uniao.right, closeTo(46.98, 0.1));
      expect(uniao.bottom, closeTo(48, 0.1));
    });

    testWidgets('desenha no tamanho pedido', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Center(child: GoogleG(size: 32))),
      );
      expect(tester.getSize(find.byType(GoogleG)), const Size(32, 32));
    });
  });
}
