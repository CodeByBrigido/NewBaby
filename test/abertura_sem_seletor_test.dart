import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Abrir o aplicativo não pode pedir a conta do Google.
///
/// O seletor aparecia em toda abertura, com a linha do tempo já carregada
/// atrás dele: a sessão estava restaurada e a escolha era inútil.
///
/// A causa é o `attemptLightweightAuthentication`. O nome promete uma
/// restauração silenciosa, mas no Android o plugin faz duas tentativas em
/// sequência (`google_sign_in_android.dart`): a primeira com
/// `filterToAuthorized: true` e `autoSelectEnabled: true`, silenciosa de
/// fato; e, quando essa devolve nulo, uma segunda com as duas em falso, que
/// é a folha do Credential Manager com todas as contas do aparelho. Em
/// aparelho com mais de uma conta, cai sempre na segunda.
///
/// Quem sustenta a sessão é o Firebase Auth, lido do disco sem rede. A conta
/// do Google só faz falta para o Drive.
///
/// O teste lê o código porque o defeito não aparece em teste de widget nem
/// no `analyze`: ele só se vê num aparelho com duas contas, que é justamente
/// onde ninguém roda a suíte. O que ele protege é a **ausência** de uma
/// chamada, e ausência não quebra nada quando volta.
void main() {
  /// O arquivo sem comentário nenhum.
  ///
  /// Sem isto o teste se acusa sozinho: este arquivo e o outro explicam o
  /// defeito citando o nome do método, e uma varredura ingênua conta a
  /// explicação como se fosse a chamada. O que importa é o que executa.
  String semComentarios(String codigo) => codigo
      .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
      .split('\n')
      .map((String linha) {
        final int barra = linha.indexOf('//');
        return barra == -1 ? linha : linha.substring(0, barra);
      })
      .join('\n');

  final String fonte = semComentarios(
    File('lib/services/auth_service.dart').readAsStringSync(),
  );

  /// O corpo de um método, da abertura da chave até a que a fecha.
  ///
  /// Os parênteses são percorridos primeiro porque um parâmetro nomeado
  /// também vem entre chaves: contar chaves desde o cabeçalho faria o corpo
  /// terminar na lista de parâmetros, e o teste passaria sem olhar nada.
  String corpoDe(String assinatura) {
    final int cabecalho = fonte.indexOf(assinatura);
    expect(cabecalho, isNot(-1), reason: 'não achei `$assinatura`');

    int parenteses = 0;
    int i = cabecalho;
    for (; i < fonte.length; i++) {
      if (fonte[i] == '(') parenteses++;
      if (fonte[i] == ')') {
        parenteses--;
        if (parenteses == 0) break;
      }
    }

    final int corpo = fonte.indexOf('{', i);
    expect(corpo, isNot(-1), reason: 'não achei o corpo de `$assinatura`');

    int chaves = 0;
    for (int j = corpo; j < fonte.length; j++) {
      if (fonte[j] == '{') chaves++;
      if (fonte[j] == '}') {
        chaves--;
        if (chaves == 0) return fonte.substring(corpo, j + 1);
      }
    }
    fail('não achei o fim de `$assinatura`');
  }

  group('a abertura do aplicativo', () {
    test('não toca no login do Google', () {
      final String initialize = corpoDe('Future<void> initialize(');

      expect(
        initialize,
        isNot(contains('attemptLightweightAuthentication')),
        reason:
            'No Android essa chamada abre a folha de contas quando não '
            'consegue escolher sozinha, e na abertura isso vira um seletor '
            'em toda vez que o aplicativo é aberto.',
      );
      expect(
        initialize,
        isNot(contains('_restoreAccount')),
        reason: 'Recuperar a conta na abertura tem o mesmo efeito.',
      );
      expect(
        initialize,
        isNot(contains('authenticate(')),
        reason: 'Abrir o aplicativo nunca é motivo para pedir a conta.',
      );
    });
  });

  group('a conta do Google', () {
    test('é recuperada quando o Drive precisa dela, e não antes', () {
      // O adiamento só é aceitável porque alguém recupera a conta depois.
      // Sem isto, o primeiro envio depois de reabrir falharia com "Entre com
      // a conta Google para continuar" numa sessão que está perfeitamente
      // válida.
      final String autorizar = corpoDe(
        'Future<GoogleSignInClientAuthorization> _authorizeDrive(',
      );

      expect(autorizar, contains('_restoreAccount()'));
    });

    test('a recuperação existe e é a única dona da chamada do plugin', () {
      final String restaurar = corpoDe(
        'Future<GoogleSignInAccount?> _restoreAccount(',
      );
      expect(restaurar, contains('attemptLightweightAuthentication'));

      // Uma ocorrência no método que a encapsula, e nenhuma fora dele.
      expect(
        'attemptLightweightAuthentication'.allMatches(fonte).length,
        1,
        reason:
            'A chamada abre interface no Android; ela precisa ter um dono '
            'só, com o porquê escrito ao lado.',
      );
    });

    test('não derruba o envio quando não consegue recuperar', () {
      // Aparelho sem Play Services, ou pessoa que fecha a folha: o envio
      // precisa acabar numa frase legível, e não numa exceção crua.
      final String restaurar = corpoDe(
        'Future<GoogleSignInAccount?> _restoreAccount(',
      );
      expect(restaurar, contains('on GoogleSignInException'));
      expect(restaurar, contains('on TimeoutException'));
      expect(restaurar, contains('on Object'));
    });
  });

  group('a autorização do Drive', () {
    test('tenta o caminho sem conta antes de abrir qualquer tela', () {
      // A ordem é o que decide se enviar uma foto depois de reabrir o
      // aplicativo mostra um seletor de contas ou não passa nada na frente.
      //
      // O token do Drive não depende de saber quem é a pessoa: o
      // consentimento fica guardado no aparelho. Pedir a conta antes disso
      // era o que transformava todo envio numa escolha, e depois num envio
      // travado quando alguém fechava a folha.
      final String corpo = corpoDe(
        'Future<GoogleSignInClientAuthorization> _authorizeDrive(',
      );

      // Sem os espaços: onde o `dart format` quebra a linha é assunto dele,
      // e um teste que dependa disso quebra por reformatação, não por
      // regressão.
      final String liso = corpo.replaceAll(RegExp(r'\s+'), '');
      final int semConta = liso.indexOf('_googleSignIn.authorizationClient');
      final int comTela = liso.indexOf('_restoreAccount()');

      expect(semConta, isNot(-1), reason: 'o degrau sem conta precisa existir');
      expect(comTela, isNot(-1), reason: 'o degrau interativo precisa existir');
      expect(
        semConta,
        lessThan(comTela),
        reason:
            'A autorização guardada precisa ser tentada antes de qualquer '
            'coisa que possa abrir tela.',
      );
    });

    test('o envio comum nunca pede a tela do Google', () {
      // `driveClient` é o caminho de todo envio e de toda miniatura. Se ele
      // pudesse abrir tela, a folha de contas voltaria a aparecer sozinha.
      final String corpo = corpoDe('Future<gapis.AuthClient> driveClient(');
      expect(corpo, contains('interactive: false'));
    });

    test('tentar de novo pode pedir, porque a pessoa está olhando', () {
      final String corpo = corpoDe('Future<void> garantirPermissaoDoDrive(');
      expect(corpo, contains('interactive: true'));
    });

    test('um token de outra conta é recusado, e não usado em silêncio', () {
      // O degrau sem conta não diz de qual conta é. Num aparelho com duas
      // contas autorizadas, o sistema pode devolver a errada, e aí as
      // memórias de um filho entrariam no Drive do outro: silencioso na hora
      // e irreversível depois.
      final String corpo = corpoDe('Future<void> _conferirDono(');

      expect(corpo, contains('currentUser?.email'));
      expect(corpo, contains('toLowerCase()'));
      expect(corpo, contains('needsPermission: true'));
      expect(
        corpo,
        contains('_account = null'),
        reason:
            'Recusar sem esquecer a conta deixaria o próximo pedido repetir '
            'o mesmo token errado.',
      );
    });

    test('a conferência não bloqueia o envio quando não dá para comparar', () {
      // Sem email no Firebase, ou com a rede fora, não há o que comparar.
      // Recusar por falta de informação deixaria o envio impossível em vez
      // de seguro.
      final String conferir = corpoDe('Future<void> _conferirDono(');
      expect(conferir, contains('esperado == null'));

      final String consultar = corpoDe('Future<String?> _emailDoDrive(');
      expect(consultar, contains('on Object'));
      expect(consultar, contains('return null'));
    });
  });
}
