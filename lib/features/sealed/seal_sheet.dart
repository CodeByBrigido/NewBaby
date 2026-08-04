import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';

/// Uma data de abertura, escolhida por quem está guardando.
///
/// `null` no resultado quer dizer "não lacrar"; o `Future` vem sem valor
/// quando a pessoa fecha a folha sem decidir nada.
Future<SealChoice?> showSealSheet(
  BuildContext context, {
  required BabyProfile? profile,
  DateTime? current,
}) {
  return showModalBottomSheet<SealChoice>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) =>
        _SealSheet(profile: profile, current: current),
  );
}

/// O que a folha devolveu.
class SealChoice {
  const SealChoice(this.until);

  /// `null` remove o lacre.
  final DateTime? until;
}

class _SealSheet extends StatelessWidget {
  const _SealSheet({required this.profile, required this.current});

  final BabyProfile? profile;
  final DateTime? current;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DateTime hoje = DateTime.now();

    /// Aniversários redondos são as datas que alguém de fato escolhe.
    List<(String, DateTime)> opcoes() {
      final BabyProfile? p = profile;
      if (p == null) return const <(String, DateTime)>[];
      return <(String, DateTime)>[
        for (final int anos in <int>[15, 18, 21, 25, 30])
          (
            'Quando fizer $anos anos',
            DateTime(p.birth.year + anos, p.birth.month, p.birth.day),
          ),
      ].where(((String, DateTime) o) => o.$2.isAfter(hoje)).toList();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Guardar para o futuro', style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Isto fica fechado até a data que você escolher. O conteúdo '
              'continua no seu Drive, e você pode abrir antes se quiser: é '
              'um lacre, como o da cápsula enterrada no quintal, não um '
              'cofre.',
              style: text.bodySmall,
            ),
            const SizedBox(height: 20),

            for (final (String rotulo, DateTime data) in opcoes())
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.lock_clock, color: context.cores.primary),
                title: Text(rotulo),
                subtitle: Text(Fmt.longDate(data)),
                onTap: () => Navigator.of(context).pop(SealChoice(data)),
              ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.event_outlined,
                color: context.cores.textSecondary,
              ),
              title: const Text('Escolher outra data'),
              onTap: () async {
                final DateTime? escolhida = await showDatePicker(
                  context: context,
                  initialDate: current ?? hoje.add(const Duration(days: 365)),
                  firstDate: hoje.add(const Duration(days: 1)),
                  lastDate: DateTime(hoje.year + 60),
                  helpText: 'Abrir em',
                );
                if (escolhida != null && context.mounted) {
                  Navigator.of(context).pop(SealChoice(escolhida));
                }
              },
            ),

            if (current != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_open, color: AppPalette.danger),
                title: const Text('Tirar o lacre'),
                onTap: () => Navigator.of(context).pop(const SealChoice(null)),
              ),
          ],
        ),
      ),
    );
  }
}
