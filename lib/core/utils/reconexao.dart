import 'dart:async';

/// Mantém um fluxo de dados vivo depois de um erro.
///
/// Um ouvinte do Firestore que falha **não volta sozinho**: o fluxo termina
/// ali, e a tela fica presa no erro até o aplicativo ser fechado e aberto.
/// Foi o que aconteceu quando faltava um índice: as memórias eram enviadas
/// e gravadas, e a linha do tempo só as mostrava no reinício seguinte, o
/// que parecia atraso quando na verdade era um ouvinte morto.
///
/// O erro continua chegando à tela, de propósito: esconder a falha e girar
/// para sempre seria pior que mostrá-la. O que muda é que a tentativa
/// seguinte acontece sozinha, então quando a causa passa (o índice terminou
/// de ser criado, a rede voltou) a tela se conserta sem ninguém tocar nela.
///
/// A espera dobra a cada falha, até o teto. Um erro que não passa vira uma
/// tentativa a cada [limite], e não uma enxurrada de leituras cobradas.
Stream<T> comReconexao<T>(
  Stream<T> Function() abrir, {
  Duration espera = const Duration(seconds: 3),
  Duration limite = const Duration(minutes: 1),
}) {
  StreamSubscription<T>? assinatura;
  Timer? proxima;
  Duration atual = espera;
  late final StreamController<T> saida;

  void ouvir() {
    assinatura = abrir().listen(
      (T dado) {
        // Deu certo: a próxima falha recomeça a espera do começo, em vez de
        // herdar o teto de uma queda antiga.
        atual = espera;
        saida.add(dado);
      },
      onError: (Object erro, StackTrace pilha) {
        saida.addError(erro, pilha);
        assinatura?.cancel();
        assinatura = null;
        proxima = Timer(atual, ouvir);
        final Duration dobro = atual * 2;
        atual = dobro > limite ? limite : dobro;
      },
      onDone: () => saida.close(),
    );
  }

  saida = StreamController<T>(
    onListen: ouvir,
    onCancel: () {
      proxima?.cancel();
      final StreamSubscription<T>? atual = assinatura;
      assinatura = null;
      return atual?.cancel();
    },
  );

  return saida.stream;
}
