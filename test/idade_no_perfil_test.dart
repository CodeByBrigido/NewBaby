import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/features/common/widgets.dart';

/// A idade no Perfil precisa caber, e caber daqui a vinte anos.
///
/// O defeito, visto no aparelho: "1 ano e 9 meses e 14 dias" já espremia o
/// cartão, e o texto encostava no elemento ao lado. O cartão tinha dois
/// dados lado a lado, cada um com metade da largura, e metade não cabe a
/// idade. Pior: o divisor entre eles tinha 34 px fixos, então quanto mais o
/// texto crescia mais curto ele parecia.
///
/// Este teste usa a idade mais longa que o aplicativo consegue escrever, e
/// não a de hoje. Um aplicativo que promete durar até a criança abrir a
/// cápsula aos vinte anos não pode ser verificado só com um bebê de meses:
/// o texto cresce sozinho com o tempo, e quem descobre é quem estiver
/// usando, anos depois de alguém ter escrito o código.
void main() {
  /// A forma mais longa possível: dois dígitos em cada uma das três partes.
  const String maisLonga = '20 anos e 11 meses e 30 dias';

  /// Uma tela de telefone comum, em pontos lógicos.
  Future<void> montar(WidgetTester tester, Widget filho, {double dp = 360}) {
    tester.view.physicalSize = Size(dp * 3, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(AppPalette.girl),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.x16),
            child: filho,
          ),
        ),
      ),
    );
  }

  /// O cartão do Perfil, montado com os mesmos widgets da tela.
  Widget cartao(String valor) => SoftCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _linha(S.birthDate, '10/04/2026'),
        const SizedBox(height: Space.x12),
        const Divider(height: 1),
        const SizedBox(height: Space.x12),
        _linha(S.currentAge, valor),
      ],
    ),
  );

  group('a idade mais longa que o aplicativo escreve', () {
    test('é mesmo a que este teste usa', () {
      // Sem isto o teste protege uma frase inventada. A idade sai de
      // `detailedLabel`, e é ela que precisa caber.
      final Age idade = AgeCalculator.ageAt(
        DateTime(2026, 4, 10),
        DateTime(2047, 3, 10),
      );
      final String real = idade.detailedLabel(alwaysShowDays: true);
      expect(
        real,
        matches(RegExp(r'^\d+ anos? e \d+ (mês|meses) e \d+ dias?$')),
      );
      expect(
        real.length,
        lessThanOrEqualTo(maisLonga.length),
        reason: 'apareceu uma idade mais longa que a usada no teste: $real',
      );
    });

    testWidgets('cabe em duas linhas num telefone comum', (
      WidgetTester tester,
    ) async {
      await montar(tester, cartao(maisLonga));
      await tester.pumpAndSettle();

      final Rect valor = tester.getRect(find.text(maisLonga));
      expect(
        valor.height,
        lessThanOrEqualTo(48),
        reason:
            'a idade passou de duas linhas: com três o cartão fica torto ao '
            'lado de uma data de uma linha só.',
      );
    });

    testWidgets('encosta na borda direita, e não passa dela', (
      WidgetTester tester,
    ) async {
      // O pedido era alinhar mais para a direita. Alinhado à direita, o valor
      // ganha toda a largura que sobra do rótulo para quebrar quando precisa.
      await montar(tester, cartao(maisLonga));
      await tester.pumpAndSettle();

      final Rect valor = tester.getRect(find.text(maisLonga));
      final Rect card = tester.getRect(find.byType(SoftCard));
      expect(valor.right, lessThanOrEqualTo(card.right));
      expect(
        valor.right,
        greaterThan(card.right - Space.x16 - 1),
        reason: 'o valor deveria encostar na folga interna do cartão',
      );
    });

    testWidgets('num telefone estreito continua sem estourar', (
      WidgetTester tester,
    ) async {
      // 320 dp é o mais estreito que ainda se vende. Aqui a idade passa de
      // duas linhas, e tudo bem: o que não pode é vazar do cartão.
      await montar(tester, cartao(maisLonga), dp: 320);
      await tester.pumpAndSettle();

      final Rect valor = tester.getRect(find.text(maisLonga));
      final Rect card = tester.getRect(find.byType(SoftCard));
      expect(valor.right, lessThanOrEqualTo(card.right));
      expect(valor.left, greaterThanOrEqualTo(card.left));
    });
  });
}

/// A mesma composição de `_Fact`, que é privada da tela do Perfil.
Widget _linha(String label, String valor) => Builder(
  builder: (BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: text.labelSmall),
        const SizedBox(width: Space.x12),
        Expanded(
          child: Text(
            valor,
            style: text.titleSmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  },
);
