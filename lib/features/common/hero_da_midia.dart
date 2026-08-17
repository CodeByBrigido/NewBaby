/// A miniatura crescendo até virar a foto em tela cheia.
///
/// Não é enfeite: é o que diz **qual** foto foi aberta. Sem o voo, a tela
/// cheia aparece do nada e a pessoa perde o lugar de onde veio, ainda mais
/// numa grade de dezesseis miniaturas parecidas.
library;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../models/entry.dart';

/// As telas que abrem mídia em tela cheia.
///
/// Constantes, e não texto solto no lugar da chamada: origem e destino
/// precisam combinar exatamente, e um erro de digitação aqui não daria erro
/// de compilação, só um voo que não acontece.
const String origemDetalhe = 'detalhe';
const String origemGaleria = 'galeria';
const String origemDesenhos = 'desenhos';

/// Etiqueta do voo, por arquivo e por tela de origem.
///
/// O prefixo não é capricho. A casca do aplicativo é um `IndexedStack`, e as
/// abas continuam montadas quando não estão à frente: a mesma foto pode
/// estar viva na linha do tempo e na galeria ao mesmo tempo. Duas etiquetas
/// iguais na árvore é `assert` do Flutter, e ele derruba a tela em vez de
/// escolher uma. Já com o prefixo, cada tela voa para a sua.
///
/// O identificador cai no caminho local enquanto o arquivo não subiu, que é
/// justamente quando ele ainda não tem id no Drive.
String etiquetaDaMidia(String origem, EntryFile file) {
  final String id = file.driveId.isNotEmpty
      ? file.driveId
      : (file.localPath ?? file.name);
  return 'midia:$origem:$id';
}

/// Abre a tela cheia com o voo da miniatura.
///
/// A rota é própria, e não a padrão do Material, por dois motivos. O tempo
/// do voo é o `Motion.hero` do Design System, e não os 300 ms fixos do
/// Material. E quem desligou animações no aparelho recebe duração zero: o
/// `Hero` tira o tempo de voo da rota, então zerar aqui desliga o voo sem
/// precisar de um caminho separado.
///
/// A tela de baixo esmaece em vez de deslizar. Deslizar competiria com a
/// miniatura que está crescendo, e o olho não sabe qual dos dois seguir.
Future<void> abrirEmTelaCheia(BuildContext context, Widget tela) {
  final bool semAnimacao = MediaQuery.disableAnimationsOf(context);
  final Duration tempo = semAnimacao ? Duration.zero : Motion.hero;

  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: tempo,
      reverseTransitionDuration: tempo,
      pageBuilder:
          (BuildContext context, Animation<double> _, Animation<double> _) =>
              tela,
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animacao,
            Animation<double> _,
            Widget filho,
          ) => FadeTransition(
            opacity: CurvedAnimation(parent: animacao, curve: Motion.padrao),
            child: filho,
          ),
    ),
  );
}

/// Envolve a miniatura no voo.
///
/// Fica separado do widget da imagem de propósito: nem toda miniatura abre
/// em tela cheia (a do cartão de crescimento, por exemplo, leva para o
/// gráfico), e um `Hero` sem par do outro lado é um voo que começa e morre
/// no meio.
class HeroDaMidia extends StatelessWidget {
  const HeroDaMidia({
    required this.origem,
    required this.file,
    required this.child,
    this.ativo = true,
    super.key,
  });

  final String origem;
  final EntryFile file;
  final Widget child;

  /// Se esta cópia é a que pode voar.
  ///
  /// Existe para o visualizador, onde três páginas ficam montadas ao mesmo
  /// tempo e só a que está à frente tem par do outro lado.
  ///
  /// **Desligar é diferente de tirar da árvore, e a diferença era um defeito
  /// visível.** O visualizador envolvia no voo só a página aberta e deixava
  /// as vizinhas sem envoltório nenhum. A cada deslize a forma da árvore
  /// mudava nas duas páginas, o Flutter desmontava e remontava o que havia
  /// ali dentro, e a imagem recomeçava o download: dava um piscar, como se a
  /// foto fechasse e abrisse.
  ///
  /// Com a etiqueta apenas trocando, o `Hero` continua sendo o mesmo widget
  /// no mesmo lugar, e o que está dentro dele sobrevive intacto.
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    final String etiqueta = etiquetaDaMidia(origem, file);
    return Hero(
      // Parada, a etiqueta ganha um sufixo que não existe em tela nenhuma:
      // sem par, não há voo. É o mesmo efeito de não ter `Hero`, sem o custo
      // de mudar a forma da árvore.
      tag: ativo ? etiqueta : '$etiqueta:parado',
      // Durante o voo a imagem sai do cartão e passa a ser desenhada sozinha
      // sobre a tela. Sem isto ela herda o retângulo da miniatura e pisca de
      // um recorte para o outro no meio do caminho.
      flightShuttleBuilder:
          (
            BuildContext _,
            Animation<double> _,
            HeroFlightDirection _,
            BuildContext contextoDeOrigem,
            BuildContext _,
          ) => contextoDeOrigem.widget,
      child: child,
    );
  }
}
