import 'package:meta/meta.dart';

/// Um item já com o tamanho que vai ocupar na tela.
@immutable
class LadrilhoDoMosaico<T> {
  const LadrilhoDoMosaico({
    required this.item,
    required this.largura,
    required this.altura,
  });

  final T item;
  final double largura;
  final double altura;
}

/// Uma faixa horizontal de itens, todos com a mesma altura.
@immutable
class LinhaDoMosaico<T> {
  const LinhaDoMosaico({required this.ladrilhos, required this.altura});

  final List<LadrilhoDoMosaico<T>> ladrilhos;
  final double altura;
}

/// Um mês do acervo, com o título que aparece no cabeçalho.
@immutable
class MesDoMosaico<T> {
  const MesDoMosaico({
    required this.mes,
    required this.linhas,
    required this.quantos,
  });

  /// Primeiro dia do mês, para formatar o título e para o rolador lateral.
  final DateTime mes;

  final List<LinhaDoMosaico<T>> linhas;

  /// Quantos itens o mês tem, somando todas as linhas.
  final int quantos;
}

/// Monta o acervo em linhas justificadas, agrupadas por mês do calendário.
///
/// É o desenho do Google Fotos, e o que ele resolve é real: numa grade de
/// quadrados iguais toda foto é recortada, e uma paisagem vira um pedaço do
/// meio. Aqui cada foto mantém a própria proporção, e o que se ajusta é a
/// altura da linha.
///
/// ## Como a linha se fecha
///
/// Os itens vão entrando na linha, e a cada entrada a altura que a linha
/// teria para preencher a largura toda diminui. Quando ela cai abaixo de
/// [alturaAlvo], a linha está cheia e fecha. Assim toda linha ocupa a
/// largura inteira e nenhuma fica alta demais.
///
/// A última linha do mês é a exceção: ela quase nunca tem itens suficientes
/// para preencher a largura. Esticá-la faria uma foto sozinha virar um
/// pôster no fim de todo mês, então ela fica na altura alvo e sobra espaço à
/// direita, que é o que o olho espera de uma lista que acabou.
///
/// ## Por que é função pura
///
/// Layout que se decide no `build` só se verifica olhando a tela, e olhar a
/// tela é justamente o que não dá para automatizar. Aqui a conta sai
/// separada: dá para perguntar quantas linhas um mês tem, se a soma das
/// larguras fecha a largura disponível, e o que acontece com uma foto sem
/// dimensão gravada.
List<MesDoMosaico<T>> mosaico<T>({
  required List<T> itens,
  required DateTime Function(T) quando,
  required double Function(T) proporcao,
  required double largura,
  required double alturaAlvo,
  required double espaco,
}) {
  if (itens.isEmpty || largura <= 0) return const <Never>[];

  // Do mais recente para o mais antigo, como o resto do aplicativo.
  final List<T> ordenados = <T>[...itens]
    ..sort((T a, T b) => quando(b).compareTo(quando(a)));

  final List<MesDoMosaico<T>> meses = <MesDoMosaico<T>>[];
  List<T> doMes = <T>[];
  DateTime? mesAtual;

  void fechar() {
    final DateTime? mes = mesAtual;
    if (mes == null || doMes.isEmpty) return;
    meses.add(
      MesDoMosaico<T>(
        mes: mes,
        quantos: doMes.length,
        linhas: _linhas<T>(
          itens: doMes,
          proporcao: proporcao,
          largura: largura,
          alturaAlvo: alturaAlvo,
          espaco: espaco,
        ),
      ),
    );
    doMes = <T>[];
  }

  for (final T item in ordenados) {
    final DateTime d = quando(item);
    final DateTime mes = DateTime(d.year, d.month);
    if (mesAtual != mes) {
      fechar();
      mesAtual = mes;
    }
    doMes.add(item);
  }
  fechar();

  return meses;
}

