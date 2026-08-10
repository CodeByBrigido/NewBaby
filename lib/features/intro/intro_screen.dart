import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../state/providers.dart';
import 'onboarding_page.dart';

/// Um slide da apresentação.
@immutable
class IntroSlide {
  const IntroSlide({
    required this.image,
    required this.title,
    required this.body,
  });

  final String image;
  final String title;
  final String body;
}

/// As cinco telas antes do login.
///
/// Não são um tutorial de botões: são o único momento em que dá para dizer o
/// que este aplicativo é, e por que vale a pena criar uma conta só para a
/// cápsula. Depois do login ninguém mais lê isso, e a decisão da conta já
/// terá sido tomada.
const List<IntroSlide> introSlides = <IntroSlide>[
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_1.png',
    title: 'A infância passa depressa.',
    body:
        'Guarde os pequenos momentos antes que eles se tornem apenas '
        'lembranças.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_2.png',
    title: 'Toda lembrança tem seu lugar.',
    body:
        'Fotos, vídeos, cartas, desenhos, documentos e registros de '
        'crescimento. Tudo reunido em um único lugar.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_3.png',
    title: 'Cada memória no seu tempo.',
    body:
        'Cada lembrança é organizada pela idade em que aconteceu, formando '
        'uma verdadeira linha do tempo da infância.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_4.png',
    title: 'Um presente para o futuro.',
    body:
        'Um dia, essa cápsula poderá ser aberta por quem mais importa: seu '
        'filho.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_5.png',
    title: 'Vamos criar essa cápsula?',
    body:
        'Recomendamos usar uma conta Google exclusiva para guardar todas '
        'essas lembranças por muitos anos.',
  ),
];

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final PageController _pages = PageController();
  int _atual = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Sair da apresentação.
  ///
  /// Quando ela foi aberta pela tela Sobre, só volta. Na primeira vez, marca
  /// como vista e deixa o roteador levar para o login.
  Future<void> _sair({bool contaNova = false}) async {
    await ref.read(introSeenProvider.notifier).markSeen();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Routes.login, extra: contaNova ? loginComContaNova : null);
  }

  void _avancar() =>
      _pages.nextPage(duration: Motion.screen, curve: Motion.entrada);

  @override
  Widget build(BuildContext context) {
    final bool ultimo = _atual == introSlides.length - 1;

    return Scaffold(
      // Branco puro, e não o fundo do tema. As ilustrações são PNG sem
      // transparência: o branco delas é opaco. Sobre o creme da paleta da
      // menina ou o azulado da do menino, cada uma apareceria como um bloco
      // mais claro recortado no meio da tela. Aqui isso não é escolha de
      // estilo, é o que faz a arte encostar no fundo.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _sair,
                child: Text(ultimo ? 'Fechar' : 'Pular'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: introSlides.length,
                onPageChanged: (int i) => setState(() => _atual = i),
                itemBuilder: (BuildContext context, int i) => OnboardingPage(
                  imagePath: introSlides[i].image,
                  title: introSlides[i].title,
                  description: introSlides[i].body,
                  isLastPage: i == introSlides.length - 1,
                ),
              ),
            ),
            _Pontos(total: introSlides.length, atual: _atual),
            const SizedBox(height: Space.x24),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.x24,
                0,
                Space.x24,
                Space.x24,
              ),
              child: ultimo
                  ? _EscolhaDaConta(aoEscolher: _sair)
                  : _Continuar(aoTocar: _avancar),
            ),
          ],
        ),
      ),
    );
  }
}

class _Continuar extends StatelessWidget {
  const _Continuar({required this.aoTocar});

  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: aoTocar,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Sizes.button),
      ),
      child: const Text('Continuar'),
    );
  }
}

/// As duas saídas da última tela.
///
/// Uma embaixo da outra, e não lado a lado, porque os rótulos são longos e
/// numa linha só eles quebrariam em duas. A conta nova vem primeiro e
/// preenchida, que é o que a palavra "recomendada" já promete; usar a conta
/// atual continua a um toque de distância, e não escondido.
class _EscolhaDaConta extends StatelessWidget {
  const _EscolhaDaConta({required this.aoEscolher});

  final Future<void> Function({bool contaNova}) aoEscolher;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FilledButton(
          onPressed: () => aoEscolher(contaNova: true),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(Sizes.button),
          ),
          child: const Text('Criar conta recomendada'),
        ),
        const SizedBox(height: Space.x12),
        OutlinedButton(
          onPressed: () => aoEscolher(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(Sizes.button),
          ),
          child: const Text('Usar minha conta atual'),
        ),
      ],
    );
  }
}

class _Pontos extends StatelessWidget {
  const _Pontos({required this.total, required this.atual});

  final int total;
  final int atual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < total; i++)
          AnimatedContainer(
            duration: Motion.micro,
            curve: Motion.padrao,
            margin: const EdgeInsets.symmetric(horizontal: Space.x4),
            width: i == atual ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == atual ? context.cores.primary : context.cores.divider,
              borderRadius: Radii.pillR,
            ),
          ),
      ],
    );
  }
}
