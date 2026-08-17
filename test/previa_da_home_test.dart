@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';

import 'fonte_de_verdade.dart';

/// Desenhos das ideias para a tela inicial, para olhar antes de decidir.
///
/// **O que é real aqui:** a paleta, a tipografia, os espaçamentos, os raios e
/// as sombras do Design System, e a fonte do produto. Se um destes desenhos
/// for escolhido, ele vai parecer com isto no aparelho.
///
/// **O que é encenação:** os números e os textos, que são plausíveis mas
/// inventados, e as fotos, que são retângulos de cor chapada. Nenhuma destas
/// telas existe no aplicativo: são propostas.
///
/// Marcada com a etiqueta `previa`, que o `dart_test.yaml` pula. Roda à mão:
/// `flutter test --run-skipped --update-goldens test/previa_da_home_test.dart`
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
    await carregarIconesDoMaterial();
  });

  for (final (String nome, Widget Function() constroi) ideia
      in <(String, Widget Function())>[
        ('1-neste-dia', _NesteDia.new),
        ('2-contagem-do-lacre', _ContagemDoLacre.new),
        ('3-regua-ate-os-18', _ReguaDaVida.new),
        ('4-o-que-falta', _OQueFalta.new),
        ('5-frase-para-a-crianca', _FraseParaACrianca.new),
        ('6-home-montada', _HomeMontada.new),
      ]) {
    testWidgets('previa da home, ${ideia.$1}', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2760);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: _Moldura(titulo: ideia.$1, child: ideia.$2()),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(_Moldura),
        matchesGoldenFile('previa/home-${ideia.$1}.png'),
      );
    });
  }
}

/// O bloco proposto dentro da tela, com o cabeçalho de hoje por cima.
///
/// O cabeçalho vem junto de propósito: nenhuma destas ideias vive sozinha, e
/// olhar um cartão fora da tela engana sobre o peso que ele tem.
class _Moldura extends StatelessWidget {
  const _Moldura({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool montada = titulo.startsWith('6');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Bebê'),
        leading: const Icon(Icons.menu),
        actions: const <Widget>[
          Icon(Icons.search),
          SizedBox(width: Space.x16),
          Icon(Icons.insert_chart_outlined),
          SizedBox(width: Space.x12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x16,
          Space.x8,
          Space.x16,
          Space.x24,
        ),
        children: <Widget>[
          if (!montada) ...<Widget>[
            const _Cabecalho(),
            const SizedBox(height: Space.x24),
          ],
          child,
        ],
      ),
    );
  }
}

/// O cabeçalho que já existe hoje, redesenhado aqui só para dar contexto.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(Space.x20),
      decoration: BoxDecoration(
        color: context.cores.heroFill,
        borderRadius: Radii.cardR,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  'Boa tarde!',
                  style: text.bodyMedium?.copyWith(
                    color: context.cores.onHeroSoft,
                  ),
                ),
                const SizedBox(height: Space.x12),
                Text(
                  'Hoje a Maria está com',
                  style: text.bodyMedium?.copyWith(
                    color: context.cores.onHeroSoft,
                  ),
                ),
                const SizedBox(height: Space.x4),
                Text(
                  '1 ano, 9 meses\ne 14 dias',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    color: context.cores.onHero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.x16),
          CircleAvatar(
            radius: 34,
            backgroundColor: context.cores.primarySoft,
            child: Icon(
              Icons.child_care,
              color: context.cores.primaryDark,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

/// Título de seção, no formato que o aplicativo já usa.
class _Titulo extends StatelessWidget {
  const _Titulo(this.texto, {this.acao});

  final String texto;
  final String? acao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
          ),
          if (acao case final String rotulo)
            Text(
              rotulo,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: context.cores.primary),
            ),
        ],
      ),
    );
  }
}

/// Um lugar de foto, com a proporção que ela teria.
class _Foto extends StatelessWidget {
  const _Foto({this.altura = 180, this.tom = 0});

  final double altura;
  final int tom;

