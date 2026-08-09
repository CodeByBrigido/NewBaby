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
        'Seus direitos',
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

    test(
      'o nome do responsável precisa ser preenchido antes de publicar',
      () {
        // Falha de propósito enquanto o marcador estiver lá. O GDPR exige
        // identificar o controlador nominalmente, e publicar com um marcador
        // no lugar do nome é pior que não ter política.
        expect(
          privacyController,
          isNot(contains('[')),
          reason:
              'Preencha privacyController em lib/core/l10n/privacy_policy.dart '
              'com o nome completo antes de publicar na loja.',
        );
      },
      skip: 'aguardando o nome completo do responsável',
    );
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
