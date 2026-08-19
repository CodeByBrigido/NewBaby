import 'package:meta/meta.dart';

import '../core/l10n/copy.dart';
import '../core/l10n/strings.dart';
import '../core/utils/age_calculator.dart';
import 'baby_profile.dart';
import 'capsule_pulse.dart';
import 'entry.dart';
import 'inspiration.dart';
import 'special_date.dart';

/// Por que o aplicativo interromperia alguém.
///
/// Cada tipo tem um botão próprio nas Configurações, e é assim de propósito:
/// quem quer só o aviso do aniversário e nada mais precisa poder ter isso
/// sem desligar tudo. Um interruptor único transforma "isso aqui me irrita"
/// em "desliguei tudo", e aí a pessoa perde também o que gostaria de saber.
enum ReminderKind {
  /// "Hoje ela faz 8 meses."
  dataRedonda,

  /// A contagem do aniversário.
  aniversario,

  /// Primeiro Natal, primeira Páscoa.
  dataEspecial,

  /// Uma leitura com prazo, da aba Inspirações.
  inspiracao,

  /// "Faz um tempo desde a última foto."
  ausencia,

  /// O único que protege a cápsula, e não a memória de alimentá-la.
  contaInativa;

  const ReminderKind();

  /// O nome e a explicação, na língua ativa.
  ///
  /// Eram valores fixos no próprio enum, o que congelava o português na
  /// construção. Como getters, acompanham a escolha de idioma.
  String get label => switch (this) {
    ReminderKind.dataRedonda => S.reminderRoundLabel,
    ReminderKind.aniversario => S.reminderBirthdayLabel,
    ReminderKind.dataEspecial => S.reminderSpecialLabel,
    ReminderKind.inspiracao => S.reminderInspirationLabel,
    ReminderKind.ausencia => S.reminderAbsenceLabel,
    ReminderKind.contaInativa => S.reminderInactiveLabel,
  };

  String get description => switch (this) {
    ReminderKind.dataRedonda => S.reminderRoundDesc,
    ReminderKind.aniversario => S.reminderBirthdayDesc,
    ReminderKind.dataEspecial => S.reminderSpecialDesc,
    ReminderKind.inspiracao => S.reminderInspirationDesc,
    ReminderKind.ausencia => S.reminderAbsenceDesc,
    ReminderKind.contaInativa => S.reminderInactiveDesc,
  };

  /// Quem ganha o dia quando dois lembretes caem na mesma data.
  ///
  /// Menor vence. O aniversário ganha de tudo; o lembrete gentil perde para
  /// todos, porque é o único que não tem hora marcada e pode esperar.
  ///
  /// O aviso da conta vem logo depois do aniversário: se ele perder o dia,
  /// espera um ano inteiro, e o que estava em jogo era a cápsula inteira.
  int get priority => switch (this) {
    ReminderKind.aniversario => 0,
    ReminderKind.contaInativa => 1,
    ReminderKind.dataEspecial => 2,
    ReminderKind.dataRedonda => 3,
    ReminderKind.inspiracao => 4,
    ReminderKind.ausencia => 5,
  };

  /// Se este lembrete pode ser marcado além da janela de [reminderHorizonDays].
  ///
  /// Só um pode, e a razão é o próprio assunto dele: o aviso da conta existe
  /// para quem **parou** de abrir o aplicativo. Todos os outros são
  /// recalculados na próxima abertura, então marcar longe seria marcar com
  /// dado velho. Este não pode contar com abertura nenhuma, porque a
  /// ausência de abertura é exatamente o que ele avisa.
  bool get livesBeyondHorizon => this == ReminderKind.contaInativa;
}

/// O que a pessoa escolheu nas Configurações.
@immutable
class ReminderSettings {
  const ReminderSettings({
    this.enabled = true,
    this.kinds = const <ReminderKind>{
      ReminderKind.dataRedonda,
      ReminderKind.aniversario,
      ReminderKind.dataEspecial,
      ReminderKind.inspiracao,
      ReminderKind.ausencia,
      ReminderKind.contaInativa,
    },
    this.hour = 10,
    this.absenceDays = 14,
  });

