import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/formatters.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
import 'package:meu_bebe/models/entry.dart';

/// As contas que a tela inicial mostra.
///
/// Erro de data não quebra nada: só fica errado. O aniversário atrasa um
/// dia, o mês some em fevereiro, o "há quanto tempo" conta a partir do lugar
/// errado - e ninguém percebe até alguém reparar que a conta não fecha. Por
/// isso cada caso de borda tem um teste aqui, com o dia de hoje injetado.
void main() {
  BabyProfile nascidaEm(DateTime birth) =>
      BabyProfile(name: 'Maria Eduarda', birth: birth);

  Entry entradaEm(EntryType type, DateTime date) => Entry(
    id: '${type.id}-${date.toIso8601String()}',
    type: type,
    date: date,
    createdAt: date,
    ageDays: 0,
    bucketKey: 'x',
    bucketName: 'x',
  );

  CapsulePulse pulseEm(
    DateTime birth,
    DateTime hoje, {
    List<Entry> entries = const <Entry>[],
  }) =>
      CapsulePulse.from(profile: nascidaEm(birth), entries: entries, now: hoje);

  group('o próximo aniversário', () {
    test('conta os dias que faltam', () {
      final CapsulePulse p = pulseEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 2, 19),
      );
      expect(p.daysToBirthday, 19);
      expect(p.birthdayYears, 1, reason: 'Será o primeiro aniversário.');
      expect(p.isBirthday, isFalse);
    });

    test('no próprio dia, faltam zero', () {
      final CapsulePulse p = pulseEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 3, 10),
      );
      expect(p.daysToBirthday, 0);
      expect(p.isBirthday, isTrue);
      expect(p.birthdayYears, 1);
    });

    test('passado o dia, aponta para o ano seguinte', () {
      final CapsulePulse p = pulseEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 3, 11),
      );
      expect(p.nextBirthday, DateTime(2028, 3, 10));
      expect(p.birthdayYears, 2);
      expect(p.daysToBirthday, 365);
    });

    test('nascida em 29 de fevereiro faz aniversário todo ano', () {
      // 2028 é bissexto; 2029 não é. Sem tratamento, o aniversário sumiria
      // três anos em cada quatro, e o cartão do primeiro ano nunca chegaria.
      final DateTime birth = DateTime(2028, 2, 29);

      final CapsulePulse comum = pulseEm(birth, DateTime(2029, 2, 20));
      expect(comum.nextBirthday, DateTime(2029, 2, 28));
      expect(comum.daysToBirthday, 8);

      final CapsulePulse bissexto = pulseEm(birth, DateTime(2032, 2, 20));
      expect(bissexto.nextBirthday, DateTime(2032, 2, 29));
    });

    test('nascida em 31 cai no último dia dos meses curtos', () {
      // Só importa se o mês de nascimento tiver 31 dias; aqui a checagem é
      // de que a conta não estoura para o mês seguinte.
      final CapsulePulse p = pulseEm(
        DateTime(2026, 1, 31),
        DateTime(2027, 1, 1),
      );
      expect(p.nextBirthday, DateTime(2027, 1, 31));
    });

    test('a virada do ano não confunde a conta', () {
      final CapsulePulse p = pulseEm(
        DateTime(2026, 1, 5),
        DateTime(2026, 12, 30),
      );
      expect(p.nextBirthday, DateTime(2027, 1, 5));
      expect(p.daysToBirthday, 6);
    });
  });

  group('a data redonda de hoje', () {
    final DateTime birth = DateTime(2026, 3, 10);

    test('o dia exato do mês vira marco', () {
      expect(pulseEm(birth, DateTime(2026, 11, 10)).exactMilestone, '8 meses');
      expect(pulseEm(birth, DateTime(2026, 4, 10)).exactMilestone, '1 mês');
    });

    test('um dia depois já não é marco', () {
      expect(pulseEm(birth, DateTime(2026, 11, 11)).exactMilestone, isNull);
    });

    test('doze meses viram um ano, não doze meses', () {
      expect(pulseEm(birth, DateTime(2027, 3, 10)).exactMilestone, '1 ano');
      expect(pulseEm(birth, DateTime(2028, 3, 10)).exactMilestone, '2 anos');
    });

    test('semanas contam só enquanto uma semana é muita coisa', () {
      // Recém-nascido: cada semana é um mundo.
      expect(pulseEm(birth, DateTime(2026, 3, 24)).exactMilestone, '2 semanas');
      // Aos quatro anos, "208 semanas" não diz nada a ninguém.
      final CapsulePulse crescida = pulseEm(birth, DateTime(2030, 3, 3));
      expect(crescida.exactMilestone, isNull);
    });

    test('o dia do nascimento não é marco de nada', () {
      expect(pulseEm(birth, birth).exactMilestone, isNull);
    });

    test('na maioria dos dias não há marco nenhum', () {
      // É isso que faz o cartão valer quando aparece.
      int comMarco = 0;
      for (int dia = 1; dia <= 365; dia++) {
        final DateTime hoje = birth.add(Duration(days: dia));
        if (pulseEm(birth, hoje).exactMilestone != null) comMarco++;
      }
      expect(
        comMarco,
        lessThan(30),
        reason: 'Marco todo dia deixa de ser marco.',
      );
    });
  });

  group('há quanto tempo foi a última vez', () {
    final DateTime birth = DateTime(2026, 3, 10);
    final DateTime hoje = DateTime(2027, 1, 20);

    test('conta a partir do registro mais recente do tipo', () {
      final CapsulePulse p = pulseEm(
        birth,
        hoje,
        entries: <Entry>[
          entradaEm(EntryType.photo, DateTime(2027, 1, 16)),
          entradaEm(EntryType.photo, DateTime(2026, 12, 1)),
          entradaEm(EntryType.letter, DateTime(2026, 12, 20)),
        ],
      );
      expect(p.daysSince(EntryType.photo), 4);
      expect(p.daysSince(EntryType.letter), 31);
    });

    test('tipo que nunca aconteceu devolve nulo, não zero', () {
      // Zero significaria "hoje", que é o oposto de "nunca".
      final CapsulePulse p = pulseEm(birth, hoje);
      expect(p.daysSince(EntryType.growth), isNull);
    });

    test('a hora do registro não desloca a conta', () {
      final CapsulePulse p = pulseEm(
        birth,
        DateTime(2027, 1, 20, 3),
        entries: <Entry>[
          entradaEm(EntryType.photo, DateTime(2027, 1, 19, 23, 50)),
        ],
      );
      expect(p.daysSince(EntryType.photo), 1);
    });

    test('registro marcado para o futuro não vira número negativo', () {
      final CapsulePulse p = pulseEm(
        birth,
        hoje,
        entries: <Entry>[entradaEm(EntryType.photo, DateTime(2027, 2, 1))],
      );
      expect(p.daysSince(EntryType.photo), 0);
    });
  });

  group('as palavras que a tela inicial usa', () {
    test('a saudação segue a hora', () {
      expect(Fmt.greeting(DateTime(2027, 4, 10, 0)), 'Bom dia');
      expect(Fmt.greeting(DateTime(2027, 4, 10, 11, 59)), 'Bom dia');
      expect(Fmt.greeting(DateTime(2027, 4, 10, 12)), 'Boa tarde');
      expect(Fmt.greeting(DateTime(2027, 4, 10, 17, 59)), 'Boa tarde');
      expect(Fmt.greeting(DateTime(2027, 4, 10, 18)), 'Boa noite');
      expect(Fmt.greeting(DateTime(2027, 4, 10, 23)), 'Boa noite');
    });

    test('"há quanto tempo" troca de unidade conforme a distância', () {
      // "há 40 dias" obriga a pessoa a fazer a conta de cabeça.
      expect(Fmt.ago(0), 'hoje');
      expect(Fmt.ago(1), 'ontem');
      expect(Fmt.ago(4), 'há 4 dias');
      expect(Fmt.ago(13), 'há 13 dias');
      expect(Fmt.ago(14), 'há 2 semanas');
      expect(Fmt.ago(45), 'há 6 semanas');
      expect(Fmt.ago(60), 'há 2 meses');
      expect(Fmt.ago(400), 'há 1 ano');
    });

    test('nada de número negativo, nem por acidente', () {
      expect(Fmt.ago(-5), 'hoje');
    });

    test('o ordinal vira número quando a palavra fica pior', () {
      expect(Fmt.ordinal(1), 'primeiro');
      expect(Fmt.ordinal(10), 'décimo');
      expect(Fmt.ordinal(11), '11º');
      expect(Fmt.ordinal(18), '18º');
    });
  });
}
