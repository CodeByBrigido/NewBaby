import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/features/common/widgets.dart';

/// O cartão de Informações do bebê.
///
/// O pedido: a data de nascimento e a idade em uma linha só. O caminho até
/// lá teve duas tentativas erradas, e é por isso que este teste mede em vez
/// de conferir a aparência de olho.
///
/// A primeira: rótulo à esquerda, valor à direita. Não cabia. Os rótulos
/// daqui são longos ("Data de nascimento", "Altura ao nascer") e ocupavam
/// 216 dos 288 px do cartão, deixando menos de sessenta para o valor.
///
/// A segunda: a mesma coisa com `maxLines: 1`. Aí a data parava de quebrar e
/// passava a sair truncada com reticências, o que é pior: quebrar espreme o
/// dado, truncar esconde. E nada acusa, porque o widget não dá erro. Foi este
/// teste que pegou: dentro do `SoftCard` sobram 248 px num telefone de 320,
/// e `10 de abril de 2026` precisa de 265.
///
/// Por isso a garantia de linha única vale para 360 dp, que é o telefone
/// comum, e a de nunca truncar vale para qualquer largura.
void main() {
  /// O texto mais longo de cada campo que precisa caber numa linha.
  const String dataPorExtenso = '10 de abril de 2026';
  const String idadeMaisLonga = '20 anos e 11 meses';

  Future<void> montar(WidgetTester tester, {required double dp}) {
    tester.view.physicalSize = Size(dp * 3, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(AppPalette.girl),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(Space.x20),
            child: SoftCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _linha(S.birthDate, dataPorExtenso),
                  const Divider(height: 26),
                  _linha(S.currentAge, idadeMaisLonga),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('num telefone comum, de 360 dp', () {
    testWidgets('a data de nascimento cabe numa linha', (
      WidgetTester tester,
    ) async {
      await montar(tester, dp: 360);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text(dataPorExtenso)).height, 20);
    });

    testWidgets('a idade cabe numa linha', (WidgetTester tester) async {
      await montar(tester, dp: 360);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text(idadeMaisLonga)).height, 20);
    });
  });

  for (final double dp in <double>[360, 320]) {
    group('num telefone de ${dp.toInt()} dp', () {
      testWidgets('e nenhuma delas sai truncada', (WidgetTester tester) async {
        // Linha única obtida com reticências passaria no teste de altura e
        // esconderia metade do dado, sem erro nenhum no console.
        //
        // A prova é comparar a altura desenhada com a altura de que o texto
        // precisa naquela largura. Se o texto pede duas linhas e a caixa tem
        // uma, alguma coisa foi cortada. Quebrar em duas linhas passa, porque
        // ali nada se perde.
        await montar(tester, dp: dp);
        await tester.pumpAndSettle();

        for (final String valor in <String>[dataPorExtenso, idadeMaisLonga]) {
          final RenderBox caixa = tester.renderObject<RenderBox>(
            find.text(valor),
          );
          final TextPainter medidor = TextPainter(
            text: TextSpan(
              text: valor,
              style: tester.widget<Text>(find.text(valor)).style,
            ),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: caixa.size.width);

          expect(
            caixa.size.height,
            greaterThanOrEqualTo(medidor.height),
            reason: '"$valor" saiu cortado em $dp dp',
          );
        }
      });
    });
  }
}

/// A mesma composição de `_Row`, que é privada da tela.
Widget _linha(String label, String valor) => Builder(
  builder: (BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text(label, style: text.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: Space.x4),
        Text(valor, style: text.titleSmall, textAlign: TextAlign.center),
      ],
    );
  },
);
