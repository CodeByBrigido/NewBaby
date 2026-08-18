import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/home/atalho_de_inspiracao.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/inspiration.dart';
import 'package:meu_bebe/services/inspiration_source.dart';
import 'package:meu_bebe/state/providers.dart';

import 'fonte_de_verdade.dart';

/// O atalho para uma postagem, na tela inicial.
///
/// Tudo o que ele mostra sai do arquivo da postagem: título, resumo, capa e
/// etiqueta. É isso que faz corrigir uma postagem ser mexer num arquivo, sem
/// tocar em código, e é o que estes testes prendem.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
  });

  Inspiration ideia(String id, {String? etiqueta}) => Inspiration(
    id: id,
    title: 'Título $id',
    summary: 'Resumo $id',
    kind: InspirationKind.brincadeira,
    anchor: const AgeAnchor(fromDays: 0, toDays: 99999),
    label: etiqueta,
  );

  ActiveInspiration ativa(Inspiration i, {int? faltam}) => ActiveInspiration(
    inspiration: i,
    relevance: 1,
    daysLeft: faltam,
    deadline: faltam == null ? null : DateTime(2028, 1, 1),
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
          inspirationSourceProvider.overrideWithValue(_Catalogo(catalogo)),
          profileProvider.overrideWith(
            (Ref _) => Stream<BabyProfile?>.value(
              BabyProfile(
                name: nome,
                // No passado: o catálogo é resolvido contra a idade de hoje.
                birth: DateTime.now().subtract(const Duration(days: 400)),
                gender: BabyGender.girl,
              ),
            ),
          ),
          sementeDaAberturaProvider.overrideWithValue(semente),
        ],
        child: MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: const Scaffold(body: AtalhoDeInspiracao()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('o que vem do arquivo da postagem', () {
    testWidgets('o título e o resumo são os que estão escritos nela', (
      WidgetTester tester,
    ) async {
      await montar(tester, catalogo: <Inspiration>[ideia('a')]);

      expect(find.text('Título a'), findsOneWidget);
      expect(find.text('Resumo a'), findsOneWidget);
    });

    testWidgets('a etiqueta da postagem manda, quando existe', (
      WidgetTester tester,
    ) async {
      // O campo existe para quem escreve a postagem decidir por que aquele
      // texto merece a tela inicial, em vez de uma regra decidir por ele.
      await montar(
        tester,
        catalogo: <Inspiration>[
          ideia('a', etiqueta: 'Um momento para guardar'),
        ],
      );

      expect(find.text('UM MOMENTO PARA GUARDAR'), findsOneWidget);
    });

    testWidgets('é um atalho: o cartão inteiro abre a postagem', (
      WidgetTester tester,
    ) async {
      await montar(tester, catalogo: <Inspiration>[ideia('a')]);
      expect(find.text('Ver inspiração'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });
  });

  group('a etiqueta montada, quando a postagem não traz uma', () {
    final Copy comNome = Copy.of(
      BabyProfile(name: 'Maria', birth: DateTime(2026, 1, 1)),
    );

    test('sem prazo, fala da fase da criança', () {
      expect(etiquetaDe(ativa(ideia('a')), comNome), 'Para Maria, agora');
    });

    test('com prazo, fala com o adulto', () {
      // Quem precisa se preparar para uma data que se aproxima é o adulto.
      expect(etiquetaDe(ativa(ideia('a'), faltam: 10), comNome), 'Para você');
    });

    test('sem nome no cadastro, outra frase, e não uma pior', () {
      final Copy semNome = Copy.of(
        BabyProfile(name: '', birth: DateTime(2026, 1, 1)),
      );
      expect(etiquetaDe(ativa(ideia('a')), semNome), 'Para viver agora');
    });

    test('a da postagem vence as duas regras', () {
      expect(
        etiquetaDe(ativa(ideia('a', etiqueta: 'Só hoje'), faltam: 3), comNome),
        'Só hoje',
      );
    });
  });

  group('a troca a cada abertura', () {
    List<ActiveInspiration> ativas(int quantas) => <ActiveInspiration>[
      for (int i = 0; i < quantas; i++) ativa(ideia('i$i')),
    ];

    test('sementes diferentes escolhem postagens diferentes', () {
      final List<ActiveInspiration> lista = ativas(3);
      expect(
        AtalhoDeInspiracao.sorteada(lista, 0)!.inspiration.id,
        isNot(AtalhoDeInspiracao.sorteada(lista, 1)!.inspiration.id),
      );
    });

    test('a mesma semente escolhe sempre a mesma', () {
      // Quem abre e fecha a tela inicial dentro da mesma sessão não deveria
      // ver o cartão mudar debaixo do dedo.
      final List<ActiveInspiration> lista = ativas(5);
      expect(
        AtalhoDeInspiracao.sorteada(lista, 7)!.inspiration.id,
        AtalhoDeInspiracao.sorteada(lista, 7)!.inspiration.id,
      );
    });

    test('uma postagem só não tem por onde variar, e não quebra', () {
      expect(AtalhoDeInspiracao.sorteada(ativas(1), 99)!.inspiration.id, 'i0');
    });

    test('sem postagem nenhuma, ninguém é escolhido', () {
      expect(
        AtalhoDeInspiracao.sorteada(const <ActiveInspiration>[], 3),
        isNull,
      );
    });

    test('semente negativa não estoura o índice', () {
      // A semente é um instante em microssegundos, e o resto de um número
      // negativo em Dart também é negativo: sem o `abs`, isto seria um
      // índice fora da lista.
      expect(AtalhoDeInspiracao.sorteada(ativas(3), -7), isNotNull);
    });

    test('o sorteio fica entre as mais relevantes', () {
      // Sortear entre dezenas traria à tona a que combina menos com a fase da
      // criança, que é justamente o que a ordem do catálogo evita.
      final List<ActiveInspiration> lista = ativas(40);
      final Set<String> vistas = <String>{
        for (int s = 0; s < 200; s++)
          AtalhoDeInspiracao.sorteada(lista, s)!.inspiration.id,
      };
      expect(vistas, hasLength(AtalhoDeInspiracao.entreAsPrimeiras));
    });
  });

  group('sem catálogo', () {
    testWidgets('o bloco some inteiro', (WidgetTester tester) async {
      // Melhor não existir do que existir vazio.
      await montar(tester, catalogo: <Inspiration>[]);
      expect(find.text('Ver inspiração'), findsNothing);
    });
  });
}

class _Catalogo implements InspirationSource {
  const _Catalogo(this.postagens);

  final List<Inspiration> postagens;

  @override
  Future<List<Inspiration>> load() async => postagens;
}
