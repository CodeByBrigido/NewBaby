import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/capsule_pulse.dart';
import '../../models/entry.dart';
import '../common/widgets.dart';

/// Os cartões que respondem "como estamos hoje".
///
/// Cada um existe para responder a uma pergunta que alguém de fato faz, e
/// nenhum aparece quando não tem resposta: cartão vazio é ruído, e ruído na
/// primeira tela é o que faz a pessoa parar de olhar.
class PulseCards extends StatelessWidget {
  const PulseCards({required this.pulse, required this.copy, super.key});

  final CapsulePulse pulse;
  final Copy copy;

  @override
  Widget build(BuildContext context) {
    // Os cartões de ocasião: aniversário e marco. Aparecem de vez em
    // quando, têm texto de tamanho imprevisível, e por isso continuam num
    // `Wrap`, que os deixa ocupar o que precisarem.
    final List<Widget> ocasiao = <Widget>[
      if (pulse.isBirthday)
        _PulseCard(
          icon: Icons.cake_outlined,
          label: 'Hoje',
          value: pulse.birthdayYears == 1
              ? '1 ano ${copy.ofName}'
              : '${pulse.birthdayYears} anos ${copy.ofName}',
          accent: context.cores.primary,
          background: context.cores.primarySoft,
        )
      else ...<Widget>[
        if (pulse.exactMilestone != null)
          _PulseCard(
            icon: Icons.auto_awesome_outlined,
            label: 'Hoje faz exatamente',
            value: pulse.exactMilestone!,
            accent: context.cores.primary,
            background: context.cores.primarySoft,
          ),
        if (pulse.daysToBirthday <= 45)
          _PulseCard(
            icon: Icons.cake_outlined,
            label: 'Para o ${Fmt.ordinal(pulse.birthdayYears)} aniversário',
            value: pulse.daysToBirthday == 1
                ? 'falta 1 dia'
                : 'faltam ${pulse.daysToBirthday} dias',
            accent: context.cores.accent,
            background: context.cores.accentSoft,
          ),
      ],
    ];

    // Os três "última foto / última carta / última medição" são sempre os
    // mesmos três, e por isso ganham largura igual numa linha só.
    //
    // Antes eles também estavam no `Wrap`, cada um do tamanho do próprio
    // texto, e "Última medição" nunca cabia: sobrava sempre um cartão
    // sozinho na linha de baixo, sem motivo aparente. Diminuir a folga não
    // resolvia, porque o problema era a largura ser livre.
    const List<EntryType> ultimos = <EntryType>[
      EntryType.photo,
      EntryType.letter,
      EntryType.growth,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (ocasiao.isNotEmpty) ...<Widget>[
          Wrap(spacing: Space.x8, runSpacing: Space.x8, children: ocasiao),
          const SizedBox(height: Space.x8),
        ],
        Row(
          children: <Widget>[
            for (final EntryType type in ultimos) ...<Widget>[
              Expanded(
                child: _LastOfType(pulse: pulse, type: type),
              ),
              if (type != ultimos.last) const SizedBox(width: Space.x8),
            ],
          ],
        ),
      ],
    );
  }
}

/// "Última foto: há 4 dias", tocável, levando para a categoria.
///
/// Quando o tipo nunca aconteceu, o cartão convida em vez de acusar: um
/// aplicativo que começa cobrando o que a pessoa não fez é um aplicativo
/// que ela desinstala.
class _LastOfType extends StatelessWidget {
  const _LastOfType({required this.pulse, required this.type});

  final CapsulePulse pulse;
  final EntryType type;

  @override
  Widget build(BuildContext context) {
    final int? days = pulse.daysSince(type);
    return _PulseCard(
      icon: type.icon,
      label: days == null ? 'Ainda não há' : type.lastLabel,
      value: days == null ? type.singular : Fmt.ago(days),
      accent: type.accent(context),
      background: type.soft(context),
      onTap: () => context.push(_routeFor(type)),
    );
  }

  static String _routeFor(EntryType type) => switch (type) {
    EntryType.video => Routes.videos,
    EntryType.letter => Routes.letters,
    EntryType.drawing => Routes.drawings,
    EntryType.document => Routes.documents,
    EntryType.growth => Routes.growth,
    EntryType.photo || EntryType.birth => Routes.photos,
  };
}

class _PulseCard extends StatelessWidget {
  const _PulseCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.background,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: background,
      borderRadius: Radii.buttonR,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.buttonR,
        child: Padding(
          // Folga menor por dentro, pelo mesmo motivo: o que sobra de
          // largura aqui é o que decide se três cartões cabem numa linha.
          padding: const EdgeInsets.symmetric(
            horizontal: Space.x12,
            vertical: Space.x12,
          ),
          // Ícone em cima, texto embaixo. Lado a lado, o ícone comia a
          // largura de que o rótulo precisava, e "Última medição" quebrava
          // em três linhas dentro de um cartão de um terço da tela.
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
      ),
    );
  }
}
