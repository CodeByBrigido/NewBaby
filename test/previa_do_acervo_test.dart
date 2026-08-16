import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/core/utils/formatters.dart';
import 'package:meu_bebe/core/utils/mosaico.dart';

import 'fonte_de_verdade.dart';

/// Gera uma imagem do acervo para olhar antes de instalar.
///
/// **O que é real aqui:** a função `mosaico`, que decide quantas fotos
/// entram em cada linha e que tamanho cada uma tem; o agrupamento por mês; o
/// cabeçalho; os espaçamentos e as cores do Design System; a fonte do
/// produto.
///
/// **O que é encenação:** o conteúdo das fotos, que são retângulos com um
/// número. Miniatura de verdade vem do Drive, e teste não tem rede. A
/// proporção de cada retângulo é a mesma que a foto teria, então o
/// enquadramento na tela é fiel mesmo sem a imagem.
///
/// Não roda por padrão: gerar imagem em toda execução da suíte deixaria o
/// CI comparando pixels e falhando por diferença de máquina. Roda à mão com
/// `flutter test --update-goldens test/previa_do_acervo_test.dart`.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
  });

  for (final (String nome, double deslocamento, bool bolha)
      in <(String, double, bool)>[
        // Como a tela abre: sem bolha, porque ninguém rolou ainda.
        ('topo', 0, false),
        // Como ela fica durante a rolagem, que é quando a bolha existe.
        ('rolando', 620, true),
      ]) {
    testWidgets('previa do acervo, $nome', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: _Previa(deslocamento: deslocamento, comBolha: bolha),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(_Previa),
        matchesGoldenFile('previa/acervo-$nome.png'),
      );
    });
  }
}

/// Uma foto de mentira: só a data e a proporção, que é o que o mosaico usa.
@immutable
class _Foto {
  const _Foto(this.quando, this.proporcao, this.numero);
  final DateTime quando;
  final double proporcao;
  final int numero;
}

class _Previa extends StatelessWidget {
  const _Previa({this.deslocamento = 0, this.comBolha = false});

  /// Onde a rolagem está, para mostrar a tela em uso e não só no começo.
  final double deslocamento;

  /// A bolha e as marcas de ano só existem enquanto a rolagem acontece.
  final bool comBolha;

  /// Um acervo plausível: meses de tamanhos diferentes, e uma mistura de
  /// paisagem, retrato e quadrado como sai de um telefone de verdade.
  static List<_Foto> get _acervo {
    const List<double> proporcoes = <double>[
      1.33,
      0.75,
      1.0,
      1.78,
      0.75,
      1.33,
      1.0,
      0.56,
      1.5,
      1.0,
      0.75,
      1.33,
    ];
    final List<_Foto> fotos = <_Foto>[];
    int n = 1;
    for (final (int mes, int quantas) in <(int, int)>[
      (8, 7),
      (7, 11),
      (6, 4),
    ]) {
      for (int i = 0; i < quantas; i++) {
        fotos.add(
          _Foto(
            DateTime(2027, mes, 28 - i),
            proporcoes[n % proporcoes.length],
            n,
          ),
        );
        n++;
      }
    }
    return fotos;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Fotos')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints vaga) {
          final List<MesDoMosaico<_Foto>> meses = mosaico<_Foto>(
            itens: _acervo,
            quando: (_Foto f) => f.quando,
            proporcao: (_Foto f) => f.proporcao,
            largura: vaga.maxWidth - Space.x8 * 2,
            alturaAlvo: 116,
            espaco: Space.x4,
          );

          return Stack(
            children: <Widget>[
              ListView(
                controller: ScrollController(initialScrollOffset: deslocamento),
                children: <Widget>[
                  for (final MesDoMosaico<_Foto> mes in meses) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Space.x16,
                        Space.x20,
                        Space.x16,
                        Space.x8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(height: 1, color: context.cores.divider),
                          const SizedBox(height: Space.x12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Text(
                                Fmt.monthYear(mes.mes),
                                style: text.titleSmall,
                              ),
                              const SizedBox(width: Space.x8),
                              Text(
                                Fmt.count(mes.quantos, 'item', 'itens'),
                                style: text.labelSmall?.copyWith(
                                  color: context.cores.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.x8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          for (final LinhaDoMosaico<_Foto> linha in mes.linhas)
                            Padding(
                              padding: const EdgeInsets.only(bottom: Space.x4),
                              child: Row(
                                children: <Widget>[
                                  for (final LadrilhoDoMosaico<_Foto> l
                                      in linha.ladrilhos) ...<Widget>[
                                    _Retangulo(ladrilho: l),
                                    if (l != linha.ladrilhos.last)
                                      const SizedBox(width: Space.x4),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              // A bolha do mês, no estado em que ela aparece durante a
              // rolagem. Na tela ela some sozinha quando a rolagem para.
              if (comBolha)
                Positioned(
                  top: Space.x12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.x16,
                        vertical: Space.x8,
                      ),
                      decoration: BoxDecoration(
                        color: context.cores.surface,
                        borderRadius: Radii.pillR,
                        boxShadow: Shadows.level2,
                      ),
                      child: Text(
                        Fmt.monthYear(DateTime(2027, 8)),
                        style: text.labelLarge,
                      ),
                    ),
                  ),
                ),
              // As marcas de ano ao lado do rolador.
              if (comBolha) ...<Widget>[
                const Positioned(
                  top: 140,
                  right: Space.x16,
                  child: _Marca(texto: '2027'),
                ),
                const Positioned(
                  top: 520,
                  right: Space.x16,
                  child: _Marca(texto: '2026'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// O lugar da foto, com a proporção que ela teria.
class _Retangulo extends StatelessWidget {
  const _Retangulo({required this.ladrilho});

  final LadrilhoDoMosaico<_Foto> ladrilho;

  @override
  Widget build(BuildContext context) {
    // Tons da paleta, só para as peças se distinguirem umas das outras.
    final List<Color> tons = <Color>[
      context.cores.primarySoft,
      context.cores.accentSoft,
      context.cores.surfaceMuted,
      context.cores.border,
    ];

    return Container(
      width: ladrilho.largura,
      height: ladrilho.altura,
      decoration: BoxDecoration(
        color: tons[ladrilho.item.numero % tons.length],
        borderRadius: Radii.mediaR,
      ),
      alignment: Alignment.center,
      child: Text(
        '${ladrilho.item.numero}',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: context.cores.textSecondary),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x12,
        vertical: Space.x4,
      ),
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: Radii.pillR,
        boxShadow: Shadows.level1,
      ),
      child: Text(texto, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
