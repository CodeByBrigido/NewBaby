import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Aplica o arrastão e grava a ordem nova.
///
/// Usa `onReorderItem`, e não o `onReorder` antigo. O antigo entregava a
/// posição de destino contada **antes** de o item sair de onde estava, então
/// quem move para baixo recebia um índice a mais e precisava descontar na
/// mão. Esse desconto é o erro clássico daqui: esquecido, o item cai sempre
/// uma posição antes de onde a pessoa soltou, e só se descobre arrastando.
/// O novo já entrega o índice final.
void _reordenar(WidgetRef ref, List<Entry> atual, int de, int para) {
  if (de == para) return;

  final List<Entry> nova = <Entry>[...atual];
  nova.insert(para, nova.removeAt(de));

  final String? uid = ref.read(uidProvider);
  if (uid == null) return;
  unawaited(ref.read(memoryRepositoryProvider).reordenar(uid, nova));
}

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Entry> documents = ref.watch(documentsProvider);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.documents),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: documents.isEmpty
          ? const EmptyState(
              icon: Icons.description_outlined,
              title: 'Nenhum documento ainda',
              message:
                  'Certidão, carteira de vacinação, passaporte - tudo em um '
                  'lugar só.',
            )
          // Arrastável, porque documento não tem ordem natural.
          //
          // Foto e vídeo se ordenam sozinhos pelo tempo: quem procura uma
          // foto procura por quando ela aconteceu. Documento não. Uma
          // certidão não fica menos importante por ser antiga, e quem abre
          // esta tela abre procurando o que precisa hoje, que pode ser o
          // documento mais velho de todos.
          //
          // A ordem escolhida fica gravada, então vale em qualquer aparelho
          // que entre na mesma conta.
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x8,
                Space.x16,
                Space.scrollEnd,
              ),
              itemCount: documents.length,
              onReorderItem: (int de, int para) =>
                  _reordenar(ref, documents, de, para),
              // Sem a alça de série: o cartão inteiro responde ao toque
              // longo. Uma alça de 24 px ao lado de um cartão de 72 é um
              // alvo pequeno para quem está com o bebê no colo, e ela ainda
              // roubaria a largura do nome do documento.
              buildDefaultDragHandles: false,
              itemBuilder: (BuildContext context, int index) {
                final Entry entry = documents[index];
                final EntryFile? file = entry.coverFile;

                return Padding(
                  key: ValueKey<String>(entry.id),
                  padding: const EdgeInsets.only(bottom: Space.x12),
                  child: ReorderableDelayedDragStartListener(
                    index: index,
                    child: SoftCard(
                      onTap: () => context.push(Routes.document(entry.id)),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.cores.documentSoft,
                              borderRadius: Radii.fieldR,
                            ),
                            child: Text(
                              file?.extensionLabel ?? 'DOC',
                              style: text.labelSmall?.copyWith(
                                color: context.cores.document,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: Space.x16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  entry.title ?? file?.name ?? S.documents,
                                  style: text.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: Space.x4),
                                Text(
                                  <String>[
                                    Fmt.date(entry.date),
                                    if (file != null && file.sizeBytes > 0)
                                      Fmt.bytes(file.sizeBytes),
                                  ].join(' · '),
                                  style: text.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          if (entry.uploadStatus.isBusy)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: context.cores.textSecondary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
