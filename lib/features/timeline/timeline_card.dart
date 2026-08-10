import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../common/drive_image.dart';
import '../sealed/sealed_screen.dart';
import '../common/widgets.dart';

/// Cartão de um item da linha do tempo. O desenho muda com o tipo: fotos
/// viram grade, vídeo vira player, carta vira texto, crescimento vira
/// números - o que evita a sensação de lista de arquivos.
class TimelineCard extends ConsumerWidget {
  const TimelineCard({required this.entry, super.key});

  final Entry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;

    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: () => _open(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.x16,
              Space.x12,
              Space.x16,
              Space.x8,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  entry.type.icon,
                  size: Sizes.iconSmall,
                  color: entry.type.accent(context),
                ),
                const SizedBox(width: Space.x8),
                Expanded(
                  child: Text(
                    entry.headline,
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.uploadStatus.isBusy)
                  const SizedBox(
                    width: Sizes.iconSmall,
                    height: Sizes.iconSmall,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (entry.uploadStatus == UploadStatus.failed)
                  const Icon(
                    Icons.error_outline,
                    size: Sizes.iconSmall,
                    color: AppPalette.danger,
                  ),
              ],
            ),
          ),
          _Body(entry: entry),
        ],
      ),
    );
  }

  void _open(BuildContext context) {
    switch (entry.type) {
      case EntryType.letter:
        context.push(Routes.letter(entry.id));
      case EntryType.document:
        context.push(Routes.document(entry.id));
      case EntryType.growth:
        context.push(Routes.growth);
      case EntryType.birth:
      case EntryType.photo:
      case EntryType.video:
      case EntryType.drawing:
        context.push(Routes.entry(entry.id));
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    // O lacre vem antes de tudo: enquanto ele vale, o conteúdo não aparece
    // nem de relance, e nem o título.
    if (entry.isSealedAt()) {
      return SealedNotice(entry: entry);
    }

    return switch (entry.type) {
      EntryType.growth => _GrowthBody(entry: entry),
      EntryType.letter => _LetterBody(entry: entry),
      EntryType.document => _DocumentBody(entry: entry),
      EntryType.video => _VideoBody(entry: entry),
      EntryType.birth => _BirthBody(entry: entry),
      EntryType.photo || EntryType.drawing => _PhotoBody(entry: entry),
    };
  }
}

/// Até três miniaturas; o excedente vira `+N` na última célula.
class _PhotoBody extends StatelessWidget {
  const _PhotoBody({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    if (!entry.hasFiles) return _DescriptionOnly(entry: entry);

    final List<EntryFile> files = entry.files;
    final int shown = files.length > 3 ? 3 : files.length;
    // A terceira miniatura fica sob o "+N", então ela também entra na conta:
    // com 14 fotos aparecem 2 inteiras e o selo marca as 12 restantes.
    final int extra = files.length > shown ? files.length - (shown - 1) : 0;

    return Padding(
      // As fotos entram mais para a borda que o texto: é o que faz a imagem
      // parecer o conteúdo do cartão, e não uma ilustração dentro dele.
      padding: const EdgeInsets.fromLTRB(Space.x12, 0, Space.x12, Space.x12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: shown == 1 ? 168 : 92,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < shown; i++) ...<Widget>[
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        DriveThumbnail(
                          file: files[i],
                          borderRadius: Radii.mediaR,
                        ),
                        if (i == shown - 1 && extra > 0)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: Radii.mediaR,
                            ),
                            child: Center(
                              child: Text(
                                '+$extra',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (i < shown - 1) const SizedBox(width: Space.x8),
                ],
              ],
            ),
          ),
          if (entry.description != null && entry.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.x4,
                Space.x12,
                Space.x4,
                0,
              ),
              child: Text(
                entry.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoBody extends StatelessWidget {
  const _VideoBody({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final EntryFile? file = entry.coverFile;
    if (file == null) return _DescriptionOnly(entry: entry);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.x12, 0, Space.x12, Space.x12),
      child: SizedBox(
        height: 168,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DriveThumbnail(file: file, borderRadius: Radii.mediaR),
            Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: Sizes.iconLarge,
                ),
              ),
            ),
            if (file.duration != null)
              Positioned(
                right: Space.x8,
                bottom: Space.x8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.x8,
                    vertical: Space.x4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: Radii.pillR,
                  ),
                  child: Text(
                    Fmt.duration(file.duration!),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LetterBody extends StatelessWidget {
  const _LetterBody({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final String? message = entry.description;
    if (message == null || message.isEmpty) {
      return const SizedBox(height: Space.x4);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.x16, 0, Space.x16, Space.x16),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _GrowthBody extends StatelessWidget {
  const _GrowthBody({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final GrowthData? growth = entry.growth;
    if (growth == null) return const SizedBox(height: Space.x4);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.x16, 0, Space.x16, Space.x16),
      child: Row(
        children: <Widget>[
          _Measure(value: Fmt.weight(growth.weightGrams), label: S.weightField),
          const SizedBox(width: Space.x12),
          _Measure(value: Fmt.height(growth.heightCm), label: S.heightField),
          if (entry.coverFile != null) ...<Widget>[
            const SizedBox(width: Space.x12),
            SizedBox(
              width: 52,
              height: 52,
              child: DriveThumbnail(
                file: entry.coverFile!,
                borderRadius: Radii.mediaR,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Measure extends StatelessWidget {
  const _Measure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.x12,
          vertical: Space.x8,
        ),
        decoration: BoxDecoration(
          color: context.cores.surfaceMuted,
          borderRadius: Radii.fieldR,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(value, style: text.titleSmall),
            const SizedBox(height: Space.x4),
            Text(label, style: text.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _DocumentBody extends StatelessWidget {
  const _DocumentBody({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final EntryFile? file = entry.coverFile;
    if (file == null) return const SizedBox(height: Space.x4);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.x16, 0, Space.x16, Space.x16),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.x12,
              vertical: Space.x4,
            ),
            decoration: BoxDecoration(
              color: context.cores.documentSoft,
              borderRadius: Radii.pillR,
            ),
            child: Text(
              file.extensionLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.cores.document,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: Space.x12),
          if (file.sizeBytes > 0)
            Text(
              Fmt.bytes(file.sizeBytes),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _BirthBody extends StatelessWidget {
  const _BirthBody({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final GrowthData? growth = entry.growth;
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.x16, 0, Space.x16, Space.x16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (entry.description != null && entry.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.x12),
              child: Text(entry.description!, style: text.bodySmall),
            ),
          if (growth != null)
            Row(
              children: <Widget>[
                _Measure(
                  value: Fmt.weight(growth.weightGrams),
                  label: S.weightField,
                ),
                const SizedBox(width: Space.x12),
                _Measure(
                  value: Fmt.height(growth.heightCm),
                  label: S.heightField,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DescriptionOnly extends StatelessWidget {
  const _DescriptionOnly({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final String? description = entry.description;
    if (description == null || description.isEmpty) {
      return const SizedBox(height: Space.x4);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.x16, 0, Space.x16, Space.x16),
      child: Text(description, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
