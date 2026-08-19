import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'features/shell/startup_error_screen.dart';
import 'firebase_options.dart';
import 'services/session_service.dart';
import 'state/providers.dart';

/// Nada aqui pode terminar sem chamar `runApp`.
///
/// Uma exceção ou um `await` que nunca resolve antes do `runApp` deixa o
/// Android com a tela **em branco**: sem erro, sem aviso, sem pista nenhuma
/// de que algo quebrou. É o pior resultado possível, porque some com a
/// própria mensagem que diria o que fazer.
///
/// Por isso o preparo inteiro vive dentro de um `try`, as esperas que
/// dependem de rede ou de serviço externo têm prazo, e o que falhar acaba
/// numa tela que a pessoa consegue ler e copiar.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    // Datas por extenso em qualquer língua que não seja o inglês dependem
    // destes dados. O inglês funciona sem, porque o `intl` já embute os
    // símbolos de `en_US` por padrão; carregá-lo aqui também não custa nada
    // e evita depender desse detalhe de implementação.
    for (final String locale in <String>[
      'pt_BR',
      'en',
      'es',
      'fr',
      'de',
      'it',
    ]) {
      await initializeDateFormatting(locale);
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final ProviderContainer container = ProviderContainer();

    await SessionService.clearPendingCache(signedIn: await _restoredSession());

    // Prepara o login com Google. O `AuthService` já tem prazo por dentro e
    // solta a restauração da sessão anterior sem esperar; o prazo aqui é a
    // rede de segurança, para o caso de a trava aparecer num lugar novo.
    //
    // Falhar aqui não pode impedir o aplicativo de abrir: quem sabe explicar
    // um problema de login é a tela de login, com a pessoa olhando.
    try {
      await container
          .read(authServiceProvider)
          .initialize(serverClientId: DefaultFirebaseOptions.serverClientId)
          .timeout(const Duration(seconds: 12));
    } on Object catch (error) {
      debugPrint('Preparo do login indisponível: $error');
    }

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MeuBebeApp(),
      ),
    );
  } on Object catch (error) {
    // `Object`, e não `Exception`: um `Error` (chave errada, plataforma sem
    // suporte, asserção) também derrubaria a inicialização, e ele não é um
    // `Exception`.
    debugPrint('Falha ao iniciar o aplicativo: $error');
    runApp(StartupErrorApp(error: error));
  }
}

/// Se havia uma sessão para restaurar, com prazo.
///
/// O primeiro evento de `authStateChanges` é mais confiável que ler
/// `currentUser` direto, que pode responder nulo enquanto a restauração
/// acontece. Mas ele depende do canal com o lado nativo, e esperar por ele
/// sem prazo foi o que deixou a tela em branco: se o evento não vem, o
/// `runApp` nunca acontece.
///
/// Cinco segundos é folgado para um evento que costuma chegar em
/// milissegundos. Estourando o prazo, o pior caso é adiar uma limpeza de
/// cache para a próxima abertura - o aplicativo abre do mesmo jeito.
Future<bool> _restoredSession() async {
  try {
    final User? user = await FirebaseAuth.instance
        .authStateChanges()
        .first
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => FirebaseAuth.instance.currentUser,
        );
    return user != null;
  } on Object catch (error) {
    debugPrint('Estado da sessão indisponível na abertura: $error');
    // Na dúvida, assume que há sessão: a limpeza de cache fica para depois,
    // o que é reversível. Apagar dado por engano não é.
    return true;
  }
}
