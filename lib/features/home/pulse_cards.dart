import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/capsule_pulse.dart';

/// Os cartões de ocasião: hoje é aniversário, hoje faz exatamente, e a
/// contagem para o próximo aniversário.
///
/// Cada um existe para responder a uma pergunta que alguém de fato faz, e
/// nenhum aparece quando não tem resposta: cartão vazio é ruído, e ruído na
/// primeira tela é o que faz a pessoa parar de olhar.
///
/// Aqui também moravam "última foto", "última carta" e "última medição",
/// sempre os três, sempre visíveis. Eles saíram. Numa cápsula do tempo,
/// dizer "há 1 ano" na primeira linha da tela é cobrança, não informação: a
/// pessoa já sabe que não registrou, e quem acabou de criar a conta abre o
/// aplicativo e leva três avisos de que não fez nada. O acervo logo abaixo
/// já leva a cada categoria, e a linha do tempo conta a mesma história sem
/// transformar a ausência em placar.
class PulseCards extends StatelessWidget {
  const PulseCards({required this.pulse, required this.copy, super.key});

  final CapsulePulse pulse;
  final Copy copy;

  @override
  Widget build(BuildContext context) {
    // Aparecem de vez em quando, têm texto de tamanho imprevisível, e por
    // isso vivem num `Wrap`, que os deixa ocupar o que precisarem.
    final List<Widget> ocasiao = <Widget>[
      if (pulse.isBirthday)
        _PulseCard(
          icon: Icons.cake_outlined,
          label: S.hoje,
          value: S.birthdayAgeOf(pulse.birthdayYears, copy.ofName),
          accent: context.cores.primary,
          background: context.cores.primarySoft,
        )
      else ...<Widget>[
        if (pulse.exactMilestone != null)
          _PulseCard(
            icon: Icons.auto_awesome_outlined,
            label: S.exactlyToday,
            value: pulse.exactMilestone!,
            accent: context.cores.primary,
            background: context.cores.primarySoft,
          ),
        if (pulse.daysToBirthday <= 45)
          _PulseCard(
            icon: Icons.cake_outlined,
            label: S.birthdayOrdinal(pulse.birthdayYears),
            value: S.daysLeft(pulse.daysToBirthday),
            accent: context.cores.accent,
            background: context.cores.accentSoft,
          ),
      ],
    ];

    // Sem ocasião nenhuma não sobra nada para desenhar, e a folga de baixo
    // vai junto: um espaço em branco sem cartão acima dele é um buraco.
    if (ocasiao.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(spacing: Space.x8, runSpacing: Space.x8, children: ocasiao),
        const SizedBox(height: Space.x16),
      ],
    );
  }
}

/// Um cartão de ocasião: um ícone, um rótulo curto e o dado em destaque.
///
/// Não é tocável, e isso é de propósito: ele não leva a lugar nenhum, ele
/// **conta** uma coisa que é verdade só hoje.
class _PulseCard extends StatelessWidget {
  const _PulseCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: background,
      borderRadius: Radii.buttonR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.x12,
          vertical: Space.x12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: Space.x8),
            Text(
              label,
              style: text.labelSmall?.copyWith(
                color: context.cores.textSecondary,
              ),
            ),
            const SizedBox(height: Space.x4),
            Text(
              value,
              style: text.titleSmall?.copyWith(
                color: context.cores.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
