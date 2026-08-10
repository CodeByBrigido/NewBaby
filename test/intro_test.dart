import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/intro/google_g.dart';
import 'package:meu_bebe/features/intro/intro_screen.dart';
import 'package:meu_bebe/features/intro/onboarding_page.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A apresentação antes do login.
///
/// É a única vez em que dá para dizer o que o aplicativo é e por que vale
/// criar uma conta só para a cápsula. Depois do login essa decisão já foi
/// tomada, e ninguém volta para ler.
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

  /// Vai até a última tela pelo botão, como uma pessoa faria.
  Future<void> ateOFim(WidgetTester tester) async {
    for (int i = 0; i < introSlides.length - 1; i++) {
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    }
  }

  group('o conteúdo das cinco telas', () {
    test('são cinco, e nenhuma vazia', () {
      expect(introSlides, hasLength(5));
      for (final IntroSlide s in introSlides) {
        expect(s.title.trim(), isNotEmpty);
        expect(s.body.trim(), isNotEmpty);
        expect(s.image.trim(), isNotEmpty);
      }
    });

    test('cada tela aponta para a própria arte, na ordem', () {
      // Um caminho repetido passaria despercebido em revisão e apareceria
      // como a mesma ilustração duas vezes.
      for (int i = 0; i < introSlides.length; i++) {
        expect(
          introSlides[i].image,
          'assets/images/onboarding/onboarding_${i + 1}.png',
        );
      }
    });

    test('a última fala da conta, que é a decisão que ela pede', () {
      final IntroSlide ultima = introSlides.last;
      expect(ultima.title, contains('cápsula'));
      expect(ultima.body, contains('conta Google'));
    });

    test('nenhum texto promete o que o aplicativo não faz', () {
      // A gravação de voz saiu do produto. Prometer áudio aqui seria vender
      // uma função que não existe, e esta é a primeira tela que a pessoa vê.
      final String tudo = introSlides
          .map((IntroSlide s) => '${s.title} ${s.body}')
          .join(' ')
          .toLowerCase();
      expect(tudo, isNot(contains('áudio')));
      expect(tudo, isNot(contains('audio')));
    });

    test('nenhum texto usa travessão', () {
      // Regra do projeto, e aqui é fácil de esquecer porque é texto corrido.
      for (final IntroSlide s in introSlides) {
        expect('${s.title}${s.body}', isNot(contains('—')));
      }
    });
  });

  group('a página, isolada', () {
    Widget sozinha({required bool ultima}) => MaterialApp(
      theme: AppTheme.build(AppPalette.of(BabyGender.girl)),
      home: Scaffold(
        body: OnboardingPage(
          imagePath: introSlides.first.image,
          title: 'Um título',
          description: 'Um texto',
          isLastPage: ultima,
        ),
      ),
    );

    testWidgets('mostra título, texto e a arte', (WidgetTester tester) async {
      await tester.pumpWidget(sozinha(ultima: false));
      expect(find.text('Um título'), findsOneWidget);
      expect(find.text('Um texto'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('só a última traz o selo de recomendação', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(sozinha(ultima: false));
      expect(find.byType(SeloRecomendado), findsNothing);

      await tester.pumpWidget(sozinha(ultima: true));
      expect(find.byType(SeloRecomendado), findsOneWidget);
      expect(find.text('Recomendado'), findsOneWidget);
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
      expect(find.text('Fechar'), findsNothing);
      // As duas escolhas de conta só aparecem no fim.
      expect(find.text('Criar conta recomendada'), findsNothing);
    });

    testWidgets('o indicador acompanha a página', (WidgetTester tester) async {
      await tester.pumpWidget(harness());
      await tester.pump();
      expect(find.byType(AnimatedContainer), findsNWidgets(5));
      expect(find.byType(GoogleG), findsNothing);

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text(introSlides[1].title), findsOneWidget);
    });

    testWidgets('o dedo também vira a página', (WidgetTester tester) async {
      // O botão não pode ser o único caminho: a apresentação é um PageView e
      // arrastar é o gesto que as pessoas tentam primeiro.
      await tester.pumpWidget(harness());
      await tester.pump();

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text(introSlides[1].title), findsOneWidget);
    });

    testWidgets('no fim, "Pular" vira "Fechar" e as contas aparecem', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pump();
      await ateOFim(tester);

      expect(find.text(introSlides.last.title), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('Pular'), findsNothing);
      expect(find.text('Criar conta recomendada'), findsOneWidget);
      expect(find.text('Usar minha conta atual'), findsOneWidget);
      expect(find.text('Continuar'), findsNothing);
      // O símbolo do Google só faz sentido no botão que leva à conta que a
      // pessoa já tem; nas outras telas ele seria enfeite.
      expect(find.byType(GoogleG), findsOneWidget);
    });

    testWidgets('as duas escolhas de conta têm a mesma largura', (
      WidgetTester tester,
    ) async {
      // A conta nova é sugestão, não exigência. Um botão largo e outro
      // estreito transformaria a sugestão em pressão.
      await tester.pumpWidget(harness());
      await tester.pump();
      await ateOFim(tester);

      final Size criar = tester.getSize(
        find.ancestor(
          of: find.text('Criar conta recomendada'),
          matching: find.byType(FilledButton),
        ),
      );
      final Size minha = tester.getSize(
        find.ancestor(
          of: find.text('Usar minha conta atual'),
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

    testWidgets('"Criar conta recomendada" leva o recado até o login', (
      WidgetTester tester,
    ) async {
      // Sem esta marca a pessoa escolhe criar uma conta e cai numa tela que
      // não diz uma palavra sobre como criar.
      await tester.pumpWidget(harness());
      await tester.pump();
      await ateOFim(tester);

      await tester.tap(find.text('Criar conta recomendada'));
      await tester.pumpAndSettle();

      expect(find.text('login:conta-nova'), findsOneWidget);
    });

    testWidgets('"Usar minha conta atual" vai para o mesmo login, sem marca', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness());
      await tester.pump();
      await ateOFim(tester);

      await tester.tap(find.text('Usar minha conta atual'));
      await tester.pumpAndSettle();

      expect(find.text('login:'), findsOneWidget);
    });
  });
}
