import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/mosaico.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/esqueleto.dart';
import '../common/hero_da_midia.dart';
import '../common/widgets.dart';
import 'media_viewer_screen.dart';

/// Um arquivo com a entrada de onde ele veio.
typedef _Par = (Entry, EntryFile);

/// O acervo inteiro numa rolagem só, agrupado por mês.
///
/// Substitui a navegação por pastas de idade, que obrigava a escolher a
/// unidade antes de ver qualquer coisa e depois a entrar numa pasta por vez.
/// Aqui tudo está numa lista, do mais recente para o mais antigo, e quem
/// procura rola.
///
/// O agrupamento é por mês do calendário, e não por idade. As duas coisas
/// convivem: a idade continua sendo a organização da cápsula, e é ela que
/// nomeia as pastas no Drive e aparece ao abrir uma foto. Aqui manda o
/// calendário porque é assim que se procura uma foto que se lembra de ter
/// tirado: pelo mês em que aconteceu, e não pela semana de vida da criança.
class AcervoScreen extends ConsumerStatefulWidget {
  const AcervoScreen({required this.type, super.key});

  final EntryType type;

  @override
  ConsumerState<AcervoScreen> createState() => _AcervoScreenState();
}

class _AcervoScreenState extends ConsumerState<AcervoScreen> {
  final ScrollController _rolagem = ScrollController();

  /// O mês que está passando na tela, mostrado na bolha flutuante.
  DateTime? _mesNaTela;

  /// A bolha só aparece enquanto a rolagem acontece.
  bool _rolando = false;
  Timer? _sumico;

  @override
  void dispose() {
    _sumico?.cancel();
    _rolagem.dispose();
    super.dispose();
  }

