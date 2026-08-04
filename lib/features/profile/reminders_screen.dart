import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../models/baby_profile.dart';
import '../../models/reminder.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Onde a pessoa decide se o aplicativo pode falar com ela, e sobre o quê.
///
/// A tela existe inteira para poder dizer não. Uma chave geral, cinco
/// específicas e a hora do dia: quem quer só o aviso do aniversário consegue
/// ter exatamente isso, sem desligar tudo e sem perder o que gostaria de
/// saber.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReminderSettings ajuste = ref.watch(reminderSettingsProvider);
    final ReminderSettingsNotifier notifier = ref.read(
      reminderSettingsProvider.notifier,
    );
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final Copy copy = Copy.of(profile);
    final List<ScheduledReminder> agenda = ref.watch(plannedRemindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            copy.hasName
                ? 'O aplicativo pode te avisar de datas que passam sem '
                      'ninguém perceber, como o dia em que ${copy.theName} '
                      'completa mais um mês.'
                : 'O aplicativo pode te avisar de datas que passam sem '
                      'ninguém perceber.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.cores.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          SoftCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Receber lembretes'),
              subtitle: Text(
                ajuste.enabled
                    ? 'No máximo dois por semana, nunca dois no mesmo dia.'
                    : 'Desligado. Nada é enviado.',
              ),
              value: ajuste.enabled,
              onChanged: (bool ligar) => _alternar(context, notifier, ligar),
            ),
          ),

          if (ajuste.enabled) ...<Widget>[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Sobre o quê'),
            SoftCard(
              child: Column(
                children: <Widget>[
                  for (final ReminderKind k in ReminderKind.values) ...<Widget>[
                    if (k != ReminderKind.values.first)
                      const Divider(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(k.label),
                      subtitle: Text(k.description),
                      value: ajuste.kinds.contains(k),
                      onChanged: (bool quer) {
                        final Set<ReminderKind> novos = <ReminderKind>{
                          ...ajuste.kinds,
                        };
                        if (quer) {
                          novos.add(k);
                        } else {
                          novos.remove(k);
                        }
                        notifier.save(ajuste.copyWith(kinds: novos));
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: 'A que horas'),
            SoftCard(
              onTap: () => _escolherHora(context, notifier, ajuste),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.schedule_outlined),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${ajuste.safeHour.toString().padLeft(2, '0')}:00',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.cores.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 10),
            InfoNote(
              message:
                  'Entre ${ReminderSettings.earliestHour}h e '
                  '${ReminderSettings.latestHour}h. O aplicativo não acorda '
                  'ninguém de madrugada.',
              icon: Icons.bedtime_outlined,
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: 'O que está marcado'),
            if (agenda.isEmpty)
              const InfoNote(
                message:
                    'Nada nas próximas semanas. Isso é normal: os lembretes '
                    'aparecem quando há de fato uma data por perto.',
              )
            else
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final ScheduledReminder r in agenda.take(5))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 62,
                              child: Text(
                                _dataCurta(r.day),
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: context.cores.primaryDark,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                r.title,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 24),
          const InfoNote(
            message:
                'Os lembretes são calculados dentro do seu celular, a partir '
                'do que já está aqui. Nada é enviado para nenhum servidor '
                'para isso acontecer, e nenhum aviso cita o que você '
                'escreveu.',
            icon: Icons.phone_iphone,
          ),
        ],
      ),
    );
  }

  Future<void> _alternar(
    BuildContext context,
    ReminderSettingsNotifier notifier,
    bool ligar,
  ) async {
    if (!ligar) {
      await notifier.disable();
      return;
    }
    final bool permitido = await notifier.enable();
    if (permitido || !context.mounted) return;

    // A chave não pode ficar ligada enquanto o sistema diz não: seria uma
    // promessa que nunca toca, e ninguém iria procurar o defeito.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'O Android não autorizou as notificações. Você pode liberar nos '
          'ajustes do celular, em Aplicativos, Meu Bebê.',
        ),
      ),
    );
  }

  Future<void> _escolherHora(
    BuildContext context,
    ReminderSettingsNotifier notifier,
    ReminderSettings ajuste,
  ) async {
    final TimeOfDay? escolhida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: ajuste.safeHour, minute: 0),
      helpText: 'A que horas avisar',
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
    if (escolhida == null) return;
    await notifier.save(ajuste.copyWith(hour: escolhida.hour));
  }

  static String _dataCurta(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
