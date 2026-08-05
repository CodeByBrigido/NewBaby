import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/intro/intro_screen.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A apresentação antes do login.
///
/// É a única vez em que dá para explicar por que as fotos ficam fora do
/// aplicativo e por que vale criar uma conta só para a cápsula. Depois do
/// login essa decisão já foi tomada, e ninguém volta para ler.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  /// A tela sai daqui navegando, então o teste precisa de um roteador de
  /// verdade. O destino é um substituto: a tela de login pede Firebase, e o
  /// que importa aqui é para onde a apresentação manda, não o que tem lá.
  GoRouter roteador() => GoRouter(
    initialLocation: '/apresentacao',
    routes: <RouteBase>[
      GoRoute(path: '/apresentacao', builder: (_, _) => const IntroScreen()),
      GoRoute(
        path: '/entrar',
        builder: (_, GoRouterState state) =>
            Scaffold(body: Text('login:${state.extra ?? ''}')),
      ),
    ],
  );

  Widget harness([ProviderContainer? container]) {
    final Widget app = MaterialApp.router(
      theme: AppTheme.build(AppPalette.of(BabyGender.girl)),
      locale: const Locale('pt', 'BR'),
      routerConfig: roteador(),
    );
    return container == null
        ? ProviderScope(child: app)
        : UncontrolledProviderScope(container: container, child: app);
  }

  group('o conteúdo das três telas', () {
    test('são três, e nenhuma vazia', () {
      expect(introSlides, hasLength(3));
      for (final IntroSlide s in introSlides) {
        expect(s.title.trim(), isNotEmpty);
        expect(s.body.trim(), isNotEmpty);
      }
    });

    test('a primeira diz o que o aplicativo não é', () {
      // A régua do produto inteiro. Se esta frase sair, a apresentação vira
      // propaganda de álbum de fotos.
      expect(introSlides.first.title, contains('não é um álbum'));
    });

    test('a segunda promete o que o aplicativo cumpre', () {
      final String texto = introSlides[1].body;
      expect(texto, contains('Google Drive'));
      expect(texto, contains('sua conta'));
    });

    test('a terceira explica a conta pela entrega, não por espaço', () {
      // O argumento não é armazenamento: é que a conta pode ser dela um dia.
      // Trocar isso por "mais espaço" é perder o motivo inteiro.
      final String texto = introSlides.last.body;
      expect(texto, contains('não é espaço'));
      expect(texto, contains('dela um dia'));
    });

    test('nenhum texto usa travessão', () {
      // Regra do projeto, e aqui é fácil de esquecer porque é texto corrido.
      for (final IntroSlide s in introSlides) {
        expect('${s.title}${s.body}', isNot(contains('—')));
      }
    });
  });

  group('a navegação', () {
    testWidgets('abre na primeira tela, com "Pular" à mão', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      expect(find.text(introSlides.first.title), findsOneWidget);
      expect(find.text('Pular'), findsOneWidget);
      // As duas escolhas de conta só aparecem no fim.
      expect(find.text('Criar uma conta'), findsNothing);
    });

    testWidgets('no fim, as duas escolhas de conta têm o mesmo peso', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text(introSlides.last.title), findsOneWidget);
      expect(find.text('Criar uma conta'), findsOneWidget);
      expect(find.text('Usar a minha conta'), findsOneWidget);

      // Mesma largura: a conta nova é sugestão, não exigência. Um botão
      // grande e outro pequeno transformaria a sugestão em pressão.
      final Size criar = tester.getSize(
        find.ancestor(
          of: find.text('Criar uma conta'),
          matching: find.byType(FilledButton),
        ),
      );
      final Size minha = tester.getSize(
        find.ancestor(
          of: find.text('Usar a minha conta'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(criar.width, minha.width);
    });

    testWidgets('"Pular" marca como vista, e não volta a aparecer', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(introSeenProvider, (_, _) {});

      await tester.pumpWidget(harness(container));
      await tester.pump();
      expect(container.read(introSeenProvider), isFalse);

      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();

      expect(container.read(introSeenProvider), isTrue);
      expect(find.text('login:'), findsOneWidget);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('apresentacao.vista'), isTrue);
    });

    testWidgets('"Criar uma conta" leva o recado até a tela de login', (
      WidgetTester tester,
    ) async {
      // Sem esta marca a pessoa escolhe criar uma conta e cai numa tela que
      // não diz uma palavra sobre como criar.
      await tester.pumpWidget(harness());
      await tester.pump();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar uma conta'));
      await tester.pumpAndSettle();

      expect(find.text('login:conta-nova'), findsOneWidget);
    });
  });
}
