/// As divisões internas de uma pasta de idade.
///
/// Uma pasta de mês guarda quatro ou cinco semanas de vida, e uma de ano
/// guarda doze meses. Numa grade única isso vira uma parede de fotos sem
/// nenhuma pista de quando cada uma aconteceu: abrir o `Mês 14` e rolar
/// cinquenta fotos não conta que a primeira dezena é de uma semana e o resto
/// de outra.
///
/// A contagem aqui é **relativa à pasta**, e não à vida inteira. Dentro do
/// `Mês 14` as seções são `Semana 1` a `Semana 5`, e não `Semana 57`: quem
/// abriu a pasta do mês está pensando naquele mês.
library;

import 'package:flutter/foundation.dart';

import '../l10n/strings.dart';
import 'age_calculator.dart';

/// Um pedaço de uma pasta de idade, com o que caiu dentro dele.
@immutable
class SecaoDoBalde<T> {
  const SecaoDoBalde({required this.titulo, required this.itens});

  /// `Semana 1`, `Mês 3`. Vazio quando a pasta não se divide.
  final String titulo;

  final List<T> itens;
}

/// Quantos dias tem uma semana. Existe para a conta abaixo se ler.
const int _diasDaSemana = 7;

/// Divide o conteúdo de uma pasta de idade nas seções que ela comporta.
///
/// * pasta de **semana**: não se divide. Sete dias não têm o que separar, e
///   inventar seções ali só acrescentaria títulos entre fotos vizinhas.
/// * pasta de **mês**: dividida por semana daquele mês.
/// * pasta de **ano**: dividida por mês daquele ano.
///
/// [quando] diz a data de cada item, porque quem chama tem pares de entrada
/// e arquivo, e não datas soltas.
///
/// A ordem das seções segue a do conteúdo, e seções vazias não aparecem: uma
/// semana em que ninguém registrou nada não é informação, é buraco.
List<SecaoDoBalde<T>> secoesDoBalde<T>({
  required AgeBucket balde,
  required List<T> itens,
  required DateTime Function(T) quando,
}) {
  if (balde.unit == AgeBucketUnit.week || itens.isEmpty) {
    return <SecaoDoBalde<T>>[
      if (itens.isNotEmpty) SecaoDoBalde<T>(titulo: '', itens: itens),
    ];
  }

  final Map<int, List<T>> porIndice = <int, List<T>>{};
  for (final T item in itens) {
    final int indice = _indiceDentroDoBalde(balde, quando(item));
    porIndice.putIfAbsent(indice, () => <T>[]).add(item);
  }

  final List<int> indices = porIndice.keys.toList()..sort();
  return <SecaoDoBalde<T>>[
    for (final int i in indices)
      SecaoDoBalde<T>(
        titulo: balde.unit == AgeBucketUnit.month
            ? S.semanaNumero(i)
            : S.mesNumero(i),
        itens: porIndice[i]!,
      ),
  ];
}

/// Em que semana (ou mês) da pasta a data cai, contando a partir de 1.
///
/// Datas fora do intervalo da pasta são grampeadas na ponta mais próxima em
/// vez de virarem seção negativa. Elas existem: a data de uma memória pode
/// ser corrigida à mão depois de o arquivo já estar guardado, e nesse caso o
/// balde antigo continua sendo o dono do arquivo no Drive.
int _indiceDentroDoBalde(AgeBucket balde, DateTime data) {
  final DateTime dia = AgeCalculator.dayOf(data);
  final DateTime inicio = AgeCalculator.dayOf(balde.start);

  if (!dia.isAfter(inicio)) return 1;

  if (balde.unit == AgeBucketUnit.month) {
    final int dias = dia.difference(inicio).inDays;
    return (dias ~/ _diasDaSemana) + 1;
  }

  // Ano: quantos meses inteiros se passaram desde o começo da pasta.
  int meses = (dia.year - inicio.year) * 12 + (dia.month - inicio.month);
  if (dia.day < inicio.day) meses--;
  return meses < 0 ? 1 : meses + 1;
}
