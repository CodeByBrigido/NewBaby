import 'dart:convert';

import 'package:flutter/services.dart' show AssetManifest, rootBundle;
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
/// É de propósito, e não um provisório: assim o blog funciona sem rede, sem
/// custo de servidor e sem mandar para lugar nenhum a idade da criança, que
/// é o que uma consulta a um backend inevitavelmente entregaria.
///
/// Uma postagem é **um arquivo**, `assets/inspiracoes/<id>.json`, com a capa
/// ao lado dela como `<id>.webp`. Não há catálogo central para editar, não
/// há id para inventar (o nome do arquivo é o id) e não há linha para
/// acrescentar no `pubspec.yaml`: a pasta inteira já está declarada, e o
/// [AssetManifest] descobre em tempo de execução o que existe dentro dela.
///
/// Publicar uma postagem é soltar dois arquivos com o mesmo nome na pasta.
class AssetInspirationSource implements InspirationSource {
  const AssetInspirationSource({this.pasta = 'assets/inspiracoes/'});

  final String pasta;

  @override
  Future<List<Inspiration>> load() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );

    final List<String> arquivos =
        manifest
            .listAssets()
            .where((String a) => a.startsWith(pasta) && a.endsWith('.json'))
            .toList()
          // Ordem estável, para a lista não depender do sistema de arquivos
          // de quem compilou.
          ..sort();

    final List<Inspiration> postagens = <Inspiration>[];
    for (final String arquivo in arquivos) {
      final String cru = await rootBundle.loadString(arquivo);
      postagens.add(
        parseInspiration(cru, id: idDoArquivo(arquivo, pasta: pasta)),
      );
    }
    return postagens;
  }
}

/// O id de uma postagem é o nome do arquivo, sem pasta e sem extensão.
String idDoArquivo(String caminho, {String pasta = 'assets/inspiracoes/'}) {
  final String semPasta = caminho.startsWith(pasta)
      ? caminho.substring(pasta.length)
      : caminho;
  return semPasta.endsWith('.json')
      ? semPasta.substring(0, semPasta.length - '.json'.length)
      : semPasta;
}

/// Separado da leitura do arquivo para que o teste consiga exercitar o mesmo
/// caminho sem depender do carregador de assets do Flutter.
Inspiration parseInspiration(String json, {required String id}) =>
    Inspiration.fromMap(
      (jsonDecode(json) as Map<Object?, Object?>).cast<String, Object?>(),
      id: id,
    );

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
