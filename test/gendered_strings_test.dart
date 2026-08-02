import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/gendered.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';

void main() {
  group('concordância de gênero', () {
    test('menina recebe a forma feminina', () {
      final G g = G.of(BabyGender.girl);
      expect(g.yourBaby, 'sua bebê');
      expect(g.ofYourBaby, 'da sua bebê');
      expect(g.forThem, 'para ela');
      expect(g.babyInfo, 'Informações da bebê');
      expect(g.letterHint, contains('filha'));
    });

    test('menino recebe a forma masculina', () {
      final G g = G.of(BabyGender.boy);
      expect(g.yourBaby, 'seu bebê');
      expect(g.ofYourBaby, 'do seu bebê');
      expect(g.forThem, 'para ele');
      expect(g.babyInfo, 'Informações do bebê');
      expect(g.letterHint, contains('filho'));
    });

    test(
      'sem gênero conhecido cai no masculino, que é o neutro em português',
      () {
        // "bebê" é substantivo masculino: "o bebê" serve para os dois,
        // "a bebê" só para menina. Por isso o neutro é o masculino.
        expect(G.neutral.yourBaby, 'seu bebê');
        expect(G.of(null).ofYourBaby, 'do seu bebê');
      },
    );

    test('as frases montadas concordam de ponta a ponta', () {
      expect(G.of(BabyGender.girl).addPhotoHint, 'Adicionar fotos da sua bebê');
      expect(G.of(BabyGender.boy).addPhotoHint, 'Adicionar fotos do seu bebê');
      expect(G.of(BabyGender.boy).timelineEmptyBody, contains('do seu bebê'));
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

  group('gênero no cadastro', () {
    test('vai e volta do Firestore', () {
      final BabyProfile profile = BabyProfile(
        name: 'Maria Eduarda',
        birth: DateTime(2027, 1, 22),
        gender: BabyGender.girl,
      );
      expect(BabyProfile.fromMap(profile.toMap()).gender, BabyGender.girl);
    });

    test('cadastro sem gênero não quebra a leitura', () {
      final BabyProfile profile = BabyProfile.fromMap(<String, Object?>{
        'nome': 'Antigo',
      });
      expect(profile.gender, isNull);
      expect(G.of(profile.gender).yourBaby, 'seu bebê');
    });

    test('um valor desconhecido é tratado como ausente', () {
      expect(BabyGender.fromId('outro'), isNull);
      expect(BabyGender.fromId(null), isNull);
      expect(BabyGender.fromId('menino'), BabyGender.boy);
    });
  });
}
