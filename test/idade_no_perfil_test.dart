import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/features/common/widgets.dart';

import 'fonte_de_verdade.dart';

/// O cartão do Perfil: nascimento e idade, lado a lado.
///
/// Duas colunas é o desenho pedido, e ele quase não coube. O que apertava
/// não era a idade: era o rótulo. Com a fonte do produto, "Data de
/// nascimento" mede 114 px e a data em si mede 77, num cartão de 296. O
/// rótulo curto devolve quase quarenta pixels para a coluna da idade.
///
/// A divisão é 2 para 5 pelo mesmo motivo: a data tem tamanho fixo para
/// sempre, e a idade vai de "3 dias" a "20 anos, 10 meses e 30 dias".
///
/// **Este teste carrega a fonte do produto.** Sem ela o `flutter test`
/// desenha com uma substituta em que todo caractere ocupa um em, e as
/// larguras saem com o dobro do tamanho. Foi assim que eu concluí, errado,
/// que estas duas colunas eram impossíveis e cheguei a empilhá-las.
void main() {
  setUpAll(carregarFonteDeVerdade);

  /// A idade que o dono do produto mandou verificar.
  ///
  /// Se essa passa, qualquer outra passa: é a forma mais longa que o
  /// aplicativo escreve, com dois dígitos em cada uma das três parcelas.
  const String idadeDeVinteAnos = '20 anos, 10 meses e 30 dias';

  Future<void> montar(WidgetTester tester, String idade, {double dp = 360}) {
    tester.view.physicalSize = Size(dp * 3, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(AppPalette.girl),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.x16),
            child: SoftCard(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: _fato(S.birthDateShort, '02/11/2024'),
                    ),
                    const VerticalDivider(width: Space.x16, thickness: 1),
                    Expanded(flex: 5, child: _fato(S.currentAge, idade)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('a idade de vinte anos', () {
    testWidgets('cabe numa linha, ao lado da data', (
      WidgetTester tester,
    ) async {
      await montar(tester, idadeDeVinteAnos);
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.text(idadeDeVinteAnos)).height,
        20,
        reason: 'a idade quebrou de linha',
      );
      expect(
        tester.getRect(find.text('02/11/2024')).height,
        20,
        reason: 'a data quebrou de linha',
      );
    });

    testWidgets('e os rótulos também', (WidgetTester tester) async {
      // O rótulo é o que apertava a coluna. Se ele voltar a ser longo, quem
      // quebra é ele, e o cartão fica torto de novo.
      await montar(tester, idadeDeVinteAnos);
      await tester.pumpAndSettle();

      expect(tester.getRect(find.text(S.birthDateShort)).height, 16);
      expect(tester.getRect(find.text(S.currentAge)).height, 16);
    });

    testWidgets('nada vaza do cartão', (WidgetTester tester) async {
      await montar(tester, idadeDeVinteAnos);
      await tester.pumpAndSettle();

      final Rect card = tester.getRect(find.byType(SoftCard));
      for (final String t in <String>[
        idadeDeVinteAnos,
        '02/11/2024',
        S.birthDateShort,
        S.currentAge,
      ]) {
        final Rect r = tester.getRect(find.text(t));
        expect(r.left, greaterThanOrEqualTo(card.left), reason: t);
        expect(r.right, lessThanOrEqualTo(card.right), reason: t);
      }
    });
  });

  group('as bordas', () {
    testWidgets('a idade de hoje, bem mais curta, também cabe', (
      WidgetTester tester,
    ) async {
      await montar(tester, '1 ano, 9 meses e 14 dias');
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('1 ano, 9 meses e 14 dias')).height, 20);
    });

    testWidgets('num telefone estreito nada é cortado', (
      WidgetTester tester,
    ) async {
      // A 320 dp a idade de vinte anos pode quebrar, e tudo bem: o cartão
      // cresce um pouco. O que não pode é sumir texto ou vazar da borda.
      await montar(tester, idadeDeVinteAnos, dp: 320);
      await tester.pumpAndSettle();

      final RenderBox caixa = tester.renderObject<RenderBox>(
        find.text(idadeDeVinteAnos),
      );
      final TextPainter medidor = TextPainter(
        text: TextSpan(
          text: idadeDeVinteAnos,
          style: tester.widget<Text>(find.text(idadeDeVinteAnos)).style,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: caixa.size.width);

      expect(caixa.size.height, greaterThanOrEqualTo(medidor.height));
    });
  });

  group('a idade mais longa que o aplicativo escreve', () {
    test('é mesmo a que este teste usa', () {
      // Sem isto o teste protege uma frase inventada. A idade sai de
      // `detailedLabel`, e é ela que precisa caber.
      final String real = AgeCalculator.ageAt(
        DateTime(2026, 4, 10),
        DateTime(2047, 3, 10),
      ).detailedLabel(alwaysShowDays: true);

      expect(
        real,
        matches(RegExp(r'^\d+ anos?, \d+ (mês|meses) e \d+ dias?$')),
      );
      expect(
        real.length,
        lessThanOrEqualTo(idadeDeVinteAnos.length),
        reason: 'apareceu uma idade mais longa que a usada no teste: $real',
      );
    });
  });
}

/// A mesma composição de `_Fact`, que é privada da tela do Perfil.
Widget _fato(String label, String valor) => Builder(
  builder: (BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(label, style: text.labelSmall, textAlign: TextAlign.center),
        const SizedBox(height: Space.x4),
        Text(valor, style: text.titleSmall, textAlign: TextAlign.center),
      ],
    );
  },
);
