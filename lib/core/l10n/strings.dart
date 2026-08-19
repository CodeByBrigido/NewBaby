import 'textos.dart';
import 'textos_en.dart';
import 'textos_pt.dart';

export 'textos.dart';

/// O texto do aplicativo, no idioma ativo.
///
/// Continua se chamando `S` porque é assim que as 236 chamadas espalhadas
/// pelo aplicativo o escrevem, e trocar o nome delas seria trocar 236 linhas
/// para não ganhar nada. O que mudou por baixo é que `S` deixou de ser uma
/// classe de constantes e passou a ser esta função, que devolve a
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

/// As duas implementações, para quem precisa de uma delas sem trocar a ativa.
///
/// Os testes usam isto para comparar as duas línguas lado a lado, que é o
/// jeito de garantir que nenhuma frase ficou para trás.
const Textos textosPt = TextosPt();
const Textos textosEn = TextosEn();
