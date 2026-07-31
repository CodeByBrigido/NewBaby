import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/age_calculator.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';
import 'gallery_screen.dart';
import 'media_viewer_screen.dart';

/// Grade com todos os arquivos de um balde de idade.
class BucketScreen extends ConsumerWidget {
  const BucketScreen({
    required this.type,
    required this.bucketKey,
    super.key,
  });

  final EntryType type;
  final String bucketKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<Entry> entries = ref.watch(entriesOfTypeProvider(type));

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
              itemCount: files.length,
              itemBuilder: (BuildContext context, int index) {
                final (Entry entry, EntryFile file) = files[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MediaViewerScreen(
                        files: files.map((r) => r.$2).toList(),
                        entries: files.map((r) => r.$1).toList(),
                        initialIndex: index,
                      ),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      DriveThumbnail(
                        file: file,
                        borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.all(4),
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
              },
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
