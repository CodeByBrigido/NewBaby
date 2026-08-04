import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';

/// Quem entrega os lembretes ao sistema.
///
/// A interface existe para o resto do aplicativo poder ser montado em teste
/// sem plataforma nenhuma por baixo: o que importa testar é **o que** seria
/// agendado, e isso é o motor de regras, não o canal do Android.
abstract interface class ReminderScheduler {
  /// Prepara o canal e o fuso. Pode ser chamado mais de uma vez.
  Future<void> prepare();

  /// Pede a permissão do sistema. Devolve se foi concedida.
  Future<bool> requestPermission();

  /// Se o sistema já autorizou notificações para este aplicativo.
  Future<bool> isAllowed();

  /// Troca a agenda inteira pela nova.
  Future<void> replaceAll(List<ScheduledReminder> reminders);

  /// Apaga tudo o que estava agendado.
  Future<void> cancelAll();
}

/// Onde a escolha da pessoa fica guardada.
///
/// No aparelho, e não no Firestore: é uma preferência deste celular, e quem
/// entra numa cápsula pelo tablet da sala não quer o tablet apitando.
class ReminderPreferences {
  ReminderPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _chave = 'lembretes';

  /// Se o sistema já foi consultado sobre notificações neste aparelho.
  ///
  /// Guardado aqui, e não deduzido do estado da permissão, porque as duas
  /// coisas são diferentes: "ainda não perguntamos" e "perguntamos e a
  /// pessoa disse não" levam a caminhos opostos. Sem esta marca, o
  /// aplicativo insistiria na caixa de diálogo a cada abertura, que é o
  /// jeito mais rápido de a pessoa desinstalar.
  bool get alreadyAsked => _prefs.getBool('$_chave.perguntou') ?? false;

  Future<void> markAsked() => _prefs.setBool('$_chave.perguntou', true);

  ReminderSettings load() {
    final String? ligado = _prefs.getString('$_chave.ligado');
    if (ligado == null) return const ReminderSettings();
    return ReminderSettings(
      enabled: ligado == 'sim',
      kinds: <ReminderKind>{
        for (final ReminderKind k in ReminderKind.values)
          if (_prefs.getBool('$_chave.tipo.${k.name}') ?? true) k,
      },
      hour: _prefs.getInt('$_chave.hora') ?? 10,
      absenceDays: _prefs.getInt('$_chave.diasAusencia') ?? 14,
    );
  }

  Future<void> save(ReminderSettings settings) async {
    await _prefs.setString('$_chave.ligado', settings.enabled ? 'sim' : 'nao');
    for (final ReminderKind k in ReminderKind.values) {
      await _prefs.setBool(
        '$_chave.tipo.${k.name}',
        settings.kinds.contains(k),
      );
    }
    await _prefs.setInt('$_chave.hora', settings.hour);
    await _prefs.setInt('$_chave.diasAusencia', settings.absenceDays);
  }

  Future<void> clear() async {
    await _prefs.remove('$_chave.perguntou');
    await _prefs.remove('$_chave.ligado');
    for (final ReminderKind k in ReminderKind.values) {
      await _prefs.remove('$_chave.tipo.${k.name}');
    }
    await _prefs.remove('$_chave.hora');
    await _prefs.remove('$_chave.diasAusencia');
  }
}

/// Lembretes locais, sem servidor nenhum.
///
/// Tudo o que o aplicativo precisa saber para lembrar de alguma coisa já
/// está no aparelho: a data de nascimento, o que foi registrado e quando.
/// Push exigiria Cloud Functions, plano pago e mandar para fora um dado que
/// o celular já tem na mão. Local é mais barato, funciona sem rede e não
/// conta nada a ninguém.
class NotificationService implements ReminderScheduler {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _pronto = false;

  static const String _canalId = 'lembretes';
  static const String _canalNome = 'Lembretes da cápsula';
  static const String _canalDescricao =
      'Datas redondas, aniversários e lembretes de guardar uma memória.';

  @override
  Future<void> prepare() async {
    if (_pronto) return;

    tzdata.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        // `@mipmap/ic_launcher` é o ícone que já existe no projeto. Um ícone
        // próprio, monocromático, entra quando houver arte para ele.
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Nada é pedido na inicialização: a permissão tem hora certa, e é
          // depois de a pessoa dizer que quer.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _canalId,
        _canalNome,
        description: _canalDescricao,
        importance: Importance.defaultImportance,
      ),
    );

    _pronto = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() async {
    await prepare();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    return await _android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<bool> isAllowed() async {
    await prepare();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    // No iOS não há como perguntar sem pedir; quem manda é a escolha guardada.
    return true;
  }

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {
    await prepare();
    await _plugin.cancelAll();

    for (final ScheduledReminder r in reminders) {
      final tz.TZDateTime quando = tz.TZDateTime.from(r.when, tz.local);
      // Um aviso marcado para trás nunca dispara e ainda entope a agenda.
      if (!quando.isAfter(tz.TZDateTime.now(tz.local))) continue;

      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        scheduledDate: quando,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _canalId,
            _canalNome,
            channelDescription: _canalDescricao,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // **Inexato de propósito.** O alarme exato do Android exige uma
        // permissão à parte, que o sistema apresenta com cara de coisa
        // séria, e que a Play Store audita. Um lembrete de tirar uma foto
        // não precisa cair às dez em ponto: pode chegar meia hora depois e
        // continua valendo. Pedir aquela permissão para isto seria cobrar
        // caro por algo barato.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await prepare();
    await _plugin.cancelAll();
  }
}
