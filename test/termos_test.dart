import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/pagina_web.dart';
import 'package:meu_bebe/core/l10n/privacy_policy.dart';
import 'package:meu_bebe/core/l10n/terms_of_use.dart';
import 'package:meu_bebe/core/router/app_router.dart';
import 'package:meu_bebe/services/auth_service.dart';

/// Os termos de uso.
///
/// O aplicativo não tinha nenhum, e o que aparecia na tela de entrada, ao
/// lado da política, era o atalho para apagar a conta: uma resposta para uma
/// pergunta que ninguém faz antes de ter conta.
///
/// Cada teste aqui prende uma frase do texto a um fato do código, para o
/// documento não virar promessa que o aplicativo não cumpre.
void main() {
  final String texto = termsOfUse
      .map((PrivacySection s) => '${s.title}\n${s.body.join("\n")}')
      .join('\n\n');

  group('o texto e o código dizem a mesma coisa', () {
    test('o acesso ao Drive descrito é o que o aplicativo pede', () {
      // A promessa "não enxerga nada que já estivesse na sua conta" só é
      // verdade porque o escopo é estreito. Um escopo mais amplo tornaria a
      // frase falsa, e é a frase que a loja lê.
      expect(AuthService.driveScopes, hasLength(1));
      expect(AuthService.driveScopes.single, contains('drive.file'));
      expect(texto, contains('apenas para os arquivos que ele mesmo cria'));
    });

    test('o caminho de sair descrito existe', () {
      expect(texto, contains('página de exclusão de conta'));
      expect(Routes.accountDeletion, isNotEmpty);
    });

    test('o email e o responsável são os mesmos da política', () {
      // Dois endereços diferentes em dois documentos é um pedido que se perde.
      expect(texto, contains(privacyEmail));
      expect(texto, contains(privacyController));
    });

    test('a idade mínima aparece escrita, e não só na constante', () {
      expect(idadeMinima, greaterThanOrEqualTo(18));
      expect(texto, contains('$idadeMinima'));
    });
  });

  group('o que os termos precisam dizer', () {
    test('que o conteúdo continua sendo de quem guarda', () {
      expect(texto, contains('continua sendo seu'));
      expect(texto, contains('não usamos o seu conteúdo para treinar'));
    });

    test('que não somos backup', () {
      // É a expectativa mais perigosa que alguém pode trazer para um
      // aplicativo de memórias, e ela precisa ser desfeita por escrito.
      expect(texto, contains('Não somos um serviço de backup'));
    });

    test('que as inspirações não são conselho médico', () {
      expect(texto, contains('Não são orientação médica'));
    });

    test('que quem cria a conta responde pela criança', () {
      expect(texto, contains('responsável legal'));
      expect(texto, contains('Lei Geral de Proteção de Dados'));
    });

    test('a lei e o foro', () {
      expect(texto, contains('lei brasileira'));
      expect(texto, contains('domicílio do usuário'));
    });

    test('nenhuma seção está vazia, e nenhuma usa travessão', () {
      for (final PrivacySection s in termsOfUse) {
        expect(s.body, isNotEmpty, reason: s.title);
        for (final String p in s.body) {
          expect(p.trim(), isNotEmpty, reason: s.title);
          expect(p, isNot(contains('—')), reason: s.title);
        }
      }
    });
  });

  group('o rodapé da tela de entrada', () {
    String fonte(String caminho) =>
        File(caminho).readAsStringSync().replaceAll(RegExp(r'\s+'), '');

    test('leva aos termos, e não mais a apagar a conta', () {
      // Quem está nessa tela ainda não tem conta: um atalho para apagá-la
      // ali responde uma pergunta que ninguém fez.
      final String tela = fonte('lib/features/auth/login_screen.dart');
      expect(tela, contains('destino:Routes.terms'));
      expect(tela, isNot(contains('destino:Routes.accountDeletion')));
    });

    test('a política continua no rodapé', () {
      // Ela é exigência da loja, e é o documento que mais gente abre antes de
      // decidir. Trocar um pelo outro seria perder mais do que se ganha.
      expect(
        fonte('lib/features/auth/login_screen.dart'),
        contains('destino:Routes.privacy'),
      );
    });

    test('a página de exclusão continua alcançável dentro do aplicativo', () {
      // Ela é exigência do Google Play. Sair do rodapé só é aceitável porque
      // o Perfil continua levando até lá, que é onde alguém a procura.
      expect(
        fonte('lib/features/profile/profile_screen.dart'),
        contains('Routes.accountDeletion'),
      );
    });
  });

  group('a versão pública é a mesma que está no código', () {
    test('o arquivo no repositório está em dia', () {
      final File arquivo = File('TERMOS-DE-USO.md');
      expect(
        arquivo.existsSync(),
        isTrue,
        reason: 'Rode: dart run tool/gerar_termos.dart',
      );
      expect(
        arquivo.readAsStringSync(),
        termosEmMarkdown(),
        reason:
            'O texto mudou e o arquivo público não. Rode: '
            'dart run tool/gerar_termos.dart',
      );
    });

    test('a página no ar está em dia', () {
      final File arquivo = File('docs/termos.html');
      expect(
        arquivo.existsSync(),
        isTrue,
        reason: 'Rode: dart run tool/gerar_site.dart',
      );
      expect(
        arquivo.readAsStringSync(),
        termosEmHtml(),
        reason: 'docs/termos.html mudou. Rode: dart run tool/gerar_site.dart',
      );
    });

    test('o índice e a política levam aos termos', () {
      // Uma página que ninguém alcança é uma página que não existe.
      expect(indiceEmHtml(), contains('termos.html'));
      expect(privacidadeEmHtml(), contains('termos.html'));
    });

    test('a página é um arquivo só, sem buscar nada de fora', () {
      final String html = termosEmHtml();
      expect(html, isNot(contains('<script')));
      expect(html, isNot(contains('<link')));
      expect(html, contains('<style>'));
    });

    test('não sobrou marcação de Markdown à vista', () {
      expect(termosEmHtml(), isNot(contains('**')));
    });
  });
}
