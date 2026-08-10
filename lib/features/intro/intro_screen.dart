import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../state/providers.dart';
import '../common/google_g.dart';
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
    image: 'assets/images/onboarding/onboarding_1.webp',
    title: 'A infância passa depressa.',
    body:
        'Guarde os pequenos momentos antes que eles se tornem apenas '
        'lembranças.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_2.webp',
    title: 'Toda lembrança tem seu lugar.',
    body:
        'Fotos, vídeos, cartas, desenhos, documentos e registros de '
        'crescimento. Tudo reunido em um único lugar.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_3.webp',
    title: 'Cada memória no seu tempo.',
    body:
        'Organizamos tudo pela idade em que aconteceu, formando uma '
        'verdadeira linha do tempo da infância.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_4.webp',
    title: 'Um presente para o futuro.',
    body:
        'Um dia, essa cápsula poderá ser aberta por quem mais importa: seu '
        'filho.',
  ),
  IntroSlide(
    image: 'assets/images/onboarding/onboarding_5.webp',
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: Space.x8),
                child: TextButton(
                  onPressed: _sair,
                  child: Text(ultimo ? 'Fechar' : 'Pular'),
                ),
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.block,
                0,
                Space.block,
                Space.block,
              ),
              // O indicador fica sempre acima do botão, nas cinco telas. Ele
              // diz onde a pessoa está, e essa informação vem antes da ação:
              // embaixo, ele ficava depois do que já tinha sido decidido.
              child: Column(
                children: <Widget>[
                  _Pontos(total: introSlides.length, atual: _atual),
                  const SizedBox(height: Space.block),
                  if (ultimo)
                    _EscolhaDaConta(aoEscolher: _sair)
                  else
                    _BotaoPilula(rotulo: 'Continuar', aoTocar: _avancar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O botão cheio da apresentação.
///
/// Usa `Radii.pill` em vez de `Radii.button`, e os dois são do Design
/// System: a pílula é o que ele reserva para o que deve parecer redondo.
/// Aqui cabe porque a tela não tem nada em volta para dar escala, e a forma
/// arredondada é o que separa o botão do fundo. É a única tela assim.
class _BotaoPilula extends StatelessWidget {
  const _BotaoPilula({required this.rotulo, required this.aoTocar});

  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: aoTocar,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Sizes.button),
        shape: RoundedRectangleBorder(borderRadius: Radii.pillR),
      ),
      child: Text(rotulo),
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
        _BotaoPilula(
          rotulo: 'Criar conta recomendada',
          aoTocar: () => aoEscolher(contaNova: true),
        ),
        const SizedBox(height: Space.x12),
        OutlinedButton.icon(
          onPressed: () => aoEscolher(),
          icon: const GoogleG(),
          label: const Text('Usar minha conta atual'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(Sizes.button),
            shape: RoundedRectangleBorder(borderRadius: Radii.pillR),
            backgroundColor: context.cores.surface,
            foregroundColor: context.cores.textPrimary,
            side: BorderSide(color: context.cores.border),
          ),
        ),
      ],
    );
  }
}

/// O indicador de página.
///
/// Bolinhas iguais, e só a cor muda. A da página atual não cresce nem vira
/// barra: com cinco telas e um botão logo abaixo, movimento aqui compete com
/// o que a pessoa precisa tocar.
class _Pontos extends StatelessWidget {
  const _Pontos({required this.total, required this.atual});

  final int total;
  final int atual;

  @override
  Widget build(BuildContext context) {
    const double lado = 8;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < total; i++)
          AnimatedContainer(
            duration: Motion.micro,
            curve: Motion.padrao,
            margin: const EdgeInsets.symmetric(horizontal: Space.x4),
            width: lado,
            height: lado,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == atual ? context.cores.primary : context.cores.border,
            ),
          ),
      ],
    );
  }
}
