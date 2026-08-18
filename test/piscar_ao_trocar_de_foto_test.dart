import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/features/common/hero_da_midia.dart';
import 'package:meu_bebe/models/entry.dart';

/// A foto que piscava ao trocar de página no visualizador.
///
/// O relato: deslizar de uma foto para a outra dava um piscar, "como se
/// estivesse fechando e abrindo a imagem rapidamente".
///
/// A causa não estava na animação nem no carregamento. O visualizador
/// envolvia no voo **só** a página aberta, e deixava as vizinhas sem
/// envoltório nenhum. A cada deslize, duas páginas mudavam de forma ao mesmo
/// tempo: a que saía perdia o `Hero` e a que entrava ganhava um. O Flutter
/// reconcilia por tipo de widget em cada posição, então mudar a forma ali
/// desmonta o que estava dentro e monta de novo, do zero. E o que estava
/// dentro era a imagem, que busca o arquivo em `initState`: ela voltava para
/// a miniatura e a rodinha, e só então reaparecia.
///
/// Estes testes prendem a propriedade que conserta: ligar e desligar o voo
/// não pode custar o que está dentro dele.
void main() {
  const EntryFile arquivo = EntryFile(
    driveId: 'foto-1',
    name: 'a.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1,
  );

  setUp(() => _Imagem.criacoes = 0);

  Future<void> montar(WidgetTester tester, Widget filho) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: filho)));

  group('ligar e desligar o voo', () {
    testWidgets('a imagem sobrevive à troca', (WidgetTester tester) async {
      await montar(
        tester,
        const HeroDaMidia(
          origem: origemGaleria,
          file: arquivo,
          child: _Imagem(),
        ),
      );
      expect(_Imagem.criacoes, 1);

      await montar(
        tester,
        const HeroDaMidia(
          origem: origemGaleria,
          file: arquivo,
          ativo: false,
          child: _Imagem(),
        ),
      );

      // Uma só: o `Hero` continua no mesmo lugar, e o que está dentro dele
      // nunca foi desmontado. É isso que faz a foto não piscar.
      expect(_Imagem.criacoes, 1);
    });

    testWidgets('e sobrevive na volta também', (WidgetTester tester) async {
      // Deslizar e voltar é o caminho comum: a mesma página sai e entra.
      for (final bool ativo in <bool>[true, false, true, false]) {
        await montar(
          tester,
          HeroDaMidia(
            origem: origemGaleria,
            file: arquivo,
            ativo: ativo,
            child: const _Imagem(),
          ),
        );
      }
      expect(_Imagem.criacoes, 1);
    });

    testWidgets('parado, a etiqueta não é a que voa', (
      WidgetTester tester,
    ) async {
      // Sem par do outro lado não há voo, que é o efeito que se queria ao
      // tirar o `Hero` da árvore.
      await montar(
        tester,
        const HeroDaMidia(
          origem: origemGaleria,
          file: arquivo,
          ativo: false,
          child: _Imagem(),
        ),
      );

      final Hero heroi = tester.widget<Hero>(find.byType(Hero));
      expect(heroi.tag, isNot(etiquetaDaMidia(origemGaleria, arquivo)));
    });

    testWidgets('ativo, a etiqueta é exatamente a da origem', (
      WidgetTester tester,
    ) async {
      // O voo só acontece se as duas pontas combinarem letra por letra.
      await montar(
        tester,
        const HeroDaMidia(
          origem: origemGaleria,
          file: arquivo,
          child: _Imagem(),
        ),
      );

      final Hero heroi = tester.widget<Hero>(find.byType(Hero));
      expect(heroi.tag, etiquetaDaMidia(origemGaleria, arquivo));
    });

    testWidgets('duas páginas paradas não colidem', (
      WidgetTester tester,
    ) async {
      // Etiquetas iguais na mesma árvore são `assert` do Flutter, e ele
      // derruba a tela. As vizinhas do visualizador ficam paradas ao mesmo
      // tempo, então o sufixo precisa preservar o que as distingue.
      await montar(
        tester,
        const Column(
          children: <Widget>[
            HeroDaMidia(
              origem: origemGaleria,
              file: arquivo,
              ativo: false,
              child: SizedBox(),
            ),
            HeroDaMidia(
              origem: origemGaleria,
              file: EntryFile(
                driveId: 'foto-2',
                name: 'b.jpg',
                mimeType: 'image/jpeg',
                sizeBytes: 1,
              ),
              ativo: false,
              child: SizedBox(),
            ),
          ],
        ),
      );

      final List<Hero> herois = tester
          .widgetList<Hero>(find.byType(Hero))
          .toList();
      expect(herois.map((Hero h) => h.tag).toSet(), hasLength(2));
    });
  });

  group('o desenho antigo, para registro', () {
    testWidgets('tirar o voo da árvore recriava a imagem', (
      WidgetTester tester,
    ) async {
      // É o que o visualizador fazia, e é o defeito. Fica testado para que
      // ninguém volte a trocar `ativo:` por um `if` achando que dá no mesmo.
      await montar(
        tester,
        const HeroDaMidia(
          origem: origemGaleria,
          file: arquivo,
          child: _Imagem(),
        ),
      );
      expect(_Imagem.criacoes, 1);

      await montar(tester, const _Imagem());

      expect(
        _Imagem.criacoes,
        2,
        reason: 'Sem o envoltório, o que estava dentro é montado de novo.',
      );
    });
  });
}

/// Conta quantas vezes foi montada do zero.
///
/// Está no lugar da imagem de verdade, que busca o arquivo em `initState`:
/// cada montagem nova é um download recomeçado e um piscar na tela.
class _Imagem extends StatefulWidget {
  const _Imagem();

  static int criacoes = 0;

  @override
  State<_Imagem> createState() => _ImagemState();
}

class _ImagemState extends State<_Imagem> {
  @override
  void initState() {
    super.initState();
    _Imagem.criacoes++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
