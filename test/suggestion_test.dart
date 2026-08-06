import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/suggestion.dart';

/// O catálogo de sugestões.
///
/// A regra que governa tudo aqui: **o aplicativo nunca assume que algo
/// aconteceu.** Ele não tem como saber se a criança já sorriu, e dar isso
/// como certo seria inventar a memória de outra pessoa. Tudo é convite.
void main() {
  BabyProfile nascidaEm(DateTime birth) =>
      BabyProfile(name: 'Maria Eduarda', birth: birth);

  List<String> idsEm(
    DateTime birth,
    DateTime hoje, {
    Set<String> resolvidas = const <String>{},
  }) => Suggestions.activeFor(
    profile: nascidaEm(birth),
    resolved: resolvidas,
    now: hoje,
  ).map((ActiveSuggestion a) => a.suggestion.id).toList();

  group('o catálogo é consistente', () {
    test('nenhum id repetido', () {
      // Id repetido faria dispensar uma sugestão apagar outra.
      final List<String> ids = Suggestions.all
          .map((Suggestion s) => s.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('todo id é estável e legível', () {
      for (final Suggestion s in Suggestions.all) {
        expect(s.id, matches(RegExp(r'^[a-z0-9-]+$')), reason: s.id);
        expect(s.title.trim(), isNotEmpty);
      }
    });

    test('nenhum título afirma que já aconteceu', () {
      // "O primeiro sorriso" convida. "O primeiro sorriso foi" inventa.
      for (final Suggestion s in Suggestions.all) {
        for (final String proibido in <String>[' foi ', 'aconteceu', 'já ']) {
          expect(
            s.title.toLowerCase(),
            isNot(contains(proibido)),
            reason: '"${s.title}" afirma em vez de sugerir.',
          );
        }
      }
    });
  });

  group('momentos aparecem na faixa de idade', () {
    final DateTime birth = DateTime(2026, 3, 10);

    test('o primeiro sorriso aparece nas primeiras semanas', () {
      expect(
        idsEm(birth, birth.add(const Duration(days: 40))),
        contains('primeiro-sorriso'),
      );
    });

    test('e some quando a faixa passa', () {
      expect(
        idsEm(birth, birth.add(const Duration(days: 200))),
        isNot(contains('primeiro-sorriso')),
      );
    });

    test('não aparece antes da hora', () {
      expect(
        idsEm(birth, birth.add(const Duration(days: 3))),
        isNot(contains('primeiro-sorriso')),
      );
    });

    test('a bicicleta não é sugerida a um recém-nascido', () {
      expect(
        idsEm(birth, birth.add(const Duration(days: 30))),
        isNot(contains('primeira-bicicleta')),
      );
    });
  });

  group('datas especiais valem só na primeira vez', () {
    // Nascida em outubro de 2026: o primeiro Natal é o de 2026.
    final DateTime birth = DateTime(2026, 10, 1);

    test('aparece perto da primeira ocorrência', () {
      expect(idsEm(birth, DateTime(2026, 12, 15)), contains('primeiro-natal'));
    });

    test('não aparece cedo demais', () {
      expect(
        idsEm(birth, DateTime(2026, 11, 1)),
        isNot(contains('primeiro-natal')),
        reason: 'Faltando quase dois meses, ainda não é hora.',
      );
    });

    test('não volta no segundo Natal', () {
      // O segundo Natal é um Natal, mas não é o primeiro.
      expect(
        idsEm(birth, DateTime(2027, 12, 15)),
        isNot(contains('primeiro-natal')),
      );
    });

    test('nascida em janeiro, o primeiro Natal é o do mesmo ano', () {
      final DateTime cedo = DateTime(2026, 1, 5);
      expect(idsEm(cedo, DateTime(2026, 12, 20)), contains('primeiro-natal'));
      expect(
        idsEm(cedo, DateTime(2027, 12, 20)),
        isNot(contains('primeiro-natal')),
      );
    });

    test('o Carnaval segue a data móvel, não um dia fixo', () {
      // Carnaval de 2027: 9 de fevereiro.
      final DateTime birth = DateTime(2026, 6, 1);
      expect(idsEm(birth, DateTime(2027, 2, 1)), contains('primeiro-carnaval'));
      expect(
        idsEm(birth, DateTime(2027, 1, 10)),
        isNot(contains('primeiro-carnaval')),
      );
    });
  });

  group('o checklist do primeiro aniversário', () {
    final DateTime birth = DateTime(2026, 3, 10);

    test('aparece com antecedência de sobra para organizar', () {
      final List<ActiveSuggestion> ativas = Suggestions.activeFor(
        profile: nascidaEm(birth),
        resolved: const <String>{},
        now: DateTime(2027, 2, 18),
      );
      final ActiveSuggestion aniversario = ativas.firstWhere(
        (ActiveSuggestion a) => a.suggestion.id == 'primeiro-aniversario',
      );
      expect(aniversario.daysLeft, 20);
      expect(aniversario.deadline, DateTime(2027, 3, 10));
      expect(aniversario.suggestion.checklist, hasLength(6));
    });

    test('some depois que o aniversário passa', () {
      expect(
        idsEm(birth, DateTime(2027, 3, 11)),
        isNot(contains('primeiro-aniversario')),
      );
    });

    test('não aparece com um ano de antecedência', () {
      expect(
        idsEm(birth, DateTime(2026, 6, 1)),
        isNot(contains('primeiro-aniversario')),
      );
    });

    test('os itens marcados chegam junto', () {
      final List<ActiveSuggestion> ativas = Suggestions.activeFor(
        profile: nascidaEm(birth),
        resolved: const <String>{},
        checked: <String, Set<String>>{
          'primeiro-aniversario': <String>{'Escolher o bolo'},
        },
        now: DateTime(2027, 2, 18),
      );
      expect(
        ativas
            .firstWhere(
              (ActiveSuggestion a) => a.suggestion.id == 'primeiro-aniversario',
            )
            .checked,
        <String>{'Escolher o bolo'},
      );
    });
  });

  group('o que foi resolvido não volta', () {
    test('dispensar tira a sugestão da lista', () {
      final DateTime birth = DateTime(2026, 3, 10);
      final DateTime hoje = birth.add(const Duration(days: 40));

      expect(idsEm(birth, hoje), contains('primeiro-sorriso'));
      expect(
        idsEm(birth, hoje, resolvidas: <String>{'primeiro-sorriso'}),
        isNot(contains('primeiro-sorriso')),
        reason: 'Insistir no que já foi resolvido é o que faz desinstalar.',
      );
    });
  });

  group('a ordem', () {
    test('o que tem prazo vem antes do que não tem', () {
      // Nascida em outubro; em dezembro o Natal tem prazo e os momentos não.
      final List<ActiveSuggestion> ativas = Suggestions.activeFor(
        profile: nascidaEm(DateTime(2026, 10, 1)),
        resolved: const <String>{},
        now: DateTime(2026, 12, 15),
      );
      expect(ativas.first.suggestion.id, 'primeiro-natal');
      expect(ativas.first.daysLeft, 10);
      expect(ativas.last.daysLeft, isNull);
    });
  });
}
