import 'dart:async';

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Os idiomas que o aplicativo oferece.
///
/// A ordem aqui **é** a ordem do seletor: as telas de configurações e de
/// cadastro percorrem `Idioma.values` direto, sem lista própria. Trocar a
/// ordem declarada troca a ordem que a pessoa vê, e é por isso que ela segue
/// exatamente o pedido: inglês, português, espanhol, francês, alemão,
/// italiano.
///
/// Cada idioma novo é um documento jurídico a mais para manter em dia
/// (termos, política e exclusão) em cada uma das seis línguas, e um texto
/// legal desatualizado é pior que um idioma a menos. A garantia de que
/// nenhuma fica pela metade é o compilador: `TextosEs implements Textos` não
/// compila com um texto faltando.
enum Idioma {
  ingles('en', 'English', 'English'),
  portugues('pt', 'Português', 'Português (Brasil)'),
  espanhol('es', 'Español', 'Español'),
  frances('fr', 'Français', 'Français'),
  alemao('de', 'Deutsch', 'Deutsch'),
  italiano('it', 'Italiano', 'Italiano');

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

  /// A localidade que o Flutter usa para os textos dele: o calendário, o
  /// menu de recortar e colar, o leitor de tela.
  Locale get localidade => switch (this) {
    Idioma.portugues => const Locale('pt', 'BR'),
    Idioma.ingles => const Locale('en'),
    Idioma.espanhol => const Locale('es'),
    Idioma.frances => const Locale('fr'),
    Idioma.alemao => const Locale('de'),
    Idioma.italiano => const Locale('it'),
  };

  static Idioma deCodigo(String? codigo) => values.firstWhere(
    (Idioma i) => i.codigo == codigo,
    orElse: () => Idioma.portugues,
  );
}

/// O idioma escolhido, guardado no aparelho.
///
/// Fica no aparelho e não na conta, como as demais preferências de interface:
/// é a língua de quem está segurando o telefone, e não um dado da criança.
final NotifierProvider<IdiomaNotifier, Idioma> idiomaProvider =
    NotifierProvider<IdiomaNotifier, Idioma>(IdiomaNotifier.new);

class IdiomaNotifier extends Notifier<Idioma> {
  static const String chave = 'idioma';

  /// A escolha lida do disco antes do primeiro quadro.
  ///
  /// [build] é síncrono e o disco não é. Sem esta semente, o primeiro quadro
  /// nasce na língua do aparelho e a escolha guardada chega um quadro
  /// depois: quem escolheu alemão vê o aplicativo abrir em português e virar
  /// em seguida, e essa virada ainda refaz o roteador à toa.
  ///
  /// Esquecer de semear não deixa o aplicativo na língua errada, só o faz
  /// piscar: a escolha chega mesmo assim, um quadro depois, e agora o
  /// roteador acompanha.
  static Idioma? _semente;

  /// Lê a escolha guardada. `main()` chama isto antes de `runApp`.
  static Future<void> semearDoDisco() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? guardado = prefs.getString(chave);
      if (guardado != null) _semente = Idioma.deCodigo(guardado);
    } on Object {
      // Fica no que o aparelho sugerir.
    }
  }

  /// A semente é estática e atravessaria de um teste para o outro.
  @visibleForTesting
  static void esquecerSemente() => _semente = null;

  @override
  Idioma build() {
    final Idioma? semeado = _semente;
    if (semeado != null) return semeado;
    unawaited(_carregar());
    return doAparelho();
  }

  /// A língua do próprio aparelho, quando ninguém escolheu ainda.
  ///
  /// Sem isto, quem tem o celular em inglês via a apresentação e a tela de
  /// entrada em português, e só conseguia trocar depois de já ter criado a
  /// conta. Uma tela de boas-vindas que a pessoa não lê é a pior primeira
  /// impressão possível.
  ///
  /// Qualquer língua que não seja uma das oferecidas cai no português, que é
  /// o texto original do produto.
  @visibleForTesting
  static Idioma doAparelho([Locale? locale]) {
    final Locale l =
        locale ??
        PlatformDispatcher.instance.locales.firstOrNull ??
        const Locale('pt');
    return Idioma.values.firstWhere(
      (Idioma i) => i.codigo == l.languageCode,
      orElse: () => Idioma.portugues,
    );
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
      final String? guardado = prefs.getString(chave);
      // Só sobrescreve quando **há** escolha guardada. Sem esta guarda, o
      // disco responder vazio jogaria de volta para o português quem tem o
      // aparelho em inglês e ainda não escolheu nada.
      if (guardado != null) state = Idioma.deCodigo(guardado);
    } on Object {
      // Fica no que o aparelho sugeriu.
    }
  }

  Future<void> escolher(Idioma idioma) async {
    state = idioma;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(chave, idioma.codigo);
  }
}
