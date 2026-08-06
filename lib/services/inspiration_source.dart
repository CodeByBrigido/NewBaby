import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

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
    return parseInspirations(cru);
  }
}

/// Separado da leitura do arquivo para que o teste consiga exercitar o
/// mesmo caminho sem depender do carregador de assets do Flutter.
List<Inspiration> parseInspirations(String json) {
  return (jsonDecode(json) as List<Object?>)
      .whereType<Map<String, Object?>>()
      .map(Inspiration.fromMap)
      .toList();
}

/// O que já foi lido.
///
/// Fica no aparelho, e não no Firestore, porque é preferência de leitura e
/// não memória: não vale um documento por pessoa nem uma sincronização.
class ReadInspirations {
  const ReadInspirations(this._prefs);

  static const String _chave = 'inspiracoes_lidas';

  final SharedPreferences _prefs;

  Set<String> get ids => <String>{...?_prefs.getStringList(_chave)};

  Future<void> markRead(String id) async {
    final Set<String> atual = ids..add(id);
    await _prefs.setStringList(_chave, atual.toList());
  }
}
