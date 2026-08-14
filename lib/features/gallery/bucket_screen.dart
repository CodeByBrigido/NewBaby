import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/utils/secoes_do_balde.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/hero_da_midia.dart';
import '../common/widgets.dart';
import 'gallery_screen.dart';
import 'media_viewer_screen.dart';

/// Grade com todos os arquivos de um balde de idade.
class BucketScreen extends ConsumerWidget {
  const BucketScreen({required this.type, required this.bucketKey, super.key});

  final EntryType type;
  final String bucketKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<Entry> entries = ref.watch(entriesOfTypeProvider(type));

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final AgeBucketUnit unit = _unitFromKey(bucketKey);
    final List<BucketSummary> buckets = groupIntoBuckets(
      entries: entries,
      profile: profile,
      unit: unit,
    );
    final BucketSummary? summary = buckets
        .where((BucketSummary b) => b.bucket.key == bucketKey)
        .firstOrNull;

    final List<(Entry, EntryFile)> files = <(Entry, EntryFile)>[
      if (summary != null)
        for (final Entry entry in summary.entries)
          for (final EntryFile file in entry.files) (entry, file),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(summary?.bucket.folderName ?? type.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: files.isEmpty
          ? EmptyState(icon: type.icon, title: S.noItemsYet)
          : _Grade(
              secoes: summary == null
                  ? const <SecaoDoBalde<(Entry, EntryFile)>>[]
                  : secoesDoBalde<(Entry, EntryFile)>(
                      balde: summary.bucket,
                      itens: files,
                      quando: ((Entry, EntryFile) r) => r.$1.date,
                    ),
              todos: files,
            ),
    );
  }

  /// A primeira letra da chave (`S07`, `M14`, `A03`) diz a unidade.
  static AgeBucketUnit _unitFromKey(String key) {
    final String prefix = key.isEmpty ? '' : key[0];
    return switch (prefix) {
      'M' => AgeBucketUnit.month,
      'A' => AgeBucketUnit.year,
      _ => AgeBucketUnit.week,
    };
  }
}

/// A grade da pasta, dividida nas seções que a pasta comporta.
///
/// Uma lista de seções e não uma grade só, porque um mês guarda semanas e um
/// ano guarda meses: sem os títulos, abrir o `Mês 14` é rolar uma parede de
/// fotos sem nenhuma pista de quando cada uma aconteceu.
///
/// A pasta de semana volta com uma seção só, de título vazio, e aí nenhum
/// cabeçalho é desenhado: sete dias não têm o que separar.
class _Grade extends StatelessWidget {
  const _Grade({required this.secoes, required this.todos});

  final List<SecaoDoBalde<(Entry, EntryFile)>> secoes;

  /// Todos os arquivos da pasta, na ordem em que aparecem.
  ///
  /// O visualizador em tela cheia desliza pela pasta inteira, e não só pela
  /// seção em que se tocou: quem está olhando uma foto da Semana 2 espera
  /// chegar na Semana 3 arrastando, como chegaria numa grade sem seções.
  final List<(Entry, EntryFile)> todos;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        for (final SecaoDoBalde<(Entry, EntryFile)> secao
            in secoes) ...<Widget>[
          if (secao.titulo.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Space.x12,
                Space.x16,
                Space.x12,
                Space.x8,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(title: secao.titulo),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Space.x12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: Space.x8,
                mainAxisSpacing: Space.x8,
              ),
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final (Entry, EntryFile) par = secao.itens[index];
                return _Ladrilho(par: par, todos: todos);
              }, childCount: secao.itens.length),
            ),
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: Space.scrollEnd)),
      ],
    );
  }
}

class _Ladrilho extends StatelessWidget {
  const _Ladrilho({required this.par, required this.todos});

  final (Entry, EntryFile) par;
  final List<(Entry, EntryFile)> todos;

  @override
  Widget build(BuildContext context) {
    final (Entry entry, EntryFile file) = par;
    return GestureDetector(
      onTap: () => abrirEmTelaCheia(
        context,
        MediaViewerScreen(
          files: todos.map(((Entry, EntryFile) r) => r.$2).toList(),
          entries: todos.map(((Entry, EntryFile) r) => r.$1).toList(),
          initialIndex: todos.indexOf(par),
          origemDoVoo: origemGaleria,
        ),
      ),
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
                size: 32,
              ),
            ),
          if (entry.uploadStatus.isBusy)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(Space.x4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
