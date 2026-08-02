import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/gendered.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../services/memory_repository.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';
import '../growth/growth_editor_sheet.dart';
import '../timeline/details_editor_sheet.dart';

/// Folha "O que você deseja adicionar?".
///
/// Cada opção leva ao envio em dois ou três toques - sem formulário
/// obrigatório em nenhum caminho.
Future<void> showAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => const _AddSheet(),
  );
}

class _AddSheet extends ConsumerWidget {
  const _AddSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final G g = G.of(ref.watch(profileProvider).value?.gender);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(S.addQuestion, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            _Option(
              type: EntryType.photo,
              title: S.addPhoto,
              subtitle: g.addPhotoHint,
              onTap: () => _addPhotos(context, ref),
            ),
            _Option(
              type: EntryType.video,
              title: S.addVideo,
              subtitle: g.addVideoHint,
              onTap: () => _addVideos(context, ref),
            ),
            _Option(
              type: EntryType.letter,
              title: S.addLetter,
              subtitle: g.addLetterHint,
              onTap: () {
                Navigator.of(context).pop();
                context.push(Routes.newLetter);
              },
            ),
            _Option(
              type: EntryType.drawing,
              title: S.addDrawing,
              subtitle: S.addDrawingHint,
              onTap: () => _addDrawings(context, ref),
            ),
            _Option(
              type: EntryType.document,
              title: S.addDocument,
              subtitle: S.addDocumentHint,
              onTap: () => _addDocuments(context, ref),
            ),
            _Option(
              type: EntryType.growth,
              title: S.addGrowth,
              subtitle: S.addGrowthHint,
              onTap: () {
                Navigator.of(context).pop();
                showGrowthEditor(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Contexto necessário para qualquer envio.
({String uid, BabyProfile profile})? _context(WidgetRef ref) {
  final String? uid = ref.read(uidProvider);
  final BabyProfile? profile = ref.read(profileProvider).value;
  if (uid == null || profile == null) return null;
  return (uid: uid, profile: profile);
}

Future<void> _addPhotos(BuildContext context, WidgetRef ref) async {
  final List<XFile> picked = await ExternalActivity.run(
    () => ImagePicker().pickMultiImage(
      // Sem metadados completos a seleção é bem mais rápida; a orientação é
      // preservada na compressão.
      requestFullMetadata: false,
    ),
  );
  if (picked.isEmpty) return;
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    type: EntryType.photo,
    files: picked
        .map((XFile f) => PendingFile(path: f.path, kind: EntryType.photo))
        .toList(),
    message:
        'Enviando ${picked.length == 1 ? 'a foto' : '${picked.length} fotos'}...',
  );
}

Future<void> _addDrawings(BuildContext context, WidgetRef ref) async {
  final List<XFile> picked = await ExternalActivity.run(
    () => ImagePicker().pickMultiImage(requestFullMetadata: false),
  );
  if (picked.isEmpty) return;
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    type: EntryType.drawing,
    files: picked
        .map((XFile f) => PendingFile(path: f.path, kind: EntryType.drawing))
        .toList(),
    message: 'Guardando o desenho...',
  );
}

Future<void> _addVideos(BuildContext context, WidgetRef ref) async {
  // `image_picker` só escolhe um vídeo por vez; o `file_picker` permite
  // vários de uma vez, que é o que a especificação pede.
  final FilePickerResult? result = await ExternalActivity.run(
    () => FilePicker.pickFiles(type: FileType.video, allowMultiple: true),
  );
  final List<PlatformFile> files = result?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return;
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    type: EntryType.video,
    files: files
        .where((PlatformFile f) => f.path != null)
        .map(
          (PlatformFile f) =>
              PendingFile(path: f.path!, kind: EntryType.video, name: f.name),
        )
        .toList(),
    message: 'Convertendo para 720p e enviando...',
  );
}

Future<void> _addDocuments(BuildContext context, WidgetRef ref) async {
  final FilePickerResult? result = await ExternalActivity.run(
    () => FilePicker.pickFiles(allowMultiple: true),
  );
  final List<PlatformFile> files = result?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return;
  if (!context.mounted) return;

  for (final PlatformFile file in files) {
    if (file.path == null) continue;
    if (!context.mounted) return;
    await _send(
      context,
      ref,
      type: EntryType.document,
      files: <PendingFile>[
        PendingFile(
          path: file.path!,
          kind: EntryType.document,
          name: file.name,
        ),
      ],
      title: _titleFromFileName(file.name),
      message: 'Enviando ${file.name}...',
      keepSheetOpen: true,
    );
  }
  if (context.mounted) Navigator.of(context).maybePop();
}

/// `Certidão de Nascimento.pdf` vira `Certidão de Nascimento`.
String _titleFromFileName(String name) {
  final int dot = name.lastIndexOf('.');
  return dot <= 0 ? name : name.substring(0, dot);
}

Future<void> _send(
  BuildContext context,
  WidgetRef ref, {
  required EntryType type,
  required List<PendingFile> files,
  required String message,
  String? title,
  bool keepSheetOpen = false,
}) async {
  final ({String uid, BabyProfile profile})? ctx = _context(ref);
  if (ctx == null) {
    showMessage(context, S.genericError);
    return;
  }
  if (files.isEmpty) return;

  if (!keepSheetOpen) Navigator.of(context).pop();

  try {
    final Entry entry = await ref
        .read(memoryRepositoryProvider)
        .addFiles(
          uid: ctx.uid,
          profile: ctx.profile,
          type: type,
          files: files,
          title: title,
        );
    if (!context.mounted) return;

    // Documentos já vêm com o nome do arquivo como título; para foto, vídeo
    // e desenho o aviso é a chance de dizer que aquilo foi o "Primeiro
    // sorriso" - opcional, e sem segurar o envio.
    if (type == EntryType.document) {
      showMessage(context, message);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Marcar',
            onPressed: () => showDetailsEditor(context, entry),
          ),
        ),
      );
  } on Exception catch (e) {
    if (context.mounted) {
      showMessage(context, userMessage(e, context: 'Enviar memória'));
    }
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final EntryType type;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: type.soft,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Icon(type.icon, color: type.accent, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