  /// Qual mês está no topo da área visível.
  ///
  /// Cada seção conhece a própria faixa de deslocamento, então descobrir o
  /// mês é achar em qual faixa o topo da tela caiu. É uma busca linear sobre
  /// dezenas de meses, o que é barato; o que seria caro é perguntar isso a
  /// cada widget desenhado.
  void _acompanhar(List<_Secao> secoes) {
    if (!_rolagem.hasClients || secoes.isEmpty) return;

    final DateTime? achado = mesEm(<FaixaDeMes>[
      for (final _Secao s in secoes) s.faixa,
    ], _rolagem.offset);

    _sumico?.cancel();
    _sumico = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _rolando = false);
    });

    if (achado != _mesNaTela || !_rolando) {
      setState(() {
        _mesNaTela = achado;
        _rolando = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Entry> entries = ref.watch(entriesOfTypeProvider(widget.type));
    final List<_Par> arquivos = <_Par>[
      for (final Entry e in entries)
        for (final EntryFile f in e.files) (e, f),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: entries.isEmpty
          ? EmptyState(
              icon: widget.type.icon,
              title: S.noItemsYet,
              message: widget.type == EntryType.photo
                  ? 'Toque no + para adicionar as primeiras fotos.'
                  : S.firstVideoHint,
            )
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints vaga) {
                final List<_Secao> secoes = _montar(arquivos, vaga.maxWidth);
                if (secoes.isEmpty) return const EsqueletoDeGrade();

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification n) {
                    if (n is ScrollUpdateNotification ||
                        n is ScrollStartNotification) {
                      _acompanhar(secoes);
                    }
                    return false;
                  },
                  child: Stack(
                    children: <Widget>[
                      _Lista(
                        controlador: _rolagem,
                        secoes: secoes,
                        todos: arquivos,
                      ),
                      _Reguas(
                        secoes: secoes,
                        alturaTotal: secoes.isEmpty ? 0 : secoes.last.faixa.fim,
                        visivel: _rolando,
                      ),
                      _BolhaDoMes(mes: _mesNaTela, visivel: _rolando),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// Monta as seções e mede onde cada uma começa na rolagem.
  ///
  /// A medida é feita aqui, e não durante a rolagem, porque o rolador
  /// lateral precisa saber para onde pular **antes** de alguém arrastar, e
  /// porque perguntar a posição de um widget que ainda não foi desenhado não
  /// tem resposta: a lista é preguiçosa e só existe o que está na tela.
  List<_Secao> _montar(List<_Par> arquivos, double largura) {
    final double util = largura - Space.x8 * 2;
    final List<MesDoMosaico<_Par>> meses = mosaico<_Par>(
      itens: arquivos,
      quando: (_Par p) => p.$1.date,
      proporcao: (_Par p) => proporcaoSegura(p.$2.width, p.$2.height),
      largura: util,
      alturaAlvo: _alturaAlvo,
      espaco: _espaco,
    );

    final List<_Secao> secoes = <_Secao>[];
    double y = 0;
    for (final MesDoMosaico<_Par> m in meses) {
      final double altura =
          _alturaDoCabecalho +
          m.linhas.fold<double>(
            0,
            (double s, LinhaDoMosaico<_Par> l) => s + l.altura + _espaco,
          );
      secoes.add(
        _Secao(
          mosaico: m,
          faixa: FaixaDeMes(mes: m.mes, inicio: y, altura: altura),
        ),
      );
      y += altura;
    }
    return secoes;
  }

  /// Altura que uma linha tenta ter. Miniatura grande o bastante para
  /// reconhecer um rosto, e pequena o bastante para caber várias na tela.
  static const double _alturaAlvo = 116;

  /// Um respiro fino entre as fotos, no espírito do Design System.
  static const double _espaco = Space.x4;

  /// Cabeçalho do mês: a linha, o título e a folga em volta.
  static const double _alturaDoCabecalho = 56;
}

/// Uma seção de mês: o mosaico e a faixa que ele ocupa na rolagem.
@immutable
class _Secao {
  const _Secao({required this.mosaico, required this.faixa});

  final MesDoMosaico<_Par> mosaico;
  final FaixaDeMes faixa;

  DateTime get mes => faixa.mes;
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.controlador,
    required this.secoes,
    required this.todos,
  });

  final ScrollController controlador;
  final List<_Secao> secoes;
  final List<_Par> todos;

  @override
  Widget build(BuildContext context) {
    // O rolador lateral é o do Material, com arraste ligado. Ele já sabe
    // parar quando a lista acaba e já respeita a barra de sistema; refazê-lo
    // à mão custaria mais e acertaria menos. O que ele não faz é dizer onde
    // o dedo está no tempo, e é isso que o `_Reguas` desenha ao lado.
    return Scrollbar(
      controller: controlador,
      thumbVisibility: true,
      interactive: true,
      child: CustomScrollView(
        controller: controlador,
        slivers: <Widget>[
          for (final _Secao secao in secoes) ...<Widget>[
            SliverToBoxAdapter(child: _CabecalhoDoMes(secao: secao)),
            SliverToBoxAdapter(
              child: _Mosaico(mes: secao.mosaico, todos: todos),
            ),
          ],
          const SliverPadding(
            padding: EdgeInsets.only(bottom: Space.scrollEnd),
          ),
        ],
      ),
    );
  }
}

/// O título do mês, com a linha que separa uma seção da outra.
class _CabecalhoDoMes extends StatelessWidget {
  const _CabecalhoDoMes({required this.secao});

  final _Secao secao;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.x16,
        Space.x20,
        Space.x16,
        Space.x8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Divider(height: 1, color: context.cores.divider),
          const SizedBox(height: Space.x12),
          // Centralizado e sozinho.
          //
          // Sem a contagem de itens: aqui ela era um número que ninguém foi
          // buscar. Quem abre o acervo quer ver as fotos, e saber que julho
          // teve onze não muda nada do que se faz em seguida. Na linha do
          // tempo é diferente, porque lá o número diz o tamanho do mês antes
          // de a pessoa decidir se entra nele.
          //
          // Mês e ano sempre juntos: só o mês seria a mesma frase em vinte
          // anos diferentes.
          Text(
            Fmt.monthYear(secao.mes),
            textAlign: TextAlign.center,
            style: text.titleSmall,
          ),
        ],
      ),
    );
  }
}

/// As linhas justificadas de um mês.
class _Mosaico extends StatelessWidget {
  const _Mosaico({required this.mes, required this.todos});

