import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/account_deletion.dart';
import 'package:meu_bebe/core/l10n/pagina_web.dart';
import 'package:meu_bebe/core/l10n/privacy_policy.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/services/auth_service.dart';
import 'package:meu_bebe/services/drive_service.dart';
import 'package:meu_bebe/services/firestore_service.dart';

/// A página pública de exclusão de conta.
///
/// O Google Play a exige, e quem a lê toma decisão com base nela: alguém que
/// acredita ter apagado tudo e não apagou fica com o registro do filho num
/// lugar de onde achava ter saído. Uma página desatualizada aqui é pior que
/// página nenhuma.
///
/// Cada teste prende uma frase do texto a um fato do código.
void main() {
  final String texto = accountDeletionPage
      .map((PrivacySection s) => '${s.title}\n${s.body.join("\n")}')
      .join('\n\n');

  group('o texto e o código dizem a mesma coisa', () {
    test('o caminho dentro do aplicativo existe como está descrito', () {
      // A página manda tocar em Perfil e depois no botão de apagar. Se
      // alguém renomear esse botão, a instrução vira uma caça ao tesouro.
      expect(texto, contains('Perfil'));
      expect(texto, contains('Apagar minha conta e meus dados'));
    });

    test('a pasta citada é a pasta que o aplicativo cria', () {
      // A página ensina a apagar a pasta pelo Drive, pelo nome. Nome errado
      // aqui é a pessoa procurando uma pasta que não existe.
      expect(texto, contains(DriveService.rootFolderName));
    });

    test('o escopo citado é o escopo que o aplicativo pede', () {
      // A promessa "não temos como apagar seus arquivos depois" só é
      // verdade porque o acesso é estreito e revogável. Um escopo mais
      // amplo tornaria a frase falsa.
      expect(AuthService.driveScopes, hasLength(1));
      expect(texto, contains(AuthService.driveScopes.single));
    });

    test('o email é o mesmo da política', () {
      // Dois endereços diferentes em dois documentos é um pedido que se
      // perde e um prazo que estoura sem ninguém saber.
      expect(texto, contains(privacyEmail));
      expect(texto, contains(privacyController));
    });

    test('o que a página promete apagar é o que o código apaga', () {
      // A varredura de exclusão passa por estas coleções. Uma coleção nova
      // é dado novo, e dado novo precisa aparecer na página antes de
      // existir, senão a promessa "tudo, sem exceção" deixa de ser verdade.
      expect(
        FirestoreService.debugCollections,
        <String>[
          'perfil',
          'entradas',
          'pastas',
          'sugestoes',
          'miniaturas',
          'imagens',
        ],
        reason:
            'Coleção nova: descreva-a em "O que é apagado" antes de mudar '
            'este teste.',
      );

      expect(texto, contains('cadastro da criança'));
      expect(texto, contains('cartas'));
      expect(texto, contains('conta de autenticação'));
    });
  });

  group('as arestas que a loja cobra', () {
    test('funciona para quem já desinstalou', () {
      // É a razão de a página existir. Sem um caminho fora do aplicativo,
      // ela não cumpre a exigência.
      expect(texto, contains('desinstalado'));
      expect(texto, contains('Excluir minha conta'));
    });

    test('diz de que endereço o pedido precisa vir', () {
      // Sem verificação de identidade, um email bastaria para apagar o
      // acervo de outra pessoa.
      expect(texto, contains('conta Google que você usou'));
    });

    test('promete um prazo, e ele é o do GDPR', () {
      expect(deletionDeadlineDays, lessThanOrEqualTo(30));
      expect(texto, contains('$deletionDeadlineDays dias'));
    });

    test('diz o que não é apagado, e não esconde isso no fim', () {
      // A loja pede que o texto separe o que é excluído do que é retido. E
      // a honestidade aqui é o ponto forte do produto, não a fraqueza.
      final List<String> titulos = accountDeletionPage
          .map((PrivacySection s) => s.title)
          .toList();
      expect(titulos, contains('O que é apagado'));
      expect(titulos, contains('O que não é apagado, e por quê'));
      expect(
        titulos.indexOf('O que não é apagado, e por quê'),
        titulos.indexOf('O que é apagado') + 1,
        reason:
            'As duas seções andam juntas: separá-las deixa a segunda '
            'parecendo letra miúda',
      );
    });

    test('oferece apagar parte sem apagar a conta', () {
      // O formulário de Segurança dos Dados pergunta isso explicitamente.
      expect(texto, contains('Apagar só uma parte'));
    });

    test('há uma versão em inglês para quem revisa a loja', () {
      // Uma URL de exclusão que o revisor não consegue ler custa um ciclo
      // de revisão inteiro, e o revisor raramente lê português.
      final PrivacySection ingles = accountDeletionPage.last;
      expect(ingles.title, contains('English'));
      expect(ingles.body.join(' '), contains('delete your'));
      expect(ingles.body.join(' '), contains('irreversible'));
    });

    test('nenhuma seção está vazia, e nenhuma usa travessão', () {
      for (final PrivacySection s in accountDeletionPage) {
        expect(s.body, isNotEmpty, reason: s.title);
        for (final String p in s.body) {
          expect(p.trim(), isNotEmpty, reason: s.title);
          expect(p, isNot(contains('—')), reason: s.title);
        }
      }
    });
  });

  group('a versão pública é a mesma que está no código', () {
    test('o arquivo no repositório está em dia', () {
      final File arquivo = File('EXCLUSAO-DE-CONTA.md');
      expect(
        arquivo.existsSync(),
        isTrue,
        reason: 'Rode: dart run tool/gerar_exclusao.dart',
      );
      expect(
        arquivo.readAsStringSync(),
        exclusaoEmMarkdown(),
        reason:
            'O texto mudou e o arquivo público não. Rode: '
            'dart run tool/gerar_exclusao.dart',
      );
    });

    test('as três páginas de docs/ estão em dia', () {
      // São elas que ficam no ar. Um texto novo aqui sem regerar o site é
      // uma página no Play Console descrevendo um aplicativo que mudou.
      final Map<String, String> esperado = <String, String>{
        'docs/index.html': indiceEmHtml(),
        'docs/privacidade.html': privacidadeEmHtml(),
        'docs/exclusao.html': exclusaoEmHtml(),
      };
      esperado.forEach((String caminho, String conteudo) {
        final File arquivo = File(caminho);
        expect(
          arquivo.existsSync(),
          isTrue,
          reason: '$caminho: rode dart run tool/gerar_site.dart',
        );
        expect(
          arquivo.readAsStringSync(),
          conteudo,
          reason: '$caminho mudou. Rode: dart run tool/gerar_site.dart',
        );
      });
    });
  });

  group('a página no ar funciona para quem a abre', () {
    final String html = exclusaoEmHtml();

    test('o email é clicável nas duas páginas', () {
      // Quem lê isso está no celular. Um endereço que não é link é um
      // endereço copiado errado, e um pedido que não chega.
      expect(html, contains('href="mailto:$privacyEmail"'));
      expect(privacidadeEmHtml(), contains('href="mailto:$privacyEmail"'));
    });

    test('o escopo aparece como texto, e não como link quebrado', () {
      // A URL do escopo é um identificador do OAuth: aberta no navegador
      // ela devolve erro, e quem clicou foi justamente conferir a promessa.
      final String escopo = AuthService.driveScopes.single;
      expect(html, contains('<code>$escopo</code>'));
      expect(html, isNot(contains('href="$escopo"')));
    });

    test('não sobrou marcação de Markdown à vista', () {
      // O texto usa **negrito**, que o Markdown entende e o navegador não.
      expect(html, isNot(contains('**')));
      expect(html, contains('<strong>'));
      expect(html, isNot(contains('<p>• ')));
      expect(html, contains('<li>'));
    });

    test('a página é um arquivo só, sem buscar nada de fora', () {
      // Sem CSS remoto, sem fonte remota, sem script: uma página que
      // depende de terceiro é uma página que um dia abre em branco para o
      // revisor da loja.
      expect(html, isNot(contains('<script')));
      expect(html, isNot(contains('<link')));
      expect(html, isNot(contains('src=')));
      expect(html, contains('<style>'));
    });

    test('as cores da página são as da paleta do aplicativo', () {
      // Estão escritas à mão no CSS porque o gerador roda em Dart puro. É
      // aqui que a cópia à mão é conferida.
      String hex(Color c) =>
          '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';

      const AppPalette p = AppPalette.neutral;
      expect(coresDaPagina, <String, String>{
        'primary': hex(p.primary),
        'primaryDark': hex(p.primaryDark),
        'background': hex(p.background),
        'surface': hex(p.surface),
        'textPrimary': hex(p.textPrimary),
        'textSecondary': hex(p.textSecondary),
        'border': hex(p.border),
      });
    });
  });
}
