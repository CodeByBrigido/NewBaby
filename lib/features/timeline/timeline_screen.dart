import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/utils/error_text.dart';
import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/mosaico.dart';
import '../../core/utils/periodo.dart';
import '../../models/baby_profile.dart';
import '../../models/capsule_pulse.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/entrada_na_rolagem.dart';
import '../common/drive_image.dart';
import '../common/esqueleto.dart';
import '../common/hero_da_midia.dart';
import '../common/widgets.dart';
import '../gallery/media_viewer_screen.dart';
import 'timeline_card.dart';
import 'upload_banner.dart';

/// Tela principal: tudo em ordem cronológica, misturado numa linha só.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  EntryType? _filter;

  /// A lente do agrupamento. O mês é o padrão porque é a gaveta em que as
  /// pessoas pensam: "as fotos de maio", e não "as fotos da semana 19".
  Periodo _periodo = Periodo.mes;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Entry>> entries = ref.watch(entriesProvider);
    final BabyProfile? profile = ref.watch(profileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.timeline),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () =>
              ref.read(shellScaffoldKeyProvider).currentState?.openDrawer(),
        ),
        actions: <Widget>[
          // A escolha do período fica num menu suspenso, e não em abas.
          //
          // Abas ocupariam uma faixa da tela o tempo todo para uma escolha
          // que se faz uma vez e raramente se muda. O menu some depois de
          // usado, e o ícone marcado conta qual lente está valendo.
          PopupMenuButton<Periodo>(
            icon: const Icon(Icons.calendar_view_month_outlined),
            tooltip: S.groupBy,
            initialValue: _periodo,
            onSelected: (Periodo p) => setState(() => _periodo = p),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Periodo>>[
              for (final Periodo p in Periodo.values)
                PopupMenuItem<Periodo>(
                  value: p,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        p == _periodo
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: p == _periodo
                            ? context.cores.primary
                            : context.cores.muted,
                      ),
                      const SizedBox(width: Space.x12),
                      Text(p.plural),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
              _filter == null ? Icons.filter_list : Icons.filter_list_alt,
              color: _filter == null ? null : context.cores.primary,
            ),
            onPressed: _showFilter,
          ),
          // A lupa saiu daqui. Buscar por palavra só alcança o que tem texto
          // escrito, e o que enche a linha do tempo é foto e vídeo, que não
          // têm nenhum: procurar aqui quase sempre devolvia nada. Quem quer
          // procurar continua tendo a lupa na tela inicial.
        ],
      ),
      body: entries.when(
        loading: () => const EsqueletoDaLinhaDoTempo(),
        error: (Object error, _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: S.genericError,
          message: userMessage(error),
          // A reconexão já tenta sozinha, com espera crescente. O botão é
          // para quem não quer esperar: quem acabou de consertar a causa
          // do outro lado quer ver agora, não daqui a um minuto.
          action: TextButton(
            onPressed: () => ref.invalidate(entriesProvider),
            child: Text(S.retry),
          ),
        ),
        data: (List<Entry> all) {
          // O cadastro chega por outro caminho que as entradas, e pode
          // demorar um instante a mais. Mostrar o mesmo esqueleto evita a
          // troca de bolinha por esqueleto por conteúdo, que são três
          // desenhos diferentes para uma espera só.
          if (profile == null) return const EsqueletoDaLinhaDoTempo();
          final List<Entry> visible = _filter == null
              ? all
              : all.where((Entry e) => e.type == _filter).toList();

          if (visible.isEmpty) {
            return EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: _filter == null ? S.timelineEmptyTitle : S.noItemsYet,
              message: _filter == null
                  ? Copy.of(profile).timelineEmptyBody
                  : null,
            );
          }

          return TimelineList(
            entries: visible,
            profile: profile,
            periodo: _periodo,
          );
        },
      ),
    );
  }

  Future<void> _showFilter() async {
    final EntryType? selected = await showModalBottomSheet<EntryType?>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: Space.x16),
            Text(S.filterTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: Space.x8),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(S.filterAll),
              selected: _filter == null,
              onTap: () => Navigator.of(context).pop(),
            ),
            for (final EntryType type in EntryType.values)
              if (type != EntryType.birth)
                ListTile(
                  leading: Icon(type.icon, color: type.accent(context)),
                  title: Text(type.label),
                  selected: _filter == type,
                  onTap: () => Navigator.of(context).pop(type),
                ),
            const SizedBox(height: Space.x12),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _filter = selected);
  }
}

