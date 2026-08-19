import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
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
      appBar: AppBar(title: Text(S.remindersSection)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x16,
          Space.x8,
          Space.x16,
          Space.x32,
        ),
        children: <Widget>[
          Text(
            copy.hasName
                ? S.remindersIntroNamed(copy.theName)
                : S.remindersIntroGeneric,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.cores.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: Space.x16),

          SoftCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.receiveReminders),
              subtitle: Text(
                ajuste.enabled ? S.remindersFrequency : S.remindersOffNote,
              ),
              value: ajuste.enabled,
              onChanged: (bool ligar) => _alternar(context, notifier, ligar),
            ),
          ),

          if (ajuste.enabled) ...<Widget>[
            const SizedBox(height: Space.x24),
            SectionHeader(title: S.remindersHowTitle),
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

            const SizedBox(height: Space.x24),
            SectionHeader(title: S.atWhatTime),
            SoftCard(
              onTap: () => _escolherHora(context, notifier, ajuste),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.schedule_outlined),
                  const SizedBox(width: Space.x16),
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
            const SizedBox(height: Space.x12),
            InfoNote(
              message: S.remindersHourRange(
                ReminderSettings.earliestHour,
                ReminderSettings.latestHour,
              ),
              icon: Icons.bedtime_outlined,
            ),

            const SizedBox(height: Space.x24),
            SectionHeader(title: S.remindersMarkedTitle),
            if (agenda.isEmpty)
              InfoNote(message: S.remindersNothingSoon)
            else
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final ScheduledReminder r in agenda.take(5))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Space.x8),
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

          const SizedBox(height: Space.x24),
          InfoNote(message: S.remindersPrivacy, icon: Icons.phone_iphone),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.remindersDenied)));
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
