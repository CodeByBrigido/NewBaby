import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/features/common/widgets.dart';

import 'fonte_de_verdade.dart';

/// O cartão de Informações do bebê.
///
/// O pedido: a data de nascimento e a idade em uma linha só, com os dias.
///
/// **Este teste carrega a fonte de verdade, e sem isso ele mentiria.** O
/// `flutter test` desenha com uma fonte substituta em que todo caractere
/// ocupa um em: `i` e `W` medem igual. Nela a idade completa parecia pedir
/// 378 px, e eu cheguei a quebrar o texto em duas linhas por causa desse
/// número. Com a Plus Jakarta Sans ela pede 179, contra os 288 do cartão, e
/// cabe folgada.
///
/// Fica o aprendizado: teste de layout sem a fonte do produto mede ficção,
/// e o pior é que ele passa.
///
/// O que sobrou de verdadeiro da investigação anterior é o desenho: rótulo
/// em cima e valor embaixo. Lado a lado, "Data de nascimento" come 114 dos
/// 288 px e sobram 158 para o valor, menos que os 179 da idade.
void main() {
  setUpAll(carregarFonteDeVerdade);

  /// O texto mais longo de cada campo.
  const String dataPorExtenso = '10 de abril de 2026';

  /// A idade completa, na forma mais longa que o aplicativo escreve.
  const String idadeMaisLonga = '20 anos, 11 meses e 30 dias';

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

    testWidgets('a idade completa cabe numa linha', (
      WidgetTester tester,
    ) async {
      await montar(tester, dp: 360);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text(idadeMaisLonga)).height, 20);
    });
  });

  group('a fonte usada para medir', () {
    test('é a do produto, e não a substituta do ambiente de teste', () {
      // A guarda que faltava. Na fonte substituta todo caractere mede um em,
      // então `i` e `W` saem iguais; foi assim que uma frase de 179 px
      // pareceu pedir 378 e me levou a quebrar o texto sem necessidade.
      //
      // Se este teste falhar, a fonte parou de ser carregada e toda medida
      // de largura deste arquivo voltou a ser ficção.
      double largura(String texto) => (TextPainter(
        text: TextSpan(
          text: texto,
          style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout()).width;

      expect(
        largura('W'),
        greaterThan(largura('i')),
        reason: 'a fonte de verdade não foi carregada',
      );
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
