import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' show DetailedApiRequestError;

import '../../services/auth_service.dart';
import '../../services/media_optimizer.dart';

/// Transforma uma exceção em algo que dá para mostrar a uma pessoa.
///
/// Exceções carregam caminho completo de arquivo, id do Drive e detalhe de
/// protocolo. Nada disso ajuda quem está com o celular na mão - e num
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

    DetailedApiRequestError() => _drive(error),

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

/// O que o Google Drive respondeu, dito de um jeito que ajuda.
///
/// Antes tudo isto caía no "Não foi possível concluir. Tente de novo.", que
/// é a pior resposta possível para o erro mais comum do primeiro cadastro:
/// a pessoa não tem o que tentar de novo, porque nada do lado dela está
/// errado. O detalhe cru continua indo só para o log.
///
/// Nenhuma destas frases repete o texto do Google. Ele vem em inglês, cita
/// número de projeto e endereço de console, e não é para quem está com o
/// celular na mão.
String _drive(DetailedApiRequestError error) {
  final String detalhe = (error.message ?? '').toLowerCase();

  bool diz(String trecho) => detalhe.contains(trecho);

  // `status` é anulável na biblioteca, e um erro sem código HTTP não é
  // nenhum dos casos abaixo: cai no genérico do Drive.
  return switch (error.status ?? 0) {
    401 =>
      'O acesso ao Google Drive expirou. Saia da conta e entre de novo '
          'para renovar a permissão.',

    // O 403 é o que mais aparece, e são causas bem diferentes uma da outra.
    403
        when diz('has not been used in project') ||
            diz('accessnotconfigured') =>
      'O Google Drive ainda não está liberado para este aplicativo. É uma '
          'configuração nossa, não sua: nada do que você preencheu se perdeu.',
    403 when diz('storagequotaexceeded') =>
      'O seu Google Drive está sem espaço. Libere espaço na conta e tente '
          'de novo.',
    403 when diz('ratelimit') || diz('userratelimit') =>
      'O Google Drive pediu para esperar um pouco. Tente de novo em '
          'instantes.',
    403 =>
      'O Google Drive recusou o acesso. Saia da conta e entre de novo para '
          'autorizar a pasta da cápsula.',

    404 => 'A pasta da cápsula não foi encontrada no seu Google Drive.',
    429 =>
      'O Google Drive pediu para esperar um pouco. Tente de novo em '
          'instantes.',
    >= 500 =>
      'O Google Drive não respondeu. Tente de novo em instantes; nada do que '
          'você preencheu se perdeu.',

    _ => 'Não foi possível falar com o Google Drive. Tente de novo.',
  };
}
