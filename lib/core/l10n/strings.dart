import 'textos.dart';
import 'textos_de.dart';
import 'textos_en.dart';
import 'textos_es.dart';
import 'textos_fr.dart';
import 'textos_it.dart';
import 'textos_pt.dart';

export 'textos.dart';

/// O texto do aplicativo, no idioma ativo.
///
/// Continua se chamando `S` porque é assim que as chamadas espalhadas pelo
/// aplicativo o escrevem, e trocar o nome delas seria trocar centenas de
/// linhas para não ganhar nada. O que mudou por baixo é que `S` deixou de ser
/// uma classe de constantes e passou a ser esta função, que devolve a
/// implementação da língua escolhida.
///
/// **A consequência prática:** texto não é mais `const`. Um `const Text(S.x)`
/// não compila, e é isso que se quer, porque o valor passa a depender de uma
/// escolha feita em tempo de execução. Onde o `const` saiu, o widget continua
/// idêntico.
// ignore: non_constant_identifier_names
Textos get S => _ativo;

Textos _ativo = const TextosPt();

/// Troca a língua de todo o aplicativo.
///
/// **Trocar aqui não redesenha nada sozinho.** Quem chama é o
/// `idiomaProvider`, e a tela só passa a mostrar a língua nova porque a raiz
/// do aplicativo se refaz inteira quando o idioma muda. Sem essa parte, esta
/// função trocaria o texto que ainda não foi desenhado e deixaria na tela o
/// que já estava lá.
void definirTextos(Textos textos) => _ativo = textos;

/// O código da língua ativa: `pt`, `en`, `es`, `fr`, `de` ou `it`.
///
/// Existe para quem precisa escolher entre implementações sem comparar texto
/// traduzido nem testar `is TextosEn` uma língua de cada vez. `Copy` e os
/// documentos públicos usam isto para escolher a versão certa entre seis, em
/// vez de um booleano que só sabia responder sim ou não para o inglês.
String get codigoAtivo => _ativo.codigo;

/// As seis implementações, para quem precisa de uma delas sem trocar a
/// ativa, ou de percorrer todas de uma vez.
///
/// Os testes usam isto para comparar as línguas lado a lado, que é o jeito
/// de garantir que nenhuma frase ficou para trás.
const Textos textosPt = TextosPt();
const Textos textosEn = TextosEn();
const Textos textosEs = TextosEs();
const Textos textosFr = TextosFr();
const Textos textosDe = TextosDe();
const Textos textosIt = TextosIt();

const List<Textos> todasAsTextos = <Textos>[
  textosPt,
  textosEn,
  textosEs,
  textosFr,
  textosDe,
  textosIt,
];

/// A implementação de um código guardado, com o português como piso.
///
/// Cápsula antiga não tem o campo salvo em lugar nenhum que dependa disto, e
/// um código desconhecido (aparelho numa língua que o aplicativo não
/// oferece) cai na língua original do produto, e não trava nem escolhe uma
/// língua ao acaso.
Textos textosPara(String? codigo) => todasAsTextos.firstWhere(
  (Textos t) => t.codigo == codigo,
  orElse: () => textosPt,
);