  final MesDoMosaico<_Par> mes;
  final List<_Par> todos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.x8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final LinhaDoMosaico<_Par> linha in mes.linhas)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.x4),
              child: Row(
                children: <Widget>[
                  for (final LadrilhoDoMosaico<_Par> l in linha.ladrilhos) ...[
                    _Ladrilho(ladrilho: l, todos: todos),
                    if (l != linha.ladrilhos.last)
                      const SizedBox(width: Space.x4),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Ladrilho extends StatelessWidget {
  const _Ladrilho({required this.ladrilho, required this.todos});

  final LadrilhoDoMosaico<_Par> ladrilho;
  final List<_Par> todos;

  @override
  Widget build(BuildContext context) {
    final (Entry entry, EntryFile file) = ladrilho.item;

    return GestureDetector(
      onTap: () => abrirEmTelaCheia(
        context,
        MediaViewerScreen(
          files: todos.map((_Par r) => r.$2).toList(),
          entries: todos.map((_Par r) => r.$1).toList(),
          initialIndex: todos.indexOf(ladrilho.item),
          origemDoVoo: origemGaleria,
        ),
      ),
      child: SizedBox(
        width: ladrilho.largura,
        height: ladrilho.altura,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // O voo da miniatura até a tela cheia continua sendo o mesmo do
            // resto do aplicativo: a foto cresce do lugar onde estava.
            HeroDaMidia(
              origem: origemGaleria,
              file: file,
              child: DriveThumbnail(file: file, borderRadius: Radii.mediaR),
            ),
            if (file.isVideo)
              const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            if (entry.uploadStatus.isBusy)
              const Positioned(
                right: 6,
                top: 6,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A bolha que diz qual mês está passando.
///
/// Aparece com a rolagem e some sozinha quando ela para. Um rótulo fixo
/// ocuparia a tela o tempo todo para responder a uma pergunta que só existe
/// enquanto o dedo está se movendo.
class _BolhaDoMes extends StatelessWidget {
  const _BolhaDoMes({required this.mes, required this.visivel});

  final DateTime? mes;
  final bool visivel;

  @override
  Widget build(BuildContext context) {
    final DateTime? quando = mes;
    return Positioned(
      top: Space.x12,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visivel && quando != null ? 1 : 0,
          duration: Motion.fade,
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
                quando == null ? '' : Fmt.monthYear(quando),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// As marcas de ano ao lado do rolador.
///
/// É o que a barra sozinha não conta: ela diz que a lista é longa, e não em
/// que época o dedo está. Num acervo de vinte anos, arrastar sem referência
/// é procurar no escuro.
///
/// Só os anos aparecem, e não todos os meses. Um rótulo por mês num acervo
/// de dez anos seriam cento e vinte marcas empilhadas em quinhentos pixels,
/// ilegíveis por sobreposição. O mês continua sendo dito pela bolha, que é
/// exata e acompanha a rolagem.
class _Reguas extends StatelessWidget {
  const _Reguas({
    required this.secoes,
    required this.alturaTotal,
    required this.visivel,
  });

  final List<_Secao> secoes;

  /// Altura de toda a lista, para converter deslocamento em posição na tela.
  final double alturaTotal;

  final bool visivel;

  @override
  Widget build(BuildContext context) {
    if (alturaTotal <= 0) return const SizedBox.shrink();

    // Um rótulo por ano, na posição do primeiro mês daquele ano.
    final Map<int, _Secao> primeiroDoAno = <int, _Secao>{};
    for (final _Secao s in secoes) {
      primeiroDoAno.putIfAbsent(s.mes.year, () => s);
    }

    return Positioned(
      top: 0,
      bottom: 0,
      right: Space.x16,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visivel ? 1 : 0,
          duration: Motion.fade,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints vaga) {
              return Stack(
                children: <Widget>[
                  for (final _Secao s in primeiroDoAno.values)
                    Positioned(
                      // A posição do ano na barra é a fração dele na lista.
                      top: (s.faixa.inicio / alturaTotal * vaga.maxHeight)
                          .clamp(0.0, vaga.maxHeight - Sizes.chip),
                      right: 0,
                      child: _Marca(ano: s.mes.year),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.ano});

  final int ano;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Space.x4),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x12,
        vertical: Space.x4,
      ),
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: Radii.pillR,
        boxShadow: Shadows.level1,
      ),
      child: Text(
        '$ano',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: context.cores.textPrimary),
      ),
    );
  }
}
