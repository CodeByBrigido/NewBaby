import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/router/app_router.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/state/idioma_providers.dart';
import 'package:meu_bebe/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fonte_de_verdade.dart';

/// A língua chegando **na tela**, e não só na tabela.
///
/// Trocar o idioma nas Configurações mudava `S` e não mudava o que estava
/// desenhado: era preciso fechar e abrir o aplicativo, e mesmo assim várias
/// telas continuavam em português.
///
/// A causa tem duas metades, e este arquivo cobre as duas.
///
/// A primeira é o go_router: ele guarda a página já montada de cada rota e
/// não chama o construtor dela de novo enquanto a rota não muda. Refazer a
/// raiz, empurrar o `refreshListenable`, trocar a chave do `MaterialApp` e
/// até um `go` para a mesma rota deixam a página exatamente como estava. Só
/// um roteador novo a monta outra vez.
///
/// A segunda é o arranque: o provedor do idioma nasce síncrono e o disco não
/// é, então a página nascia na língua do aparelho e a escolha guardada
/// chegava um quadro depois, quando já não havia quem a lesse.
void main() {
  setUpAll(carregarFonteDeVerdade);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    definirTextos(textosPt);
    IdiomaNotifier.esquecerSemente();
  });

  group('o roteador do aplicativo', () {
    /// Só a sessão é forjada: sem isso o `authStateProvider` iria ao
    /// Firebase, que não existe no teste.
    ProviderContainer conteiner() {
      final ProviderContainer c = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((Ref _) => Stream<User?>.value(null)),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('nasce de novo quando o idioma muda', () async {
      final ProviderContainer c = conteiner();

      final GoRouter antes = c.read(routerProvider);
      await c.read(idiomaProvider.notifier).escolher(Idioma.alemao);

      expect(
        identical(antes, c.read(routerProvider)),
        isFalse,
        reason:
            'O roteador é o mesmo, então ele ainda tem guardadas as telas '
            'montadas na língua antiga.',
      );
    });

    test('não nasce de novo à toa', () async {
      final ProviderContainer c = conteiner();

      final GoRouter antes = c.read(routerProvider);
      // Escolher a mesma língua de novo não é uma troca.
      await c.read(idiomaProvider.notifier).escolher(c.read(idiomaProvider));

      expect(identical(antes, c.read(routerProvider)), isTrue);
    });
  });

  testWidgets('um roteador novo monta a tela na língua nova', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: _Raiz()));
    await tester.pumpAndSettle();

    // Sem escolha guardada vale a língua do aparelho, e o teste não tem como
    // fixá-la: `doAparelho` lê o `PlatformDispatcher` de verdade. Perguntar
    // a ela qual é evita depender da locale que a máquina por acaso usar.
    final Textos inicial = textosPara(IdiomaNotifier.doAparelho().codigo);
    expect(find.text(inicial.closeLabel), findsOneWidget);

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    await container.read(idiomaProvider.notifier).escolher(Idioma.alemao);
    await tester.pumpAndSettle();

    expect(
      find.text(textosDe.closeLabel),
      findsOneWidget,
      reason: 'A tela continuou na língua em que nasceu.',
    );
    expect(find.text(inicial.closeLabel), findsNothing);
  });

  testWidgets('a rota onde a pessoa estava sobrevive à troca', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: _Raiz()));
    await tester.pumpAndSettle();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    container.read(_roteador).go('/segunda');
    await tester.pumpAndSettle();
    expect(find.textContaining('segunda'), findsOneWidget);

    await container.read(idiomaProvider.notifier).escolher(Idioma.alemao);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('segunda'),
      findsOneWidget,
      reason:
          'Trocar de idioma jogou a pessoa de volta para a primeira tela, '
          'em vez de deixá-la onde estava.',
    );
  });

  group('o rótulo do nascimento', () {
    Entry nascimento({String? titulo}) => Entry(
      id: 'n',
      type: EntryType.birth,
      date: DateTime(2026, 4, 15),
      createdAt: DateTime(2026, 4, 15),
      ageDays: 0,
      bucketKey: 'ano-0',
      bucketName: 'Ano 0',
      title: titulo,
    );

    test('segue a língua quando nada foi digitado', () {
      definirTextos(textosDe);
      expect(nascimento().headline, textosDe.birth);
    });

    test('segue a língua mesmo numa cápsula antiga, criada em português', () {
      // O cadastro gravava o rótulo. A cápsula criada em português mostrava
      // "Nascimento" para sempre, em qualquer idioma.
      definirTextos(textosDe);
      expect(nascimento(titulo: textosPt.birth).headline, textosDe.birth);
    });

    test('um título digitado continua vencendo', () {
      definirTextos(textosDe);
      expect(
        nascimento(titulo: 'O dia mais longo').headline,
        'O dia mais longo',
      );
    });
  });

  testWidgets('no arranque, a tela nasce na língua guardada no disco', (
    WidgetTester tester,
  ) async {
    // Alguém que já escolheu italiano e fechou o aplicativo.
    SharedPreferences.setMockInitialValues(<String, Object>{
      IdiomaNotifier.chave: 'it',
    });
    // O mesmo que `main()` faz antes de `runApp`.
    await IdiomaNotifier.semearDoDisco();

    await tester.pumpWidget(const ProviderScope(child: _Raiz()));
    await tester.pumpAndSettle();

    expect(
      find.text(textosIt.closeLabel),
      findsOneWidget,
      reason:
          'A página nasceu antes de a escolha guardada chegar do disco, e '
          'nunca mais foi refeita.',
    );
  });
}

/// A raiz, montada como a de verdade: idioma observado no topo, telas
/// desenhadas por um `GoRouter` abaixo.
class _Raiz extends ConsumerWidget {
  const _Raiz();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Idioma idioma = ref.watch(idiomaProvider);
    definirTextos(textosPara(idioma.codigo));

    return MaterialApp.router(routerConfig: ref.watch(_roteador));
  }
}

/// Duas telas atrás de um `Router`, ligadas ao idioma como o roteador do
/// aplicativo.
///
/// Não é o roteador de verdade porque aquele arrasta sessão, cadastro e
/// Firestore para dentro do teste. O que estes dois testes precisam é da
/// forma: páginas abaixo de um `Router`, que é onde a troca de idioma se
/// perdia. Que o roteador de verdade tenha essa mesma ligação é o que o
/// grupo acima verifica.
final Provider<GoRouter> _roteador = Provider<GoRouter>((Ref ref) {
  ref.watch(idiomaProvider);
  final _Onde onde = ref.read(_ondeDoTeste);

  final GoRouter router = GoRouter(
    initialLocation: onde.rota,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: Text(S.closeLabel)),
      ),
      GoRoute(
        path: '/segunda',
        builder: (_, _) => Scaffold(body: Text('segunda ${S.closeLabel}')),
      ),
    ],
  );
  router.routerDelegate.addListener(() {
    onde.rota = router.routerDelegate.currentConfiguration.uri.toString();
  });
  ref.onDispose(router.dispose);
  return router;
});

class _Onde {
  String rota = '/';
}

final Provider<_Onde> _ondeDoTeste = Provider<_Onde>((Ref _) => _Onde());
