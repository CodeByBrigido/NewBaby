import 'package:intl/intl.dart';

/// Formatação em português do Brasil para datas, medidas e tamanhos.
abstract final class Fmt {
  static const String locale = 'pt_BR';

  static final DateFormat _short = DateFormat('dd/MM/yyyy', locale);
  static final DateFormat _dayMonth = DateFormat('dd/MM', locale);
  static final DateFormat _long = DateFormat("dd 'de' MMMM 'de' yyyy", locale);
  static final DateFormat _monthYear = DateFormat("MMMM 'de' yyyy", locale);
  static final DateFormat _time = DateFormat('HH:mm', locale);
  static final DateFormat _fileStamp = DateFormat('yyyy-MM-dd_HHmmss', locale);

  /// `22/01/2027`
  static String date(DateTime d) => _short.format(d);

  /// `22/01` - usado nos intervalos das telas de fotos e vídeos.
  static String dayMonth(DateTime d) => _dayMonth.format(d);

  /// `22 de janeiro de 2027`
  static String longDate(DateTime d) => _long.format(d);

  /// `Janeiro de 2027` - cabeçalho de agrupamento.
  static String monthYear(DateTime d) => _capitalize(_monthYear.format(d));

  /// `14:35`
  static String time(DateTime d) => _time.format(d);

  /// `22/01 a 28/01` - subtítulo dos baldes de idade.
  static String dateRange(DateTime start, DateTime end) =>
      '${dayMonth(start)} a ${dayMonth(end)}';

  /// Prefixo do nome do arquivo enviado ao Drive: `2027-01-22_143500`.
  static String fileStamp(DateTime d) => _fileStamp.format(d);

  /// Cabeçalho da linha do tempo: `Hoje`, `Ontem` ou a data completa.
  static String timelineDay(DateTime day, {DateTime? now}) {
    final DateTime today = _dayOnly(now ?? DateTime.now());
    final DateTime target = _dayOnly(day);
    final int diff = today.difference(target).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    return date(target);
  }

  /// `3,250 kg` - peso guardado em gramas.
  /// Lê um decimal digitado, aceitando vírgula ou ponto.
  ///
  /// Vive aqui, e não na tela de cadastro onde nasceu, porque a tela de
  /// editar precisa ler exatamente do mesmo jeito. Duas leituras diferentes
  /// para o mesmo campo é como o peso vira outro ao ser corrigido.
  static double? parseDecimal(String raw) {
    final String limpo = raw.trim().replaceAll(',', '.');
    if (limpo.isEmpty) return null;
    final double? valor = double.tryParse(limpo);
    return (valor == null || valor <= 0) ? null : valor;
  }

  /// Peso vem em quilos e é guardado em gramas, para não acumular erro de
  /// ponto flutuante ao longo dos anos.
  static int? parseWeightGrams(String raw) {
    final double? kg = parseDecimal(raw);
    return kg == null ? null : (kg * 1000).round();
  }

  /// O peso de volta ao campo, no formato em que foi digitado.
  ///
  /// Sem unidade e sem separador de milhar: isto volta para dentro de um
  /// `TextField`, e o que sai daqui precisa ser lido de novo por
  /// [parseWeightGrams] sem perder nada.
  static String weightInput(int grams) =>
      (grams / 1000).toStringAsFixed(3).replaceAll('.', ',');

  /// A altura de volta ao campo. Sem casa decimal quando é número redondo.
  static String decimalInput(double value) =>
      (value == value.roundToDouble() ? value.round().toString() : '$value')
          .replaceAll('.', ',');

  static String weight(int grams) {
    final String value = NumberFormat('#,##0.000', locale).format(grams / 1000);
    return '$value kg';
  }

  /// `49 cm` ou `52,5 cm`.
  static String height(double cm) {
    final NumberFormat f = cm == cm.roundToDouble()
        ? NumberFormat('#,##0', locale)
        : NumberFormat('#,##0.#', locale);
    return '${f.format(cm)} cm';
  }

  /// `1,2 MB`, `12,4 GB` - tamanho de arquivo em português.
  static String bytes(int value) {
    if (value < 1024) return '$value B';
    const List<String> units = <String>['KB', 'MB', 'GB', 'TB'];
    double size = value / 1024;
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final NumberFormat f = size >= 100
        ? NumberFormat('#,##0', locale)
        : NumberFormat('#,##0.#', locale);
    return '${f.format(size)} ${units[unit]}';
  }

  /// `0:24` - duração de vídeo.
  static String duration(Duration d) {
    final int minutes = d.inMinutes;
    final String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (minutes < 60) return '$minutes:$seconds';
    final String m = (minutes % 60).toString().padLeft(2, '0');
    return '${d.inHours}:$m:$seconds';
  }

  /// `1 foto` / `15 fotos`.
  /// Saudação pela hora do dia.
  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Bom dia';
    if (now.hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Há quanto tempo, em palavras.
  ///
  /// A unidade cresce com a distância: "há 40 dias" obriga a pessoa a fazer
  /// a conta de cabeça, "há 1 mês" já diz o que ela queria saber.
  static String ago(int days) {
    if (days <= 0) return 'hoje';
    if (days == 1) return 'ontem';
    if (days < 14) return 'há $days dias';
    if (days < 60) {
      final int semanas = days ~/ 7;
      return semanas == 1 ? 'há 1 semana' : 'há $semanas semanas';
    }
    if (days < 365) {
      final int meses = days ~/ 30;
      return meses == 1 ? 'há 1 mês' : 'há $meses meses';
    }
    final int anos = days ~/ 365;
    return anos == 1 ? 'há 1 ano' : 'há $anos anos';
  }

  /// `primeiro`, `segundo`, ... e a partir de onde a palavra fica pior que
  /// o número, o número.
  static String ordinal(int n) => switch (n) {
    1 => 'primeiro',
    2 => 'segundo',
    3 => 'terceiro',
    4 => 'quarto',
    5 => 'quinto',
    6 => 'sexto',
    7 => 'sétimo',
    8 => 'oitavo',
    9 => 'nono',
    10 => 'décimo',
    _ => '$nº',
  };

  static String count(int value, String singular, String plural) =>
      '$value ${value == 1 ? singular : plural}';

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