  @override
  Widget build(BuildContext context) {
    final List<Color> tons = <Color>[
      context.cores.primarySoft,
      context.cores.accentSoft,
      context.cores.surfaceMuted,
    ];

    return Container(
      height: altura,
      decoration: BoxDecoration(
        color: tons[tom % tons.length],
        borderRadius: Radii.mediaR,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_outlined,
        color: context.cores.textSecondary.withValues(alpha: 0.35),
        size: 28,
      ),
    );
  }
}

Widget _cartao(BuildContext context, {required Widget child}) => Container(
  padding: const EdgeInsets.all(Space.x16),
  decoration: BoxDecoration(
    color: context.cores.surface,
    borderRadius: Radii.cardR,
    boxShadow: Shadows.level1,
  ),
  child: child,
);

// ------------------------------------------------------------------- 1

/// Neste dia: a cápsula falando de volta.
class _NesteDia extends StatelessWidget {
  const _NesteDia();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Titulo('Neste dia', acao: 'Ver o dia'),
        _cartao(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.x12,
                      vertical: Space.x4,
                    ),
                    decoration: BoxDecoration(
                      color: context.cores.primarySoft,
                      borderRadius: Radii.pillR,
                    ),
                    child: Text(
                      'Há 1 ano',
                      style: text.labelMedium?.copyWith(
                        color: context.cores.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '17 de agosto de 2026',
                    style: text.labelSmall?.copyWith(
                      color: context.cores.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.x12),
              const _Foto(altura: 190),
              const SizedBox(height: Space.x12),
              Text('A Maria tinha 9 meses.', style: text.bodyMedium),
              const SizedBox(height: Space.x4),
              Text(
                'Foi o dia em que ela ficou de pé sozinha pela primeira vez.',
                style: text.bodySmall?.copyWith(
                  color: context.cores.textSecondary,
                ),
              ),
              const SizedBox(height: Space.x12),
              Row(
                children: <Widget>[
                  for (int i = 0; i < 3; i++) ...<Widget>[
                    Expanded(child: _Foto(altura: 64, tom: i + 1)),
                    if (i < 2) const SizedBox(width: Space.x8),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.x16),
        Text(
          'No primeiro ano, quando ainda não há "ano passado", '
          'a mesma seção diz "Há 6 meses" ou "Há 1 mês". Sem nada guardado '
          'naquela data, ela some inteira.',
          style: text.bodySmall?.copyWith(color: context.cores.textSecondary),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- 2

/// A contagem do lacre: a promessa de vinte anos dita todo dia.
class _ContagemDoLacre extends StatelessWidget {
  const _ContagemDoLacre();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Titulo('Guardado a sete chaves', acao: 'Ver tudo'),
        Container(
          padding: const EdgeInsets.all(Space.x20),
          decoration: BoxDecoration(
            color: context.cores.heroFill,
            borderRadius: Radii.cardR,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: context.cores.onHeroSoft,
                  ),
                  const SizedBox(width: Space.x8),
                  Text(
                    'Para quando você tiver 18 anos',
                    style: text.labelMedium?.copyWith(
                      color: context.cores.onHeroSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.x16),
              Text(
                'Faltam 5.938 dias',
                style: text.headlineSmall?.copyWith(
                  color: context.cores.onHero,
                ),
              ),
              const SizedBox(height: Space.x4),
              Text(
                'para a Maria abrir a carta que você escreveu '
                'em 12 de março.',
                style: text.bodySmall?.copyWith(
                  color: context.cores.onHeroSoft,
                ),
              ),
              const SizedBox(height: Space.x20),
              // A barra mostra quanto do caminho já foi andado. Aqui é
              // pouco, e é justamente esse "pouco" que dá o tamanho da
              // promessa.
              ClipRRect(
                borderRadius: Radii.pillR,
                child: LinearProgressIndicator(
                  value: 0.09,
                  minHeight: 6,
                  backgroundColor: context.cores.onHeroSoft.withValues(
                    alpha: 0.25,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.cores.onHero,
                  ),
                ),
              ),
              const SizedBox(height: Space.x8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'escrita há 1 ano e 5 meses',
                    style: text.labelSmall?.copyWith(
                      color: context.cores.onHeroSoft,
                    ),
                  ),
                  Text(
                    '2044',
                    style: text.labelSmall?.copyWith(
                      color: context.cores.onHeroSoft,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.x16),
        _cartao(
          context,
          child: Row(
            children: <Widget>[
              Icon(Icons.mail_outline, color: context.cores.primary, size: 20),
              const SizedBox(width: Space.x12),
              Expanded(
                child: Text(
                  'Outras 3 cartas esperando, a próxima abre em 2032.',
                  style: text.bodySmall?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- 3

/// A régua da vida: a duração, que é o que a cápsula vende.
class _ReguaDaVida extends StatelessWidget {
  const _ReguaDaVida();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Titulo('A vida até aqui'),
        _cartao(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('1 ano e 9 meses de 18', style: text.titleMedium),
              const SizedBox(height: Space.x4),
              Text(
                'Guardado em 14 dos 21 meses vividos.',
                style: text.bodySmall?.copyWith(
                  color: context.cores.textSecondary,
                ),
              ),
              const SizedBox(height: Space.x32),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints vaga) {
                  // 21 meses vividos de 216, que são os 18 anos.
                  const double vivido = 21 / 216;
                  final double x = vaga.maxWidth * vivido;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // O rótulo de hoje fica acima da barra, preso ao ponto.
                      SizedBox(
                        height: 18,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Positioned(
                              left: (x - 14).clamp(0.0, vaga.maxWidth - 34),
                              child: Text(
                                'hoje',
                                style: text.labelSmall?.copyWith(
                                  color: context.cores.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Space.x4),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: context.cores.surfaceMuted,
                              borderRadius: Radii.pillR,
                            ),
                          ),
                          Container(
                            height: 10,
                            width: x,
                            decoration: BoxDecoration(
                              color: context.cores.primary,
                              borderRadius: Radii.pillR,
                            ),
                          ),
                          // O ponto de hoje, na ponta do vivido.
                          Positioned(
                            left: (x - 7).clamp(0.0, vaga.maxWidth - 14),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: context.cores.primaryDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.cores.surface,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.x12),
                      // Os anos, com a marca cheia onde há memória guardada.
                      SizedBox(
                        height: 26,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            for (final int ano in <int>[0, 3, 6, 9, 12, 15, 18])
                              Positioned(
                                left: (vaga.maxWidth * (ano * 12 / 216) - 10)
                                    .clamp(0.0, vaga.maxWidth - 22),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: 2,
                                      height: 6,
                                      color: ano <= 1
                                          ? context.cores.primaryDark
                                          : context.cores.border,
                                    ),
                                    const SizedBox(height: Space.x4),
                                    Text(
                                      '$ano',
                                      style: text.labelSmall?.copyWith(
                                        color: ano <= 1
                                            ? context.cores.primaryDark
                                            : context.cores.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Space.x8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'nascimento',
                            style: text.labelSmall?.copyWith(
                              color: context.cores.textSecondary,
                            ),
                          ),
                          Text(
                            '18 anos',
                            style: text.labelSmall?.copyWith(
                              color: context.cores.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.x16),
        Text(
          'A barra cheia é o tempo vivido, e os números embaixo são os anos. '
          'Num acervo que vai durar duas décadas, é aqui que se vê de um golpe '
          'o quanto ainda falta viver.',
          style: text.bodySmall?.copyWith(color: context.cores.textSecondary),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- 4

/// O que a cápsula ainda não tem: a tese do produto virada em fato.
class _OQueFalta extends StatelessWidget {
  const _OQueFalta();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(Space.x20),
          decoration: BoxDecoration(
            color: context.cores.accentSoft,
            borderRadius: Radii.cardR,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'A Maria vai receber 340 fotos\ne nenhuma carta.',
                style: text.titleMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: Space.x12),
              Text(
                'Foto o telefone dela também vai ter. A sua letra, não.',
                style: text.bodySmall?.copyWith(
                  color: context.cores.textSecondary,
                ),
              ),
              const SizedBox(height: Space.x20),
              // Dentro de `Expanded`, como toda linha de botões do projeto:
              // o tema dá largura mínima infinita, e um botão assim solto
              // numa `Row` não chega a ser medido.
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: Sizes.buttonCompact,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text(
                          'Escrever a primeira',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.x12),
                  Expanded(
                    child: SizedBox(
                      height: Sizes.buttonCompact,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Agora não'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.x16),
        Text(
          'É a ideia mais fácil de errar. Aparecendo sempre, vira cobrança, e '
          'ninguém quer abrir um aplicativo que reclama. Teria que ser raro, '
          'e sumir de vez depois da primeira carta.',
          style: text.bodySmall?.copyWith(color: context.cores.textSecondary),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- 5

/// A frase escrita para a criança, e não para quem está segurando o celular.
class _FraseParaACrianca extends StatelessWidget {
  const _FraseParaACrianca();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.x20,
            vertical: Space.x24,
          ),
          decoration: BoxDecoration(
            color: context.cores.surfaceMuted,
            borderRadius: Radii.cardR,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Quando você abrir isto,',
                style: text.bodyMedium?.copyWith(
                  color: context.cores.textSecondary,
                ),
              ),
              const SizedBox(height: Space.x8),
              Text(
                'vai encontrar 1.204 fotos,\n18 cartas e 3 anos de história.',
                style: text.titleMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: Space.x16),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.favorite_outline,
                    size: 16,
                    color: context.cores.primary,
                  ),
                  const SizedBox(width: Space.x8),
                  Text(
                    'Guardado no Drive da Maria desde 2026.',
                    style: text.labelSmall?.copyWith(
                      color: context.cores.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.x16),
        Text(
          'Uma linha só, e quase de graça: as Estatísticas já calculam estes '
          'números. O que muda é para quem a frase é escrita. Fica no rodapé '
          'da tela, e não no topo: é despedida, não manchete.',
          style: text.bodySmall?.copyWith(color: context.cores.textSecondary),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- 6

/// A recomendação: a tela inteira, com Acervo e Fotos recentes fora.
class _HomeMontada extends StatelessWidget {
  const _HomeMontada();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Cabecalho(),
        const SizedBox(height: Space.x24),
        const _Titulo('Neste dia', acao: 'Ver o dia'),
        _cartao(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.x12,
                      vertical: Space.x4,
                    ),
                    decoration: BoxDecoration(
                      color: context.cores.primarySoft,
                      borderRadius: Radii.pillR,
                    ),
                    child: Text(
                      'Há 1 ano',
                      style: text.labelMedium?.copyWith(
                        color: context.cores.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'a Maria tinha 9 meses',
                    style: text.labelSmall?.copyWith(
                      color: context.cores.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.x12),
              const _Foto(altura: 150),
            ],
          ),
        ),
        const SizedBox(height: Space.x24),
        Container(
          padding: const EdgeInsets.all(Space.x16),
          decoration: BoxDecoration(
            color: context.cores.heroFill,
            borderRadius: Radii.cardR,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.lock_outline,
                size: 20,
                color: context.cores.onHeroSoft,
              ),
              const SizedBox(width: Space.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Faltam 5.938 dias',
                      style: text.titleSmall?.copyWith(
                        color: context.cores.onHero,
                      ),
                    ),
                    const SizedBox(height: Space.x4),
                    Text(
                      'para a Maria abrir a sua carta.',
                      style: text.bodySmall?.copyWith(
                        color: context.cores.onHeroSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.x24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Space.x16,
            vertical: Space.x20,
          ),
          decoration: BoxDecoration(
            color: context.cores.surfaceMuted,
            borderRadius: Radii.cardR,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Quando você abrir isto,',
                style: text.bodySmall?.copyWith(
                  color: context.cores.textSecondary,
                ),
              ),
              const SizedBox(height: Space.x4),
              Text(
                'vai encontrar 1.204 fotos, 18 cartas\ne 3 anos de história.',
                style: text.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
