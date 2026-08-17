import 'package:meta/meta.dart';

/// Em que unidade a pasta do Drive agrupa o conteúdo.
enum AgeBucketUnit { week, month, year }

/// Um "balde" de idade: a pasta do Drive onde o conteúdo é guardado
/// (`Semana 07`, `Mês 14`, `Ano 3`) e o intervalo de datas que ela cobre.
@immutable
class AgeBucket {
  const AgeBucket({
    required this.unit,
    required this.index,
    required this.start,
    required this.end,
  });

  final AgeBucketUnit unit;

  /// Número exibido no nome da pasta: semana 1..52, mês 13..24, ano 2..N.
  final int index;

  /// Primeiro dia coberto pelo balde.
  final DateTime start;

  /// Último dia coberto pelo balde (inclusive).
  final DateTime end;

  /// Nome da pasta no Google Drive, exatamente como aparece para o usuário.
  String get folderName => switch (unit) {
    AgeBucketUnit.week => 'Semana ${index.toString().padLeft(2, '0')}',
    AgeBucketUnit.month => 'Mês ${index.toString().padLeft(2, '0')}',
    AgeBucketUnit.year => 'Ano $index',
  };

  /// Chave estável usada no Firestore e para ordenar os baldes.
  /// Ordena corretamente porque semana < mês < ano na comparação de texto.
  String get key => switch (unit) {
    AgeBucketUnit.week => 'S${index.toString().padLeft(2, '0')}',
    AgeBucketUnit.month => 'M${index.toString().padLeft(2, '0')}',
    AgeBucketUnit.year => 'A${index.toString().padLeft(2, '0')}',
  };

  @override
  bool operator ==(Object other) =>
      other is AgeBucket && other.unit == unit && other.index == index;

  @override
  int get hashCode => Object.hash(unit, index);

  @override
  String toString() => folderName;
}

/// A idade da criança em uma data, já decomposta para exibição.
@immutable
class Age {
  const Age({
    required this.totalDays,
    required this.months,
    required this.daysInMonth,
  });

  /// Dias completos desde o nascimento (0 no dia do nascimento).
  final int totalDays;

  /// Meses completos de calendário desde o nascimento.
  final int months;

  /// Dias que sobram depois dos [months] meses completos.
  final int daysInMonth;

  int get years => months ~/ 12;
  int get monthsInYear => months % 12;
  int get totalWeeks => totalDays ~/ 7;

  /// Rótulo curto, no estilo pedido na especificação:
  /// `3 dias`, `2 semanas`, `5 semanas`, `4 meses`, `1 ano e 2 meses`.
  ///
  /// Nenhum rótulo daqui tem gênero: no dia zero diz "No nascimento", que
  /// descreve o momento em vez da criança. Assim o cálculo de idade fica
  /// livre de concordância, e o texto com gênero mora só na camada de
  /// interface, onde o cadastro está disponível.
  String get shortLabel {
    if (totalDays == 0) return 'No nascimento';
    if (totalDays < 7) return _plural(totalDays, 'dia', 'dias');
    if (totalDays < 84) {
      return _plural(totalWeeks, 'semana', 'semanas');
    }
    if (months < 12) return _plural(months, 'mês', 'meses');
    if (monthsInYear == 0) return _plural(years, 'ano', 'anos');
    return '${_plural(years, 'ano', 'anos')} e '
        '${_plural(monthsInYear, 'mês', 'meses')}';
  }

  /// Rótulo detalhado usado na linha do tempo, como no mockup:
  /// `22 dias`, `1 mês e 29 dias`, `2 meses e 27 dias`, `1 ano e 2 meses`.
  ///
  /// Com [alwaysShowDays] o `e 0 dias` é mantido - é o formato do perfil
  /// e do menu lateral (`3 meses e 0 dias`).
  String detailedLabel({bool alwaysShowDays = false}) {
    final List<String> partes = _partes(alwaysShowDays: alwaysShowDays);
    if (partes.isEmpty) return 'No nascimento';
    return _juntar(partes);
  }

