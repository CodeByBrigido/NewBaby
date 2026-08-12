import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' show DetailedApiRequestError;
import 'package:meu_bebe/core/utils/error_text.dart';

/// O que o aplicativo diz quando o Google Drive recusa.
///
/// Estas mensagens aparecem no pior momento possível: no cadastro, antes de
/// existir uma linha do tempo, quando a pessoa ainda não sabe se o
/// aplicativo funciona. "Tente de novo" ali é a pior resposta possível para
/// um erro que não depende dela em nada, e foi o que motivou este arquivo.
void main() {
  const String generico = 'Não foi possível concluir. Tente de novo.';

  String falha(int status, [String mensagem = '']) =>
      userMessage(DetailedApiRequestError(status, mensagem));

  group('cada recusa do Drive vira uma frase própria', () {
    test('a API desligada no projeto não vira culpa de quem cadastrou', () {
      // É o erro do primeiro cadastro num projeto recém-criado, e não há o
      // que a pessoa possa fazer: o conserto é do lado de quem publica.
      final String texto = falha(
        403,
        'Google Drive API has not been used in project 123 before or it is '
        'disabled',
      );
      expect(texto, isNot(generico));
      expect(texto, contains('não está liberado'));
      expect(texto, contains('não sua'));
    });

    test('sem espaço no Drive diz que é espaço', () {
      final String texto = falha(403, 'storageQuotaExceeded');
      expect(texto, contains('sem espaço'));
    });

    test(
      'o limite de chamadas pede espera, e não uma segunda tentativa já',
      () {
        for (final String texto in <String>[
          falha(403, 'userRateLimitExceeded'),
          falha(429, ''),
        ]) {
          expect(texto, contains('esperar um pouco'), reason: texto);
        }
      },
    );

    test('permissão recusada manda renovar o acesso', () {
      expect(falha(403, 'insufficientPermissions'), contains('Saia da conta'));
      expect(falha(401, ''), contains('expirou'));
    });

    test('a pasta sumida diz que é a pasta', () {
      expect(falha(404, ''), contains('pasta da cápsula'));
    });

    test('erro do servidor do Google avisa que nada se perdeu', () {
      // Sem isso a pessoa acha que precisa preencher tudo de novo, e o
      // formulário está inteiro na tela, atrás do aviso.
      for (final int status in <int>[500, 502, 503]) {
        expect(
          falha(status),
          contains('nada do que você preencheu se perdeu'),
          reason: '$status',
        );
      }
    });

    test('um erro sem código HTTP ainda diz que foi o Drive', () {
      expect(
        userMessage(DetailedApiRequestError(null, 'vazio')),
        contains('Google Drive'),
      );
    });
  });

  group('as frases servem para quem lê', () {
    test('nenhuma repete o texto que o Google mandou', () {
      // O texto do Google vem em inglês, cita número de projeto e endereço
      // de console. Repeti-lo na tela é despejar detalhe de infraestrutura
      // em cima de quem só queria cadastrar um filho.
      const String cru =
          'Google Drive API has not been used in project 14672319711';
      final String texto = falha(403, cru);
      expect(texto, isNot(contains('project')));
      expect(texto, isNot(contains('14672319711')));
      expect(texto, isNot(contains('API')));
    });

    test('nenhuma usa travessão', () {
      for (final int status in <int>[401, 403, 404, 429, 500, 0]) {
        expect(falha(status), isNot(contains('—')), reason: '$status');
      }
    });
  });
}
