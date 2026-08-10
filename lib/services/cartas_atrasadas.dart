import '../models/entry.dart';

/// Grava no Drive o `.txt` das cartas escritas antes de o arquivo existir.
///
/// A carta passou a virar arquivo depois de as primeiras já terem sido
/// escritas. Quem usava o aplicativo antes disso tem cartas que só existem no
/// índice, e são justamente elas as memórias que morreriam junto com o
/// aplicativo: foto e vídeo já sobrevivem sozinhos, porque são arquivos numa
/// pasta.
///
/// Duas decisões definem esta classe.
///
/// **A lista entra pronta.** Ela é a mesma que a linha do tempo já tem em
/// memória, e não uma consulta nova. Perguntar ao Firestore custaria uma
/// leitura por carta a cada abertura, quase sempre para não achar nada; aqui
/// o custo é zero até haver trabalho de verdade.
///
/// **Não há marca de "já rodou".** A marca é o próprio dado: carta com
/// arquivo está pronta, carta sem arquivo não está. Uma falha de rede se
/// conserta na abertura seguinte sem ninguém precisar lembrar, e uma marca
/// gravada cedo demais deixaria a carta sem arquivo para sempre.
class CartasAtrasadas {
  CartasAtrasadas(this._gravar);

  /// Grava uma carta e devolve a versão com o id do arquivo.
  ///
  /// Devolver a carta igual significa que não deu: quem implementa engole o
  /// erro, porque o texto já está no índice e é de lá que o aplicativo lê.
  final Future<Entry> Function(Entry carta) _gravar;

  /// Quantas cartas cada abertura tenta gravar.
  ///
  /// O limite existe para a primeira abertura de quem tem um acervo antigo
  /// não virar uma rajada de uploads, possivelmente numa conexão que a
  /// pessoa paga por megabyte. O que sobra vai na próxima abertura, e em
  /// poucos dias a conta fecha sozinha.
  static const int porVez = 25;

  bool _emAndamento = false;

  /// As cartas que ainda não têm arquivo, das mais antigas primeiro.
  ///
  /// Da mais antiga porque, se o trabalho for interrompido no meio, o que
  /// ficou para trás é o registro mais recente, que é o mais fácil de
  /// reescrever de memória.
  static List<Entry> pendentes(List<Entry> entradas) =>
      entradas
          .where(
            (Entry e) =>
                e.type == EntryType.letter &&
                (e.textFileId == null || e.textFileId!.isEmpty),
          )
          .toList()
        ..sort((Entry a, Entry b) => a.date.compareTo(b.date));

  /// Grava o que está atrasado e devolve quantas cartas foram gravadas.
  ///
  /// Chamado a cada mudança na linha do tempo, e cada gravação muda a linha
  /// do tempo: sem a trava, uma chamada entraria por cima da anterior e a
  /// mesma carta viraria dois arquivos na pasta.
  Future<int> gravar(List<Entry> entradas) async {
    if (_emAndamento) return 0;

    final List<Entry> fila = pendentes(entradas);
    if (fila.isEmpty) return 0;

    _emAndamento = true;
    try {
      int gravadas = 0;
      for (final Entry carta in fila.take(porVez)) {
        final Entry depois = await _gravar(carta);
        if (depois.textFileId != null && depois.textFileId!.isNotEmpty) {
          gravadas++;
        }
      }
      return gravadas;
    } finally {
      _emAndamento = false;
    }
  }
}
