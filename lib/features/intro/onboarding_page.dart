import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';

/// Uma das cinco telas da apresentação.
///
/// Existe separada da tela que as folheia porque as cinco têm exatamente a
/// mesma estrutura: ilustração, título, texto. Repetir isso cinco vezes é
/// como o espaçamento entre elas começa a divergir.
///
/// [isLastPage] muda o conteúdo, e não só a decoração: a última tela é a que
/// pede a conta, e por isso ela mostra o ícone do aplicativo e o selo de
/// recomendação. Os dois botões ficam de fora, com a tela que os navega,
/// porque eles pertencem ao fluxo e não à página.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
    this.isLastPage = false,
    super.key,
  });

  final String imagePath;
  final String title;
  final String description;
  final bool isLastPage;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    // Centralizado quando cabe, rolável quando não cabe. Sem o `minHeight` a
    // coluna encosta no topo e sobra um vão embaixo; sem a rolagem, um
    // aparelho pequeno com fonte grande cortaria o fim do texto.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints limites) =>
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: limites.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // A arte vai de borda a borda, e só o texto tem margem. Uma das
                  // ilustrações é alta e estreita, com legendas desenhadas dentro
                  // dela: qualquer margem lateral encolhe a imagem inteira e são
                  // essas legendas que somem primeiro.
                  _Ilustracao(caminho: imagePath),
                  const SizedBox(height: Space.x32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.x32),
                    child: Column(
                      children: <Widget>[
                        Text(
                          title,
                          style: text.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Space.x16),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge?.copyWith(
                            height: 1.6,
                            color: context.cores.textSecondary,
                          ),
                        ),
                        if (isLastPage) ...<Widget>[
                          const SizedBox(height: Space.x16),
                          const SeloRecomendado(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

/// A arte da tela.
///
/// A altura é uma fração da tela, e não um número fixo, porque a mesma
/// apresentação roda num aparelho pequeno e num tablet: fixar a altura faria
/// a ilustração comer o texto num e boiar no outro.
class _Ilustracao extends StatelessWidget {
  const _Ilustracao({required this.caminho});

  final String caminho;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData tela = MediaQuery.of(context);
    // Quase metade da tela. Uma das artes é bem mais alta que larga, e com
    // `contain` é a altura que manda: cada ponto a menos aqui estreita
    // aquela ilustração inteira, e é nela que estão as legendas desenhadas.
    final double altura = tela.size.height * 0.48;

    return SizedBox(
      height: altura,
      child: Image.asset(
        caminho,
        fit: BoxFit.contain,
        // As artes vêm com mais de mil pixels de altura e são desenhadas com
        // um terço disso. Sem este limite, cada uma ocuparia na memória o
        // tamanho cheio descomprimido, e o `PageView` mantém as vizinhas
        // vivas: seriam dezenas de megabytes parados para nada.
        cacheHeight: (altura * tela.devicePixelRatio).round(),
        // Uma arte que falta não pode virar tela vermelha na primeira coisa
        // que a pessoa vê do aplicativo. O texto sozinho ainda diz tudo.
        errorBuilder: (BuildContext context, Object _, StackTrace? _) =>
            const SizedBox.shrink(),
      ),
    );
  }
}

/// O selo da recomendação, na última tela.
///
/// A estrela é ícone, e não o emoji do texto: emoji depende da fonte do
/// aparelho, muda de desenho entre Android e iOS e não acompanha a cor do
/// tema. O sentido é o mesmo e o resultado é igual em todo lugar.
class SeloRecomendado extends StatelessWidget {
  const SeloRecomendado({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x12,
        vertical: Space.x4,
      ),
      decoration: BoxDecoration(
        color: context.cores.primarySoft,
        borderRadius: Radii.pillR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.star_rounded,
            size: Sizes.iconSmall,
            color: AppPalette.warning,
          ),
          const SizedBox(width: Space.x4),
          Text(
            'Recomendado',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.cores.primaryStrong,
            ),
          ),
        ],
      ),
    );
  }
}