/// Quebra os itens de um mês em linhas justificadas.
List<LinhaDoMosaico<T>> _linhas<T>({
  required List<T> itens,
  required double Function(T) proporcao,
  required double largura,
  required double alturaAlvo,
  required double espaco,
}) {
  final List<LinhaDoMosaico<T>> linhas = <LinhaDoMosaico<T>>[];
  final List<T> atual = <T>[];
  double somaDasProporcoes = 0;

  /// A altura que a linha teria para preencher a largura exatamente.
  ///
  /// Cada item ocupa `altura * proporção`, e entre eles há o espaço. Daí:
  /// `largura = altura * soma + espaço * (n - 1)`.
  double alturaPara(int quantos, double soma) =>
      soma <= 0 ? alturaAlvo : (largura - espaco * (quantos - 1)) / soma;

  void fecharLinha({required bool ultima}) {
    if (atual.isEmpty) return;
    // A última fica na altura alvo: esticá-la faria uma foto sozinha virar
    // um pôster no fim do mês.
    final double altura = ultima
        ? alturaAlvo
        : alturaPara(atual.length, somaDasProporcoes);

    linhas.add(
      LinhaDoMosaico<T>(
        altura: altura,
        ladrilhos: <LadrilhoDoMosaico<T>>[
          for (final T item in atual)
            LadrilhoDoMosaico<T>(
              item: item,
              largura: altura * proporcao(item),
              altura: altura,
            ),
        ],
      ),
    );
    atual.clear();
    somaDasProporcoes = 0;
  }

  for (final T item in itens) {
    final double prop = proporcao(item);
    final double comEle = alturaPara(
      atual.length + 1,
      somaDasProporcoes + prop,
    );

    // O item cabe sem derrubar a linha abaixo do alvo: entra e segue.
    if (atual.isEmpty || comEle >= alturaAlvo) {
      atual.add(item);
      somaDasProporcoes += prop;
      continue;
    }

    // Aqui a linha fecha, e a escolha é onde: com este item dentro, ficando
    // mais baixa que o alvo, ou sem ele, ficando mais alta.
    //
    // Fechar sempre com ele dentro é o erro fácil, e ele aparece em linha de
    // poucas fotos: com três paisagens numa tela estreita a linha desabava a
    // dois terços da altura pedida, e a diferença entre uma linha e a
    // seguinte ficava gritante. Ganha a que erra menos.
    final double semEle = alturaPara(atual.length, somaDasProporcoes);
    if ((semEle - alturaAlvo).abs() <= (alturaAlvo - comEle).abs()) {
      fecharLinha(ultima: false);
      atual.add(item);
      somaDasProporcoes = prop;
    } else {
      atual.add(item);
      somaDasProporcoes += prop;
      fecharLinha(ultima: false);
    }
  }

  fecharLinha(ultima: true);

  return linhas;
}

/// A proporção de uma foto, com um piso e um teto.
///
/// Foto sem dimensão gravada volta quadrada: é o que a versão antiga do
/// aplicativo enviava, e um acervo com anos de história tem dessas.
///
/// Os limites existem para o panorama e para a foto de documento em pé. Sem
/// eles, um panorama de 6:1 sozinho preencheria a linha inteira e ficaria
/// com uma faixa de altura ridícula, e uma foto muito alta empurraria a
/// linha para fora da tela.
double proporcaoSegura(int? largura, int? altura) {
  if (largura == null || altura == null || largura <= 0 || altura <= 0) {
    return 1;
  }
  return (largura / altura).clamp(0.5, 2.5);
}

/// Onde um mês começa e quanto ele ocupa na rolagem.
///
/// Medido antes de desenhar, e não durante a rolagem. A lista é preguiçosa:
/// só existe o que está na tela, então perguntar a posição de um mês que
/// ainda não foi desenhado não tem resposta. E o rolador lateral precisa
/// saber onde cada ano cai **antes** de alguém arrastar.
@immutable
class FaixaDeMes {
  const FaixaDeMes({
    required this.mes,
    required this.inicio,
    required this.altura,
  });

  final DateTime mes;

  /// Deslocamento em que a faixa começa, contado do topo da lista.
  final double inicio;
  final double altura;

  double get fim => inicio + altura;
}

/// Qual mês está no topo da área visível, para a bolha flutuante.
///
/// Devolve `null` só quando não há faixa nenhuma. Antes do começo da lista
/// vale a primeira faixa, e depois do fim vale a última: rolagem elástica
/// passa dos dois lados, e uma bolha que apaga ao esticar a lista pisca sem
/// motivo justamente quando o dedo ainda está na tela.
DateTime? mesEm(List<FaixaDeMes> faixas, double deslocamento) {
  if (faixas.isEmpty) return null;

  DateTime achado = faixas.first.mes;
  for (final FaixaDeMes f in faixas) {
    // A tolerância existe porque a soma das alturas acumula erro de ponto
    // flutuante ao longo de dezenas de meses, e sem ela o mês trocaria um
    // pixel antes ou depois da linha divisória.
    if (deslocamento >= f.inicio - 0.5) {
      achado = f.mes;
    } else {
      break;
    }
  }
  return achado;
}
