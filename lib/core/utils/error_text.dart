import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' show DetailedApiRequestError;

import '../l10n/strings.dart';
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

    SocketException() || HttpException() => S.errNoConnection,

    FileSystemException() => S.errFileRead,

    DetailedApiRequestError() => _drive(error),

    FirebaseException(:final String code) => switch (code) {
      // Duas causas moram neste código, e são opostas: ou a sessão caiu, ou
      // o servidor recusou o formato do que foi gravado (regra publicada
      // fora de dia com a versão instalada, por exemplo).
      //
      // Dizer só "sua sessão expirou" manda a pessoa sair e entrar de novo
      // para resolver algo que não é dela, e esconde de quem publica o
      // aplicativo o único sintoma que apontaria para as regras. A frase
      // cobre as duas, e a segunda metade tira o peso das costas de quem
      // está tentando cadastrar um filho.
      'permission-denied' => S.errPermissionDenied,
      'unauthenticated' => S.errSessionExpired,
      // Falta um índice no Firestore. Nada foi perdido: as memórias estão
      // gravadas, é a consulta que ordena a lista que não consegue rodar.
      // Dizer isso importa, porque a tela fica vazia e vazia parece
      // "sumiu tudo".
      'failed-precondition' => S.errMissingIndex,
      'unavailable' || 'deadline-exceeded' => S.errServerQuiet,
      'requires-recent-login' => S.errRecentLogin,
      _ => S.errGeneric,
    },

    _ => S.errGeneric,
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
    401 => S.errDriveExpired,

    // O 403 é o que mais aparece, e são causas bem diferentes uma da outra.
    403
        when diz('has not been used in project') ||
            diz('accessnotconfigured') =>
      S.errDriveNotEnabled,
    403 when diz('storagequotaexceeded') => S.errDriveFull,
    403 when diz('ratelimit') || diz('userratelimit') => S.errDriveRateLimit,
    403 => S.errDriveForbidden,

    404 => S.errDriveFolderMissing,
    429 => S.errDriveRateLimit,
    >= 500 => S.errDriveQuiet,

    _ => S.errDriveGeneric,
  };
}
