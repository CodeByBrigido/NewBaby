import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/home/carrossel_de_inspiracao.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/inspiration.dart';
import 'package:meu_bebe/services/inspiration_source.dart';
import 'package:meu_bebe/state/providers.dart';

import 'fonte_de_verdade.dart';

/// O carrossel de ideias que entrou no lugar da grade do Acervo.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
  });

  Inspiration ideia(String id, {int deDias = 0, int ateDias = 99999}) =>
      Inspiration(
        id: id,
        title: 'Título $id',
        summary: 'Resumo $id',
        kind: InspirationKind.brincadeira,
        anchor: AgeAnchor(fromDays: deDias, toDays: ateDias),
        sections: const <InspirationSection>[],
      );

  Future<void> montar(
    WidgetTester tester, {
    required List<Inspiration> catalogo,
    int semente = 0,
    String nome = 'Maria',
  }) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inspirationSourceProvider.overrideWithValue(_CatalogoFixo(catalogo)),
          profileProvider.overrideWith(
            (Ref ref) => Stream<BabyProfile?>.value(
              BabyProfile(
                name: nome,
                // No passado de propósito: o catálogo é resolvido contra a
                // idade de hoje, e uma criança que ainda não nasceu não tem
                // inspiração nenhuma que valha.
                birth: DateTime.now().subtract(const Duration(days: 400)),
                gender: BabyGender.girl,
              ),
            ),
          ),
          sementeDaAberturaProvider.overrideWithValue(semente),
        ],
        child: MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: const Scaffold(body: CarrosselDeInspiracao()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('o que aparece', () {
    testWidgets('uma ideia por vez, com o convite de abrir', (
      WidgetTester tester,
    ) async {
      await montar(tester, catalogo: <Inspiration>[ideia('a'), ideia('b')]);

      expect(find.text('Ver inspiração'), findsOneWidget);
      expect(find.textContaining('Título'), findsOneWidget);
    });

    testWidgets('o rótulo diz o nome da criança', (WidgetTester tester) async {
      await montar(tester, catalogo: <Inspiration>[ideia('a')]);
      expect(find.text('PARA MARIA, AGORA'), findsOneWidget);
    });

    testWidgets('cadastro sem nome ganha outra frase, e não uma pior', (
      WidgetTester tester,
    ) async {
      await montar(tester, catalogo: <Inspiration>[ideia('a')], nome: '');
      expect(find.text('PARA VIVER AGORA'), findsOneWidget);
    });

    testWidgets('sem catálogo, o carrossel some inteiro', (
      WidgetTester tester,
    ) async {
      // Melhor não existir do que existir vazio: um cartão sem conteúdo é um
      // buraco no meio da tela inicial.
      await montar(tester, catalogo: <Inspiration>[]);
      expect(find.text('Ver inspiração'), findsNothing);
    });
  });

  group('a troca a cada abertura', () {
    testWidgets('a semente decide por onde começa', (
      WidgetTester tester,
    ) async {
      final List<Inspiration> catalogo = <Inspiration>[
        ideia('a'),
        ideia('b'),
        ideia('c'),
      ];

      await montar(tester, catalogo: catalogo, semente: 0);
      final String primeira = tester
          .widget<Text>(find.textContaining('Título'))
          .data!;

      // Desmonta antes de montar de novo. Sem isto o Flutter reaproveita o
      // `State` que está na mesma posição da árvore, o `PageController`
      // sobrevive com a página antiga, e o teste passaria a medir a memória
      // do teste anterior em vez da semente nova.
      await tester.pumpWidget(const SizedBox.shrink());
      await montar(tester, catalogo: catalogo, semente: 1);
      final String segunda = tester
          .widget<Text>(find.textContaining('Título'))
          .data!;

      expect(primeira, isNot(segunda));
    });

    testWidgets('uma ideia só não tem por onde variar, e não quebra', (
      WidgetTester tester,
    ) async {
      // O resto da divisão por um é sempre zero. O teste existe porque a
      // conta com lista vazia seria divisão por zero, e com uma só o índice
      // precisa continuar válido.
      await montar(tester, catalogo: <Inspiration>[ideia('a')], semente: 7);
      expect(tester.takeException(), isNull);
      expect(find.text('Título a'), findsOneWidget);
    });

    testWidgets('o carrossel não cresce sem limite', (
      WidgetTester tester,
    ) async {
      // O catálogo devolve dezenas, e um carrossel sem fim vira uma segunda
      // aba de inspirações dentro da tela inicial.
      await montar(
        tester,
        catalogo: <Inspiration>[for (int i = 0; i < 20; i++) ideia('i$i')],
      );

      expect(find.byType(PageView), findsOneWidget);
      final PageView pagina = tester.widget<PageView>(find.byType(PageView));
      expect(
        (pagina.childrenDelegate as SliverChildBuilderDelegate).childCount,
        CarrosselDeInspiracao.quantas,
      );
    });
  });
}

class _CatalogoFixo implements InspirationSource {
  const _CatalogoFixo(this.postagens);

  final List<Inspiration> postagens;

  @override
  Future<List<Inspiration>> load() async => postagens;
}
