import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'formatters.dart';

/// A lente pela qual a linha do tempo agrupa as memórias.
enum Periodo {
  ano('Anos'),
  mes('Meses'),
  semana('Semanas');

  const Periodo(this.plural);

  /// O nome como aparece no menu de escolha.
  final String plural;
}

/// Um período com as memórias que caíram dentro dele.
@immutable
class FatiaDoTempo<T> {
  const FatiaDoTempo({
    required this.inicio,
    required this.rotulo,
    required this.itens,
  });

  /// Primeiro dia do período, e a chave que o identifica.
  final DateTime inicio;

  /// O que o cabeçalho mostra: `2027`, `Maio de 2027`, `5 a 11 de maio`.
  final String rotulo;

  final List<T> itens;
}

/// O primeiro dia do período que contém [dia].
///
/// A semana começa na segunda, que é a convenção do calendário brasileiro.
/// `DateTime.weekday` já numera de 1 (segunda) a 7 (domingo), então voltar
/// `weekday - 1` dias cai sempre na segunda.
DateTime inicioDoPeriodo(DateTime dia, Periodo periodo) {
  final DateTime d = DateTime(dia.year, dia.month, dia.day);
  return switch (periodo) {
    Periodo.ano => DateTime(d.year),
    Periodo.mes => DateTime(d.year, d.month),
    Periodo.semana => d.subtract(Duration(days: d.weekday - 1)),
  };
}

/// O texto do cabeçalho de um período.
///
/// O ano aparece em todos, e não é enfeite: num acervo que atravessa
/// décadas, "Maio" sozinho é a mesma palavra em vinte anos diferentes.
///
/// A semana é a única que precisa de duas datas, porque não tem nome. Quando
/// ela cruza a virada do mês, cada ponta leva o próprio mês, senão a
/// primeira data ficaria dizendo um mês que não é o dela.
String rotuloDoPeriodo(DateTime inicio, Periodo periodo) {
  switch (periodo) {
    case Periodo.ano:
      return '${inicio.year}';
    case Periodo.mes:
      return Fmt.monthYear(inicio);
    case Periodo.semana:
      final DateTime fim = inicio.add(const Duration(days: 6));
      final DateFormat mes = DateFormat('MMMM', Fmt.locale);
      if (inicio.month == fim.month) {
        return '${inicio.day} a ${fim.day} de '
            '${mes.format(inicio)} de ${inicio.year}';
      }
      return '${inicio.day} de ${mes.format(inicio)} a '
          '${fim.day} de ${mes.format(fim)} de ${fim.year}';
  }
}

/// Divide os itens nos períodos escolhidos, do mais recente para o mais
/// antigo.
///
/// Função pura, e é o que permite perguntar coisas que a tela não responde:
/// se uma semana que cruza dezembro fica com o ano certo, se dois janeiros
/// de anos diferentes se juntam, se a ordem sai estável.
List<FatiaDoTempo<T>> fatiarPorPeriodo<T>({
  required List<T> itens,
  required DateTime Function(T) quando,
  required Periodo periodo,
}) {
  if (itens.isEmpty) return const <Never>[];

  final Map<DateTime, List<T>> porInicio = <DateTime, List<T>>{};
  for (final T item in itens) {
    final DateTime chave = inicioDoPeriodo(quando(item), periodo);
    porInicio.putIfAbsent(chave, () => <T>[]).add(item);
  }

  final List<DateTime> inicios = porInicio.keys.toList()
    ..sort((DateTime a, DateTime b) => b.compareTo(a));

  return <FatiaDoTempo<T>>[
    for (final DateTime inicio in inicios)
      FatiaDoTempo<T>(
        inicio: inicio,
        rotulo: rotuloDoPeriodo(inicio, periodo),
        // Dentro do período, do mais recente para o mais antigo também.
        itens: porInicio[inicio]!
          ..sort((T a, T b) => quando(b).compareTo(quando(a))),
      ),
  ];
}
