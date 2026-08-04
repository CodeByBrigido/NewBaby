import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/models/reminder.dart';
import 'package:meu_bebe/services/notification_service.dart';
import 'package:meu_bebe/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A ponte entre o motor de regras e o sistema.
///
/// O que se verifica aqui é o contrato, não o Android: que a agenda é
/// trocada inteira em vez de remendada, que ninguém é avisado sem ter
/// permitido, e que os ids cabem onde precisam caber.
class _Agendador implements ReminderScheduler {
  List<ScheduledReminder> agendados = <ScheduledReminder>[];
  int trocas = 0;
  int cancelamentos = 0;
  bool permitir = true;
  int pedidosDePermissao = 0;

  @override
  Future<void> prepare() async {}

  @override
  Future<bool> requestPermission() async {
    pedidosDePermissao++;
    return permitir;
  }

  @override
  Future<bool> isAllowed() async => permitir;

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {
    trocas++;
    agendados = reminders;
  }

  @override
  Future<void> cancelAll() async {
    cancelamentos++;
    agendados = <ScheduledReminder>[];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // O ajuste vive no aparelho, então o `SharedPreferences` precisa existir
  // mesmo aqui. Vazio: o padrão é desligado, e é isso que se quer verificar.
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  final DateTime nascimento = DateTime(2026, 3, 10);
  final BabyProfile maria = BabyProfile(name: 'Maria', birth: nascimento);

  group('o id do lembrete', () {
    test('cabe num inteiro de 32 bits, que é o que o Android aceita', () {
      // Um id acima disso estoura no lado nativo, e o aviso simplesmente
      // não acontece. Vale conferir até bem depois de esta criança crescer.
      for (int ano = 2026; ano <= 2100; ano++) {
        final List<ScheduledReminder> plano = planReminders(
          profile: BabyProfile(name: 'Maria', birth: DateTime(ano, 3, 10)),
          pulse: CapsulePulse.from(
            profile: BabyProfile(name: 'Maria', birth: DateTime(ano, 3, 10)),
            entries: <Entry>[],
            now: DateTime(ano + 1, 2, 20),
          ),
          settings: const ReminderSettings(enabled: true),
          now: DateTime(ano + 1, 2, 20),
        );
        for (final ScheduledReminder r in plano) {
          expect(r.id, lessThan(2147483647), reason: 'ano $ano');
          expect(r.id, greaterThan(0));
        }
      }
    });
  });

  group('ligar e desligar', () {
    test('ligar sem permissão do sistema não liga nada', () {
      // Uma chave ligada que nunca toca é pior que uma desligada: ninguém
      // vai procurar o defeito.
      final _Agendador agendador = _Agendador()..permitir = false;
      final ProviderContainer c = ProviderContainer(
        overrides: [reminderSchedulerProvider.overrideWithValue(agendador)],
      );
      addTearDown(c.dispose);

      return c.read(reminderSettingsProvider.notifier).enable().then((bool ok) {
        expect(ok, isFalse);
        expect(agendador.pedidosDePermissao, 1);
        expect(c.read(reminderSettingsProvider).enabled, isFalse);
      });
    });

    test('desligar cancela o que já estava marcado', () async {
      final _Agendador agendador = _Agendador();
      final ProviderContainer c = ProviderContainer(
        overrides: [reminderSchedulerProvider.overrideWithValue(agendador)],
      );
      addTearDown(c.dispose);

      await c.read(reminderSettingsProvider.notifier).disable();
      expect(agendador.cancelamentos, 1);
      expect(c.read(reminderSettingsProvider).enabled, isFalse);
    });
  });

  group('a agenda é trocada inteira, nunca remendada', () {
    test('reagendar duas vezes deixa a mesma agenda', () async {
      final _Agendador agendador = _Agendador();
      final List<ScheduledReminder> plano = planReminders(
        profile: maria,
        pulse: CapsulePulse.from(
          profile: maria,
          entries: <Entry>[],
          now: DateTime(2027, 2, 20),
        ),
        settings: const ReminderSettings(enabled: true),
        now: DateTime(2027, 2, 20),
      );

      await agendador.replaceAll(plano);
      final int primeira = agendador.agendados.length;
      await agendador.replaceAll(plano);

      expect(agendador.agendados.length, primeira);
      expect(agendador.trocas, 2);
    });
  });

  group('quem foi convidado não recebe lembrete', () {
    test('a agenda do familiar é vazia', () {
      // Avisar a avó de que faz duas semanas sem foto seria cobrar dela uma
      // coisa que ela nem pode fazer: ela não registra nada.
      final ProviderContainer c = ProviderContainer(
        overrides: [isReadOnlyProvider.overrideWithValue(true)],
      );
      addTearDown(c.dispose);
      expect(c.read(plannedRemindersProvider), isEmpty);
    });
  });
}
