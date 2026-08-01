import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

/// Erro de autenticação já traduzido para a interface.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.needsPermission = false});
  final String message;
  final bool needsPermission;

  @override
  String toString() => message;
}

/// Login com Google + autorização do Drive.
///
/// O `google_sign_in` 7.x separa as duas coisas: `authenticate()` identifica a
/// pessoa (e devolve o `idToken` que alimenta o Firebase Auth), e o
/// `authorizationClient` cuida do consentimento para os escopos do Drive.
/// Isso significa que o token de acesso precisa ser pedido de novo a cada uso
/// — o próprio plugin devolve um token válido do cache quando possível.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// `drive.file` dá acesso apenas ao que o próprio aplicativo cria — é um
  /// escopo não sensível, então não exige verificação do app pelo Google.
  static const List<String> driveScopes = <String>[
    'https://www.googleapis.com/auth/drive.file',
  ];

  bool _initialized = false;
  GoogleSignInAccount? _account;

  User? get currentUser => _firebaseAuth.currentUser;
  GoogleSignInAccount? get googleAccount => _account;
  String? get email => _account?.email ?? currentUser?.email;
  String? get photoUrl => _account?.photoUrl ?? currentUser?.photoURL;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Inicializa o plugin e tenta reaproveitar uma sessão anterior sem
  /// mostrar nenhuma tela. Chamado uma vez, na abertura do app.
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _initialized = true;

    _googleSignIn.authenticationEvents.listen(
      (GoogleSignInAuthenticationEvent event) {
        _account = switch (event) {
          GoogleSignInAuthenticationEventSignIn(
            :final GoogleSignInAccount user,
          ) =>
            user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };
      },
      onError: (Object _) {
        // Falhas silenciosas de restauração de sessão não devem derrubar
        // o app; a tela de login cuida do caminho manual.
      },
    );

    try {
      await _googleSignIn.attemptLightweightAuthentication();
    } on GoogleSignInException catch (e) {
      debugPrint('Login silencioso não disponível: ${e.code}');
    }
  }

  /// Fluxo completo de entrada: escolhe a conta, autoriza o Drive e conecta
  /// a sessão ao Firebase.
  Future<void> signIn() async {
    if (!_initialized) {
      throw const AuthFailure('O login ainda está sendo preparado.');
    }
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const AuthFailure(
        'Este dispositivo não oferece o login com Google.',
      );
    }

    late final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate(scopeHint: driveScopes);
    } on GoogleSignInException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
    _account = account;

    // Sem o consentimento do Drive o app não tem onde guardar nada, então
    // isso faz parte do login e não de um pedido posterior.
    await _authorizeDrive(interactive: true);

    final String? idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthFailure(
        'Não recebemos o identificador da conta. Confira a configuração '
        'do OAuth (serverClientId) e tente de novo.',
      );
    }

    await _firebaseAuth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  /// Cliente HTTP autenticado para as chamadas do `googleapis`.
  ///
  /// Sempre peça um cliente novo antes de uma sequência de chamadas: o token
  /// tem validade curta e é aqui que ele é renovado.
  Future<gapis.AuthClient> driveClient() async {
    final GoogleSignInClientAuthorization authorization = await _authorizeDrive(
      interactive: false,
    );
    return authorization.authClient(scopes: driveScopes);
  }

  Future<GoogleSignInClientAuthorization> _authorizeDrive({
    required bool interactive,
  }) async {
    final GoogleSignInAccount? account = _account;
    if (account == null) {
      throw const AuthFailure('Entre com a conta Google para continuar.');
    }

    try {
      final GoogleSignInClientAuthorization? existing = await account
          .authorizationClient
          .authorizationForScopes(driveScopes);
      if (existing != null) return existing;

      if (!interactive) {
        // Sem interação disponível: quem chamou precisa levar o usuário de
        // volta a uma tela onde o consentimento possa ser pedido.
        throw const AuthFailure(
          'Precisamos renovar a permissão do Google Drive.',
          needsPermission: true,
        );
      }
      return await account.authorizationClient.authorizeScopes(driveScopes);
    } on GoogleSignInException catch (e) {
      throw AuthFailure(_messageFor(e), needsPermission: true);
    }
  }

  Future<void> signOut() async {
    _account = null;
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Revoga a autorização concedida ao aplicativo.
  ///
  /// Diferente de [signOut], que apenas encerra a sessão: aqui o consentimento
  /// do Drive some da conta Google da pessoa, e o aplicativo deixa de existir
  /// na lista de aplicativos com acesso. É o que se espera de quem apaga a
  /// conta — sair não devolve a permissão.
  Future<void> disconnect() async {
    _account = null;
    try {
      await _googleSignIn.disconnect();
    } on GoogleSignInException catch (e) {
      // Se a revogação falhar, o resto da exclusão precisa continuar: dados
      // apagados importam mais que o consentimento pendurado.
      debugPrint('Revogação do acesso falhou: ${e.code}');
    }
  }

  /// Remove a conta do Firebase Auth.
  ///
  /// O Firebase recusa a exclusão quando o login é antigo; nesse caso a pessoa
  /// passa pela tela do Google de novo e a exclusão é refeita.
  Future<void> deleteAccount() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') rethrow;

      final String? idToken = await _reauthenticationToken();
      if (idToken == null) {
        throw const AuthFailure(
          'Para apagar a conta, entre de novo e repita a operação.',
        );
      }
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      await user.delete();
    }
  }

  Future<String?> _reauthenticationToken() async {
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      _account = account;
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  String _messageFor(GoogleSignInException e) => switch (e.code) {
    GoogleSignInExceptionCode.canceled => 'Login cancelado.',
    GoogleSignInExceptionCode.interrupted ||
    GoogleSignInExceptionCode.uiUnavailable =>
      'Não foi possível abrir a tela do Google. Tente de novo.',
    GoogleSignInExceptionCode.clientConfigurationError =>
      'A configuração do login com Google está incompleta. '
          'Confira o SETUP.md do projeto.',
    GoogleSignInExceptionCode.providerConfigurationError =>
      'Serviços do Google indisponíveis neste dispositivo.',
    GoogleSignInExceptionCode.userMismatch =>
      'A conta escolhida é diferente da conta em uso.',
    _ => 'Algo deu errado no login.',
  };
}
