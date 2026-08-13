import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/models/baby_gender.dart';

/// O tamanho do rótulo do campo, medido na tela.
///
/// O Flutter desenha o rótulo flutuante com uma **transformação** de 75%
/// aplicada por cima do estilo, e não com uma fonte menor. Isso significa
/// que conferir `fontSize` no tema não prova nada sobre o que a pessoa vê:
/// foi assim que "Título" e "Mensagem" chegaram a 9,75 px sem nenhum teste
/// reclamar.
///
/// Este arquivo mede o pixel: pega a escala real da matriz de transformação
/// do texto pintado e multiplica pelo tamanho da fonte.
void main() {
  /// O tamanho com que [rotulo] é realmente pintado.
  double tamanhoNaTela(WidgetTester tester, String rotulo) {
    final RenderParagraph paragrafo = tester.renderObject<RenderParagraph>(
      find.text(rotulo),
    );
    final double declarado = paragrafo.text.style!.fontSize!;
    // A escala horizontal da matriz acumulada até a raiz.
    final double escala = paragrafo.getTransformTo(null).storage[0];
    return declarado * escala;
  }

  Future<void> montar(WidgetTester tester, {required String rotulo}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(AppPalette.of(BabyGender.girl)),
        home: Scaffold(
          body: TextField(decoration: InputDecoration(labelText: rotulo)),
        ),
      ),
    );
  }

  testWidgets('o rótulo é pintado com 14 px, e não com 9,75', (
    WidgetTester tester,
  ) async {
    await montar(tester, rotulo: 'Título');
    await tester.pumpAndSettle();

    expect(tamanhoNaTela(tester, 'Título'), closeTo(14, 0.01));
  });

  testWidgets('vale para o campo de várias linhas também', (
    WidgetTester tester,
  ) async {
    // "Mensagem" é o campo da carta, e é o que o texto longo mais usa.
    await montar(tester, rotulo: 'Mensagem');
    await tester.pumpAndSettle();

    expect(tamanhoNaTela(tester, 'Mensagem'), closeTo(14, 0.01));
  });

  testWidgets('nenhum rótulo cai abaixo do menor tamanho da escala', (
    WidgetTester tester,
  ) async {
    await montar(tester, rotulo: 'Peso ao nascer (opcional)');
    await tester.pumpAndSettle();

    final ThemeData tema = AppTheme.build(AppPalette.of(BabyGender.girl));
    expect(
      tamanhoNaTela(tester, 'Peso ao nascer (opcional)'),
      greaterThanOrEqualTo(tema.textTheme.bodySmall!.fontSize!),
    );
  });
}