  /// O mesmo rótulo em duas linhas, com os dias embaixo.
  ///
  /// Existe para o painel da tela inicial, onde a idade vem grande. Ali
  /// `1 ano, 9 meses e 14 dias` não cabe numa linha e a quebra automática
  /// caía no pior lugar possível, separando o número da unidade:
  ///
  /// ```
  /// 1 ano, 9 meses e 14
  /// dias
  /// ```
  ///
  /// Quebrar onde a frase permite é diferente de deixar quebrar onde couber.
  ///
  /// Só quebra com três parcelas, que é quando a frase de fato não cabe.
  /// `1 mês e 14 dias` continua numa linha: parti-lo seria criar o problema
  /// que este método existe para resolver.
  ///
  /// A primeira linha usa vírgula, e não "e", porque a frase continua na
  /// linha de baixo. Fechar a de cima com "e" faria as duas juntas lerem
  /// `1 ano e 9 meses e 14 dias`, que é exatamente o erro que saiu daqui.
  List<String> detailedLines({bool alwaysShowDays = false}) {
    final List<String> partes = _partes(alwaysShowDays: alwaysShowDays);
    if (partes.isEmpty) return const <String>['No nascimento'];
    if (partes.length < 3) return <String>[_juntar(partes)];
    return <String>[
      partes.sublist(0, partes.length - 1).join(', '),
      'e ${partes.last}',
    ];
  }

  /// As parcelas da idade, já sem as que não valem a pena mostrar.
  List<String> _partes({required bool alwaysShowDays}) {
    if (totalDays == 0) return const <String>[];
    if (months == 0) return <String>[_plural(totalDays, 'dia', 'dias')];

    final List<String> partes = <String>[
      if (months >= 12) _plural(years, 'ano', 'anos'),
      if (months < 12 || monthsInYear > 0)
        _plural(months < 12 ? months : monthsInYear, 'mês', 'meses'),
    ];

    // A partir de um ano os dias poluem a leitura, então só aparecem
    // quando explicitamente pedidos.
    final bool comDias = alwaysShowDays || (months < 12 && daysInMonth != 0);
    if (comDias) partes.add(_plural(daysInMonth, 'dia', 'dias'));
    return partes;
  }

  /// Junta as parcelas como se escreve em português.
  ///
  /// Só a última leva "e"; as anteriores se separam por vírgula. Aqui isso
  /// não é preciosismo: com três parcelas, juntar tudo com "e" produzia
  /// `1 ano e 9 meses e 14 dias`, que é a frase que aparecia na tela inicial
  /// e que se lê como erro de digitação.
  static String _juntar(List<String> partes) {
    if (partes.length == 1) return partes.single;
    final String inicio = partes.sublist(0, partes.length - 1).join(', ');
    return '$inicio e ${partes.last}';
  }

  static String _plural(int value, String one, String many) =>
      '$value ${value == 1 ? one : many}';

  @override
  bool operator ==(Object other) =>
      other is Age &&
      other.totalDays == totalDays &&
      other.months == months &&
      other.daysInMonth == daysInMonth;

  @override
  int get hashCode => Object.hash(totalDays, months, daysInMonth);

  @override
  String toString() => shortLabel;
}

/// Converte data de nascimento + data do evento em idade e pasta de destino.
///
/// Este é o núcleo do aplicativo: tudo - nome da pasta no Drive, rótulo da
/// linha do tempo, agrupamento das telas de fotos e vídeos - sai daqui.
abstract final class AgeCalculator {
  /// Normaliza para meia-noite, para que a idade não dependa do horário.
  static DateTime dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Idade em [date] para quem nasceu em [birth].
  ///
  /// Datas anteriores ao nascimento são tratadas como o próprio dia do
  /// nascimento - nada no aplicativo deve exibir idade negativa.
  static Age ageAt(DateTime birth, DateTime date) {
    final DateTime b = dayOf(birth);
    final DateTime d = dayOf(date);
    if (!d.isAfter(b)) {
      return const Age(totalDays: 0, months: 0, daysInMonth: 0);
    }

    final int totalDays = d.difference(b).inDays;

    // O mês só está completo quando a data já alcançou o aniversário mensal.
    // A comparação usa [addMonths] em vez de comparar o dia diretamente para
    // que quem nasce em 31/01 complete um mês em 28/02 - o último dia de
    // fevereiro - e não fique "0 meses" até 01/03.
    int months = (d.year - b.year) * 12 + (d.month - b.month);
    if (months > 0 && addMonths(b, months).isAfter(d)) months -= 1;
    if (months < 0) months = 0;

    final DateTime anchor = addMonths(b, months);
    final int daysInMonth = d.difference(anchor).inDays;

    return Age(totalDays: totalDays, months: months, daysInMonth: daysInMonth);
  }

