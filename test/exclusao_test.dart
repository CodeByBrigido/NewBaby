import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/account_deletion.dart';
import 'package:meu_bebe/core/l10n/account_deletion_en.dart';
import 'package:meu_bebe/core/l10n/pagina_web.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/l10n/privacy_policy.dart';
import 'package:meu_bebe/core/l10n/privacy_policy_en.dart';
import 'package:meu_bebe/core/l10n/terms_of_use_en.dart';
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
String _semMarcacao(String texto) => texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

void main() {
  final String texto = accountDeletionPage
      .map((PrivacySection s) => '${s.title}\n${s.body.join("\n")}')
      .join('\n\n');

  group('o texto e o código dizem a mesma coisa', () {
    test('o caminho dentro do aplicativo existe como está descrito', () {
      // A instrução tinha um passo a menos que o aplicativo: mandava tocar
      // em Perfil e depois direto no botão vermelho, que não está no Perfil.
      // Entre os dois há a página de leitura, que existe justamente para
      // ninguém apagar sem ler.
      //
      // Os rótulos vêm de `S`, e não copiados à mão: renomear um botão passa
      // a derrubar este teste em vez de deixar a página mandando a pessoa
      // procurar um controle que mudou de nome.
      expect(texto, contains('Perfil'));
      for (final String rotulo in <String>[
        S.accountDeletionTitle,
        S.goToDeleteAccount,
        S.deleteAccount,
      ]) {
        expect(texto, contains(rotulo), reason: rotulo);
      }
    });

    test('os passos aparecem na ordem em que a pessoa vai encontrá-los', () {
      // Ordem errada num passo a passo é pior que passo faltando: manda
      // procurar no lugar errado com a confiança de quem está seguindo
      // instrução.
      expect(
        texto.indexOf(S.accountDeletionTitle),
        lessThan(texto.indexOf(S.goToDeleteAccount)),
      );
      expect(
        texto.indexOf(S.goToDeleteAccount),
        lessThan(texto.indexOf(S.deleteAccount)),
      );
    });

    test('a escolha sobre a pasta do Drive vem antes do botão', () {
      // Ela é oferecida na tela do botão vermelho, e é irreversível junto
      // com ele. Descobrir depois seria descobrir tarde.
      expect(
        texto.indexOf('Escolha o que fazer com a pasta'),
        lessThan(texto.indexOf(S.deleteAccount)),
      );
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
      // O texto deixou de citar o número de dias e passou a citar a regra:
      // sem demora indevida, em regra um mês. É o prazo do Art. 12(3), dito
      // como a lei o diz, e a constante continua valendo como teto interno.
      expect(deletionDeadlineDays, lessThanOrEqualTo(30));
      expect(texto, contains('sem demora indevida'));
      expect(texto, contains('prazo de um mês'));
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
      final String corpo = ingles.body.join(' ');
      expect(corpo, contains('delete your'));
      expect(corpo, contains('cannot be undone'));
      // O que a loja precisa achar ali: o caminho dentro do aplicativo, o
      // email alternativo, e o aviso da assinatura.
      expect(corpo, contains('Profile'));
      expect(corpo, contains(privacyEmail));
      expect(corpo, contains('cancel the subscription'));
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

  group('a assinatura', () {
    test('avisa que apagar a conta não a cancela', () {
      // Sem esse aviso, a cápsula some e a cobrança anual continua. É o
      // caminho mais curto entre um aplicativo bem-intencionado e uma
      // reclamação no Procon.
      expect(texto, contains('apagar a conta não cancela a assinatura'));
    });

    test('ensina onde cancelar, e não só que existe', () {
      expect(texto, contains('Pagamentos e assinaturas'));
      expect(texto, contains('Cancelar assinatura'));
    });

    test('diz que não conseguimos cancelar por quem pede', () {
      expect(texto, contains('não conseguimos cancelar por você'));
    });

    test('o aviso também está no texto em inglês', () {
      // A loja lê a seção em inglês, e ela precisa dizer o mesmo.
      final String ingles = accountDeletionPage
          .firstWhere((PrivacySection s) => s.title.contains('English'))
          .body
          .join(' ');
      expect(ingles, contains('does '));
      expect(ingles, contains('cancel the subscription'));
      expect(ingles, contains('Google Play'));
    });

    test('a assinatura por conta segue a conta por criança', () {
      expect(texto, contains('assinatura Premium também é por conta'));
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
      //
      // O que se proíbe é buscar recurso, e não toda etiqueta `<link>`: a
      // `rel="alternate" hreflang` que aponta para a outra língua é
      // metadado, não download, e continua valendo mesmo offline.
      expect(html, isNot(contains('<script')));
      expect(html, isNot(contains('rel="stylesheet"')));
      expect(html, isNot(contains('<img')));
      expect(html, isNot(contains('<iframe')));
      expect(html, isNot(contains('@import')));
      expect(html, isNot(contains('url(')));
      expect(html, isNot(contains('src=')));
      expect(html, contains('<style>'));
    });

    test('a página no ar e a tela do aplicativo são o mesmo texto', () {
      // Se um dia a versão de dentro do aplicativo passar a ser escrita à
      // parte, elas divergem na primeira correção, e a pessoa lê uma coisa
      // no aplicativo e outra na URL que a loja publica.
      for (final PrivacySection s in accountDeletionPage) {
        expect(html, contains(_semMarcacao(s.title)));
      }
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

  group('o site em inglês', () {
    // A Play Store pede um endereço de política que qualquer pessoa abra e
    // leia. Quem revisa raramente lê português, e uma política ilegível para
    // o revisor é uma exigência cumprida só no papel.
    final Map<String, String> paginas = <String, String>{
      'docs/en/index.html': indiceEmHtmlIngles(),
      'docs/en/privacy.html': privacidadeEmHtmlIngles(),
      'docs/en/terms.html': termosEmHtmlIngles(),
      'docs/en/deletion.html': exclusaoEmHtmlIngles(),
    };

    test('as quatro páginas existem e estão em dia', () {
      paginas.forEach((String caminho, String conteudo) {
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

    test('estão marcadas como inglês, e não como português', () {
      // O atributo `lang` é o que faz o leitor de tela pronunciar a página na
      // língua certa. Herdar o `pt-BR` do modelo deixaria a versão inglesa
      // sendo lida em voz alta com sotaque de outro idioma.
      for (final String html in paginas.values) {
        expect(html, contains('<html lang="en">'));
        expect(html, isNot(contains('<html lang="pt-BR">')));
      }

      // A data só existe nos três documentos. A porta de entrada não tem
      // versão, e carimbá-la com uma seria inventar uma data que não muda
      // quando nada mudou.
      for (final String nome in <String>['privacy', 'terms', 'deletion']) {
        final String html = paginas['docs/en/$nome.html']!;
        expect(html, contains('Last updated'), reason: nome);
        expect(html, isNot(contains('Última atualização')), reason: nome);
      }
    });

    test('o link para o português é marcado como português', () {
      // O `lang` no próprio link é o que faz o leitor de tela pronunciar
      // "Português" em português, no meio de uma página inglesa. Some com
      // ele e a palavra sai lida com fonemas ingleses.
      for (final String html in paginas.values) {
        expect(html, contains('lang="pt-BR">Português</a>'));
        expect(html, contains('hreflang="pt-BR"'));
      }
    });

    test('o texto é o inglês dos documentos, e não o português', () {
      expect(
        paginas['docs/en/privacy.html'],
        contains(privacyPolicyEn.first.title),
      );
      expect(paginas['docs/en/terms.html'], contains(termsOfUseEn.first.title));
      expect(
        paginas['docs/en/deletion.html'],
        contains(accountDeletionPageEn.first.title),
      );
    });

    test('cada página leva à gêmea, e à do mesmo assunto', () {
      // Cair na porta de entrada da outra língua é perder o lugar onde a
      // pessoa estava, e numa política longa isso é perder a resposta que ela
      // tinha vindo procurar.
      const Map<String, String> daEnParaPt = <String, String>{
        'docs/en/index.html': '../index.html',
        'docs/en/privacy.html': '../privacidade.html',
        'docs/en/terms.html': '../termos.html',
        'docs/en/deletion.html': '../exclusao.html',
      };
      daEnParaPt.forEach((String caminho, String destino) {
        expect(paginas[caminho], contains('href="$destino"'), reason: caminho);
        expect(paginas[caminho], contains('Português'), reason: caminho);
      });
    });

    test('e as portuguesas levam de volta às inglesas', () {
      const Map<String, String> daPtParaEn = <String, String>{
        'en/index.html': 'indice',
        'en/privacy.html': 'privacidade',
        'en/terms.html': 'termos',
        'en/deletion.html': 'exclusao',
      };
      final Map<String, String> portuguesas = <String, String>{
        'en/index.html': indiceEmHtml(),
        'en/privacy.html': privacidadeEmHtml(),
        'en/terms.html': termosEmHtml(),
        'en/deletion.html': exclusaoEmHtml(),
      };
      daPtParaEn.forEach((String destino, String qual) {
        expect(portuguesas[destino], contains('href="$destino"'), reason: qual);
      });
      for (final String html in portuguesas.values) {
        expect(html, contains('English'));
      }
    });

    test('não buscam nada de fora, como as portuguesas', () {
      for (final String html in paginas.values) {
        expect(html, isNot(contains('<script')));
        expect(html, isNot(contains('rel="stylesheet"')));
        expect(html, isNot(contains('src=')));
        expect(html, contains('<style>'));
      }
    });

    test('não sobrou marcação de Markdown à vista', () {
      for (final String html in paginas.values) {
        expect(html, isNot(contains('**')));
      }
    });

    test('o email e o responsável continuam iguais', () {
      for (final String html in paginas.values) {
        expect(html, contains('href="mailto:$privacyEmail"'));
        expect(html, contains(privacyController));
      }
    });
  });
}
