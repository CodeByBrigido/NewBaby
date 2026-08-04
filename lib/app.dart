import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_lock_gate.dart';
import 'models/baby_profile.dart';
import 'models/reminder.dart';
import 'state/providers.dart';

class MeuBebeApp extends ConsumerStatefulWidget {
  const MeuBebeApp({super.key});

  @override
  ConsumerState<MeuBebeApp> createState() => _MeuBebeAppState();
}

class _MeuBebeAppState extends ConsumerState<MeuBebeApp> {
  @override
  void initState() {
    super.initState();

    // A agenda de lembretes é refeita inteira sempre que algo que ela usa
    // muda: o cadastro, o que foi registrado, o ajuste. Reagendar tudo, em
    // vez de remendar, é o que mantém a agenda igual ao que o motor de
    // regras diz - e os ids são estáveis, então repetir não duplica.
    //
    // Fica aqui, e não numa tela, porque não pertence a tela nenhuma: vale
    // enquanto o aplicativo estiver aberto, em qualquer rota.
    ref.listenManual(plannedRemindersProvider, (
      List<ScheduledReminder>? antes,
      List<ScheduledReminder> agora,
    ) {
      unawaited(_reagendar(agora));
    }, fireImmediately: true);
  }

  Future<void> _reagendar(List<ScheduledReminder> agenda) async {
    try {
      await ref.read(reminderSchedulerProvider).replaceAll(agenda);
    } on Object catch (e) {
      // Lembrete é conforto, não função essencial. Se o sistema recusar,
      // o aplicativo continua inteiro: ninguém perde uma memória por isso.
      debugPrint('Não deu para agendar os lembretes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref;
    // O aplicativo inteiro se pinta conforme a criança. Enquanto o cadastro
    // não existe (login, início do onboarding) vale a paleta neutra, que não
    // parece escolhida nem para menina nem para menino.
    //
    // Quando o perfil chega, o `MaterialApp` anima a troca sozinho: é para
    // isso que a paleta é uma `ThemeExtension` e não um punhado de constantes.
    final BabyProfile? profile = ref.watch(profileProvider).value;

    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(AppPalette.of(profile?.gender)),
      routerConfig: ref.watch(routerProvider),
      // A trava fica acima do roteador, envolvendo qualquer rota: uma tela
      // trancada não pode ser contornada navegando.
      builder: (BuildContext context, Widget? child) =>
          AppLockGate(child: child ?? const SizedBox.shrink()),
      // Aplicativo de idioma único: tudo, inclusive os seletores de data
      // do Material, aparece em português do Brasil.
      locale: const Locale('pt', 'BR'),
      supportedLocales: const <Locale>[Locale('pt', 'BR')],
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
