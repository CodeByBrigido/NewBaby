import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Trava opcional do aplicativo, com a biometria do aparelho.
///
/// **Desligada por padrão, e é assim de propósito.** Este é um aplicativo de
/// família: obrigar a digital toda vez para ver a foto do filho irrita muito
/// mais do que protege. Quem quiser a proteção liga nas Configurações.
///
/// O que ela resolve: alguém pega o celular destravado e abre o aplicativo.
/// Sem a trava, vê o nome completo da criança, a data de nascimento e todas
/// as fotos. Não substitui a trava do próprio aparelho - soma a ela.
class LockService {
  LockService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  static const String _key = 'trava_biometrica';

  /// Quanto tempo o aplicativo pode ficar em segundo plano sem travar.
  ///
  /// Trocar de aplicativo para copiar um nome e voltar não deve pedir a
  /// digital. Deixar o celular na mesa e sair, sim.
  static const Duration grace = Duration(seconds: 30);

  /// Se o aparelho tem como autenticar - biometria, PIN, padrão ou senha.
  ///
  /// Num aparelho sem nada configurado a opção aparece desabilitada, com a
  /// explicação: ligar uma trava que não abre seria trancar a pessoa do lado
  /// de fora do próprio acervo.
  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Biometria indisponível neste aparelho: ${e.code}');
      return false;
    }
  }

  Future<bool> isEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// Pede a confirmação. `true` só quando a pessoa se identificou.
  ///
  /// `biometricOnly` fica em `false` de propósito: com o dedo molhado, ou num
  /// aparelho sem leitor, o PIN do sistema precisa servir. Uma trava que só
  /// aceita digital vira uma porta sem chave reserva.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // O próprio prompt tira o app do primeiro plano em alguns aparelhos;
        // com isto o plugin retoma a tentativa em vez de falhar.
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      debugPrint('Autenticação local não concluída: ${e.code}');
      return false;
    } on PlatformException catch (e) {
      debugPrint('Autenticação local falhou: ${e.code}');
      return false;
    }
  }
}

/// Marca os momentos em que o aplicativo vai para segundo plano **sem** que a
/// pessoa tenha saído dele.
///
/// Escolher uma foto, abrir um documento ou compartilhar leva o aplicativo
/// para trás enquanto uma tela do sistema aparece. Travar aí pediria a
/// digital no meio da tarefa, e não protegeria nada: o aparelho não saiu da
/// mão de ninguém.
///
/// A decisão é tomada no momento em que o aplicativo é pausado - quando esta
/// guarda comprovadamente está de pé -, e não na volta, cuja ordem de eventos
/// em relação ao resultado do seletor não é garantida.
abstract final class ExternalActivity {
  static int _depth = 0;

  static bool get isOpen => _depth > 0;

  static Future<T> run<T>(Future<T> Function() action) async {
    _depth++;
    try {
      return await action();
    } finally {
      _depth--;
    }
  }
}
