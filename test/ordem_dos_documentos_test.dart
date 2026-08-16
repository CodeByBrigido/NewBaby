import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/ordem_dos_documentos.dart';
import 'package:meu_bebe/models/entry.dart';

/// A ordem da lista de documentos.
///
/// Documento é o único tipo cuja ordem não é a do tempo. Uma certidão não
/// fica menos importante por ser antiga, e quem abre esta tela procura o
/// papel de que precisa hoje, que pode ser o mais velho de todos.
///
/// A regra tem duas metades, e a mistura entre elas é a parte que erra
/// fácil: quem foi arrastado à mão manda, e quem nunca foi arrastado entra
/// depois, por data.
void main() {
  Entry doc(String id, {int? ordem, required int dia}) => Entry(
    id: id,
    type: EntryType.document,
    date: DateTime(2027, 4, dia),
    createdAt: DateTime(2027, 4, dia),
    ageDays: 0,
    bucketKey: '',
    bucketName: '',
    ordem: ordem,
  );

  List<String> ids(List<Entry> l) => l.map((Entry e) => e.id).toList();

  group('sem ninguém arrastado', () {
    test('vale a data, do mais recente para o mais antigo', () {
      final List<Entry> r = ordemDosDocumentos(<Entry>[
        doc('a', dia: 1),
        doc('c', dia: 20),
        doc('b', dia: 10),
      ]);
      expect(ids(r), <String>['c', 'b', 'a']);
    });
  });

  group('com alguém arrastado', () {
    test('quem foi arrastado vem primeiro, na posição escolhida', () {
      final List<Entry> r = ordemDosDocumentos(<Entry>[
        doc('novo', dia: 28),
        doc('certidao', ordem: 0, dia: 2),
        doc('vacina', ordem: 1, dia: 3),
      ]);
      expect(ids(r), <String>['certidao', 'vacina', 'novo']);
    });

    test('um documento novo não empurra quem foi posto em primeiro', () {
      // É o ponto inteiro da funcionalidade. Se o mais recente subisse ao
      // topo, quem arrastou a certidão para o primeiro lugar a perderia no
      // dia seguinte, ao guardar qualquer outro papel.
      final List<Entry> r = ordemDosDocumentos(<Entry>[
        doc('certidao', ordem: 0, dia: 1),
        doc('recem-enviado', dia: 30),
      ]);
      expect(ids(r).first, 'certidao');
    });
  });

  group('as bordas', () {
    test('lista vazia devolve lista vazia', () {
      expect(ordemDosDocumentos(<Entry>[]), isEmpty);
    });

    test('duas posições iguais não fazem a lista dançar', () {
      // Dois aparelhos podem arrastar a lista sem se falar, e aí a mesma
      // posição chega duas vezes. O desempate pelo id não é bonito; é
      // estável, e estável é o que impede a ordem de mudar a cada abertura.
      final List<Entry> entrada = <Entry>[
        doc('b', ordem: 0, dia: 5),
        doc('a', ordem: 0, dia: 9),
      ];
      final List<String> uma = ids(ordemDosDocumentos(entrada));
      final List<String> outra = ids(
        ordemDosDocumentos(entrada.reversed.toList()),
      );
      expect(uma, outra);
      expect(uma, <String>['a', 'b']);
    });

    test('a entrada não é alterada', () {
      // A lista vem de um provedor do Riverpod, e ordenar no lugar mexeria
      // no que outras telas estão lendo.
      final List<Entry> entrada = <Entry>[doc('a', dia: 1), doc('b', dia: 9)];
      ordemDosDocumentos(entrada);
      expect(ids(entrada), <String>['a', 'b']);
    });
  });

  group('o arrastão', () {
    /// A mesma conta de `_reordenar`: tirar de um lugar e pôr no outro.
    List<String> mover(List<String> lista, int de, int para) {
      final List<String> nova = <String>[...lista];
      nova.insert(para, nova.removeAt(de));
      return nova;
    }

    test('para baixo, o item para onde a pessoa soltou', () {
      // O `onReorder` antigo do Flutter contava o destino antes de tirar o
      // item da lista, e quem esquecia de descontar 1 via o item cair sempre
      // uma posição antes. `onReorderItem` já entrega o índice final, e é
      // essa conta simples que este teste fixa.
      expect(mover(<String>['a', 'b', 'c'], 0, 2), <String>['b', 'c', 'a']);
    });

    test('para cima também', () {
      expect(mover(<String>['a', 'b', 'c'], 2, 0), <String>['c', 'a', 'b']);
    });

    test('a ordem gravada é a posição na lista final', () {
      // `reordenar` grava o índice de cada um. Depois de gravar, reler tem
      // de devolver exatamente a mesma lista, senão a ordem escolhida se
      // perde na próxima abertura.
      final List<Entry> depoisDoArraste = <Entry>[
        doc('c', dia: 3),
        doc('a', dia: 1),
        doc('b', dia: 2),
      ];
      final List<Entry> gravados = <Entry>[
        for (int i = 0; i < depoisDoArraste.length; i++)
          doc(
            depoisDoArraste[i].id,
            ordem: i,
            dia: depoisDoArraste[i].date.day,
          ),
      ];
      expect(ids(ordemDosDocumentos(gravados)), <String>['c', 'a', 'b']);
    });
  });
}
