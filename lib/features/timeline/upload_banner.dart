import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Faixa que aparece só quando há envio em curso ou falho.
///
/// Como a entrada já está na linha do tempo antes do upload terminar, esta
/// faixa é o que deixa claro que ainda falta subir alguma coisa.
class UploadBanner extends ConsumerWidget {
  const UploadBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Entry> active = ref.watch(activeUploadsProvider);
    final List<Entry> failed = ref.watch(failedUploadsProvider);

    if (active.isEmpty && failed.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.x16, 0, Space.x16, Space.x16),
      child: failed.isNotEmpty
          ? _FailedBanner(entries: failed)
          : _ActiveBanner(count: active.length),
    );
  }
}

class _ActiveBanner extends StatelessWidget {
  const _ActiveBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x16,
        vertical: Space.x12,
      ),
      decoration: BoxDecoration(
        color: context.cores.surfaceMuted,
        borderRadius: Radii.fieldR,
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Space.x12),
          Expanded(
            child: Text(
              '${S.uploadingCount} ${_itemCount(count)}...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// `1 item` / `3 itens`.
String _itemCount(int count) => '$count ${count == 1 ? 'item' : 'itens'}';

class _FailedBanner extends ConsumerWidget {
  const _FailedBanner({required this.entries});

  final List<Entry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x16,
        vertical: Space.x12,
      ),
      decoration: BoxDecoration(
        color: AppPalette.danger.withValues(alpha: 0.08),
        borderRadius: Radii.fieldR,
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: AppPalette.danger,
          ),
          const SizedBox(width: Space.x12),
          // O motivo, e não só a contagem. Sem ele a faixa dizia que algo
          // falhou e escondia a única informação capaz de resolver: se foi
          // permissão, rede, espaço no Drive ou arquivo que sumiu. A pessoa
          // ficava apertando "Tentar de novo" às cegas.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${S.uploadFailed}: ${_itemCount(entries.length)}',
                  style: text.bodySmall?.copyWith(color: AppPalette.danger),
                ),
                if (entries.first.errorMessage case final String motivo
                    when motivo.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Space.x4),
                  Text(
                    motivo,
                    style: text.bodySmall?.copyWith(
                      color: context.cores.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () => _retryAll(context, ref),
            child: Text(S.retry),
          ),
        ],
      ),
    );
  }

  Future<void> _retryAll(BuildContext context, WidgetRef ref) async {
    final String? uid = ref.read(uidProvider);
    final BabyProfile? profile = ref.read(profileProvider).value;
    if (uid == null || profile == null) return;

    for (final Entry entry in entries) {
      await ref.read(memoryRepositoryProvider).retry(uid, profile, entry);
    }
    if (context.mounted) showMessage(context, S.uploadSending);
  }
}