  /// Ligado desde o começo.
  ///
  /// É decisão de produto, e é o que faz esta fase valer: uma cápsula do
  /// tempo só cumpre a promessa se alguém voltar a ela, e quem tem um bebê
  /// pequeno não volta por conta própria - as semanas somem. Deixar
  /// desligado por padrão significa que quase ninguém liga, e aí os
  /// lembretes existem no código e não na vida de ninguém.
  ///
  /// **Isto não é permissão.** No Android 13 em diante o sistema é quem
  /// decide, e ele pergunta. Esta chave só diz que o aplicativo *quer*
  /// lembrar; a permissão é pedida logo depois do cadastro, e se a pessoa
  /// recusar, a chave volta sozinha para desligado. O teto de
  /// [maxRemindersPerWeek] continua valendo acima de tudo: ligado por
  /// padrão só se sustenta porque o volume é pequeno.
  final bool enabled;

  final Set<ReminderKind> kinds;

  /// A hora do dia, em 24h. Fora da janela silenciosa.
  final int hour;

  /// Quantos dias sem registrar nada antes de o lembrete gentil aparecer.
  final int absenceDays;

  bool wants(ReminderKind kind) => enabled && kinds.contains(kind);

  /// Nunca de madrugada, nunca na hora do jantar de quem tem bebê.
  static const int earliestHour = 7;
  static const int latestHour = 21;
  int get safeHour => hour.clamp(earliestHour, latestHour);

  ReminderSettings copyWith({
    bool? enabled,
    Set<ReminderKind>? kinds,
    int? hour,
    int? absenceDays,
  }) => ReminderSettings(
    enabled: enabled ?? this.enabled,
    kinds: kinds ?? this.kinds,
    hour: hour ?? this.hour,
    absenceDays: absenceDays ?? this.absenceDays,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'ligado': enabled,
    'tipos': kinds.map((ReminderKind k) => k.name).toList(),
    'hora': hour,
    'diasAusencia': absenceDays,
  };

  static ReminderSettings fromMap(Map<String, Object?>? map) {
    if (map == null) return const ReminderSettings();
    final List<Object?>? tipos = map['tipos'] as List<Object?>?;
    return ReminderSettings(
      enabled: map['ligado'] == true,
      kinds: tipos == null
          ? const ReminderSettings().kinds
          : <ReminderKind>{
              for (final ReminderKind k in ReminderKind.values)
                if (tipos.contains(k.name)) k,
            },
      hour: (map['hora'] as num?)?.toInt() ?? 10,
      absenceDays: (map['diasAusencia'] as num?)?.toInt() ?? 14,
    );
  }
}

/// Um lembrete já resolvido contra o calendário: dia, hora e texto.
@immutable
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.kind,
    required this.when,
    required this.title,
    required this.body,
  });

  /// Estável para o mesmo dia e o mesmo tipo, para reagendar não duplicar.
  final int id;

  final ReminderKind kind;
  final DateTime when;
  final String title;
  final String body;

  DateTime get day => DateTime(when.year, when.month, when.day);
}

/// Quanto tempo à frente vale agendar.
///
/// Curto de propósito. O aplicativo reagenda tudo a cada abertura, e um
/// lembrete marcado para daqui a seis meses seria calculado a partir de uma
/// cápsula que ainda nem existe.
const int reminderHorizonDays = 45;

/// Quando o aviso da conta é marcado, contado da última abertura.
///
/// Onze meses, e não os dois anos que o Google leva para apagar uma conta
/// sem uso: um aviso que chega no último dia é um aviso que chega tarde. Em
/// onze meses ainda sobra mais de um ano para reagir, e o aplicativo tem
/// muitas chances de ser aberto antes disso e empurrar o aviso adiante.
///
/// Cada abertura reagenda tudo, então este aviso vive fugindo para a frente
/// enquanto a pessoa continua aparecendo. Ele só chega mesmo para quem
/// sumiu, que é para quem ele foi escrito.
const int inactivityWarningDays = 334;

