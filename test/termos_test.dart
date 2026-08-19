import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/pagina_web.dart';
import 'package:meu_bebe/core/l10n/privacy_policy.dart';
import 'package:meu_bebe/core/l10n/terms_of_use.dart';
import 'package:meu_bebe/core/router/app_router.dart';
import 'package:meu_bebe/features/premium/porta_do_premium.dart';
import 'package:meu_bebe/models/entry.dart';
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
      expect(texto, contains('destinado aos arquivos que ele próprio cria'));
      expect(
        texto,
        contains('não solicita acesso geral aos arquivos preexistentes'),
      );
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

  group('uso pessoal e familiar', () {
    test('está escrito, e não só implícito', () {
      // É a frase que ancora a isenção doméstica do GDPR para quem lê os
      // termos. Sem ela, "uso pessoal" seria só a nossa intenção, não uma
      // condição do contrato.
      //
      // O texto não afirma que quem usa está isento: ele diz que o
      // enquadramento depende da lei de cada lugar. Prometer a isenção em
      // nome de quem lê seria prometer o que não é nosso para prometer.
      expect(texto, contains('uso pessoal e familiar'));
      expect(texto, contains('obrigação legal de proteção de dados'));
    });
  });

  group('onde o aplicativo não é oferecido', () {
    test(
      'localização de dados é motivo de exclusão, dito com todas as letras',
      () {
        // O ponto não é fingir cumprir uma lei que a arquitetura não cumpre.
        // É dizer, por escrito, qual é o limite: a infraestrutura é global,
        // e onde a lei exigir que os dados fiquem dentro do país o
        // aplicativo pode não ser oferecido. O texto descreve o motivo em
        // vez de listar países, porque a lista envelhece e o motivo não.
        expect(texto, contains('requisitos de localização de dados'));
        expect(
          texto,
          contains('armazenamento exclusivamente dentro de determinada jurisdição'),
        );
      },
    );
  });

  group('os planos', () {
    test('o que o texto chama de pago é o que o portão barra', () {
      // O laço é o ponto. Mudar `exigeLicenca` sem mexer nos termos passa a
      // derrubar este teste, que é o único jeito de o documento não virar
      // promessa velha depois de a primeira pessoa ter pago.
      const Map<EntryType, String> comoOTextoChama = <EntryType, String>{
        EntryType.letter: 'cartas',
        EntryType.drawing: 'desenhos',
        EntryType.document: 'documentos',
        EntryType.growth: 'registros de crescimento',
      };

      for (final EntryType tipo in EntryType.values) {
        if (!exigeLicenca(tipo)) continue;
        expect(
          comoOTextoChama[tipo],
          isNotNull,
          reason: 'O portão barra ${tipo.id} e os termos não dizem qual é.',
        );
        expect(texto, contains(comoOTextoChama[tipo]!), reason: tipo.id);
      }
    });

    test('foto e vídeo estão escritos como livres', () {
      expect(exigeLicenca(EntryType.photo), isFalse);
      expect(exigeLicenca(EntryType.video), isFalse);
      expect(texto, contains('continua guardando fotos e vídeos'));
    });

    test('que ler nunca depende de pagar', () {
      // É a linha que separa um convite de um resgate, e ela precisa estar
      // no documento, e não só na nossa intenção.
      expect(texto, contains('nunca fecha nada que já é seu'));
      expect(texto, contains('continuam à vista'));
    });

    test('que a assinatura é por conta, e não por família', () {
      expect(
        texto,
        contains('A assinatura vale para a conta que entra no aplicativo'),
      );
      expect(
        texto,
        contains('a disponibilidade do Premium será determinada pela conta'),
      );
    });

    test('quem cobra, com que periodicidade e como cancelar', () {
      expect(texto, contains('Google Play'));
      expect(texto, contains('anual'));
      expect(texto, contains('renova sozinha'));
      expect(texto, contains('Pagamentos e assinaturas'));
    });

    test('que apagar a conta não cancela a assinatura', () {
      // O esquecimento mais caro que existe neste desenho: a cápsula some e
      // a cobrança continua.
      expect(texto, contains('não cancela a assinatura'));
    });

    test('não sobrou nenhuma promessa de que não há assinatura', () {
      expect(texto, isNot(contains('Não há compra dentro do aplicativo')));
      expect(texto, isNot(contains('O uso é gratuito')));
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
      expect(texto, contains('responsável pela criança'));
      expect(texto, contains('autoridade adequada'));
      // As quatro molduras que alcançam quase todo mercado da loja. Citar
      // só a brasileira era o que estava errado para um lançamento mundial.
      for (final String lei in <String>['LGPD', 'GDPR', 'UK GDPR', 'COPPA']) {
        expect(texto, contains(lei), reason: lei);
      }
    });

    test('a idade mínima cede à maioridade local, quando ela for maior', () {
      expect(texto, contains('maioridade'));
    });

    test('a lei, o foro e o que nenhum contrato pode tirar', () {
      // A regência é irlandesa porque é de onde o aplicativo é operado. O
      // que não pode faltar é a ressalva: quem mora fora não perde a própria
      // lei de consumo por causa de uma cláusula nossa, e continua podendo
      // acionar a Justiça de casa.
      expect(texto, contains('lei irlandesa'));
      expect(texto, contains('normas obrigatórias de proteção do consumidor'));
      expect(texto, contains('não possam ser afastados por contrato'));
      expect(texto, contains('tribunais de seu país ou local de residência'));
      expect(texto, contains('foro do consumidor'));
    });

    test('nada obriga a arbitragem nem impede direito processual', () {
      // A cláusula que costuma aparecer em termos americanos e que é nula em
      // boa parte do mundo. Não tê-la é escolha, e escolha vale a pena
      // escrever.
      expect(texto, contains('Nada aqui obriga você a arbitragem'));
      expect(texto, contains('impedir o exercício de direitos processuais'));
    });

    test('o prazo de arrependimento de cada lugar é reconhecido', () {
      expect(texto, contains('14 dias'));
      expect(texto, contains('7 dias'));
    });

    test('o limite de responsabilidade cede à lei local', () {
      expect(
        texto,
        contains('Na medida máxima permitida pela legislação aplicável'),
      );
      expect(texto, contains('não for válida em sua jurisdição'));
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
