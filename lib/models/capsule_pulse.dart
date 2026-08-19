import 'package:meta/meta.dart';

import '../core/l10n/strings.dart';
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
    required this.nextMilestone,
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
      nextMilestone: proximoMarcoDe(birth, today),
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

  /// O próximo marco de idade, ou o de hoje quando hoje é um.
  ///
  /// `null` só antes do nascimento, e no caso improvável de a regra deixar
  /// de produzir marcos.
  final ProximoMarco? nextMilestone;

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
      if (age.months % 12 == 0) return S.contarAnos(age.months ~/ 12);
      return S.contarMeses(age.months);
    }

    if (age.totalDays < 90 && age.totalDays % 7 == 0) {
      return S.contarSemanas(age.totalDays ~/ 7);
    }

    return null;
  }

  /// Os marcos de desenvolvimento, em meses de vida.
  ///
  /// **Não é toda data redonda.** A linha do tempo marca todo mês, e faz
  /// sentido que marque: rolando o histórico, ver "22 meses" ao lado das
  /// fotos daquele mês ajuda a se situar. Mas um cartão que olha para a
  /// frente e anuncia "22 meses, daqui a 12 dias" não anuncia nada: todo mês
  /// vira marco, e o que acontece todo mês deixa de ser marco.
  ///
  /// A lista é a que os pais de fato usam para falar da criança: os três e os
  /// seis meses, o primeiro aniversário, e daí em diante ano a ano. Entre os
  /// seis meses e o primeiro ano não há nada de propósito, porque a próxima
  /// coisa que a família espera depois do meio ano é o aniversário.
  static const List<int> marcosEmMeses = <int>[3, 6];

  /// Até que idade a lista acima vale antes de virar contagem de anos.
  static const int _mesesDoPrimeiroAno = 12;

  /// O próximo marco de desenvolvimento, contado a partir de [dia] e
  /// incluindo ele.
  ///
  /// A data de cada marco vem de [AgeCalculator.addMonths], que é a mesma
  /// função que a linha do tempo usa para saber quando a criança completa
  /// meses. É isso que garante que o cartão nunca anuncie um dia que o
  /// histórico depois não celebre: todo marco daqui é também uma data redonda
  /// de lá, só que o contrário não vale.
  ///
  /// O nascimento não é marco: no dia zero o cartão apontaria para o próprio
  /// dia, e "é hoje" para alguém que acabou de nascer não acrescenta nada a
  /// quem está com a criança no colo.
  static ProximoMarco? proximoMarcoDe(DateTime birth, DateTime dia) {
    final DateTime hoje = AgeCalculator.dayOf(dia);
    final DateTime nascimento = AgeCalculator.dayOf(birth);

    for (final int meses in _mesesDosMarcos()) {
      final DateTime quando = AgeCalculator.dayOf(
        AgeCalculator.addMonths(nascimento, meses),
      );
      if (quando.isBefore(hoje)) continue;

      return ProximoMarco(
        rotulo: rotuloDoMarco(meses),
        quando: quando,
        diasAte: quando.difference(hoje).inDays,
      );
    }
    return null;
  }

  /// A sequência de marcos, do primeiro em diante.
  ///
  /// Preguiçosa porque é infinita por natureza: a criança vira adulta e os
  /// aniversários continuam. O teto de cem anos existe só para a busca acabar
  /// caso alguém passe uma data de nascimento absurda.
  static Iterable<int> _mesesDosMarcos() sync* {
    yield* marcosEmMeses;
    for (int ano = 1; ano <= 100; ano++) {
      yield ano * _mesesDoPrimeiroAno;
    }
  }

  /// `3 meses`, `1 ano`, `2 anos`.
  @visibleForTesting
  static String rotuloDoMarco(int meses) {
    if (meses % _mesesDoPrimeiroAno == 0) {
      return S.contarAnos(meses ~/ _mesesDoPrimeiroAno);
    }
    return S.contarMeses(meses);
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

/// Um marco de idade que ainda vai acontecer, e quando.
@immutable
class ProximoMarco {
  const ProximoMarco({
    required this.rotulo,
    required this.quando,
    required this.diasAte,
  });

  /// Como o marco se chama: `1 ano`, `8 meses`, `3 semanas`.
  final String rotulo;

  final DateTime quando;

  /// Zero quando é hoje.
  final int diasAte;

  bool get ehHoje => diasAte == 0;
}