/// No máximo um lembrete por dia, e no máximo dois em qualquer sete dias.
///
/// Este é o número mais importante deste arquivo. Um aplicativo de memórias
/// que avisa demais vira um aplicativo que a pessoa desliga, e um aplicativo
/// desligado não lembra de nada. O teto vale acima de qualquer regra: se
/// houver cinco motivos válidos numa semana, três não são enviados.
const int maxRemindersPerWeek = 2;

/// Monta a agenda de lembretes a partir do que o aplicativo já sabe.
///
/// Função pura: mesma cápsula e mesmo dia, mesma agenda. Nada aqui toca
/// rede, nem plataforma, nem relógio - o `now` entra por parâmetro, que é o
/// que torna tudo isto testável sem esperar um mês para ver o mensiversário.
///
/// Acrescentar um lembrete novo é acrescentar um `_candidatos` novo. Foi o
/// critério combinado para esta fase.
List<ScheduledReminder> planReminders({
  required BabyProfile profile,
  required CapsulePulse pulse,
  required ReminderSettings settings,
  List<ActiveInspiration> inspirations = const <ActiveInspiration>[],
  Set<String> readInspirations = const <String>{},
  DateTime? now,
}) {
  if (!settings.enabled) return const <ScheduledReminder>[];

  final DateTime hoje = AgeCalculator.dayOf(now ?? DateTime.now());
  final DateTime limite = hoje.add(const Duration(days: reminderHorizonDays));
  final Copy copy = Copy.of(profile);

  final List<ScheduledReminder> candidatos = <ScheduledReminder>[
    ..._aniversario(profile, pulse, copy, settings, hoje),
    ..._datasRedondas(profile, copy, settings, hoje, limite),
    ..._datasEspeciais(profile, copy, settings, hoje, limite),
    ..._inspiracoes(inspirations, readInspirations, copy, settings, hoje),
    ..._ausencia(pulse, copy, settings, hoje),
    ..._contaInativa(copy, settings, hoje),
  ];

  return _peneirar(candidatos, hoje: hoje, limite: limite, settings: settings);
}

// ------------------------------------------------------------- as regras

Iterable<ScheduledReminder> _aniversario(
  BabyProfile profile,
  CapsulePulse pulse,
  Copy copy,
  ReminderSettings settings,
  DateTime hoje,
) sync* {
  if (!settings.wants(ReminderKind.aniversario)) return;

  final DateTime data = pulse.nextBirthday;
  final int anos = pulse.birthdayYears;
  final String quem = copy.hasName ? copy.theName : S.theChild;

  // Uma semana antes: dá tempo de organizar sem virar cobrança.
  yield _lembrete(
    ReminderKind.aniversario,
    data.subtract(const Duration(days: 7)),
    settings,
    titulo: S.notifWeekLeftTitle,
    corpo: anos == 1
        ? S.notifFirstBirthdaySoon(quem)
        : S.notifBirthdaySoon(quem, anos),
  );

  yield _lembrete(
    ReminderKind.aniversario,
    data,
    settings,
    titulo: S.notifBirthdayTitle(anos),
    corpo: copy.hasName
        ? S.notifBirthdayToday(copy.ofName)
        : S.notifBirthdayTodayGeneric,
  );
}

/// Os mensiversários, e só enquanto eles ainda significam alguma coisa.
///
/// Até os dois anos. Depois disso "vinte e sete meses" não é como ninguém
/// conta a idade de uma criança, e um aviso que soa estranho é um aviso que
/// ensina a ignorar os outros.
Iterable<ScheduledReminder> _datasRedondas(
  BabyProfile profile,
  Copy copy,
  ReminderSettings settings,
  DateTime hoje,
  DateTime limite,
) sync* {
  if (!settings.wants(ReminderKind.dataRedonda)) return;

  final DateTime nascimento = profile.birthDay;
  for (int meses = 1; meses <= 24; meses++) {
    final DateTime dia = AgeCalculator.addMonths(nascimento, meses);
    if (!dia.isAfter(hoje) || dia.isAfter(limite)) continue;
    // O aniversário de um ano e o de dois têm aviso próprio, mais bonito.
    if (meses % 12 == 0) continue;

    yield _lembrete(
      ReminderKind.dataRedonda,
      dia,
      settings,
      titulo: S.notifMonthsTitle(meses),
      corpo: copy.hasName
          ? S.notifMonthsBody(copy.theName, meses)
          : S.notifPhotoWorthIt,
    );
  }
}