  /// Soma meses de calendário preservando o fim do mês.
  /// 31/01 + 1 mês vira 28/02 (ou 29/02 em ano bissexto), nunca 03/03.
  static DateTime addMonths(DateTime date, int months) {
    final int totalMonths = date.year * 12 + (date.month - 1) + months;
    final int year = totalMonths ~/ 12;
    final int month = totalMonths % 12 + 1;
    final int lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, date.day > lastDay ? lastDay : date.day);
  }

  /// Pasta de destino no Drive para um conteúdo daquela data.
  ///
  /// Regra da especificação: `Semana 01`…`Semana 52` no primeiro ano,
  /// depois `Mês 13`…`Mês 24`, depois `Ano 2`, `Ano 3`, …
  static AgeBucket bucketAt(DateTime birth, DateTime date) {
    final DateTime b = dayOf(birth);
    final Age age = ageAt(b, date);

    if (age.months < 12) {
      // Semana 01 é a primeira semana de vida; a última semana do primeiro
      // ano é limitada a 52 para não criar uma "Semana 53" de dois dias.
      final int index = (age.totalDays ~/ 7) + 1 > 52
          ? 52
          : (age.totalDays ~/ 7) + 1;
      final DateTime start = b.add(Duration(days: (index - 1) * 7));
      final DateTime end = index == 52
          ? addMonths(b, 12).subtract(const Duration(days: 1))
          : start.add(const Duration(days: 6));
      return AgeBucket(
        unit: AgeBucketUnit.week,
        index: index,
        start: start,
        end: end,
      );
    }

    if (age.months < 24) {
      // Mês de vida: aos 12 meses completos a criança vive o 13º mês.
      final int index = age.months + 1;
      final DateTime start = addMonths(b, index - 1);
      final DateTime end = addMonths(
        b,
        index,
      ).subtract(const Duration(days: 1));
      return AgeBucket(
        unit: AgeBucketUnit.month,
        index: index,
        start: start,
        end: end,
      );
    }

    final int index = age.years;
    final DateTime start = addMonths(b, index * 12);
    final DateTime end = addMonths(
      b,
      (index + 1) * 12,
    ).subtract(const Duration(days: 1));
    return AgeBucket(
      unit: AgeBucketUnit.year,
      index: index,
      start: start,
      end: end,
    );
  }

  /// O caminho da pasta no Drive para um conteúdo daquela data.
  ///
  /// `['Ano 0', 'Mês 07']`, `['Ano 1', 'Mês 03']`, `['Ano 5', 'Mês 11']`.
  ///
  /// **Duas convenções, e são dois públicos.** Quem registra hoje quer a
  /// semana, e é ela que a galeria mostra ([AgeBucket.folderName]). Quem
  /// abrir a pasta daqui a vinte anos quer a idade como se fala dela:
  /// `Semana 33` não diz nada a essa segunda pessoa, e cinquenta e duas
  /// pastas por ano de vida atrapalham quem está folheando o acervo inteiro.
  ///
  /// **O mês reinicia a cada ano** porque é assim que a idade de uma criança
  /// é dita: `Ano 1/Mês 03` se lê "1 ano e 3 meses". Uma numeração contínua
  /// daria `Mês 15`, que ordena igualmente bem e não corresponde a nada que
  /// alguém fale em voz alta.
  ///
  /// `Mês 00` é o primeiro mês de vida, antes de completar um mês. Fica com
  /// zero, e não com um, para o número da pasta continuar sendo a idade e
  /// não a contagem: dentro de `Ano 0`, `Mês 00` é quem ainda não tem mês
  /// nenhum completo.
  ///
  /// Dois níveis, e não um só com tudo dentro: o ano é a gaveta que alguém
  /// abre primeiro, e a criança de cinco anos tem sessenta meses de acervo.
  static List<String> caminhoNoDrive(DateTime birth, DateTime date) {
    final Age idade = ageAt(birth, date);
    return <String>[
      'Ano ${idade.years}',
      'Mês ${(idade.months % 12).toString().padLeft(2, '0')}',
    ];
  }
}
