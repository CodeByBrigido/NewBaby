import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_lock_gate.dart';
import 'features/shell/splash_gate.dart';
import 'models/baby_gender.dart';
import 'models/baby_profile.dart';
import 'models/entry.dart';
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
    // A gravação de voz saiu do produto, e quem usou a versão de teste tem
    // entradas gravadas. Elas precisam sair do índice, e não só deixar de
    // ser criadas. Roda uma vez por aparelho, assim que há sessão.
    ref.listenManual<String?>(uidProvider, (String? _, String? uid) {
      if (uid == null) return;
      unawaited(ref.read(sessionServiceProvider).limparRestosDeAudio(uid));
    }, fireImmediately: true);

    // As cartas escritas antes de a carta virar arquivo só existem no
    // índice. Elas ganham o `.txt` aos poucos, a partir da lista que a linha
    // do tempo já tem em memória: nenhuma leitura nova sai daqui.
    ref.listenManual(entriesProvider, (
      AsyncValue<List<Entry>>? _,
      AsyncValue<List<Entry>> agora,
    ) {
      final List<Entry>? entradas = agora.value;
      if (entradas == null) return;
      unawaited(ref.read(cartasAtrasadasProvider).gravar(entradas));

      // O acervo guardado nas versões anteriores está em `Fotos/Semana 07`,
      // e a organização passou a ser `Fotos/Ano 0/Mês 01`. Duas convenções
      // convivendo seriam pior que qualquer uma sozinha, então o que já
      // existe muda de lugar.
      //
      // Sai daqui, junto das cartas atrasadas, pelo mesmo motivo: a lista já
      // está em memória e nenhuma leitura nova é feita. Ela mesma decide se
      // há trabalho, olhando se sobrou chave antiga no cache de pastas.
      final String? uid = ref.read(uidProvider);
      final BabyProfile? profile = ref.read(profileProvider).value;
      if (uid == null || profile == null) return;
      unawaited(
        ref
            .read(memoryRepositoryProvider)
            .reorganizarODrive(uid: uid, profile: profile, entradas: entradas),
      );
    }, fireImmediately: true);

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
    // Enquanto não há cadastro, vale o que a pessoa acabou de escolher na
    // tela de cadastro. Com cadastro, ele manda: o que está salvo é a
    // verdade, e a escolha em andamento deixa de importar.
    final BabyGender? genero =
        profile?.gender ?? ref.watch(generoEscolhidoProvider);

    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(AppPalette.of(genero)),
      routerConfig: ref.watch(routerProvider),
      // A trava fica acima do roteador, envolvendo qualquer rota: uma tela
      // trancada não pode ser contornada navegando. A abertura fica por cima
      // de tudo, inclusive da trava: enquanto ela está na frente, o
      // roteador já decidiu por baixo entre login, cadastro e linha do
      // tempo, e ninguém vê esse pulo acontecer.
      builder: (BuildContext context, Widget? child) => SplashGate(
        child: AppLockGate(child: child ?? const SizedBox.shrink()),
      ),
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
