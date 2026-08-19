import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/privacy_policy.dart';
import 'package:meu_bebe/services/auth_service.dart';
import 'package:meu_bebe/services/firestore_service.dart';

/// A política de privacidade só vale se for verdade.
///
/// Uma política é uma lista de promessas sobre o que o código faz. O código
/// muda, ela não, e o resultado é um documento que descreve um aplicativo
/// que não existe mais. Num produto que guarda o registro de uma criança,
/// isso não é descuido: é exposição jurídica.
///
/// Cada teste aqui prende uma frase do texto a um fato do código.
void main() {
  final String texto = privacyPolicy
      .map((PrivacySection s) => '${s.title}\n${s.body.join("\n")}')
      .join('\n\n');

  group('o texto e o código dizem a mesma coisa', () {
    test('o escopo citado é o escopo que o aplicativo pede', () {
      // Se um dia alguém acrescentar `drive.readonly` para ler a pasta
      // inteira, a frase "apenas os arquivos que o próprio aplicativo cria"
      // vira mentira, e é uma mentira cara.
      expect(AuthService.driveScopes, hasLength(1));
      expect(
        AuthService.driveScopes.single,
        'https://www.googleapis.com/auth/drive.file',
      );
      expect(texto, contains('drive.file'));
      expect(texto, contains('apenas aos arquivos que o próprio aplicativo'));
    });

    test('a lista de coleções do índice não cresceu sem o texto saber', () {
      // A política enumera o que fica no servidor. Uma coleção nova é dado
      // novo, e dado novo precisa aparecer no texto antes de existir.
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
            'Coleção nova no Firestore: acrescente o campo correspondente na '
            'seção "O que fica no nosso índice" antes de mudar este teste.',
      );
    });

    test('nenhum pacote de rastreamento entrou no projeto', () {
      // "Nenhum dado de uso, estatística ou analytics" é a promessa mais
      // fácil de quebrar sem perceber: basta uma dependência nova. Este
      // teste é o que faz essa frase continuar verdadeira daqui a dois anos.
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      const List<String> proibidos = <String>[
        'firebase_analytics',
        'firebase_crashlytics',
        'firebase_performance',
        'google_mobile_ads',
        'facebook_app_events',
        'amplitude',
        'mixpanel',
        'sentry',
        'posthog',
        'appsflyer',
        'onesignal',
        'firebase_messaging',
      ];
      final List<String> achados = proibidos
          .where((String p) => pubspec.contains(p))
          .toList();
      expect(
        achados,
        isEmpty,
        reason:
            'A política afirma que o aplicativo não coleta dado de uso e não '
            'recebe notificação de servidor. Reescreva a seção "O que não é '
            'coletado" antes de acrescentar: ${achados.join(", ")}',
      );
    });

    test('o email de contato é o mesmo em todo lugar', () {
      expect(privacyEmail, contains('@'));
      final int quantas = privacyPolicy
          .expand((PrivacySection s) => s.body)
          .where((String p) => p.contains(privacyEmail))
          .length;
      expect(
        quantas,
        greaterThanOrEqualTo(2),
        reason: 'O endereço precisa aparecer no responsável e nos direitos',
      );
    });
  });

  group('a Irlanda', () {
    test('o responsável está estabelecido lá, e a autoridade é a dela', () {
      expect(texto, contains('estabelecido na Irlanda'));
      expect(texto, contains('Data Protection Commission da Irlanda'));
      expect(texto, contains('balcão único'));
    });
  });

  group('os dois papéis', () {
    test('a isenção doméstica do GDPR está escrita, não só aplicada', () {
      // Sem esta frase, um pai que lê a política não tem como saber que
      // registrar o próprio filho não o transforma em controlador de dados.
      expect(texto, contains('atividade exclusivamente pessoal ou doméstica'));
      expect(texto, contains('você não se torna controlador'));
    });

    test('para o Drive, o texto admite que não somos nada', () {
      // É a frase mais fácil de querer suavizar, e a mais importante de não
      // suavizar: dizer que não somos controlador nem operador dos arquivos
      // é o que torna a promessa de "não temos cópia" juridicamente exata,
      // e não só uma frase de efeito.
      expect(texto, contains('não somos nada'));
    });
  });

  group('a violação de dados', () {
    test(
      'promete os dois prazos do GDPR, e cede a prazo diferente alhures',
      () {
        expect(texto, contains('72 horas'));
        expect(texto, contains('Art. 33'));
        expect(texto, contains('Art. 34'));
        expect(texto, contains('LGPD (Art. 48)'));
      },
    );
  });

  group('o contrato com o Google', () {
    test('cita o Art. 28 e o instrumento que o cumpre', () {
      expect(texto, contains('Art. 28'));
      expect(texto, contains('Data Processing Addendum'));
    });
  });

  group('os Estados Unidos além da Califórnia', () {
    test('outros estados aparecem nomeados, não só a Califórnia', () {
      expect(texto, contains('Virgínia'));
      expect(texto, contains('Colorado'));
    });

    test('a seção da Califórnia diz que o mesmo vale para outros estados', () {
      expect(texto, contains('as mesmas seis frases acima valem para você'));
    });

    test('a Índia aparece na lista de direitos', () {
      expect(texto, contains('DPDPA'));
    });
  });

  group('crianças, por desenho', () {
    test('cita o código do Reino Unido e o lacre como exemplo concreto', () {
      expect(texto, contains('Children’s'));
      expect(texto, contains('lacrada'));
    });

    test('não afirma certificação que não existe', () {
      // Afirmar conformidade formal sem auditoria seria pior que não
      // mencionar o código nenhum.
      expect(texto, contains('não formalizamos certificação'));
    });
  });

  group('a América do Sul além do Brasil', () {
    test(
      'Argentina, Uruguai, Chile, Colômbia, Peru e Equador aparecem nomeados',
      () {
        // Antes só o Brasil estava nomeado, e "cobrir a América do Sul" com um
        // continente inteiro escondido atrás de "em qualquer outro lugar" não
        // é a mesma coisa que nomear a lei e a autoridade de cada país.
        for (final String pais in <String>[
          'Argentina',
          'Uruguai',
          'Chile',
          'Colômbia',
          'Peru',
          'Equador',
        ]) {
          expect(texto, contains(pais), reason: pais);
        }
      },
    );

    test('cada lei citada existe de verdade, pelo nome', () {
      expect(texto, contains('Ley 25.326'));
      expect(texto, contains('Ley 18.331'));
      expect(texto, contains('Ley 21.719'));
      expect(texto, contains('Ley 1581'));
      expect(texto, contains('Ley 29733'));
    });

    test('a autoridade de cada um está na seção de reclamação', () {
      expect(texto, contains('AAIP'));
      expect(texto, contains('URCDP'));
      expect(texto, contains('SIC'));
    });

    test('a exigência mais rígida da região, a colombiana, é admitida', () {
      // A Colômbia exige mais que consentimento: exige que o tratamento
      // respeite o melhor interesse da criança. Não é uma brecha para
      // esconder, é um padrão para admitir e mostrar que já é cumprido.
      expect(texto, contains('melhor interesse dela'));
    });
  });

  group('o pagamento', () {
    test('diz que quem cobra é o Google Play', () {
      expect(texto, contains('Google Play'));
    });

    test('diz que nenhum dado de pagamento passa por nós', () {
      // A frase mais importante desta seção, e a que a loja lê.
      expect(texto, contains('Nenhum dado de pagamento passa por nós'));
      expect(
        texto,
        contains('não recebemos, não vemos e não guardamos nenhum dado'),
      );
    });

    test('a licença aparece na lista fechada do que o índice guarda', () {
      // A lista se diz completa. Um campo novo que não estivesse nela faria
      // a palavra "completa" virar mentira.
      expect(texto, contains('assinatura Premium'));
      expect(texto, contains('Do plano'));
    });

    test('o Google Play está entre os destinatários', () {
      // A seção diz "não há nenhum outro destinatário". Cobrar por fora dela
      // sem citá-la seria contradizer a própria frase.
      expect(texto, contains('Não há nenhum outro destinatário'));
      final int listado = texto.indexOf('para cobrar a assinatura Premium');
      final int fecho = texto.indexOf('Não há nenhum outro destinatário');
      expect(listado, greaterThan(0));
      expect(listado, lessThan(fecho));
    });
  });

  group('o documento está completo', () {
    test('todas as seções que a lei exige estão lá', () {
      // GDPR Arts. 13 e 14, e LGPD Art. 9: identidade do controlador, o que
      // é tratado, base legal, com quem se compartilha, por quanto tempo,
      // direitos e como reclamar. Falta uma e o documento não cumpre a lei.
      const List<String> exigidas = <String>[
        'Quem é o responsável',
        'O que fica no nosso índice',
        'O que não é coletado',
        'Com quem os dados são compartilhados',
        'Base legal de cada tratamento',
        'Por quanto tempo, e como apagar',
        'Seus direitos, onde quer que você more',
        'Se você mora na Califórnia',
        'Crianças, e por que este aplicativo é diferente',
        'Transferência internacional',
        'Segurança',
        'Mudanças nesta política',
        'Reclamação',
      ];
      final List<String> titulos = privacyPolicy
          .map((PrivacySection s) => s.title)
          .toList();
      for (final String t in exigidas) {
        expect(titulos, contains(t));
      }
    });

    test('nenhuma seção está vazia, e nenhuma usa travessão', () {
      for (final PrivacySection s in privacyPolicy) {
        expect(s.body, isNotEmpty, reason: s.title);
        for (final String p in s.body) {
          expect(p.trim(), isNotEmpty, reason: s.title);
          expect(p, isNot(contains('—')), reason: s.title);
        }
      }
    });

    test('o responsável está identificado nominalmente', () {
      // O GDPR exige identificar o controlador pelo nome, e não só por um
      // endereço de email: sem isso ninguém consegue exercer um direito
      // judicialmente. Este teste era pendente e passou a valer.
      expect(privacyController, isNot(contains('[')));
      expect(privacyController.trim().split(' ').length, greaterThan(1));
    });
  });

  group('a versão pública é a mesma que o aplicativo mostra', () {
    test('o arquivo no repositório está em dia com o texto da tela', () {
      // Duas cópias de um texto jurídico é uma cópia a mais. O arquivo é
      // gerado do mesmo Dart que a tela lê, e este teste é o que garante
      // que ninguém publicou uma versão e mostrou outra.
      final File arquivo = File('POLITICA-DE-PRIVACIDADE.md');
      expect(
        arquivo.existsSync(),
        isTrue,
        reason: 'Rode: dart run tool/gerar_politica.dart',
      );
      expect(
        arquivo.readAsStringSync(),
        politicaEmMarkdown(),
        reason:
            'O texto mudou e o arquivo público não. Rode: '
            'dart run tool/gerar_politica.dart',
      );
    });
  });
}
