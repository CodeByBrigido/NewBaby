import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';

import 'fonte_de_verdade.dart';

/// As abas da galeria: Anos, Meses, Semanas.
///
/// Três pedidos que são o mesmo mecanismo por baixo, e é por isso que valem
/// um teste só: a ordem das abas, o realce deslizando de uma para a outra, e
/// a troca de aba pelo gesto de arrastar a tela.
///
/// O que amarra os três é um `TabController` único, lido pela barra e pelo
/// conteúdo. Durante o arrasto a animação dele vale um número quebrado entre
/// duas abas, e é daí que sai a posição do realce. Se a barra passar a
/// desenhar o realce a partir do índice escolhido, os toques continuam
/// funcionando e o deslize some sem nada quebrar.
void main() {
  setUpAll(carregarFonteDeVerdade);

  /// A mesma composição da tela, sem Firestore nem Drive no caminho.
  Widget montar(TabController abas) => MaterialApp(
    theme: AppTheme.build(AppPalette.girl),
    home: Scaffold(
      body: Column(
        children: <Widget>[
          TabBar(
            controller: abas,
            tabs: <Widget>[
              Tab(text: S.years),
              Tab(text: S.months),
              Tab(text: S.weeks),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: abas,
              children: const <Widget>[
                Center(child: Text('conteudo anos')),
                Center(child: Text('conteudo meses')),
                Center(child: Text('conteudo semanas')),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  group('a ordem das abas', () {
    test('vai do maior período para o menor', () {
      // A ordem em que se procura uma memória antiga: primeiro o ano, depois
      // o mês, depois a semana. É a ordem pedida, e ela é o oposto da que
      // havia antes.
      List<String> ordem = <String>[S.years, S.months, S.weeks];
      expect(ordem, <String>['Anos', 'Meses', 'Semanas']);
    });
  });

  group('a troca de aba pelo gesto', () {
    testWidgets('arrastar da direita para a esquerda avança', (
      WidgetTester tester,
    ) async {
      final TabController abas = TabController(
        length: 3,
        vsync: const TestVSync(),
        initialIndex: 0,
      );
      addTearDown(abas.dispose);

      await tester.pumpWidget(montar(abas));
      await tester.pumpAndSettle();
      expect(find.text('conteudo anos'), findsOneWidget);

      await tester.fling(find.byType(TabBarView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();

      expect(abas.index, 1);
      expect(find.text('conteudo meses'), findsOneWidget);
    });

    testWidgets('arrastar da esquerda para a direita volta', (
      WidgetTester tester,
    ) async {
      final TabController abas = TabController(
        length: 3,
        vsync: const TestVSync(),
        initialIndex: 2,
      );
      addTearDown(abas.dispose);

      await tester.pumpWidget(montar(abas));
      await tester.pumpAndSettle();

      await tester.fling(find.byType(TabBarView), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();

      expect(abas.index, 1);
    });
  });

  group('o realce que desliza', () {
    testWidgets('a animação passa por valores quebrados durante a troca', (
      WidgetTester tester,
    ) async {
      // É esta a propriedade que o desenho da barra usa. Um controlador que
      // saltasse direto de 0 para 1 daria um realce que acende e apaga; o
      // que faz a cor parecer sair de uma aba e chegar na outra é existirem
      // valores no meio do caminho.
      final TabController abas = TabController(
        length: 3,
        vsync: const TestVSync(),
        initialIndex: 0,
      );
      addTearDown(abas.dispose);

      await tester.pumpWidget(montar(abas));
      await tester.pumpAndSettle();

      final List<double> vistos = <double>[];
      abas.animation!.addListener(() => vistos.add(abas.animation!.value));

      abas.animateTo(2, duration: const Duration(milliseconds: 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(
        vistos.where((double v) => v > 0.1 && v < 1.9),
        isNotEmpty,
        reason: 'o realce saltaria em vez de deslizar',
      );
      expect(abas.animation!.value, 2.0);
    });

    testWidgets('a posição do realce sai da animação, e não do índice', (
      WidgetTester tester,
    ) async {
      // A conta que a barra faz, presa aqui: alinhamento de -1 a 1 a partir
      // do valor contínuo. No meio do caminho entre a primeira e a segunda
      // de três abas, o realce fica no meio, e não numa das duas.
      double alinhamento(double onde, int quantas) =>
          quantas == 1 ? 0 : (onde / (quantas - 1)) * 2 - 1;

      expect(alinhamento(0, 3), -1);
      expect(alinhamento(1, 3), 0);
      expect(alinhamento(2, 3), 1);
      expect(alinhamento(0.5, 3), -0.5);
    });

    test('a cor do rótulo acompanha a proximidade', () {
      // Mesma ideia para o texto: 1 na aba escolhida, 0 nas outras, e o meio
      // do caminho durante o arrasto.
      double proximidade(double onde, int i) =>
          (1 - (onde - i).abs()).clamp(0.0, 1.0);

      expect(proximidade(0, 0), 1);
      expect(proximidade(0, 1), 0);
      expect(proximidade(0.5, 0), 0.5);
      expect(proximidade(0.5, 1), 0.5);
      // Uma aba distante não acende de leve: fica em zero.
      expect(proximidade(0, 2), 0);
    });
  });
}
