import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// O que está guardado para depois.
///
/// A tela mostra **que** existe algo e **quando** abre, e nada mais. Sem
/// título, sem trecho, sem miniatura. A espera é metade do presente: quem
/// escreveu quis que ela existisse, e a interface precisa respeitar isso
/// mesmo tendo o conteúdo à mão.
class SealedScreen extends ConsumerWidget {
  const SealedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<Entry> todas =
        ref.watch(entriesProvider).value ?? const <Entry>[];
    final DateTime agora = DateTime.now();

    final List<Entry> lacradas =
        todas.where((Entry e) => e.isSealedAt(agora)).toList()..sort(
          (Entry a, Entry b) => a.sealedUntil!.compareTo(b.sealedUntil!),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Guardado para o futuro')),
      body: lacradas.isEmpty
          ? EmptyState(
              icon: Icons.lock_clock,
              title: 'Nada lacrado ainda',
              message: S.sealedEmptyIntro,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x12,
                Space.x16,
                Space.scrollEnd,
              ),
              itemCount: lacradas.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.x12),
              itemBuilder: (BuildContext context, int index) => _SealedTile(
                entry: lacradas[index],
                profile: profile,
                now: agora,
              ),
            ),
    );
  }
}

class _SealedTile extends StatelessWidget {
  const _SealedTile({
    required this.entry,
    required this.profile,
    required this.now,
  });

  final Entry entry;
  final BabyProfile? profile;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DateTime abre = entry.sealedUntil!;
    final int dias = abre.difference(now).inDays;

    return Container(
      padding: const EdgeInsets.all(Space.x16),
      decoration: BoxDecoration(
        color: context.cores.surfaceMuted,
        borderRadius: Radii.buttonR,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.lock_clock, color: context.cores.primary),
          const SizedBox(width: Space.x16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Só o tipo. O título já contaria demais.
                Text('Um ${entry.type.one}', style: text.titleSmall),
                const SizedBox(height: Space.x4),
                Text('Abre em ${Fmt.longDate(abre)}', style: text.bodySmall),
                const SizedBox(height: Space.x4),
                Text(
                  _espera(dias),
                  style: text.labelSmall?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quanto falta, e com que idade a criança vai abrir.
  String _espera(int dias) {
    final BabyProfile? p = profile;
    if (p == null) return 'Faltam $dias dias';

    final int anos = entry.sealedUntil!.year - p.birth.year;
    final bool jaFezAniversario =
        entry.sealedUntil!.month > p.birth.month ||
        (entry.sealedUntil!.month == p.birth.month &&
            entry.sealedUntil!.day >= p.birth.day);
    final int idade = jaFezAniversario ? anos : anos - 1;

    if (dias > 365) {
      final int anosFaltando = dias ~/ 365;
      return 'Daqui a ${anosFaltando == 1 ? "1 ano" : "$anosFaltando anos"}, '
          'quando tiver $idade';
    }
    return dias == 0
        ? 'Abre hoje'
        : 'Faltam ${dias == 1 ? "1 dia" : "$dias dias"}';
  }
}

/// O aviso de que uma entrada está lacrada, no lugar do conteúdo dela.
class SealedNotice extends StatelessWidget {
  const SealedNotice({required this.entry, super.key});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DateTime abre = entry.sealedUntil!;

    return Container(
      margin: const EdgeInsets.fromLTRB(Space.x12, 0, Space.x12, Space.x12),
      padding: const EdgeInsets.all(Space.x16),
      decoration: BoxDecoration(
        color: context.cores.surfaceMuted,
        borderRadius: Radii.fieldR,
        border: Border.all(color: context.cores.divider),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.lock_clock, size: 20, color: context.cores.primary),
          const SizedBox(width: Space.x12),
          Expanded(
            child: Text(
              'Guardado para abrir em ${Fmt.longDate(abre)}.',
              style: text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
