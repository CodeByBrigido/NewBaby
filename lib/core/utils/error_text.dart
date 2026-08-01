import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';
import '../../services/media_optimizer.dart';

/// Transforma uma exceção em algo que dá para mostrar a uma pessoa.
///
/// Exceções carregam caminho completo de arquivo, id do Drive e detalhe de
/// protocolo. Nada disso ajuda quem está com o celular na mão — e num
/// aplicativo que guarda o registro de uma criança, o hábito de despejar o
/// texto cru na tela (e no banco, onde ele fica gravado) é o que um dia
/// entrega algo que não devia.
///
/// O detalhe não se perde: vai para o log, que só existe em depuração.
String userMessage(Object error, {String? context}) {
  if (context != null) debugPrint('$context: $error');

  return switch (error) {
    // Já nascem escritas para o usuário.
    AuthFailure(:final String message) => message,
    MediaOptimizationException(:final String message) => message,

    SocketException() ||
    HttpException() => 'Sem conexão com a internet. Tente de novo.',

    FileSystemException() => 'Não foi possível ler o arquivo no aparelho.',

    FirebaseException(:final String code) => switch (code) {
      'permission-denied' =>
        'Sua sessão expirou. Entre de novo para continuar.',
      'unavailable' || 'deadline-exceeded' =>
        'O servidor não respondeu. Tente de novo em instantes.',
      'requires-recent-login' =>
        'Por segurança, entre de novo antes de continuar.',
      _ => 'Não foi possível concluir. Tente de novo.',
    },

    _ => 'Não foi possível concluir. Tente de novo.',
  };
}
