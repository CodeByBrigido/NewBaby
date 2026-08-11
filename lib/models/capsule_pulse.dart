import 'package:meta/meta.dart';

import '../core/utils/age_calculator.dart';
import 'baby_profile.dart';
import 'entry.dart';

/// O estado da cápsula hoje.
///
/// Responde, sem tocar em rede, às perguntas que a tela inicial faz: que
/// idade a criança tem, se hoje é uma data redonda, quanto falta para o
/// próximo aniversário e quanto tempo passou desde o último registro de
/// cada tipo.
///
/// Vive separado da tela por dois motivos. O primeiro é que datas erram em
/// silêncio: um dia a mais no aniversário ou um mês pulado em fevereiro não
/// quebram nada, só ficam errados, e isso só se pega com teste. O segundo é
/// que as notificações inteligentes precisam exatamente destas mesmas
/// contas - "faz sete dias desde a última foto" é este objeto, não outro.
@immutable
class CapsulePulse {
  const CapsulePulse({
    required this.today,
    required this.age,
    required this.exactMilestone,
    required this.nextBirthday,
    required this.birthdayYears,
    required this.daysToBirthday,
    required this.lastByType,
  });

  factory CapsulePulse.from({
    required BabyProfile profile,
    required List<Entry> entries,
    DateTime? now,
  }) {
    final DateTime today = AgeCalculator.dayOf(now ?? DateTime.now());
    final DateTime birth = profile.birthDay;
    final Age age = AgeCalculator.ageAt(profile.birth, today);

    final DateTime next = _nextBirthday(birth, today);

    final Map<EntryType, DateTime> last = <EntryType, DateTime>{};
    for (final Entry entry in entries) {
      final DateTime day = AgeCalculator.dayOf(entry.date);
      final DateTime? atual = last[entry.type];
      if (atual == null || day.isAfter(atual)) last[entry.type] = day;
    }

    return CapsulePulse(
      today: today,
      age: age,
      exactMilestone: dataRedondaEm(birth, today),
      nextBirthday: next,
      birthdayYears: next.year - birth.year,
      daysToBirthday: next.difference(today).inDays,
      lastByType: Map<EntryType, DateTime>.unmodifiable(last),
    );
  }

  /// Meia-noite de hoje - toda comparação aqui é por dia, nunca por hora.
  final DateTime today;

  final Age age;

  /// A data redonda de hoje, se houver: `1 ano`, `8 meses`, `3 semanas`.
  ///
  /// `null` na esmagadora maioria dos dias, e é o que faz o cartão valer
  /// quando aparece.
  final String? exactMilestone;

  final DateTime nextBirthday;

  /// Qual aniversário será esse: 1 para o primeiro, 2 para o segundo.
  final int birthdayYears;

  /// Zero no próprio dia do aniversário.
  final int daysToBirthday;

  final Map<EntryType, DateTime> lastByType;

  bool get isBirthday => daysToBirthday == 0;

  /// Há quantos dias foi o último registro deste tipo. `null` se nunca houve.
  int? daysSince(EntryType type) {
    final DateTime? last = lastByType[type];
    if (last == null) return null;
    // Registro com data futura (alguém marcou amanhã) conta como hoje, em
    // vez de virar um número negativo na tela.
    final int dias = today.difference(last).inDays;
    return dias < 0 ? 0 : dias;
  }

  /// O nome da data redonda que cai em [dia], ou `null` se ele for um dia
  /// comum.
  ///
  /// Anos e meses cobrem a vida inteira. Semanas só valem nos primeiros três
  /// meses, que é quando uma semana ainda é muita coisa: aos quatro anos,
  /// "208 semanas" não diz nada a ninguém.
  ///
  /// Público e recebendo o dia por parâmetro porque a linha do tempo também
  /// precisa dele, para marcar o dia em que a criança fez um ano quando
  /// alguém rola até lá. Dois cálculos separados para a mesma pergunta
  /// divergiriam, e o cartão de hoje diria uma coisa e o histórico, outra.
  static String? dataRedondaEm(DateTime birth, DateTime dia) {
    final DateTime today = AgeCalculator.dayOf(dia);
    final Age age = AgeCalculator.ageAt(birth, today);
    if (age.totalDays <= 0) return null;

    if (AgeCalculator.dayOf(AgeCalculator.addMonths(birth, age.months)) ==
            today &&
        age.months > 0) {
      if (age.months % 12 == 0) {
        final int anos = age.months ~/ 12;
        return anos == 1 ? '1 ano' : '$anos anos';
      }
      return age.months == 1 ? '1 mês' : '${age.months} meses';
    }

    if (age.totalDays < 90 && age.totalDays % 7 == 0) {
      final int semanas = age.totalDays ~/ 7;
      return semanas == 1 ? '1 semana' : '$semanas semanas';
    }

    return null;
  }

  /// O próximo aniversário a partir de [today], incluindo hoje.
  static DateTime _nextBirthday(DateTime birth, DateTime today) {
    final DateTime esteAno = _anniversaryIn(birth, today.year);
    if (!esteAno.isBefore(today)) return esteAno;
    return _anniversaryIn(birth, today.year + 1);
  }

  /// O aniversário caindo dentro de [year].
  ///
  /// Nascido em 29 de fevereiro, em ano comum, faz aniversário no dia 28: a
  /// data precisa existir todo ano, senão o cartão some de quatro em quatro.
  static DateTime _anniversaryIn(DateTime birth, int year) {
    final int ultimoDia = DateTime(year, birth.month + 1, 0).day;
    return DateTime(
      year,
      birth.month,
      birth.day < ultimoDia ? birth.day : ultimoDia,
    );
  }
}
