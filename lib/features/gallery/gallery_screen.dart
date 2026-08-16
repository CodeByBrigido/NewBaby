import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/esqueleto.dart';
import '../common/widgets.dart';

/// Um balde de idade já resolvido para exibição: quantos arquivos tem, a
/// capa e o intervalo de datas.
class BucketSummary {
  const BucketSummary({
    required this.bucket,
    required this.entries,
    required this.fileCount,
  });

  final AgeBucket bucket;
  final List<Entry> entries;
  final int fileCount;

  EntryFile? get cover =>
      entries.firstWhereOrNull((Entry e) => e.coverFile != null)?.coverFile;
}

/// Agrupa as entradas de um tipo nos baldes de idade da unidade escolhida.
///
/// Uma foto tirada na `Semana 07` também pertence ao `Mês 02` e ao `Ano 0`;
/// as abas simplesmente mudam a lente sobre o mesmo acervo.
List<BucketSummary> groupIntoBuckets({
  required List<Entry> entries,
  required BabyProfile profile,
  required AgeBucketUnit unit,
}) {
  final Map<String, List<Entry>> grouped = <String, List<Entry>>{};
  final Map<String, AgeBucket> buckets = <String, AgeBucket>{};

  for (final Entry entry in entries) {
    final AgeBucket bucket = _bucketFor(profile, entry.date, unit);
    grouped.putIfAbsent(bucket.key, () => <Entry>[]).add(entry);
    buckets[bucket.key] = bucket;
  }

  final List<BucketSummary> result = grouped.entries
      .map(
        (MapEntry<String, List<Entry>> e) => BucketSummary(
          bucket: buckets[e.key]!,
          entries: e.value,
          fileCount: e.value.fold(
            0,
            (int sum, Entry entry) =>
                sum + (entry.hasFiles ? entry.files.length : 0),
          ),
        ),
      )
      .toList();

  // Do mais recente para o mais antigo, como o resto do aplicativo.
  result.sort(
    (BucketSummary a, BucketSummary b) =>
        b.bucket.start.compareTo(a.bucket.start),
  );
  return result;
}

/// Reprojeta a data na unidade pedida pela aba.
AgeBucket _bucketFor(BabyProfile profile, DateTime date, AgeBucketUnit unit) {
  final DateTime birth = profile.birthDay;
  final Age age = AgeCalculator.ageAt(birth, date);

  switch (unit) {
    case AgeBucketUnit.week:
      final int index = (age.totalDays ~/ 7) + 1;
      final DateTime start = birth.add(Duration(days: (index - 1) * 7));
      return AgeBucket(
        unit: AgeBucketUnit.week,
        index: index,
        start: start,
        end: start.add(const Duration(days: 6)),
      );
    case AgeBucketUnit.month:
      final int index = age.months + 1;
      return AgeBucket(
        unit: AgeBucketUnit.month,
        index: index,
        start: AgeCalculator.addMonths(birth, index - 1),
        end: AgeCalculator.addMonths(
          birth,
          index,
        ).subtract(const Duration(days: 1)),
      );
    case AgeBucketUnit.year:
      final int index = age.years;
      return AgeBucket(
        unit: AgeBucketUnit.year,
        index: index,
        start: AgeCalculator.addMonths(birth, index * 12),
        end: AgeCalculator.addMonths(
          birth,
          (index + 1) * 12,
        ).subtract(const Duration(days: 1)),
      );
  }
}

