import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/services/media_optimizer.dart';

/// O tamanho com que uma foto entra no acervo.
///
/// Esta é a única decisão do aplicativo que não dá para desfazer depois. O
/// original fica no celular, mas celular se perde, troca e formata; o que
/// sobra daqui a vinte anos é exatamente o arquivo que subiu. Por isso a
/// regra tem teste próprio, e por isso ela erra para cima quando erra.
void main() {
  group('o teto de resolução da foto', () {
    test('reduz o lado maior até o teto e preserva a proporção', () {
      // A câmera de celular mais comum, 12 MP em 4:3.
      final (int, int) r = MediaOptimizer.archiveSize(4032, 3024);
      expect(r.$1, 960);
      expect(r.$2, 720);
      expect(r.$1 / r.$2, closeTo(4032 / 3024, 0.001));
    });

    test('funciona igual em pé, que é como quase toda foto é tirada', () {
      final (int, int) r = MediaOptimizer.archiveSize(3024, 4032);
      expect(r.$2, 960);
      expect(r.$1, 720);
    });

    test('a câmera de 48 MP cai na mesma faixa que a de 12 MP', () {
      // O ponto da regra: o tamanho do arquivo passa a depender do que a
      // foto precisa ser, e não de qual celular a família comprou. Pela
      // regra antiga, de metade, esta foto ficaria com 4000 px de lado.
      final (int, int) r = MediaOptimizer.archiveSize(8000, 6000);
      expect(r.$1, 960);
      expect(r.$2, 720);
    });

    test('foto que já cabe no teto sai intacta', () {
      // Pela regra antiga esta foto era reduzida a 600x450, ou seja, o
      // aplicativo estragava justamente a que já tinha menos a perder.
      expect(MediaOptimizer.archiveSize(800, 600), (800, 600));
      expect(MediaOptimizer.archiveSize(960, 720), (960, 720));
    });

    test('nunca aumenta uma foto pequena', () {
      // Aumentar inventaria pixels e ainda cobraria espaço por eles.
      final (int, int) r = MediaOptimizer.archiveSize(320, 240);
      expect(r, (320, 240));
    });

    test('o arredondamento nunca passa do original', () {
      // O compressor usa uma escala só e nunca amplia: um alvo maior que a
      // imagem faria o lado curto sair acima do teto sem ninguém notar.
      for (int w = 961; w < 1400; w++) {
        final (int, int) r = MediaOptimizer.archiveSize(w, 640);
        expect(r.$1, lessThanOrEqualTo(w));
        expect(r.$2, lessThanOrEqualTo(640));
        expect(r.$1, lessThanOrEqualTo(MediaOptimizer.maxLongEdge));
      }
    });

    test('nenhum lado chega a zero, por mais estreita que seja a foto', () {
      // Panorama de 1 px de altura existe em fotos recortadas, e um lado
      // zerado derruba o compressor em vez de devolver erro tratável.
      final (int, int) r = MediaOptimizer.archiveSize(20000, 1);
      expect(r.$1, MediaOptimizer.maxLongEdge);
      expect(r.$2, greaterThanOrEqualTo(1));
    });

    test('o teto é o único número a mexer', () {
      final (int, int) r = MediaOptimizer.archiveSize(
        4032,
        3024,
        longEdge: 2048,
      );
      expect(r.$1, 2048);
      expect(r.$2, 1536);
    });
  });

  group('a qualidade do JPEG', () {
    test('é a do acervo, e não a de compartilhar', () {
      // Abaixo de 78 o JPEG começa a deixar marca visível em pele e em céu,
      // que é metade do que uma cápsula guarda. Acima de 85 ele gasta bytes
      // guardando ruído de sensor.
      expect(MediaOptimizer().imageQuality, inInclusiveRange(78, 85));
    });
  });
}
