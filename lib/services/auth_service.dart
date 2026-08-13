import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;

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
/// - o próprio plugin devolve um token válido do cache quando possível.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// `drive.file` dá acesso apenas ao que o próprio aplicativo cria - é um
  /// escopo não sensível, então não exige verificação do app pelo Google.
  static const List<String> driveScopes = <String>[
    'https://www.googleapis.com/auth/drive.file',
  ];

  bool _initialized = false;
  Future<void>? _pluginReady;
  String? _clientId;
  String? _serverClientId;
  GoogleSignInAccount? _account;

  User? get currentUser => _firebaseAuth.currentUser;
  GoogleSignInAccount? get googleAccount => _account;
  String? get email => _account?.email ?? currentUser?.email;
  String? get photoUrl => _account?.photoUrl ?? currentUser?.photoURL;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Quanto o preparo do login pode demorar antes de desistir da espera.
  ///
  /// Nada aqui pode segurar a primeira tela: uma espera sem prazo no caminho
  /// da abertura vira tela em branco, sem erro e sem pista.
  static const Duration _prazo = Duration(seconds: 8);

  /// Inicializa o plugin e tenta reaproveitar uma sessão anterior sem mostrar
  /// nenhuma tela.
  ///
  /// Chamado na abertura do aplicativo e, se ali o prazo tiver estourado, de
  /// novo quando a pessoa toca em Entrar. Desistir da espera não pode virar
  /// um login quebrado para sempre.
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    if (_initialized) return;

    // Guardados para a tentativa de Entrar poder repetir o preparo com a
    // mesma configuração, sem depender de quem chamou daqui.
    _clientId = clientId ?? _clientId;
    _serverClientId = serverClientId ?? _serverClientId;

    // A chamada fica guardada. Se o prazo estourar, ela continua correndo por
    // baixo, e a próxima tentativa espera por essa mesma - o plugin diz, na
    // documentação, que `initialize` é para ser chamado uma única vez, e
    // chamar duas vezes tem comportamento indefinido.
    final Future<void> pendente = _pluginReady ??= _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );

    try {
      await pendente.timeout(_prazo);
    } on TimeoutException {
      // Ainda pode chegar; segura a referência para quem tentar de novo.
      rethrow;
    } on Object {
      // Falhou de verdade. Aí sim vale começar outra do zero.
      if (identical(_pluginReady, pendente)) _pluginReady = null;
      rethrow;
    }

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

    // Aqui **não** se tenta restaurar a conta do Google, e isso é o ponto
    // deste comentário.
    //
    // O nome `attemptLightweightAuthentication` promete uma restauração
    // silenciosa, mas no Android ela não é silenciosa. O plugin faz duas
    // tentativas em sequência (veja `google_sign_in_android.dart`): a
    // primeira com `filterToAuthorized: true, autoSelectEnabled: true`, que
    // de fato não mostra nada; e, **quando essa devolve nulo**, uma segunda
    // com as duas em falso, que é a folha do Credential Manager listando
    // todas as contas do aparelho.
    //
    // A primeira só resolve sozinha quando existe exatamente uma conta já
    // autorizada e o sistema topa escolher por conta própria. Em aparelho
    // com mais de uma conta, ou depois de a pessoa fechar a folha uma vez, o
    // Android para de escolher sozinho e cai sempre na segunda. Resultado:
    // um seletor de contas em toda abertura, pedindo uma escolha que o
    // aplicativo não precisa.
    //
    // Não precisa porque quem sustenta a sessão é o Firebase Auth, que
    // guarda a dele em disco e é lido sem rede nenhuma. A linha do tempo, o
    // perfil e o cadastro abrem com ela. A conta do Google só faz falta para
    // falar com o Drive, e por isso ela passou a ser buscada lá, em
    // `_authorizeDrive`, na primeira vez que o Drive é realmente usado.
    //
    // A saída pela `hostedDomain` (que faz o plugin pular a segunda
    // tentativa) não serve: ela restringe a entrada a um domínio corporativo
    // e deixaria de fora toda conta `gmail.com`, que é a de todo mundo aqui.
  }

  /// Recupera a conta do Google de uma sessão anterior.
  ///
  /// Pode abrir a folha de contas do Android, pelo motivo explicado em
  /// [initialize]. Por isso só é chamada quando o Drive é necessário de
  /// verdade: aí a escolha tem uma razão visível para quem está olhando, em
  /// vez de aparecer sozinha na abertura.
  Future<GoogleSignInAccount?> _restoreAccount() async {
    try {
      final GoogleSignInAccount? conta = await _googleSignIn
          .attemptLightweightAuthentication()
          ?.timeout(_prazo);
      _account ??= conta;
    } on GoogleSignInException catch (e) {
      debugPrint('Sessão anterior não disponível: ${e.code}');
    } on TimeoutException {
      debugPrint('Restaurar a sessão demorou demais; seguindo sem ela.');
    } on Object catch (e) {
      debugPrint('Restaurar a sessão falhou: $e');
    }
    return _account;
  }

  /// Fluxo completo de entrada: escolhe a conta, autoriza o Drive e conecta
  /// a sessão ao Firebase.
  Future<void> signIn() async {
    if (!_initialized) {
      // O preparo da abertura pode ter estourado o prazo. Aqui a pessoa está
      // olhando a tela e pediu para entrar: dá para esperar de novo, e o que
      // falhar vira uma frase que ela lê, em vez de um beco sem saída.
      try {
        await initialize(clientId: _clientId, serverClientId: _serverClientId);
      } on TimeoutException {
        throw const AuthFailure(
          'O login com Google está demorando para responder. '
          'Confira a conexão e tente de novo.',
        );
      } on GoogleSignInException catch (e) {
        throw AuthFailure(_messageFor(e));
      }
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
    final gapis.AuthClient client = authorization.authClient(
      scopes: driveScopes,
    );
    await _conferirDono(client);
    return client;
  }

  /// Garante o consentimento do Drive, podendo mostrar a tela do Google.
  ///
  /// Existe para o botão "Tentar de novo". Sem ela, um envio que falhou por
  /// falta de permissão ficava travado para sempre: o caminho normal do
  /// envio não pode abrir tela nenhuma, então tentar de novo repetia o mesmo
  /// erro sem chance de resolvê-lo. Tocar em "Tentar de novo" é a pessoa
  /// olhando para o aplicativo e pedindo, que é exatamente quando abrir a
  /// tela do Google é aceitável.
  ///
  /// Não faz nada quando o consentimento já existe, que é o caso comum.
  Future<void> garantirPermissaoDoDrive() async {
    await _authorizeDrive(interactive: true);
  }

  /// De quem é o Drive que este token abre.
  ///
  /// Guardado por sessão: a resposta não muda enquanto o aplicativo estiver
  /// aberto, e uma chamada por envio seria desperdício.
  String? _donoConferido;

  /// Recusa um token que não seja da conta em uso.
  ///
  /// O degrau 2 de [_authorizeDrive] pede autorização sem dizer de qual
  /// conta, porque não tem como dizer. Num aparelho com duas contas já
  /// autorizadas, o sistema pode devolver a outra, e aí as memórias de um
  /// filho entrariam no Drive do outro. Num aplicativo que existe para
  /// guardar a infância de alguém, isso é o pior defeito possível: silencioso
  /// na hora e irreversível depois.
  ///
  /// Por isso a conferência é contra o Firebase, que é quem sabe de quem é a
  /// sessão. Quando não dá para comparar, o token passa: recusar por falta de
  /// informação deixaria o envio impossível em vez de seguro.
  Future<void> _conferirDono(gapis.AuthClient client) async {
    final String? esperado = currentUser?.email;
    if (esperado == null || _donoConferido == esperado) return;

    final String? dono = await _emailDoDrive(client);
    if (dono == null) return;

    if (dono.toLowerCase() != esperado.toLowerCase()) {
      // O consentimento guardado é de outra conta. Some com ele para o
      // próximo pedido passar pelo caminho interativo, na conta certa.
      _account = null;
      _donoConferido = null;
      throw const AuthFailure(
        'A permissão guardada é de outra conta do Google. Entre de novo '
        'para continuar guardando nesta cápsula.',
        needsPermission: true,
      );
    }
    _donoConferido = esperado;
  }

  /// O email do dono do Drive que o token alcança.
  ///
  /// `about.get` já é usado pela tela de estatísticas com este mesmo escopo,
  /// então não custa consentimento nenhum a mais.
  Future<String?> _emailDoDrive(gapis.AuthClient client) async {
    try {
      final http.Response resposta = await client
          .get(
            Uri.parse(
              'https://www.googleapis.com/drive/v3/about'
              '?fields=user%2FemailAddress',
            ),
          )
          .timeout(_prazo);
      if (resposta.statusCode != 200) return null;

      final Object? corpo = jsonDecode(resposta.body);
      if (corpo is! Map<String, Object?>) return null;
      final Object? usuario = corpo['user'];
      if (usuario is! Map<String, Object?>) return null;
      final Object? email = usuario['emailAddress'];
      return email is String ? email : null;
    } on Object catch (e) {
      // Rede fora, ou resposta estranha. Não é motivo para bloquear o envio:
      // a conferência é uma trava contra o caso raro, não um requisito.
      debugPrint('Não foi possível conferir o dono do Drive: $e');
      return null;
    }
  }

  /// Consegue autorização para o Drive, preferindo sempre o caminho que não
  /// mostra nada na tela.
  ///
  /// A ordem dos três degraus é o que faz o envio funcionar depois de
  /// reabrir o aplicativo sem pedir a conta de novo.
  Future<GoogleSignInClientAuthorization> _authorizeDrive({
    required bool interactive,
  }) async {
    try {
      // 1. Com a conta em mãos, o pedido vai amarrado ao email dela. É o
      //    caminho de quem acabou de entrar, e o mais preciso que existe.
      final GoogleSignInAccount? account = _account;
      if (account != null) {
        final GoogleSignInClientAuthorization? existing = await account
            .authorizationClient
            .authorizationForScopes(driveScopes);
        if (existing != null) return existing;

        if (interactive) {
          return await account.authorizationClient.authorizeScopes(driveScopes);
        }
      }

      // 2. Sem a conta, que é a situação de todo reinício do aplicativo.
      //
      //    O token de autorização do Drive não depende de saber quem é a
      //    pessoa: o consentimento fica guardado no aparelho, e o plugin
      //    devolve o token sem interface nenhuma. Era isto que faltava, e a
      //    falta transformava todo envio depois de reabrir num seletor de
      //    contas, e depois num envio travado quando alguém o fechava.
      //
      //    O preço é que o pedido não diz de qual conta é. Num aparelho com
      //    duas contas já autorizadas, ele pode voltar com a errada, e por
      //    isso `driveClient` confere de quem é o token antes de usá-lo.
      final GoogleSignInClientAuthorization? guardada = await _googleSignIn
          .authorizationClient
          .authorizationForScopes(driveScopes);
      if (guardada != null) return guardada;

      // 3. Não há consentimento guardado. Agora a interface é inevitável, e
      //    só quem chamou sabe se é hora de mostrá-la.
      if (!interactive) {
        throw const AuthFailure(
          'Precisamos renovar a permissão do Google Drive.',
          needsPermission: true,
        );
      }

      final GoogleSignInAccount? recuperada =
          _account ?? await _restoreAccount();
      if (recuperada == null) {
        throw const AuthFailure('Entre com a conta Google para continuar.');
      }
      return await recuperada.authorizationClient.authorizeScopes(driveScopes);
    } on GoogleSignInException catch (e) {
      throw AuthFailure(
        _messageFor(
          e,
          // Aqui a conta já foi escolhida; o que foi recusado é a permissão
          // do Drive. Dizer "Login cancelado." mandaria a pessoa refazer a
          // parte que já tinha dado certo.
          canceled:
              'Você não autorizou o acesso ao Google Drive. É lá que as '
              'memórias ficam guardadas, na sua própria conta.',
        ),
        needsPermission: true,
      );
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
  /// conta - sair não devolve a permissão.
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

  /// Traduz a falha do plugin.
  ///
  /// [canceled] existe porque desistir tem significados diferentes conforme o
  /// passo: fechar a lista de contas não é a mesma coisa que recusar o acesso
  /// ao Drive, e a mesma frase para as duas coisas confunde.
  String _messageFor(
    GoogleSignInException e, {
    String canceled = 'Login cancelado.',
  }) => switch (e.code) {
    GoogleSignInExceptionCode.canceled => canceled,
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
