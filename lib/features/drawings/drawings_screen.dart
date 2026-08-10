import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
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
                      if (entry.title != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(Space.x12),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                              ),
                            ),
                            child: Text(
                              entry.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
