import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../state/providers.dart';

/// Um slide da apresentação.
@immutable
class IntroSlide {
  const IntroSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

/// As três telas antes do login.
///
/// Não são um tutorial de botões: são o único momento em que dá para
/// explicar por que este aplicativo guarda as fotos fora dele, e por que
/// vale a pena criar uma conta só para a cápsula. Depois do login ninguém
/// mais lê isso, e a decisão da conta já terá sido tomada.
const List<IntroSlide> introSlides = <IntroSlide>[
  IntroSlide(
    icon: Icons.hourglass_bottom_rounded,
    title: 'Isto não é um álbum de fotos',
    body:
        'É uma cápsula do tempo. Tudo que você guardar aqui está sendo '
        'guardado para alguém que ainda não sabe ler: a própria criança, '
        'daqui a vinte ou trinta anos.\n\n'
        'Por isso cada memória entra com a data e a idade dela, e não com a '
        'data em que você teve tempo de guardar.',
  ),
  IntroSlide(
    icon: Icons.cloud_done_outlined,
    title: 'As fotos continuam sendo suas',
    body:
        'Elas vão direto do celular para o Google Drive da sua conta, em '
        'pastas organizadas por idade. Não passam por servidor nosso, e o '
        'aplicativo não enxerga o resto do seu Drive.\n\n'
        'Se este aplicativo sumir amanhã, o acervo continua lá, do mesmo '
        'jeito, legível em qualquer computador.',
  ),
  IntroSlide(
    icon: Icons.vpn_key_outlined,
    title: 'Uma conta só para a cápsula',
    body:
        'A sugestão é criar uma conta do Google nova, só para isto. O motivo '
        'não é espaço.\n\n'
        'É que essa conta pode ser dela um dia. Login e senha, e a cápsula '
        'inteira passa de mão, sem transferir nada. Com a sua conta pessoal '
        'isso não daria: junto iriam seus emails, seus documentos e o resto '
        'da sua vida.',
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

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool ultimo = _atual == introSlides.length - 1;

    return Scaffold(
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
                itemBuilder: (BuildContext context, int i) =>
                    _Slide(slide: introSlides[i]),
              ),
            ),
            _Pontos(total: introSlides.length, atual: _atual),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ultimo
                  // Os dois do mesmo tamanho, de propósito: a conta nova é
                  // sugestão, não exigência. Exigir uma conta antes de a
                  // pessoa ver o aplicativo é o pedido mais caro possível no
                  // momento de maior desistência.
                  ? Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _sair(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            child: const Text('Usar a minha conta'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _sair(contaNova: true),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            child: const Text('Criar uma conta'),
                          ),
                        ),
                      ],
                    )
                  : FilledButton(
                      onPressed: () => _pages.nextPage(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text('Continuar', style: text.titleSmall),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final IntroSlide slide;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 24),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: context.cores.primarySoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(slide.icon, size: 42, color: context.cores.primaryDark),
          ),
          const SizedBox(height: 32),
          Text(slide.title, style: text.headlineSmall),
          const SizedBox(height: 16),
          Text(
            slide.body,
            style: text.bodyLarge?.copyWith(
              height: 1.6,
              color: context.cores.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == atual ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == atual ? context.cores.primary : context.cores.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
