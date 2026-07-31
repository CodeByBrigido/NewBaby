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

  /// `22/01` — usado nos intervalos das telas de fotos e vídeos.
  static String dayMonth(DateTime d) => _dayMonth.format(d);

  /// `22 de janeiro de 2027`
  static String longDate(DateTime d) => _long.format(d);

  /// `Janeiro de 2027` — cabeçalho de agrupamento.
  static String monthYear(DateTime d) => _capitalize(_monthYear.format(d));

  /// `14:35`
  static String time(DateTime d) => _time.format(d);

  /// `22/01 a 28/01` — subtítulo dos baldes de idade.
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

  /// `3,250 kg` — peso guardado em gramas.
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

  /// `1,2 MB`, `12,4 GB` — tamanho de arquivo em português.
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

  /// `0:24` — duração de vídeo.
  static String duration(Duration d) {
    final int minutes = d.inMinutes;
    final String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (minutes < 60) return '$minutes:$seconds';
    final String m = (minutes % 60).toString().padLeft(2, '0');
    return '${d.inHours}:$m:$seconds';
  }

  /// `1 foto` / `15 fotos`.
  static String count(int value, String singular, String plural) =>
      '$value ${value == 1 ? singular : plural}';

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