/// A lista da linha do tempo, agrupada pelo período escolhido.
///
/// Cada seção traz o período à esquerda, quantos itens ele tem à direita, e
/// abaixo as memórias: as que são imagem num mosaico de tamanhos variados, e
/// as que não são em cartões.
///
/// Antes o agrupamento era por dia. Dia funciona enquanto a cápsula é nova,
/// e vira uma escada infinita quando ela tem anos: rolar 2019 inteiro dia a
/// dia é o que faz alguém desistir de procurar. O período escolhido dá o
/// tamanho da gaveta, e o mesmo acervo se reagrupa sem perder nada.
///
/// Separada da tela para poder ser montada em testes sem Firebase.
class TimelineList extends StatelessWidget {
  const TimelineList({
    required this.entries,
    required this.profile,
    super.key,
    this.periodo = Periodo.mes,
    this.showHeader = true,
  });

  final List<Entry> entries;
  final BabyProfile profile;
  final Periodo periodo;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final List<FatiaDoTempo<Entry>> fatias = fatiarPorPeriodo<Entry>(
      itens: entries,
      quando: (Entry e) => e.date,
      periodo: periodo,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints vaga) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, Space.x8, 0, Space.scrollEnd),
          itemCount: fatias.length + (showHeader ? 2 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (showHeader) {
              if (index == 0) return _BabyHeader(profile: profile);
              if (index == 1) return const UploadBanner();
              index -= 2;
            }
            return EntradaNaRolagem(
              indice: index,
              child: _Fatia(
                fatia: fatias[index],
                profile: profile,
                periodo: periodo,
                largura: vaga.maxWidth,
                ultima: index == fatias.length - 1,
              ),
            );
          },
        );
      },
    );
  }
}

/// Uma seção de período: cabeçalho, mosaico e cartões.
class _Fatia extends StatelessWidget {
  const _Fatia({
    required this.fatia,
    required this.profile,
    required this.periodo,
    required this.largura,
    required this.ultima,
  });

  final FatiaDoTempo<Entry> fatia;
  final BabyProfile profile;
  final Periodo periodo;
  final double largura;
  final bool ultima;

  /// A data redonda que caiu neste período, se caiu alguma.
  ///
  /// Procurada entre os dias em que há memória, e não no calendário inteiro:
  /// um "1 ano" num mês sem nenhuma foto seria um selo apontando para o
  /// vazio. A conta é a mesma da tela inicial, de propósito: duas contas
  /// separadas para a mesma pergunta acabariam divergindo, e o histórico
  /// contradiria a abertura do aplicativo.
  String? get _redonda {
    for (final Entry e in fatia.itens) {
      final String? r = CapsulePulse.dataRedondaEm(profile.birth, e.date);
      if (r != null) return r;
    }
    return null;
  }

  /// Largura do trilho da esquerda, com o ponto e a linha.
  static const double _trilho = 32;

  /// Só o que é imagem entra no mosaico.
  ///
  /// Carta e crescimento não têm o que mostrar numa miniatura, e documento é
  /// quase sempre um PDF: os três continuam em cartão, que é onde o conteúdo
  /// deles cabe. Sem essa separação, uma carta viraria um retângulo cinza no
  /// meio das fotos.
  static bool _ehImagem(EntryType t) =>
      t == EntryType.photo || t == EntryType.video || t == EntryType.drawing;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    final List<(Entry, EntryFile)> imagens = <(Entry, EntryFile)>[
      for (final Entry e in fatia.itens)
        if (_ehImagem(e.type))
          for (final EntryFile f in e.files) (e, f),
    ];
    final List<Entry> cartoes = <Entry>[
      for (final Entry e in fatia.itens)
        if (!_ehImagem(e.type)) e,
    ];

    // Quantos itens o período tem, contando arquivo por arquivo: uma
    // postagem com doze fotos são doze memórias para quem está olhando.
    final int quantos = imagens.length + cartoes.length;
    final double util = largura - _trilho - Space.x16;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TrilhoDoPeriodo(ultima: ultima),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: Space.x16,
                bottom: Space.x24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(fatia.rotulo, style: text.titleSmall),
                      ),
                      const SizedBox(width: Space.x8),
                      Text(
                        S.contarItens(quantos),
                        style: text.labelSmall?.copyWith(
                          color: context.cores.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (_redonda case final String marco) ...<Widget>[
                    const SizedBox(height: Space.x8),
                    _SeloDaDataRedonda(rotulo: marco),
                  ],
                  const SizedBox(height: Space.x12),
                  if (imagens.isNotEmpty)
                    _MosaicoDoPeriodo(imagens: imagens, largura: util),
                  for (final Entry e in cartoes) ...<Widget>[
                    const SizedBox(height: Space.x12),
                    TimelineCard(entry: e),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// O ponto do período e a linha que liga um ao seguinte.
class _TrilhoDoPeriodo extends StatelessWidget {
  const _TrilhoDoPeriodo({required this.ultima});

  final bool ultima;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _Fatia._trilho,
      child: Column(
        children: <Widget>[
          const SizedBox(height: Space.x4),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: context.cores.primary,
              shape: BoxShape.circle,
            ),
          ),
          if (!ultima)
            Expanded(
              child: VerticalDivider(
                width: 1,
                thickness: 1.5,
                color: context.cores.primarySoft,
              ),
            ),
        ],
      ),
    );
  }
}

