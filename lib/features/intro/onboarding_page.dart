import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';

/// Uma das cinco telas da apresentação.
///
/// Existe separada da tela que as folheia porque as cinco têm exatamente a
/// mesma estrutura: ilustração, título, texto. Repetir isso cinco vezes é
/// como o espaçamento entre elas começa a divergir.
///
/// As cinco são iguais por dentro: o que muda de uma para a outra vive na
/// tela que as folheia, e não aqui. A última chegou a ter selo e ícone
/// próprios, e os dois saíram; sobrou uma página só, sem exceção.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
    super.key,
  });

  final String imagePath;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    // A arte cede espaço ao texto, e não o contrário.
    //
    // Antes ela era uma fração da tela, medida sempre igual. Só que a última
    // página tem um rodapé bem mais alto que as outras (dois botões em vez
    // de um), e ali a mesma fração não cabia: o texto era empurrado para
    // fora e aparecia cortado embaixo do botão.
    //
    // Com `Expanded` de um lado e `Flexible` do outro, a divisão é sempre do
    // que sobrou naquela página. A arte fica com três quintos, o texto com o
    // resto, e a conta fecha em qualquer tela e com qualquer rodapé.
    return Column(
      children: <Widget>[
        // A arte vai de borda a borda, e só o texto tem margem. Uma das
        // ilustrações é alta e estreita, com legendas desenhadas dentro
        // dela: qualquer margem lateral encolhe a imagem inteira e são
        // essas legendas que somem primeiro.
        Expanded(flex: 3, child: _Ilustracao(caminho: imagePath)),
        const SizedBox(height: Space.x24),
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A arte da tela, no espaço que a página lhe deu.
///
/// Não escolhe altura: recebe. Quem divide é a coluna acima, e é isso que
/// faz a mesma página servir a um telefone pequeno, a um tablet e à última
/// tela, que tem dois botões embaixo em vez de um.
class _Ilustracao extends StatelessWidget {
  const _Ilustracao({required this.caminho});

  final String caminho;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints limites) =>
          _pintar(context, limites.maxHeight),
    );
  }

  Widget _pintar(BuildContext context, double altura) {
    final MediaQueryData tela = MediaQuery.of(context);

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
