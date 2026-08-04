import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/inspiration.dart';

/// De onde vem o conteúdo das inspirações.
///
/// A interface existe para que trocar o arquivo local por uma chamada de
/// rede seja trocar uma classe, sem tocar na tela. O feed não sabe nem
/// precisa saber de onde o conteúdo veio.
abstract interface class InspirationSource {
  Future<List<Inspiration>> load();
}

/// Conteúdo que viaja dentro do aplicativo.
///
/// É de propósito, e não só um provisório: assim o feed funciona sem rede,
/// sem custo de servidor e sem mandar para lugar nenhum a idade da criança,
/// que é o que uma consulta a um backend inevitavelmente entregaria.
class AssetInspirationSource implements InspirationSource {
  const AssetInspirationSource({this.path = 'assets/inspiracoes.json'});

  final String path;

  @override
  Future<List<Inspiration>> load() async {
    final String cru = await rootBundle.loadString(path);
    final List<Object?> lista = jsonDecode(cru) as List<Object?>;
    return lista
        .whereType<Map<String, Object?>>()
        .map(Inspiration.fromMap)
        .toList();
  }
}

/// Escolhe e ordena o que mostrar para uma idade.
///
/// Fica fora da tela e fora da fonte: é a única parte com regra de verdade,
/// e é a que precisa de teste.
List<Inspiration> pickForAge(List<Inspiration> todas, int ageDays) {
  final List<Inspiration> cabem = todas
      .where((Inspiration i) => i.appliesAt(ageDays))
      .toList();

  cabem.sort((Inspiration a, Inspiration b) {
    // O que foi escrito para esta fase vem antes do que só por acaso ainda
    // cabe. Empate desempata pelo id, para a ordem não dançar a cada abertura.
    final int porRelevancia = b
        .relevanceAt(ageDays)
        .compareTo(a.relevanceAt(ageDays));
    return porRelevancia != 0 ? porRelevancia : a.id.compareTo(b.id);
  });
  return cabem;
}
