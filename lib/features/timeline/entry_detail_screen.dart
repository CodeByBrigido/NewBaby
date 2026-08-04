import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';
import '../gallery/media_viewer_screen.dart';
import 'details_editor_sheet.dart';

/// Detalhe de uma entrada com arquivos: grade, descrição e ações.
class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Entry? entry = ref
        .watch(entriesProvider)
        .value
        ?.firstWhereOrNull((Entry e) => e.id == entryId);
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final TextTheme text = Theme.of(context).textTheme;

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.timeline),
          ),
        ),
        body: const EmptyState(
          icon: Icons.image_outlined,
          title: 'Memória não encontrada',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.headline, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
        actions: <Widget>[
          // Sem editar e sem apagar para quem foi convidado. As regras do
          // servidor já recusariam, mas um botão que existe e não funciona é
          // uma promessa quebrada: melhor não oferecer.
          if (!ref.watch(isReadOnlyProvider)) ...<Widget>[
            IconButton(
              tooltip: S.milestoneOptional,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showDetailsEditor(context, entry),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, entry),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Row(
            children: <Widget>[
              CategoryBadge(type: entry.type, size: 40, iconSize: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(Fmt.longDate(entry.date), style: text.titleSmall),
                    const SizedBox(height: 3),
                    Text(entry.bucketName, style: text.labelSmall),
                  ],
                ),
              ),
              if (profile != null)
                AgeChip(age: profile.ageAt(entry.date), compact: true),
            ],
          ),
          if (entry.description != null &&
              entry.description!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Text(entry.description!, style: text.bodyMedium),
          ],
          const SizedBox(height: 20),
          if (entry.hasFiles)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: entry.files.length,
              itemBuilder: (BuildContext context, int index) {
                final EntryFile file = entry.files[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MediaViewerScreen(
                        files: entry.files,
                        entries: List<Entry>.filled(entry.files.length, entry),
                        initialIndex: index,
                      ),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      DriveThumbnail(
                        file: file,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      if (file.isVideo)
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white70,
                            size: 36,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          if (entry.uploadStatus == UploadStatus.failed) ...<Widget>[
            const SizedBox(height: 20),
            InfoNote(
              message: entry.errorMessage ?? S.uploadFailed,
              icon: Icons.error_outline,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => _retry(context, ref, entry),
              child: const Text(S.retry),
            ),
          ] else if (entry.uploadStatus.isBusy) ...<Widget>[
            const SizedBox(height: 20),
            InfoNote(
              message: entry.uploadStatus.label,
              icon: Icons.cloud_upload_outlined,
            ),
          ],
          if (entry.type == EntryType.video) ...<Widget>[
            const SizedBox(height: 20),
            const InfoNote(message: S.videoOptimizedNote),
          ],
        ],
      ),
    );
  }

  Future<void> _retry(BuildContext context, WidgetRef ref, Entry entry) async {
    final String? uid = ref.read(uidProvider);
    final BabyProfile? profile = ref.read(profileProvider).value;
    if (uid == null || profile == null) return;
    await ref.read(memoryRepositoryProvider).retry(uid, profile, entry);
    if (context.mounted) showMessage(context, S.uploadSending);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Entry entry) async {
    final bool confirmed = await confirm(
      context,
      title: S.deleteConfirmTitle,
      message: S.deleteConfirmBody,
      confirmLabel: S.delete,
    );
    if (!confirmed) return;

    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    await ref.read(memoryRepositoryProvider).moveToTrash(uid, entry);
    if (context.mounted) context.pop();
  }
}
