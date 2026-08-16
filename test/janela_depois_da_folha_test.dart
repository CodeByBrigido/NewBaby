import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A janela do envio precisa sobreviver ao fechamento da folha.
///
/// O defeito: mandar uma foto fechava a folha de adicionar e nenhuma janela
/// aparecia, nem a de progresso nem a de "Guardado". O envio acontecia, a
/// foto chegava ao Drive, e a pessoa não via nada.
///
/// A causa é uma armadilha do Flutter que não dá erro nenhum. O `context` de
/// dentro da folha pertence à rota da folha. Fechar a folha desmonta essa
/// rota, e a partir daí o `context.mounted` é falso: qualquer coisa agendada
/// depois do fechamento sai calada pelo próprio guarda de segurança. Não é
/// exceção, não é aviso, é uma função que simplesmente retorna.
///
/// O que separa o fechar da folha da janela é o envio, que demora bem mais
/// que a animação de fechamento. O conserto é guardar o `NavigatorState` da
/// raiz antes do `pop`: ele não é o que está sendo fechado, e continua vivo.
void main() {
  /// Monta uma folha que se fecha e, depois do envio, tenta abrir a janela do
  /// desfecho. É o mesmo desenho do envio de verdade.
  Future<void> enviar(WidgetTester tester, {required bool pelaRaiz}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext daFolha) => Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final NavigatorState raiz = Navigator.of(
                          daFolha,
                          rootNavigator: true,
                        );
                        Navigator.of(daFolha).pop();

                        // O envio. Um segundo é pouco para uma foto e é muito
                        // mais que a animação de fechamento da folha, que é o
                        // ponto: quando isto volta, a rota já foi descartada.
                        await Future<void>.delayed(const Duration(seconds: 1));

                        final BuildContext? vivo = pelaRaiz
                            ? (raiz.mounted ? raiz.context : null)
                            : (daFolha.mounted ? daFolha : null);
                        if (vivo == null) return;

                        await showDialog<void>(
                          context: vivo,
                          builder: (BuildContext _) =>
                              const AlertDialog(content: Text('Guardado')),
                        );
                      },
                      child: const Text('guardar'),
                    ),
                  ),
                ),
                child: const Text('adicionar'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('adicionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('guardar'));

    // A folha fecha inteira antes de o envio terminar. É essa ordem que faz o
    // defeito: com o envio instantâneo a rota ainda estaria de pé e a janela
    // abriria mesmo pelo contexto errado.
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  group('o contexto da folha', () {
    testWidgets('morre no fechamento, e a janela nunca abre', (
      WidgetTester tester,
    ) async {
      // Este é o defeito, reproduzido. Se um dia isto passar a achar a
      // janela, o cuidado no código de envio deixou de ser necessário; até
      // lá, ele é a única coisa entre a pessoa e um envio silencioso.
      await enviar(tester, pelaRaiz: false);
      expect(find.text('Guardado'), findsNothing);
    });

    testWidgets('o navegador da raiz sobrevive, e a janela abre', (
      WidgetTester tester,
    ) async {
      await enviar(tester, pelaRaiz: true);
      expect(find.text('Guardado'), findsOneWidget);
    });
  });

  group('a folha de adicionar', () {
    /// O arquivo sem comentário nenhum.
    ///
    /// Sem isto o teste se acusa sozinho: o código explica a armadilha
    /// citando o `pop` e o contexto, e uma varredura ingênua conta a
    /// explicação como se fosse código.
    String semComentarios(String codigo) => codigo
        .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
        .split('\n')
        .map((String linha) {
          final int barra = linha.indexOf('//');
          return barra == -1 ? linha : linha.substring(0, barra);
        })
        .join('\n');

    final String fonte = semComentarios(
      File('lib/features/shell/add_sheet.dart').readAsStringSync(),
    );

    /// O corpo de uma função, sem espaço nenhum.
    ///
    /// Os parênteses são percorridos antes das chaves porque um parâmetro
    /// nomeado também vem entre chaves: contar chaves desde o cabeçalho faria
    /// o corpo terminar na lista de parâmetros.
    String corpoDe(String assinatura) {
      final int cabecalho = fonte.indexOf(assinatura);
      expect(cabecalho, isNot(-1), reason: 'não achei `$assinatura`');

      int parenteses = 0;
      int i = cabecalho;
      for (; i < fonte.length; i++) {
        if (fonte[i] == '(') parenteses++;
        if (fonte[i] == ')') {
          parenteses--;
          if (parenteses == 0) break;
        }
      }

      final int corpo = fonte.indexOf('{', i);
      expect(corpo, isNot(-1), reason: 'não achei o corpo de `$assinatura`');

      int chaves = 0;
      for (int j = corpo; j < fonte.length; j++) {
        if (fonte[j] == '{') chaves++;
        if (fonte[j] == '}') {
          chaves--;
          if (chaves == 0) {
            return fonte.substring(corpo, j + 1).replaceAll(RegExp(r'\s+'), '');
          }
        }
      }
      fail('não achei o fim de `$assinatura`');
    }

    /// Os dois caminhos que fecham a folha e depois mostram a janela.
    final Map<String, String> caminhos = <String, String>{
      'o envio comum': 'Future<Entry?> _send(',
      'o envio de documentos': 'Future<void> _addDocuments(',
    };

    for (final MapEntry<String, String> caminho in caminhos.entries) {
      test('${caminho.key} abre a janela pela raiz', () {
        final String corpo = corpoDe(caminho.value);

        expect(
          corpo,
          contains('mostrarEnvio(raiz.context'),
          reason:
              'A janela precisa nascer de um contexto que sobreviva à folha.',
        );
        expect(
          corpo,
          isNot(contains('mostrarEnvio(context')),
          reason:
              'Esse contexto é o da folha que acabou de ser fechada: a janela '
              'não abre e nada avisa.',
        );
      });

      test('${caminho.key} guarda o navegador antes de fechar a folha', () {
        // A ordem é o conserto inteiro. Depois do fechamento o `Navigator.of`
        // ainda devolve um estado, mas quem chama já saiu na porta do
        // `mounted` e a janela não chega a ser pedida.
        final String corpo = corpoDe(caminho.value);

        final int guardou = corpo.indexOf('NavigatorStateraiz=Navigator.of(');
        expect(guardou, isNot(-1), reason: 'o navegador da raiz some');

        for (final String fecha in <String>['.pop()', '.maybePop()']) {
          final int fechou = corpo.indexOf(fecha);
          if (fechou == -1) continue;
          expect(
            guardou,
            lessThan(fechou),
            reason: 'Guardar depois de `$fecha` não conserta nada.',
          );
        }
      });
    }

    test('o envio de documentos abre uma janela só, e não uma por arquivo', () {
      // Documento é uma memória por arquivo. Uma janela por arquivo travaria
      // o envio do próximo até alguém fechar a anterior.
      final String corpo = corpoDe('Future<void> _addDocuments(');
      expect(corpo, contains('mostrarJanela:false'));
      expect(corpo, contains('entries:criadas'));
    });
  });
}
