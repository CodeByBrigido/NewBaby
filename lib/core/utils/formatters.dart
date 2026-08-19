import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import 'age_calculator.dart';

/// Formatação de datas, medidas e tamanhos, no idioma ativo.
///
/// **Nada aqui é guardado em variável estática.** Os `DateFormat` eram
/// `static final`, criados uma vez com `pt_BR` gravado dentro: a primeira
/// chamada decidia a língua das datas para o resto da execução, e trocar o
/// idioma deixava a linha do tempo em `10/04/2027` numa tela em inglês. São
/// construídos a cada chamada, que custa muito pouco perto de estar errado.
abstract final class Fmt {
  /// O código do `intl` para a língua ativa.
  static String get locale => S.codigoIntl;

  static DateFormat get _short => DateFormat(S.padraoData, locale);
  static DateFormat get _dayMonth => DateFormat(S.padraoDiaMes, locale);
  static DateFormat get _long => DateFormat(S.padraoDataLonga, locale);
  static DateFormat get _monthYear => DateFormat(S.padraoMesAno, locale);
  static DateFormat get _time => DateFormat(S.padraoHora, locale);

  /// Este continua fixo, e é o único que continua.
  ///
  /// Ele nomeia arquivo no Google Drive, e nome de arquivo não é texto de
  /// interface: se a língua mudasse o padrão, a mesma pasta acabaria com
  /// dois jeitos de ordenar e a ordem por nome deixaria de valer.
  static final DateFormat _fileStamp = DateFormat('yyyy-MM-dd_HHmmss');

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
  /// `02/01 a 02/02 de 2025`, ou com os dois anos quando o período vira o ano.
  ///
  /// O ano não é enfeite. Sem ele o intervalo é `02/01 a 02/02`, e num
  /// aplicativo cujo acervo atravessa décadas isso não diz de que ano se
  /// está falando: a mesma semana existe em vinte anos diferentes. Numa
  /// cápsula do tempo, um período sem ano é um período sem lugar.
  ///
  /// Quando o intervalo cruza a virada do ano, cada ponta leva o próprio
  /// ano, porque aí um ano só no fim seria mentira sobre a primeira data.
  static String dateRange(DateTime start, DateTime end) {
    if (start.year == end.year) {
      final String ano = S.codigoIntl.startsWith('pt')
          ? 'de ${start.year}'
          : '${start.year}';
      return '${dayMonth(start)} ${S.entreDatas} ${dayMonth(end)} $ano';
    }
    return '${date(start)} ${S.entreDatas} ${date(end)}';
  }

  /// Prefixo do nome do arquivo enviado ao Drive: `2027-01-22_143500`.
  static String fileStamp(DateTime d) => _fileStamp.format(d);

  /// Cabeçalho da linha do tempo: `Hoje`, `Ontem` ou a data completa.
  static String timelineDay(DateTime day, {DateTime? now}) {
    final DateTime today = _dayOnly(now ?? DateTime.now());
    final DateTime target = _dayOnly(day);
    final int diff = today.difference(target).inDays;
    if (diff == 0) return S.hoje;
    if (diff == 1) return S.ontem;
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
  static String greeting(DateTime now) => S.saudacao(now.hour);

  /// Há quanto tempo, em palavras.
  ///
  /// A unidade cresce com a distância: "há 40 dias" obriga a pessoa a fazer
  /// a conta de cabeça, "há 1 mês" já diz o que ela queria saber.
  static String ago(int days) => S.haTempo(days);

  /// Quanto tempo faz, na unidade que a pessoa usaria em voz alta.
  ///
  /// `hoje`, `1 dia`, `23 dias`, `1 mês`, `7 meses`, `1 ano`, `3 anos`.
  ///
  /// A escada é dia até 30, depois mês até 12, depois ano. É diferente do
  /// [ago], que fala em semanas e serve para datar uma memória no passado.
  /// Aqui o número é uma cutucada sobre o que anda parado, e "há 4 semanas"
  /// obriga quem lê a converter de cabeça para saber se é muito ou pouco.
  ///
  /// Os meses são de calendário, e não blocos de trinta dias: quem registrou
  /// em 31 de janeiro completa um mês em 28 de fevereiro. Com a divisão por
  /// trinta, o mesmo caso mostraria "28 dias" até março.
  ///
  /// Sem sinal de "atrás" nem de "há": a frase é montada por quem chama, e o
  /// que a lista mostra é só a duração, ao lado do nome do que está parado.
  static String tempoDesde(DateTime quando, {DateTime? agora}) {
    final DateTime hoje = AgeCalculator.dayOf(agora ?? DateTime.now());
    final DateTime dia = AgeCalculator.dayOf(quando);
    final int dias = hoje.difference(dia).inDays;

    if (dias <= 0) return S.hoje.toLowerCase();
    if (dias <= 30) return S.contarDias(dias);

    int meses = (hoje.year - dia.year) * 12 + (hoje.month - dia.month);
    if (meses > 0 && AgeCalculator.addMonths(dia, meses).isAfter(hoje)) {
      meses -= 1;
    }
    // Passou de trinta dias, então é pelo menos um mês. O piso existe para o
    // caso de virada curta, tipo 31 de janeiro para 2 de março, em que a
    // conta de calendário poderia devolver zero e a lista mostraria
    // "0 meses" logo depois de "30 dias".
    if (meses < 1) meses = 1;

    if (meses < 12) return S.contarMeses(meses);
    return S.contarAnos(meses ~/ 12);
  }

  /// `primeiro`, `segundo`, ... e a partir de onde a palavra fica pior que
  /// o número, o número.
  static String ordinal(int n) => S.ordinal(n);

  static String count(int value, String singular, String plural) =>
      '$value ${value == 1 ? singular : plural}';

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