/// Tela de Fotos ou de Vídeos: abas Anos · Meses · Semanas.
///
/// A ordem vai do maior período para o menor, e é a ordem em que se procura
/// uma memória antiga: primeiro o ano, depois o mês, depois a semana.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({required this.type, super.key});

  final EntryType type;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with SingleTickerProviderStateMixin {
  static const List<AgeBucketUnit> _unidades = <AgeBucketUnit>[
    AgeBucketUnit.year,
    AgeBucketUnit.month,
    AgeBucketUnit.week,
  ];

  /// O controlador é um só para a barra e para o conteúdo.
  ///
  /// É isso que faz o realce acompanhar o dedo em vez de pular quando o
  /// arrasto termina: os dois leem a mesma animação, que durante o gesto
  /// vale um número quebrado entre duas abas.
  late final TabController _abas = TabController(
    length: _unidades.length,
    // Abre no ano, que é a primeira da fila.
    //
    // Escrito por unidade e não como zero: se a ordem das abas mudar de
    // novo, a aba de entrada continua sendo o ano em vez de virar seja lá o
    // que tiver ido para o começo.
    initialIndex: _unidades.indexOf(AgeBucketUnit.year),
    vsync: this,
  );

  @override
  void dispose() {
    _abas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<Entry> entries = ref.watch(entriesOfTypeProvider(widget.type));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: profile == null
          ? const EsqueletoDeGrade()
          : Column(
              children: <Widget>[
                _UnitTabs(controller: _abas, unidades: _unidades),
                Expanded(
                  child: entries.isEmpty
                      ? EmptyState(
                          icon: widget.type.icon,
                          title: S.noItemsYet,
                          message: widget.type == EntryType.photo
                              ? 'Toque no + para adicionar as primeiras fotos.'
                              : 'Toque no + para adicionar o primeiro vídeo.',
                        )
                      : TabBarView(
                          controller: _abas,
                          children: <Widget>[
                            for (final AgeBucketUnit unidade in _unidades)
                              _BucketList(
                                type: widget.type,
                                buckets: groupIntoBuckets(
                                  entries: entries,
                                  profile: profile,
                                  unit: unidade,
                                ),
                              ),
                          ],
                        ),
                ),
                if (widget.type == EntryType.photo)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.x20,
                      0,
                      Space.x20,
                      Space.x16,
                    ),
                    child: Text(
                      S.photosOptimizedNote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
    );
  }
}

/// A barra de abas, com o realce deslizando de uma para a outra.
///
/// O realce não é desenhado na aba escolhida: ele é **posicionado** a partir
/// da animação do controlador, que durante um arrasto vale um número
/// quebrado. Meio caminho entre Meses e Semanas põe o realce no meio do
/// caminho, e é isso que faz a cor parecer sair de uma e chegar na outra em
/// vez de acender e apagar.
class _UnitTabs extends StatelessWidget {
  const _UnitTabs({required this.controller, required this.unidades});

  final TabController controller;
  final List<AgeBucketUnit> unidades;

  static const Map<AgeBucketUnit, String> _rotulos = <AgeBucketUnit, String>{
    AgeBucketUnit.week: S.weeks,
    AgeBucketUnit.month: S.months,
    AgeBucketUnit.year: S.years,
  };

  @override
  Widget build(BuildContext context) {
    // Não nulo porque o controlador é criado com `vsync`. O tipo é opcional
    // só para o caso de alguém montar um sem animação nenhuma.
    final Animation<double> posicao = controller.animation!;
    final bool semAnimacao = MediaQuery.disableAnimationsOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.x16,
        Space.x4,
        Space.x16,
        Space.x12,
      ),
      child: Container(
        padding: const EdgeInsets.all(Space.x4),
        decoration: BoxDecoration(
          color: context.cores.surfaceMuted,
          borderRadius: Radii.pillR,
        ),
        child: SizedBox(
          height: Sizes.chip,
          child: AnimatedBuilder(
            animation: posicao,
            builder: (BuildContext context, Widget? _) {
              final double onde = posicao.value;
              return Stack(
                children: <Widget>[
                  // O realce. `Alignment` vai de -1 a 1, e a posição sai
                  // direto da animação, sem arredondar para a aba mais
                  // próxima: arredondar aqui é o que faria ele pular.
                  Align(
                    alignment: Alignment(
                      unidades.length == 1
                          ? 0
                          : (onde / (unidades.length - 1)) * 2 - 1,
                      0,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1 / unidades.length,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.cores.primarySoft,
                          borderRadius: Radii.cardR,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < unidades.length; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => semAnimacao
                                ? controller.index = i
                                : controller.animateTo(
                                    i,
                                    duration: Motion.slide,
                                  ),
                            child: Center(
                              child: _Rotulo(
                                texto: _rotulos[unidades[i]]!,
                                // 1 na aba escolhida, 0 nas outras, e o meio
                                // do caminho durante o arrasto. A cor do
                                // texto acompanha o realce em vez de trocar
                                // de uma vez quando o gesto termina.
                                proximidade: (1 - (onde - i).abs()).clamp(
                                  0.0,
                                  1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _Rotulo extends StatelessWidget {
  const _Rotulo({required this.texto, required this.proximidade});

  final String texto;

  /// Quanto esta aba é a escolhida, de 0 a 1.
  final double proximidade;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: text.labelMedium?.copyWith(
        color: Color.lerp(
          context.cores.textSecondary,
          context.cores.primaryDark,
          proximidade,
        ),
        fontWeight: FontWeight.lerp(
          FontWeight.w500,
          FontWeight.w600,
          proximidade,
        ),
      ),
    );
  }
}

class _BucketList extends StatelessWidget {
  const _BucketList({required this.type, required this.buckets});

  final EntryType type;
  final List<BucketSummary> buckets;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Space.x16, 0, Space.x16, Space.x24),
      itemCount: buckets.length,
      separatorBuilder: (_, _) => const SizedBox(height: Space.x12),
      itemBuilder: (BuildContext context, int index) {
        final BucketSummary summary = buckets[index];
        final EntryFile? cover = summary.cover;

        return SoftCard(
          padding: const EdgeInsets.all(Space.x12),
          onTap: () => context.push(
            Routes.bucket(
              type == EntryType.photo ? 'fotos' : 'videos',
              summary.bucket.key,
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: cover == null
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: type.soft(context),
                          borderRadius: Radii.fieldR,
                        ),
                        child: Icon(type.icon, color: type.accent(context)),
                      )
                    : DriveThumbnail(file: cover, borderRadius: Radii.fieldR),
              ),
              const SizedBox(width: Space.x16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(summary.bucket.folderName, style: text.titleSmall),
                    const SizedBox(height: Space.x4),
                    Text(
                      Fmt.dateRange(summary.bucket.start, summary.bucket.end),
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: Space.x4),
                    Text(
                      type == EntryType.photo
                          ? Fmt.count(summary.fileCount, 'foto', 'fotos')
                          : Fmt.count(summary.fileCount, 'vídeo', 'vídeos'),
                      style: text.labelSmall?.copyWith(
                        color: context.cores.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: context.cores.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }
}
