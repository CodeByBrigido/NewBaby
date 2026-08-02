import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_lock_gate.dart';

class MeuBebeApp extends ConsumerWidget {
  const MeuBebeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
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
