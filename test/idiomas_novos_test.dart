import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/l10n/account_deletion.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/l10n/nomes_de_pasta.dart';
import 'package:meu_bebe/core/l10n/privacy_policy.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/l10n/terms_of_use.dart';
import 'package:meu_bebe/core/utils/formatters.dart';
import 'package:meu_bebe/models/baby_gender.dart';

/// O aplicativo em espanhol, francês, alemão e italiano.
///
/// O português e o inglês têm seu próprio arquivo, mais antigo e mais
/// detalhado. Este cobre as quatro línguas que entraram depois, uma vez
/// cada, num laço, em vez de repetir a mesma bateria de testes quatro
/// vezes: a diferença entre elas não está no que se verifica, está só no
/// valor esperado.
///
/// A completude da tradução continua garantida pelo compilador: cada
/// `TextosXx implements Textos` e cada `CopyXx extends Copy` não compila com
/// um membro faltando. O que este arquivo cobra é o que o compilador não
/// alcança: tradução preguiçosa (a frase em português esquecida dentro do
/// arquivo estrangeiro), e a ordem das palavras nas frases montadas em
/// tempo de execução.
void main() {
  setUpAll(() async {
    for (final String locale in <String>[
      'pt_BR',
      'en',
      'es',
      'fr',
      'de',
      'it',
    ]) {
      await initializeDateFormatting(locale);
    }
  });

  tearDown(() => definirTextos(textosPt));

  const Map<String, Textos> linguas = <String, Textos>{
    'es': textosEs,
    'fr': textosFr,
    'de': textosDe,
    'it': textosIt,
  };

  group('nenhuma língua fica pela metade', () {
    test('as seis implementações têm código único e batem com o arquivo', () {
      expect(todasAsTextos, hasLength(6));
      expect(todasAsTextos.map((Textos t) => t.codigo).toSet(), <String>{
        'pt',
        'en',
        'es',
        'fr',
        'de',
        'it',
      });
    });

    test('textosPara devolve a implementação certa, e o português no '
        'desconhecido', () {
      expect(textosPara('es'), same(textosEs));
      expect(textosPara('fr'), same(textosFr));
      expect(textosPara('de'), same(textosDe));
      expect(textosPara('it'), same(textosIt));
      expect(textosPara('ja'), same(textosPt));
      expect(textosPara(null), same(textosPt));
    });

    test('NomesDePasta.todas cobre as seis, sem repetir nome de pasta '
        'dentro da mesma convenção', () {
      expect(NomesDePasta.todas, hasLength(6));
      for (final NomesDePasta n in NomesDePasta.todas) {
        final Set<String> nomes = <String>{
          n.fotos,
          n.videos,
          n.cartas,
          n.desenhos,
          n.documentos,
          n.crescimento,
        };
        expect(nomes, hasLength(6), reason: n.codigo);
      }
    });
  });

  group('nenhuma frase ficou em português nas línguas novas', () {
    // ã/õ são vogais nasais exclusivas do português entre estas seis
    // línguas: não aparecem em espanhol, francês, alemão nem italiano. As
    // palavras da lista são fechadas e também exclusivas do português - não
    // são cognatas em nenhuma das outras quatro.
    final RegExp suspeita = RegExp(
      r'[ãõÃÕ]|\bnão\b|\bvocê\b|\btambém\b|\bentão\b|\bcódigo\b|\bpra\b',
    );

    for (final MapEntry<String, Textos> entrada in linguas.entries) {
      test('em textos_${entrada.key}.dart', () {
        final String fonte = File(
          'lib/core/l10n/textos_${entrada.key}.dart',
        ).readAsStringSync();
        final List<String> achadas = <String>[
          for (final String linha in fonte.split('\n'))
            if (!linha.trimLeft().startsWith('//') && suspeita.hasMatch(linha))
              linha.trim(),
        ];
        expect(achadas, isEmpty, reason: achadas.join('\n'));
      });

      test('em copy_${entrada.key}.dart', () {
        final String fonte = File(
          'lib/core/l10n/copy_${entrada.key}.dart',
        ).readAsStringSync();
        final List<String> achadas = <String>[
          for (final String linha in fonte.split('\n'))
            if (!linha.trimLeft().startsWith('//') && suspeita.hasMatch(linha))
              linha.trim(),
        ];
        expect(achadas, isEmpty, reason: achadas.join('\n'));
      });
    }
  });

  group('a troca alcança as quatro línguas novas', () {
    test('os textos simples', () {
      definirTextos(textosEs);
      expect(S.timeline, 'Línea de Tiempo');
      expect(S.save, 'Guardar');

      definirTextos(textosFr);
      expect(S.timeline, 'Chronologie');
      expect(S.save, 'Enregistrer');

      definirTextos(textosDe);
      expect(S.timeline, 'Zeitleiste');
      expect(S.save, 'Speichern');

      definirTextos(textosIt);
      expect(S.timeline, 'Cronologia');
      expect(S.save, 'Salva');
    });

    test('as datas mudam de formato em cada uma', () {
      final DateTime dia = DateTime(2027, 4, 10);

      definirTextos(textosEs);
      expect(Fmt.date(dia), '10/04/2027');

      definirTextos(textosFr);
      expect(Fmt.date(dia), '10/04/2027');

      definirTextos(textosDe);
      expect(Fmt.date(dia), '10.04.2027');

      definirTextos(textosIt);
      expect(Fmt.date(dia), '10/04/2027');
    });

    test('a contagem "há X tempo" muda de lado da frase', () {
      // Português, espanhol, francês e alemão põem a marca antes do número
      // ("há 3 dias" / "hace 3 días" / "il y a 3 jours" / "vor 3 Tagen").
      // Italiano põe depois, como o inglês ("3 giorni fa").
      definirTextos(textosEs);
      expect(Fmt.ago(3), 'hace 3 días');

      definirTextos(textosFr);
      expect(Fmt.ago(3), 'il y a 3 jours');

      definirTextos(textosDe);
      expect(Fmt.ago(3), 'vor 3 Tagen');

      definirTextos(textosIt);
      expect(Fmt.ago(3), '3 giorni fa');
    });

    test(
      'os plurais de foto e vídeo, inclusive os invariáveis do italiano',
      () {
        definirTextos(textosEs);
        expect(S.contarFotos(2), '2 fotos');

        definirTextos(textosIt);
        // "foto" e "video" não mudam no plural em italiano: escrever "fotos"
        // aqui seria um erro de português vazando, não uma tradução.
        expect(S.contarFotos(2), '2 foto');
        expect(S.contarVideos(2), '2 video');
      },
    );
  });

  group('as frases sobre a criança, nas quatro línguas novas', () {
    test(
      'nenhuma antepõe artigo ao nome próprio, ao contrário do português',
      () {
        // "da Maria" é português correto. Nas outras quatro, um artigo antes
        // do nome soaria como erro de tradução literal.
        definirTextos(textosEs);
        expect(Copy.para('Maria', BabyGender.girl).ofName, 'de Maria');

        definirTextos(textosFr);
        expect(Copy.para('Maria', BabyGender.girl).ofName, 'de Maria');
        // "Léa" começa com a consoante L: sem elisão, "de Léa" está certo.
        // "Emma" começa com vogal: é aí que o francês exige "d'".
        expect(Copy.para('Léa', BabyGender.girl).ofName, 'de Léa');
        expect(Copy.para('Emma', BabyGender.girl).ofName, "d'Emma");

        definirTextos(textosIt);
        expect(Copy.para('Maria', BabyGender.girl).ofName, 'di Maria');
      },
    );

    test('o alemão usa genitivo em -s, como o inglês', () {
      definirTextos(textosDe);
      expect(Copy.para('Maria', BabyGender.girl).ofName, 'Marias');
      expect(Copy.para('Lukas', BabyGender.boy).ofName, "Lukas'");
    });

    test('a ordem da frase muda junto com a gramática de cada língua', () {
      definirTextos(textosEs);
      expect(
        Copy.para('Maria', BabyGender.girl).addPhotoHint,
        'Agregar fotos de Maria',
      );

      definirTextos(textosDe);
      expect(
        Copy.para('Maria', BabyGender.girl).addPhotoHint,
        'Marias Fotos hinzufügen',
      );
    });
  });

  group('os documentos jurídicos existem nas quatro línguas novas', () {
    test('mesmo número de seções que o português, em todos os três', () {
      for (final MapEntry<String, Textos> entrada in linguas.entries) {
        definirTextos(entrada.value);
        expect(
          privacyPolicy,
          hasLength(privacyPolicyPt.length),
          reason: entrada.key,
        );
        expect(termsOfUse, hasLength(termsOfUsePt.length), reason: entrada.key);
        // A de exclusão tem uma seção a menos: o apêndice em inglês que só
        // a portuguesa carrega, para o revisor da Play Store, não precisa
        // se repetir numa língua que já não é português.
        expect(
          accountDeletionPage,
          hasLength(accountDeletionPagePt.length - 1),
          reason: entrada.key,
        );
      }
    });

    test('nenhuma seção vazia, e nenhuma usa travessão', () {
      for (final MapEntry<String, Textos> entrada in linguas.entries) {
        definirTextos(entrada.value);
        for (final List<PrivacySection> doc in <List<PrivacySection>>[
          privacyPolicy,
          termsOfUse,
          accountDeletionPage,
        ]) {
          for (final PrivacySection s in doc) {
            expect(s.body, isNotEmpty, reason: '${entrada.key}: ${s.title}');
            for (final String p in s.body) {
              expect(p.trim(), isNotEmpty, reason: entrada.key);
              expect(p, isNot(contains('—')), reason: entrada.key);
            }
          }
        }
      }
    });
  });
}
