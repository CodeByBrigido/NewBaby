import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/reconexao.dart';

/// A reconexão dos ouvintes do Firestore.
///
/// Um ouvinte que falha não volta sozinho: o fluxo termina ali. Sem esta
/// peça, a linha do tempo ficava presa no erro até o aplicativo ser fechado
/// e aberto, e quem enviava uma foto via o envio terminar e a lista não
/// mudar. Parecia atraso, e era um ouvinte morto.
void main() {
  group('o fluxo volta sozinho depois do erro', () {
    test('o erro chega à tela, e a tentativa seguinte também', () {
      fakeAsync((FakeAsync tempo) {
        int aberturas = 0;
        final Stream<int> fluxo = comReconexao<int>(() {
          aberturas++;
          // A primeira tentativa falha, como o índice que faltava.
          if (aberturas == 1) {
            return Stream<int>.error(StateError('sem índice'));
          }
          return Stream<int>.value(7);
        }, espera: const Duration(seconds: 3));

        final List<Object> recebidos = <Object>[];
        fluxo.listen(recebidos.add, onError: recebidos.add);

        tempo.flushMicrotasks();
        expect(
          recebidos.single,
          isA<StateError>(),
          reason: 'Esconder a falha e girar para sempre seria pior',
        );

        tempo.elapse(const Duration(seconds: 3));
        tempo.flushMicrotasks();
        expect(
          recebidos.last,
          7,
          reason:
              'A tela se conserta sem ninguém '
              'tocar nela quando a causa passa',
        );
        expect(aberturas, 2);
      });
    });

    test('a espera dobra, para um erro que não passa', () {
      fakeAsync((FakeAsync tempo) {
        int aberturas = 0;
        final Stream<int> fluxo = comReconexao<int>(
          () {
            aberturas++;
            return Stream<int>.error(StateError('nunca passa'));
          },
          espera: const Duration(seconds: 2),
          limite: const Duration(seconds: 8),
        );
        fluxo.listen((_) {}, onError: (_) {});

        tempo.flushMicrotasks();
        expect(aberturas, 1);

        tempo.elapse(const Duration(seconds: 2)); // 2s
        expect(aberturas, 2);
        tempo.elapse(const Duration(seconds: 4)); // +4s
        expect(aberturas, 3);
        tempo.elapse(const Duration(seconds: 8)); // +8s, já no teto
        expect(aberturas, 4);

        // O teto segura: sem ele, um erro permanente viraria uma enxurrada
        // de leituras cobradas.
        tempo.elapse(const Duration(seconds: 8));
        expect(aberturas, 5);
      });
    });

    test('depois de dar certo, a espera recomeça do começo', () {
      fakeAsync((FakeAsync tempo) {
        int aberturas = 0;
        late StreamController<int> vivo;
        final Stream<int> fluxo = comReconexao<int>(() {
          aberturas++;
          if (aberturas <= 2) {
            return Stream<int>.error(StateError('falha'));
          }
          vivo = StreamController<int>();
          return vivo.stream;
        }, espera: const Duration(seconds: 2));
        fluxo.listen((_) {}, onError: (_) {});

        tempo.elapse(const Duration(seconds: 2));
        tempo.elapse(const Duration(seconds: 4));
        expect(aberturas, 3);

        vivo.add(1); // deu certo: a espera volta a ser a inicial
        tempo.flushMicrotasks();
        vivo.addError(StateError('caiu de novo'));
        tempo.flushMicrotasks();

        tempo.elapse(const Duration(seconds: 2));
        expect(
          aberturas,
          4,
          reason: 'Uma queda nova não pode herdar o teto de uma queda antiga',
        );
      });
    });
  });

  group('o fluxo não deixa nada rodando para trás', () {
    test('cancelar a escuta cancela a próxima tentativa', () {
      fakeAsync((FakeAsync tempo) {
        int aberturas = 0;
        final Stream<int> fluxo = comReconexao<int>(() {
          aberturas++;
          return Stream<int>.error(StateError('falha'));
        }, espera: const Duration(seconds: 5));

        final StreamSubscription<int> assinatura = fluxo.listen(
          (_) {},
          onError: (_) {},
        );
        tempo.flushMicrotasks();
        expect(aberturas, 1);

        assinatura.cancel();
        tempo.elapse(const Duration(minutes: 5));
        expect(
          aberturas,
          1,
          reason:
              'Sair da tela e continuar reabrindo consulta é conta que '
              'ninguém pediu',
        );
      });
    });

    test('um fluxo que termina normalmente fecha, e não reabre', () async {
      // Sem `fakeAsync` aqui de propósito: o fechamento do controlador
      // acontece por microtarefa dentro da entrega de um evento, e o relógio
      // falso não a alcança. O comportamento é real, e o teste precisa
      // observá-lo no relógio de verdade.
      int aberturas = 0;
      final Stream<int> fluxo = comReconexao<int>(() {
        aberturas++;
        return Stream<int>.value(1);
      });

      bool fechou = false;
      fluxo.listen((_) {}, onDone: () => fechou = true);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fechou, isTrue);
      expect(
        aberturas,
        1,
        reason: 'Fim normal não é falha: reabrir aqui seria um laço eterno',
      );
    });
  });
}
