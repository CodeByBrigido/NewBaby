import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:meu_bebe/services/auth_service.dart';

/// Nenhuma espera do preparo do login pode segurar a abertura do aplicativo.
///
/// Este arquivo existe por causa de duas telas em branco de verdade, no
/// celular, com o aplicativo já instalado. Nas duas o sintoma foi o mesmo e o
/// pior possível: nada. Sem erro, sem aviso, sem pista - porque o `runApp`
/// nunca chegou a acontecer, e é o `runApp` que desenha a tela que explicaria
/// o problema.
///
/// A causa também foi a mesma nas duas: uma chamada ao Play Services no
/// caminho da abertura, esperada sem prazo. Enquanto ela falhava rápido, tudo
/// parecia bem; quando passou a responder devagar, o aplicativo parou de
/// abrir. Proteger contra *lançar erro* não protege contra *travar*, e foi
/// exatamente esse o engano da primeira correção.
///
/// Por isso a garantia aqui é medida em tempo, e não em resultado.
class _FakePlatform extends GoogleSignInPlatform {
  _FakePlatform({this.initTravado = false, this.leveTravado = false});

  /// O `init` nunca responde - aparelho onde o Play Services não conclui.
  final bool initTravado;

  /// O `init` responde, mas a restauração da sessão anterior não.
  final bool leveTravado;

  bool leveChamado = false;

  @override
  Future<void> init(InitParameters params) {
    if (initTravado) return Completer<void>().future;
    return Future<void>.value();
  }

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) {
    leveChamado = true;
    if (leveTravado) return Completer<AuthenticationResults?>().future;
    return Future<AuthenticationResults?>.value();
  }

  // O resto da interface não participa da abertura.
  @override
  bool supportsAuthenticate() => true;

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) =>
      throw UnimplementedError();

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) => throw UnimplementedError();

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) => throw UnimplementedError();

  @override
  Future<void> signOut(SignOutParams params) async {}

  @override
  Future<void> disconnect(DisconnectParams params) async {}
}

/// Firebase não participa de nada que este arquivo mede: os caminhos testados
/// param antes de chegar nele. Isto existe só para o construtor não ir buscar
/// o `FirebaseAuth.instance`, que exige um app inicializado.
class _SemFirebase implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} fora do escopo.');
}

void main() {
  AuthService authService() => AuthService(
    firebaseAuth: _SemFirebase(),
    googleSignIn: GoogleSignIn.instance,
  );

  /// O prazo que o [AuthService] usa, com folga, para o teste não depender do
  /// valor exato - o que importa é que exista um.
  const Duration bemMaisQueOPrazo = Duration(minutes: 2);

  group('o preparo do login não segura a abertura', () {
    test('porque nem tenta restaurar a sessão anterior', () {
      final _FakePlatform platform = _FakePlatform(leveTravado: true);
      GoogleSignInPlatform.instance = platform;

      fakeAsync((FakeAsync async) {
        bool pronto = false;
        authService().initialize().then((_) => pronto = true);

        async.elapse(bemMaisQueOPrazo);

        expect(pronto, isTrue);
        expect(
          platform.leveChamado,
          isFalse,
          reason:
              'No Android, `attemptLightweightAuthentication` abre a folha '
              'de contas do sistema quando não consegue escolher sozinha, e '
              'ela não consegue em aparelho com mais de uma conta. Na '
              'abertura isso virava um seletor de contas em toda vez que o '
              'aplicativo era aberto, com a linha do tempo já carregada '
              'atrás dele.\n'
              'Quem sustenta a sessão é o Firebase Auth, lido do disco. A '
              'conta do Google só faz falta para o Drive, e é lá que ela '
              'passou a ser buscada.',
        );
      });
    });

    test('quando o próprio plugin nunca termina de iniciar', () {
      GoogleSignInPlatform.instance = _FakePlatform(initTravado: true);

      fakeAsync((FakeAsync async) {
        Object? falha;
        authService().initialize().catchError((Object e) => falha = e);

        async.elapse(bemMaisQueOPrazo);

        // Aqui desistir é o certo, e desistir tem que ser visível: o `main`
        // segue para o `runApp` e a tela de login explica o que houve.
        expect(
          falha,
          isA<TimeoutException>(),
          reason:
              'Sem prazo, esta espera nunca terminaria e o app não abriria.',
        );
      });
    });
  });

  group('desistir da espera não quebra o login para sempre', () {
    test('depois do prazo, tocar em Entrar tenta de novo', () {
      GoogleSignInPlatform.instance = _FakePlatform(initTravado: true);
      final AuthService auth = authService();

      fakeAsync((FakeAsync async) {
        auth.initialize().catchError((Object _) {});
        async.elapse(bemMaisQueOPrazo);

        Object? falha;
        auth.signIn().catchError((Object e) => falha = e);
        async.elapse(bemMaisQueOPrazo);

        // O que a pessoa lê precisa dizer o que fazer. "O login ainda está
        // sendo preparado" deixava ela apertando um botão que nunca ia
        // funcionar naquela sessão.
        expect(falha, isA<AuthFailure>());
        expect('$falha', contains('demorando'));
        expect('$falha', contains('tente de novo'));
      });
    });
  });
}