/// A primeira vez de cada data do ano.
///
/// Só a primeira. O primeiro Natal é um acontecimento; o quarto é um Natal.
Iterable<ScheduledReminder> _datasEspeciais(
  BabyProfile profile,
  Copy copy,
  ReminderSettings settings,
  DateTime hoje,
  DateTime limite,
) sync* {
  if (!settings.wants(ReminderKind.dataEspecial)) return;

  final DateTime nascimento = profile.birthDay;
  for (final SpecialDate data in SpecialDate.values) {
    final DateTime proxima = data.nextFrom(hoje);
    if (proxima != data.nextFrom(nascimento)) continue;

    // Três dias antes: tempo de comprar a roupinha, não de fazer planos.
    final DateTime dia = proxima.subtract(const Duration(days: 3));
    if (!dia.isAfter(hoje) || dia.isAfter(limite)) continue;

    yield _lembrete(
      ReminderKind.dataEspecial,
      dia,
      settings,
      titulo: S.notifFirstHolidayTitle(data.label),
      corpo: copy.hasName
          ? S.notifFirstHolidayBody(data.label, copy.ofName)
          : S.notifFirstHolidayBodyGeneric(data.label),
    );
  }
}

/// A ideia que só serve agora.
///
/// Só destaque, só com prazo, e só o que ainda não foi lido. As três
/// condições juntas existem para isto não virar um boletim: são poucos
/// conteúdos por ano que passam por elas, e é exatamente por serem poucos
/// que valem uma interrupção.
Iterable<ScheduledReminder> _inspiracoes(
  List<ActiveInspiration> inspirations,
  Set<String> lidas,
  Copy copy,
  ReminderSettings settings,
  DateTime hoje,
) sync* {
  if (!settings.wants(ReminderKind.inspiracao)) return;

  for (final ActiveInspiration a in inspirations) {
    if (!a.inspiration.highlight) continue;
    if (!a.hasDeadline) continue;
    if (lidas.contains(a.inspiration.id)) continue;

    // Amanhã, e não hoje: quem acabou de abrir o aplicativo já viu a aba.
    yield _lembrete(
      ReminderKind.inspiracao,
      hoje.add(const Duration(days: 1)),
      settings,
      titulo: a.inspiration.title,
      corpo: a.inspiration.summary,
    );
  }
}

/// O lembrete gentil, que é o mais fácil de errar.
///
/// Ele existe porque a vida com criança pequena engole semanas inteiras, e
/// quem abre o aplicativo depois de dois meses lamenta o que não guardou.
/// E ele erra feio se soar como cobrança: quem não registrou nada em duas
/// semanas pode ter passado duas semanas num hospital.
///
/// Por isso: só um, longe (duas semanas por padrão), sem número na cara, e
/// sempre no fim da fila de prioridade.
Iterable<ScheduledReminder> _ausencia(
  CapsulePulse pulse,
  Copy copy,
  ReminderSettings settings,
  DateTime hoje,
) sync* {
  if (!settings.wants(ReminderKind.ausencia)) return;

  // O dia mais recente em que qualquer coisa foi registrada.
  int? maisRecente;
  for (final EntryType tipo in EntryType.values) {
    final int? dias = pulse.daysSince(tipo);
    if (dias == null) continue;
    if (maisRecente == null || dias < maisRecente) maisRecente = dias;
  }

  // Cápsula ainda vazia: o silêncio aqui não é esquecimento, é o começo. A
  // tela inicial já convida, e um aviso no primeiro dia seria atropelo.
  if (maisRecente == null) return;

  final int faltam = settings.absenceDays - maisRecente;
  final DateTime dia = hoje.add(Duration(days: faltam < 1 ? 1 : faltam));

  yield _lembrete(
    ReminderKind.ausencia,
    dia,
    settings,
    titulo: S.notifMomentTitle,
    corpo: copy.hasName
        ? S.notifAbsenceBody(copy.ofName)
        : S.notifAbsenceGeneric,
  );
}