/// As imagens do período, em linhas justificadas.
class _MosaicoDoPeriodo extends StatelessWidget {
  const _MosaicoDoPeriodo({required this.imagens, required this.largura});

  final List<(Entry, EntryFile)> imagens;
  final double largura;

  @override
  Widget build(BuildContext context) {
    final List<MesDoMosaico<(Entry, EntryFile)>> blocos =
        mosaico<(Entry, EntryFile)>(
          itens: imagens,
          // Um período já é uma fatia só, então o agrupamento por mês de
          // dentro do mosaico não separa nada: tudo cai num bloco.
          quando: ((Entry, EntryFile) _) => DateTime(2000),
          proporcao: ((Entry, EntryFile) p) =>
              proporcaoSegura(p.$2.width, p.$2.height),
          largura: largura,
          alturaAlvo: 104,
          espaco: Space.x4,
        );
    if (blocos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final LinhaDoMosaico<(Entry, EntryFile)> linha
            in blocos.single.linhas)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.x4),
            child: Row(
              children: <Widget>[
                for (final LadrilhoDoMosaico<(Entry, EntryFile)> l
                    in linha.ladrilhos) ...<Widget>[
                  _LadrilhoDoTempo(ladrilho: l, todos: imagens),
                  if (l != linha.ladrilhos.last)
                    const SizedBox(width: Space.x4),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _LadrilhoDoTempo extends StatelessWidget {
  const _LadrilhoDoTempo({required this.ladrilho, required this.todos});

  final LadrilhoDoMosaico<(Entry, EntryFile)> ladrilho;
  final List<(Entry, EntryFile)> todos;

  @override
  Widget build(BuildContext context) {
    final (Entry entry, EntryFile file) = ladrilho.item;

    return GestureDetector(
      onTap: () => abrirEmTelaCheia(
        context,
        MediaViewerScreen(
          files: todos.map(((Entry, EntryFile) r) => r.$2).toList(),
          entries: todos.map(((Entry, EntryFile) r) => r.$1).toList(),
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

class _BabyHeader extends StatelessWidget {
  const _BabyHeader({required this.profile});

  final BabyProfile profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.x16,
        Space.x8,
        Space.x16,
        Space.x16,
      ),
      child: Container(
        padding: const EdgeInsets.all(Space.x16),
        decoration: BoxDecoration(
          color: context.cores.primarySoft,
          borderRadius: Radii.cardR,
        ),
        child: Row(
          children: <Widget>[
            BabyAvatar(profile: profile, radius: 24),
            const SizedBox(width: Space.x16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(profile.name, style: text.titleMedium),
                  const SizedBox(height: Space.x4),
                  Text(
                    Fmt.longDate(profile.birth),
                    style: text.bodySmall?.copyWith(
                      color: context.cores.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O selo do período em que caiu uma data redonda.
///
/// A linha do tempo é uma sequência de períodos iguais, e é justamente por
/// isso que "1 ano" precisa saltar quando alguém rola até lá. Sem marca, o
/// mês mais importante do acervo tem exatamente a mesma cara que um mês
/// qualquer.
///
/// O selo fica: quem rolar de novo daqui a dez anos precisa ver a mesma
/// marca. O que é passageiro é só a entrada dele, que cresce até o tamanho
/// final para o olho ir até ali na primeira vez.
class _SeloDaDataRedonda extends StatefulWidget {
  const _SeloDaDataRedonda({required this.rotulo});

  final String rotulo;

  @override
  State<_SeloDaDataRedonda> createState() => _SeloDaDataRedondaState();
}

class _SeloDaDataRedondaState extends State<_SeloDaDataRedonda> {
  late bool _cresceu = WidgetsBinding.instance.disableAnimations;

  @override
  void initState() {
    super.initState();
    if (_cresceu) return;
    // Um quadro depois, para o `AnimatedScale` ter de onde sair. Marcado no
    // mesmo instante da construção, ele nasceria já no tamanho final.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _cresceu = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _cresceu ? 1 : 0.8,
      duration: Motion.micro,
      curve: Motion.entrada,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.x8,
          vertical: Space.x4,
        ),
        decoration: BoxDecoration(
          color: context.cores.primarySoft,
          borderRadius: Radii.pillR,
        ),
        child: Text(
          widget.rotulo,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.cores.primaryStrong,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
