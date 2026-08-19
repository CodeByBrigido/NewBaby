import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Os idiomas que o aplicativo oferece.
///
/// A lista é curta de propósito. Cada idioma novo é um documento jurídico a
/// mais para manter em dia (termos, política e exclusão), e um texto legal
/// desatualizado é pior que um idioma a menos.
enum Idioma {
  portugues('pt', 'Português', 'Português (Brasil)'),
  ingles('en', 'English', 'English');

  const Idioma(this.codigo, this.nome, this.descricao);

  /// O código guardado no aparelho, e o mesmo que o Flutter usa em `Locale`.
  final String codigo;

  /// Como o idioma se chama **no próprio idioma**.
  ///
  /// Nunca traduzido: quem procura inglês numa tela em português procura por
  /// "English", e quem procura português numa tela em inglês procura por
  /// "Português". Traduzir o nome do idioma esconde a opção justamente de
  /// quem precisa dela.
  final String nome;

  final String descricao;

  static Idioma deCodigo(String? codigo) => values.firstWhere(
    (Idioma i) => i.codigo == codigo,
    orElse: () => Idioma.portugues,
  );
}

/// O idioma escolhido, guardado no aparelho.
///
/// Fica no aparelho e não na conta, como as demais preferências de interface:
/// é a língua de quem está segurando o telefone, e não um dado da criança.
///
/// **Hoje ele só guarda a escolha.** A interface e os documentos continuam em
/// português enquanto a tradução não existir, e a tela diz isso com todas as
/// letras. Guardar desde já é o que faz a tradução, quando chegar, encontrar
/// a preferência de cada pessoa já respondida em vez de perguntar de novo.
final NotifierProvider<IdiomaNotifier, Idioma> idiomaProvider =
    NotifierProvider<IdiomaNotifier, Idioma>(IdiomaNotifier.new);

class IdiomaNotifier extends Notifier<Idioma> {
  static const String chave = 'idioma';

  @override
  Idioma build() {
    unawaited(_carregar());
    return Idioma.portugues;
  }

  /// Lê a escolha do disco, e desiste em silêncio se não conseguir.
  ///
  /// O `catch` é largo porque esta leitura roda solta, sem ninguém esperando
  /// por ela: uma exceção aqui não teria quem a pegasse e derrubaria o quadro
  /// inteiro por causa de uma preferência de idioma. Sem a leitura, fica o
  /// português, que é onde ela já começa.
  Future<void> _carregar() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      state = Idioma.deCodigo(prefs.getString(chave));
    } on Object {
      // Fica no padrão.
    }
  }

  Future<void> escolher(Idioma idioma) async {
    state = idioma;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(chave, idioma.codigo);
  }
}