/// O aviso que protege a cápsula, e não a memória de alimentá-la.
///
/// O Google apaga contas sem uso por dois anos. Quem cria uma conta só para
/// a cápsula, guarda vinte anos de fotos nela e depois passa a usar pouco o
/// aplicativo está no caminho exato desse apagamento, e provavelmente não
/// sabe. É o único aviso daqui que não é sobre registrar mais: é sobre não
/// perder o que já foi registrado.
///
/// Usar o aplicativo conta como uso da conta, então abrir de vez em quando
/// já resolve. Por isso o texto pede o mínimo possível.
Iterable<ScheduledReminder> _contaInativa(
  Copy copy,
  ReminderSettings settings,
  DateTime hoje,
) sync* {
  if (!settings.wants(ReminderKind.contaInativa)) return;

  yield _lembrete(
    ReminderKind.contaInativa,
    hoje.add(const Duration(days: inactivityWarningDays)),
    settings,
    titulo: S.notifInactiveTitle,
    corpo: copy.hasName
        ? S.notifInactiveBody(copy.ofName)
        : S.notifInactiveGeneric,
  );
}

// ------------------------------------------------------------ a peneira

ScheduledReminder _lembrete(
  ReminderKind kind,
  DateTime dia,
  ReminderSettings settings, {
  required String titulo,
  required String corpo,
}) {
  final DateTime quando = DateTime(
    dia.year,
    dia.month,
    dia.day,
    settings.safeHour,
  );
  return ScheduledReminder(
    id: _id(kind, dia),
    kind: kind,
    when: quando,
    title: titulo,
    body: corpo,
  );
}

/// Um id estável para o par tipo/dia.
///
/// Estável importa: o aplicativo reagenda a cada abertura, e sem isto o
/// mesmo aviso viraria três avisos em três aberturas.
int _id(ReminderKind kind, DateTime dia) {
  final int data = dia.year * 10000 + dia.month * 100 + dia.day;
  return data * 10 + kind.index;
}

/// Aplica, nesta ordem: janela, um por dia, e o teto semanal.
List<ScheduledReminder> _peneirar(
  List<ScheduledReminder> candidatos, {
  required DateTime hoje,
  required DateTime limite,
  required ReminderSettings settings,
}) {
  final List<ScheduledReminder> dentroDaJanela = candidatos
      .where(
        (ScheduledReminder r) =>
            r.when.isAfter(hoje) &&
            (r.kind.livesBeyondHorizon || !r.day.isAfter(limite)),
      )
      .toList();

  dentroDaJanela.sort((ScheduledReminder a, ScheduledReminder b) {
    final int porDia = a.when.compareTo(b.when);
    if (porDia != 0) return porDia;
    final int porTipo = a.kind.priority.compareTo(b.kind.priority);
    return porTipo != 0 ? porTipo : a.title.compareTo(b.title);
  });

  final List<ScheduledReminder> aceitos = <ScheduledReminder>[];
  final Set<DateTime> diasUsados = <DateTime>{};

  for (final ScheduledReminder r in dentroDaJanela) {
    if (diasUsados.contains(r.day)) continue;

    // O teto move junto com o calendário: conta quantos já foram aceitos
    // nos sete dias que terminam neste.
    final DateTime inicio = r.day.subtract(const Duration(days: 6));
    final int naSemana = aceitos
        .where(
          (ScheduledReminder a) =>
              !a.day.isBefore(inicio) && !a.day.isAfter(r.day),
        )
        .length;
    if (naSemana >= maxRemindersPerWeek) continue;

    aceitos.add(r);
    diasUsados.add(r.day);
  }

  return aceitos;
}
