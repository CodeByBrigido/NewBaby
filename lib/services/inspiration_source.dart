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

  static const String chave = 'inspiracoes_lidas';

  final SharedPreferences _prefs;

  Set<String> get ids => <String>{...?_prefs.getStringList(chave)};

  Future<void> markRead(String id) async {
    final Set<String> atual = ids..add(id);
    await _prefs.setStringList(chave, atual.toList());
  }
}

/// O que já apareceu na lista, tenha sido aberto ou não.
///
/// Separado de [ReadInspirations] porque responde a outra pergunta. "Lida"
/// é sobre consumir o conteúdo, e alimenta os lembretes. "Vista" é sobre o
/// selo de novidade, e a pergunta ali é apenas: **isto já estava aqui da
/// última vez que você olhou?**
///
/// Antes o selo dizia "Novo" para tudo o que não tinha sido aberto. Quem
/// nunca abriu nenhuma via "Novo" em todas as sugestões, para sempre, e um
/// selo que marca a lista inteira não informa nada: é ruído com cara de
/// aviso. Ler o título e decidir que aquilo não era para hoje é uma resposta
/// legítima, e não pode deixar a etiqueta acesa até o fim dos tempos.
class InspiracoesVistas {
  const InspiracoesVistas(this._prefs);

  static const String chave = 'inspiracoes_vistas';

  final SharedPreferences _prefs;

  Set<String> get ids => <String>{...?_prefs.getStringList(chave)};

  Future<void> marcar(Iterable<String> novos) async {
    final Set<String> atual = ids..addAll(novos);
    await _prefs.setStringList(chave, atual.toList());
  }
}
