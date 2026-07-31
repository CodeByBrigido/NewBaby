// PLACEHOLDER — substitua este arquivo pelo gerado no seu projeto Firebase.
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<id-do-seu-projeto>
//
// O comando acima sobrescreve este arquivo com as chaves reais e também cria
// android/app/google-services.json e ios/Runner/GoogleService-Info.plist.
// Os valores abaixo existem só para o projeto compilar e ser analisado antes
// da configuração; com eles o aplicativo não conecta em lugar nenhum.
//
// Consulte o SETUP.md para o passo a passo completo.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  /// Client ID **Web** do projeto no Google Cloud.
  ///
  /// É ele que o `google_sign_in` usa como `serverClientId` para devolver o
  /// `idToken` que o Firebase Auth aceita. Sem ele o login falha no Android.
  static const String serverClientId =
      'SEU_WEB_CLIENT_ID.apps.googleusercontent.com';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Meu Bebê é um aplicativo para celular: a compressão de vídeo e o '
        'acesso aos arquivos locais não existem no navegador.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Plataforma sem suporte: $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_API_KEY_ANDROID',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seu-projeto-firebase',
    storageBucket: 'seu-projeto-firebase.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUA_API_KEY_IOS',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seu-projeto-firebase',
    storageBucket: 'seu-projeto-firebase.firebasestorage.app',
    iosBundleId: 'br.com.brigido.meuBebe',
  );
}
