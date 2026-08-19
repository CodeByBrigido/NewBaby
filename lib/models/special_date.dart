import '../core/l10n/strings.dart';

/// As datas do ano que valem uma memória.
///
/// Metade delas se move: a Páscoa cai num domingo calculado a partir da lua
/// cheia, o Carnaval é contado a partir da Páscoa, e os dias das mães e dos
/// pais caem no segundo domingo de maio e de agosto. Chutar "sempre em
/// abril" faria o aplicativo lembrar do primeiro Natal na data errada, e
/// data errada é pior que data nenhuma: quebra a confiança em tudo o mais
/// que ele diz.
enum SpecialDate {
  anoNovo,
  carnaval,
  pascoa,
  diaDasMaes,
  diaDosPais,
  natal;

  const SpecialDate();

  /// Como aparece na tela, já no formato de "primeiro Natal".
  /// O nome da data, na língua ativa.
  ///
  /// Era um valor fixo no próprio enum, o que congelava o português. Como
  /// getter, ele acompanha a escolha de idioma.
  String get label => switch (this) {
    SpecialDate.anoNovo => S.holidayNewYear,
    SpecialDate.carnaval => S.holidayCarnival,
    SpecialDate.pascoa => S.holidayEaster,
    SpecialDate.diaDasMaes => S.holidayMothers,
    SpecialDate.diaDosPais => S.holidayFathers,
    SpecialDate.natal => S.holidayChristmas,
  };

  /// Quando esta data cai em [year].
  DateTime inYear(int year) => switch (this) {
    SpecialDate.anoNovo => DateTime(year, 1, 1),
    SpecialDate.natal => DateTime(year, 12, 25),
    SpecialDate.pascoa => easterOf(year),
    // Terça-feira de carnaval: 47 dias antes do domingo de Páscoa.
    SpecialDate.carnaval => easterOf(year).subtract(const Duration(days: 47)),
    SpecialDate.diaDasMaes => nthWeekday(year, 5, DateTime.sunday, 2),
    SpecialDate.diaDosPais => nthWeekday(year, 8, DateTime.sunday, 2),
  };

  /// A próxima ocorrência a partir de [from], incluindo o próprio dia.
  DateTime nextFrom(DateTime from) {
    final DateTime day = DateTime(from.year, from.month, from.day);
    final DateTime esteAno = inYear(day.year);
    if (!esteAno.isBefore(day)) return esteAno;
    return inYear(day.year + 1);
  }

  /// Domingo de Páscoa, pelo algoritmo de Meeus/Jones/Butcher para o
  /// calendário gregoriano.
  ///
  /// Escrito por extenso, com os nomes de uma letra do algoritmo original,
  /// porque qualquer tentativa de "melhorar" os nomes aqui torna impossível
  /// conferir contra a referência.
  static DateTime easterOf(int year) {
    final int a = year % 19;
    final int b = year ~/ 100;
    final int c = year % 100;
    final int d = b ~/ 4;
    final int e = b % 4;
    final int f = (b + 8) ~/ 25;
    final int g = (b - f + 1) ~/ 3;
    final int h = (19 * a + b - d - g + 15) % 30;
    final int i = c ~/ 4;
    final int k = c % 4;
    final int l = (32 + 2 * e + 2 * i - h - k) % 7;
    final int m = (a + 11 * h + 22 * l) ~/ 451;
    final int mes = (h + l - 7 * m + 114) ~/ 31;
    final int dia = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, mes, dia);
  }

  /// O [n]-ésimo [weekday] de um mês. Ex.: segundo domingo de maio.
  static DateTime nthWeekday(int year, int month, int weekday, int n) {
    final DateTime primeiro = DateTime(year, month);
    final int desloca = (weekday - primeiro.weekday + 7) % 7;
    return primeiro.add(Duration(days: desloca + (n - 1) * 7));
  }
}
