import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/hero_da_midia.dart';
import '../common/widgets.dart';
import '../gallery/media_viewer_screen.dart';

/// Desenhos feitos por ela ou pelos pais, em uma grade simples.
class DrawingsScreen extends ConsumerWidget {
  const DrawingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Entry> drawings = ref.watch(
      entriesOfTypeProvider(EntryType.drawing),
    );
    final BabyProfile? profile = ref.watch(profileProvider).value;

    final List<(Entry, EntryFile)> tiles = <(Entry, EntryFile)>[
      for (final Entry entry in drawings)
        for (final EntryFile file in entry.files) (entry, file),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.drawings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: tiles.isEmpty
          ? const EmptyState(
              icon: Icons.brush_outlined,
              title: 'Nenhum desenho ainda',
              message: 'Fotografe um desenho e ele fica guardado para sempre.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(Space.x12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: Space.x12,
                mainAxisSpacing: Space.x12,
              ),
              itemCount: tiles.length,
              itemBuilder: (BuildContext context, int index) {
                final (Entry entry, EntryFile file) = tiles[index];
                return GestureDetector(
                  onTap: () => abrirEmTelaCheia(
                    context,
                    MediaViewerScreen(
                      files: tiles.map(((Entry, EntryFile) t) => t.$2).toList(),
                      entries: tiles
                          .map(((Entry, EntryFile) t) => t.$1)
                          .toList(),
                      initialIndex: index,
                      origemDoVoo: origemDesenhos,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      HeroDaMidia(
                        origem: origemDesenhos,
                        file: file,
                        child: DriveThumbnail(
                          file: file,
                          borderRadius: Radii.mediaR,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _Legenda(entry: entry, profile: profile),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// A faixa embaixo do desenho: quando foi, e que idade tinha.
///
/// Antes só aparecia o título, e desenho enviado pela folha de adicionar não
/// recebe título nenhum: na prática a grade inteira ficava sem uma palavra.
/// Um desenho sem data é uma folha de papel colorida; com a idade ao lado
/// dela vira o registro de que naquele mês a criança já segurava o lápis
/// assim. É essa segunda coisa que a cápsula existe para guardar.
///
/// A idade vem do cadastro, e não de `ageDays`, porque `ageDays` é um número
/// de dias e o que se lê aqui é `7 meses`. O cálculo é o mesmo do resto do
/// aplicativo, então os dois nunca discordam.
class _Legenda extends StatelessWidget {
  const _Legenda({required this.entry, required this.profile});

  final Entry entry;
  final BabyProfile? profile;

  @override
  Widget build(BuildContext context) {
    final String quando = Fmt.date(entry.date);
    final String? idade = profile?.ageAt(entry.date).shortLabel;

    return Container(
      padding: const EdgeInsets.all(Space.x12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.transparent, Color(0xB3000000)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (entry.title case final String titulo)
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          Text(
            idade == null ? quando : '$quando · $idade',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
