import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';

/// A linguagem e a identidade visual mudam conforme a criança.
///
/// As duas coisas falham de um jeito que passa despercebido em revisão: um
/// aplicativo cor de rosa para um menino, ou uma frase chamando de "bebê"
/// alguém que já tem quatro anos. Nenhuma quebra nada. As duas envelhecem
/// mal, e o horizonte deste produto é de décadas.
void main() {
  BabyProfile profileOf(String name, BabyGender? gender) =>
      BabyProfile(name: name, birth: DateTime(2027, 1, 22), gender: gender);

  group('o nome vem antes de qualquer outra forma de chamar', () {
    test('menina: artigo feminino', () {
      final Copy c = Copy.of(profileOf('Maria Eduarda', BabyGender.girl));
      expect(c.name, 'Maria');
      expect(c.theName, 'a Maria');
      expect(c.ofName, 'da Maria');
      expect(c.forName, 'para a Maria');
    });

    test('menino: artigo masculino', () {
      final Copy c = Copy.of(profileOf('Pedro Henrique', BabyGender.boy));
      expect(c.theName, 'o Pedro');
      expect(c.ofName, 'do Pedro');
      expect(c.forName, 'para o Pedro');
    });

    test('cadastro antigo, sem sexo, dispensa o artigo', () {
      // "de Maria" é correto em português. Melhor isso que arriscar
      // "do Maria" num cadastro que nunca informou o sexo.
      final Copy c = Copy.of(profileOf('Alex', null));
      expect(c.ofName, 'de Alex');
      expect(c.theName, 'Alex');
    });

    test('as frases montadas usam o nome', () {
      final Copy c = Copy.of(profileOf('Maria', BabyGender.girl));
      expect(c.addPhotoHint, 'Adicionar fotos da Maria');
      expect(c.timelineEmptyBody, contains('da Maria'));
      expect(c.babyInfo, 'Informações da Maria');
      expect(c.letterHint, contains('Maria'));
    });
  });

  group('sem nome, a frase é outra, não uma versão pior', () {
    test('nada cai em "seu bebê"', () {
      for (final String frase in <String>[
        Copy.generic.addPhotoHint,
        Copy.generic.addVideoHint,
        Copy.generic.addLetterHint,
        Copy.generic.timelineEmptyBody,
        Copy.generic.lettersEmptyBody,
        Copy.generic.letterHint,
        Copy.generic.babyInfo,
        Copy.generic.onboardingSubtitle,
      ]) {
        expect(frase, isNot(contains('bebê')), reason: '"$frase"');
        expect(frase, isNot(contains('criança')), reason: '"$frase"');
        expect(frase.trim(), isNotEmpty);
      }
    });

    test('o subtítulo do cadastro nunca tenta usar o nome', () {
      // É a tela onde o nome está sendo digitado; não existe ainda.
      final Copy comNome = Copy.of(profileOf('Maria', BabyGender.girl));
      expect(comNome.onboardingSubtitle, isNot(contains('Maria')));
    });
  });

  group('"sua bebê" não volta', () {
    // Foi pedido explicitamente que essa forma saísse do produto. Sem esta
    // checagem, ela reaparece na primeira tela nova que alguém escrever.
    test('nenhum arquivo de interface traz a forma antiga', () {
      final List<String> ofensores = <String>[];
      for (final FileSystemEntity f in Directory(
        'lib',
      ).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        // O próprio helper cita as formas antigas para documentar por que
        // elas saíram. É o único lugar onde escrevê-las é o certo.
        if (f.path.endsWith('core/l10n/copy.dart')) continue;
        final String texto = f.readAsStringSync();
        for (final String proibido in <String>[
          'sua bebê',
          'seu bebê',
          'da bebê',
          'do bebê',
        ]) {
          if (texto.contains(proibido)) ofensores.add('${f.path}: "$proibido"');
        }
      }
      expect(
        ofensores,
        isEmpty,
        reason:
            'Use o nome da criança (Copy.ofName, Copy.theName). Aos vinte e '
            'cinco anos ela vai abrir isto, e não é mais bebê há tempo.',
      );
    });
  });

  group('a paleta muda com a criança', () {
    test('menina e menino não recebem a mesma cor de marca', () {
      expect(
        AppPalette.of(BabyGender.girl).primary,
        isNot(AppPalette.of(BabyGender.boy).primary),
      );
    });

    test('antes do cadastro, nenhuma das duas', () {
      // A tela de login é a primeira que alguém vê. Ela não pode parecer
      // escolhida para menina nem para menino.
      final AppPalette neutra = AppPalette.of(null);
      expect(neutra.primary, isNot(AppPalette.girl.primary));
      expect(neutra.primary, isNot(AppPalette.boy.primary));
      expect(neutra, AppPalette.neutral);
    });

    test('erro e sucesso significam o mesmo em qualquer paleta', () {
      // Vermelho de erro não é decoração. Trocá-lo por paleta faria a
      // pessoa reaprender o que já sabe.
      expect(AppPalette.danger, isNot(AppPalette.success));
    });

    test('as categorias continuam distinguíveis em toda paleta', () {
      for (final AppPalette p in <AppPalette>[
        AppPalette.girl,
        AppPalette.boy,
        AppPalette.neutral,
      ]) {
        final Set<int> cores = <int>{
          p.photo.toARGB32(),
          p.video.toARGB32(),
          p.letter.toARGB32(),
          p.drawing.toARGB32(),
          p.document.toARGB32(),
          p.growth.toARGB32(),
        };
        expect(
          cores.length,
          6,
          reason: 'Duas categorias com a mesma cor deixam de ser categorias.',
        );
      }
    });

    test('a transição entre paletas é contínua', () {
      // Sem `lerp` correto o Flutter salta de uma cor para a outra quando o
      // cadastro carrega, e o salto aparece na tela.
      final AppPalette meio = AppPalette.girl.lerp(AppPalette.boy, 0.5);
      expect(meio.primary, isNot(AppPalette.girl.primary));
      expect(meio.primary, isNot(AppPalette.boy.primary));
      expect(
        AppPalette.girl.lerp(AppPalette.boy, 0).primary,
        AppPalette.girl.primary,
      );
    });
  });

  group('o cálculo de idade não tem gênero', () {
    test('nenhum rótulo sai flexionado', () {
      final DateTime birth = DateTime(2027, 1, 22);
      for (final int day in <int>[0, 1, 5, 20, 90, 200, 400, 800]) {
        final Age age = AgeCalculator.ageAt(
          birth,
          birth.add(Duration(days: day)),
        );
        for (final String label in <String>[
          age.shortLabel,
          age.detailedLabel(),
          age.detailedLabel(alwaysShowDays: true),
        ]) {
          expect(
            label,
            isNot(anyOf(contains('nascida'), contains('nascido'))),
            reason: 'O rótulo "$label" (dia $day) traz gênero.',
          );
        }
      }
    });
  });

  group('o sexo no cadastro', () {
    test('vai e volta do Firestore', () {
      final BabyProfile profile = profileOf('Maria Eduarda', BabyGender.girl);
      expect(BabyProfile.fromMap(profile.toMap()).gender, BabyGender.girl);
    });

    test('cadastro sem sexo não quebra a leitura', () {
      final BabyProfile profile = BabyProfile.fromMap(<String, Object?>{
        'nome': 'Antigo',
      });
      expect(profile.gender, isNull);
      expect(Copy.of(profile).ofName, 'de Antigo');
    });

    test('um valor desconhecido é tratado como ausente', () {
      expect(BabyGender.fromId('outro'), isNull);
      expect(BabyGender.fromId(null), isNull);
      expect(BabyGender.fromId('menino'), BabyGender.boy);
    });
  });
}
