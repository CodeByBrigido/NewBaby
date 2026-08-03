import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_lock_gate.dart';
import 'models/baby_profile.dart';
import 'state/providers.dart';

class MeuBebeApp extends ConsumerWidget {
  const MeuBebeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
