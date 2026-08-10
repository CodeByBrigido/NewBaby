import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/cartas_atrasadas.dart';

/// As cartas que existiam antes de a carta virar arquivo.
///
/// Foto e vídeo já sobreviviam sem o aplicativo, porque são arquivos numa
/// pasta. A carta não: ela só existia no índice. Quem usou as primeiras
/// versões tem cartas nesse estado, e é isso que esta rotina conserta.
///
/// O que os testes aqui protegem é o que dói caro: gravar duas vezes a mesma
/// carta (duplicata na pasta) e gravar de novo o que já está gravado
/// (upload à toa toda vez que a linha do tempo muda).
void main() {
  Entry carta(String id, DateTime quando, {String? arquivo}) => Entry(
    id: id,
    type: EntryType.letter,
    date: quando,
    createdAt: quando,
    ageDays: 30,
    bucketKey: 'M01',
    bucketName: 'Mês 01',
    title: 'Carta $id',
    description: 'texto',
    textFileId: arquivo,
  );

  Entry foto(String id) => Entry(
    id: id,
    type: EntryType.photo,
    date: DateTime(2026, 5, 1),
    createdAt: DateTime(2026, 5, 1),
    ageDays: 16,
    bucketKey: 'S03',
    bucketName: 'Semana 03',
  );

  group('quem entra na fila', () {
    test('só carta, e só carta sem arquivo', () {
      final List<Entry> fila = CartasAtrasadas.pendentes(<Entry>[
        foto('f1'),
        carta('c1', DateTime(2026, 5, 2)),
        carta('c2', DateTime(2026, 5, 3), arquivo: 'drive-1'),
      ]);
      expect(fila.map((Entry e) => e.id), <String>['c1']);
    });

    test('id vazio conta como ausente', () {
      // Uma gravação interrompida pode ter deixado string vazia no lugar do
      // id. Tratar isso como "tem arquivo" deixaria a carta sem cópia para
      // sempre, e ninguém descobriria.
      final List<Entry> fila = CartasAtrasadas.pendentes(<Entry>[
        carta('c1', DateTime(2026, 5, 2), arquivo: ''),
      ]);
      expect(fila, hasLength(1));
    });

    test('a mais antiga vai primeiro', () {
      // Se o trabalho parar no meio, o que fica para trás é o registro mais
      // recente, que é o mais fácil de reescrever de memória.
      final List<Entry> fila = CartasAtrasadas.pendentes(<Entry>[
        carta('novo', DateTime(2026, 8, 1)),
        carta('velho', DateTime(2026, 4, 20)),
        carta('meio', DateTime(2026, 6, 10)),
      ]);
      expect(fila.map((Entry e) => e.id), <String>['velho', 'meio', 'novo']);
    });

    test('acervo sem carta nenhuma não dá trabalho', () {
      expect(CartasAtrasadas.pendentes(<Entry>[foto('f1')]), isEmpty);
    });
  });

  group('a gravação', () {
    test('grava o que falta e devolve a conta', () async {
      final List<String> gravadas = <String>[];
      final CartasAtrasadas rotina = CartasAtrasadas((Entry c) async {
        gravadas.add(c.id);
        return c.copyWith(textFileId: 'drive-${c.id}');
      });

      final int quantas = await rotina.gravar(<Entry>[
        carta('c1', DateTime(2026, 5, 2)),
        carta('c2', DateTime(2026, 5, 3), arquivo: 'drive-2'),
        foto('f1'),
      ]);

      expect(quantas, 1);
      expect(gravadas, <String>['c1']);
    });

    test('acervo em dia não toca no Drive', () {
      // Este é o caso normal, e ele roda a cada mudança na linha do tempo.
      // Uma chamada de rede aqui seria um upload à toa por foto adicionada.
      bool tocou = false;
      final CartasAtrasadas rotina = CartasAtrasadas((Entry c) async {
        tocou = true;
        return c;
      });

      expect(rotina.gravar(<Entry>[foto('f1')]), completion(0));
      expect(tocou, isFalse);
    });

    test('duas rodadas ao mesmo tempo não duplicam o arquivo', () async {
      // A gravação muda a carta no índice, a linha do tempo reemite, e o
      // aplicativo chama de novo. Sem a trava, a segunda chamada entraria
      // por cima da primeira com a mesma lista, e a carta viraria dois
      // arquivos na pasta.
      final List<Entry> acervo = <Entry>[carta('c1', DateTime(2026, 5, 2))];
      final List<String> gravadas = <String>[];

      // A reentrada acontece uma vez só. Deixá-la livre faria a versão sem
      // trava recorrer para sempre, e um teste que pendura não avisa nada:
      // ele estoura o tempo do CI e vira ruído. Assim a falha é uma linha.
      bool jaReentrou = false;
      late final CartasAtrasadas rotina;
      rotina = CartasAtrasadas((Entry c) async {
        gravadas.add(c.id);
        if (!jaReentrou) {
          jaReentrou = true;
          await rotina.gravar(acervo);
        }
        return c.copyWith(textFileId: 'drive-${c.id}');
      });

      await rotina.gravar(acervo);
      expect(
        gravadas,
        <String>['c1'],
        reason:
            'a mesma carta foi gravada duas vezes: são dois arquivos '
            'iguais na pasta, e ninguém apaga o segundo',
      );
    });

    test('a trava sai do caminho quando a rodada termina', () async {
      int chamadas = 0;
      final CartasAtrasadas rotina = CartasAtrasadas((Entry c) async {
        chamadas++;
        return c;
      });

      final List<Entry> acervo = <Entry>[carta('c1', DateTime(2026, 5, 2))];
      await rotina.gravar(acervo);
      await rotina.gravar(acervo);
      expect(chamadas, 2, reason: 'a segunda abertura precisa tentar de novo');
    });

    test('uma falha não trava a rodada nem mente na conta', () async {
      // `escreverCarta` engole o erro e devolve a carta como estava: o texto
      // já está no índice, que é de onde o aplicativo lê. Aqui isso precisa
      // virar "não gravou", e não impedir as outras.
      final List<String> tentadas = <String>[];
      final CartasAtrasadas rotina = CartasAtrasadas((Entry c) async {
        tentadas.add(c.id);
        if (c.id == 'ruim') return c;
        return c.copyWith(textFileId: 'drive-${c.id}');
      });

      final int quantas = await rotina.gravar(<Entry>[
        carta('ruim', DateTime(2026, 5, 2)),
        carta('boa', DateTime(2026, 5, 3)),
      ]);

      expect(tentadas, <String>['ruim', 'boa']);
      expect(quantas, 1);
    });

    test('a rodada tem teto, e o resto fica para a próxima abertura', () async {
      // Um acervo antigo com centenas de cartas não pode virar uma rajada de
      // uploads no primeiro segundo de uso.
      int chamadas = 0;
      final CartasAtrasadas rotina = CartasAtrasadas((Entry c) async {
        chamadas++;
        return c.copyWith(textFileId: 'drive-${c.id}');
      });

      final List<Entry> muitas = List<Entry>.generate(
        CartasAtrasadas.porVez + 10,
        (int i) => carta('c$i', DateTime(2026, 5, 1).add(Duration(days: i))),
      );

      expect(await rotina.gravar(muitas), CartasAtrasadas.porVez);
      expect(chamadas, CartasAtrasadas.porVez);
    });
  });
}
