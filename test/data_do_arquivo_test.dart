import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/data_do_arquivo.dart';
import 'package:path/path.dart' as p;

/// Bytes montados à mão, e não fotos de verdade no repositório.
///
/// Formato de arquivo é o tipo de coisa que só se descobre quebrada no
/// aparelho de alguém, meses depois. Montar o cabeçalho aqui deixa cada caso
/// visível: o byte de ordem invertida, a etiqueta que falta, o relógio que
/// nunca foi acertado.

// ------------------------------------------------------------------ EXIF

/// Uma entrada de IFD: etiqueta, tipo, quantidade e valor.
Uint8List _entrada(
  int etiqueta,
  int tipo,
  int quantidade,
  int valor, {
  required bool pequeno,
}) {
  final ByteData d = ByteData(12);
  final Endian ordem = pequeno ? Endian.little : Endian.big;
  d.setUint16(0, etiqueta, ordem);
  d.setUint16(2, tipo, ordem);
  d.setUint32(4, quantidade, ordem);
  d.setUint32(8, valor, ordem);
  return d.buffer.asUint8List();
}

/// Monta um JPEG mínimo com um APP1/EXIF dentro.
///
/// [original] vira `DateTimeOriginal`, no sub-IFD; [doArquivo] vira
/// `DateTime`, no IFD0. Qualquer um dos dois pode faltar.
Uint8List jpegComExif({
  String? original,
  String? doArquivo,
  bool pequeno = true,
  bool assinaturaValida = true,
}) {
  // O TIFF é montado primeiro, porque todos os deslocamentos são relativos
  // ao começo dele.
  final BytesBuilder tiff = BytesBuilder();
  final Endian ordem = pequeno ? Endian.little : Endian.big;

  final ByteData cabecalho = ByteData(8);
  cabecalho.setUint8(0, pequeno ? 0x49 : 0x4D);
  cabecalho.setUint8(1, pequeno ? 0x49 : 0x4D);
  cabecalho.setUint16(2, 42, ordem);
  cabecalho.setUint32(4, 8, ordem); // IFD0 logo depois do cabeçalho
  tiff.add(cabecalho.buffer.asUint8List());

  // Layout: IFD0 (2 + n*12 + 4), sub-IFD (2 + 12 + 4), depois os textos.
  final int entradasIfd0 =
      (doArquivo == null ? 0 : 1) + (original == null ? 0 : 1);
  final int inicioSub = 8 + 2 + entradasIfd0 * 12 + 4;
  final int inicioTextos = inicioSub + 2 + 12 + 4;

  final ByteData quantas = ByteData(2)..setUint16(0, entradasIfd0, ordem);
  tiff.add(quantas.buffer.asUint8List());

  int textoAtual = inicioTextos;
  final int offDoArquivo = doArquivo == null ? 0 : textoAtual;
  if (doArquivo != null) textoAtual += 20;
  final int offOriginal = original == null ? 0 : textoAtual;

  // As etiquetas de um IFD vão em ordem crescente: 0x0132 antes de 0x8769.
  if (doArquivo != null) {
    tiff.add(_entrada(0x0132, 2, 20, offDoArquivo, pequeno: pequeno));
  }
  if (original != null) {
    tiff.add(_entrada(0x8769, 4, 1, inicioSub, pequeno: pequeno));
  }
  tiff.add(Uint8List(4)); // sem IFD1

  // Sub-IFD, sempre presente para manter o layout previsível.
  final ByteData umaEntrada = ByteData(2)..setUint16(0, 1, ordem);
  tiff.add(umaEntrada.buffer.asUint8List());
  tiff.add(_entrada(0x9003, 2, 20, offOriginal, pequeno: pequeno));
  tiff.add(Uint8List(4));

  for (final String? texto in <String?>[doArquivo, original]) {
    if (texto == null) continue;
    final Uint8List campo = Uint8List(20);
    campo.setRange(0, texto.length, texto.codeUnits);
    tiff.add(campo);
  }

  final Uint8List corpoTiff = tiff.toBytes();
  final BytesBuilder app1 = BytesBuilder();
  app1.add(
    assinaturaValida
        ? <int>[0x45, 0x78, 0x69, 0x66, 0x00, 0x00] // "Exif\0\0"
        : <int>[0x68, 0x74, 0x74, 0x70, 0x3A, 0x00], // XMP, outro dono
  );
  app1.add(corpoTiff);
  final Uint8List corpoApp1 = app1.toBytes();

  final BytesBuilder jpeg = BytesBuilder();
  jpeg.add(<int>[0xFF, 0xD8]); // SOI
  // Um APP0/JFIF na frente, que é como quase toda câmera grava.
  jpeg.add(<int>[0xFF, 0xE0, 0x00, 0x04, 0x00, 0x00]);
  jpeg.add(<int>[0xFF, 0xE1]);
  final int tamanho = corpoApp1.length + 2;
  jpeg.add(<int>[(tamanho >> 8) & 0xFF, tamanho & 0xFF]);
  jpeg.add(corpoApp1);
  jpeg.add(<int>[0xFF, 0xDA]); // começa a imagem
  return jpeg.toBytes();
}

// ------------------------------------------------------------------- MP4

/// Uma caixa MP4: tamanho, tipo e conteúdo.
Uint8List _caixa(String tipo, List<int> conteudo) {
  final BytesBuilder b = BytesBuilder();
  final int tamanho = 8 + conteudo.length;
  b.add(<int>[
    (tamanho >> 24) & 0xFF,
    (tamanho >> 16) & 0xFF,
    (tamanho >> 8) & 0xFF,
    tamanho & 0xFF,
  ]);
  b.add(tipo.codeUnits);
  b.add(conteudo);
  return b.toBytes();
}

Uint8List mp4Com(DateTime quando, {bool versao1 = false, int? cru}) {
  final int segundos =
      cru ?? (quando.toUtc().millisecondsSinceEpoch ~/ 1000) + 2082844800;

  final BytesBuilder mvhd = BytesBuilder();
  mvhd.add(<int>[versao1 ? 1 : 0, 0, 0, 0]); // versão + flags
  if (versao1) {
    final ByteData d = ByteData(8)..setUint64(0, segundos, Endian.big);
    mvhd.add(d.buffer.asUint8List());
    mvhd.add(Uint8List(8)); // modificação
  } else {
    final ByteData d = ByteData(4)..setUint32(0, segundos, Endian.big);
    mvhd.add(d.buffer.asUint8List());
    mvhd.add(Uint8List(4));
  }
  mvhd.add(Uint8List(8)); // escala e duração

  final BytesBuilder arquivo = BytesBuilder();
  // `ftyp` na frente e uma `free` no meio: o `moov` quase nunca é a primeira
  // caixa do arquivo.
  arquivo.add(_caixa('ftyp', List<int>.filled(16, 0)));
  arquivo.add(_caixa('free', List<int>.filled(8, 0)));
  arquivo.add(_caixa('moov', _caixa('mvhd', mvhd.toBytes())));
  return arquivo.toBytes();
}

LerBytes deBytes(Uint8List b) => (int posicao, int quantidade) {
  final int fim = posicao + quantidade;
  return Uint8List.sublistView(b, posicao, fim > b.length ? b.length : fim);
};

void main() {
  group('a data no EXIF de uma foto', () {
    test('lê a hora do disparo', () {
      final DateTime? d = dataNoExif(
        jpegComExif(original: '2026:04:15 08:42:10'),
      );
      expect(d, DateTime(2026, 4, 15, 8, 42, 10));
    });

    test('lê igual com os bytes na ordem invertida', () {
      // Canon grava em little endian, Nikon em big endian. As duas existem
      // no celular de alguém, via cartão de memória.
      final DateTime? d = dataNoExif(
        jpegComExif(original: '2026:04:15 08:42:10', pequeno: false),
      );
      expect(d, DateTime(2026, 4, 15, 8, 42, 10));
    });

    test('prefere o disparo à hora em que o arquivo foi gravado', () {
      // Um editor de imagem reescreve `DateTime` e não toca em
      // `DateTimeOriginal`. Preferir o errado dataria a foto pela última vez
      // que alguém a cortou.
      final DateTime? d = dataNoExif(
        jpegComExif(
          original: '2020:01:02 03:04:05',
          doArquivo: '2026:08:13 10:00:00',
        ),
      );
      expect(d, DateTime(2020, 1, 2, 3, 4, 5));
    });

    test('cai para a hora do arquivo quando não há disparo', () {
      final DateTime? d = dataNoExif(
        jpegComExif(doArquivo: '2026:08:13 10:00:00'),
      );
      expect(d, DateTime(2026, 8, 13, 10, 0, 0));
    });

    test('foto sem EXIF nenhum não inventa data', () {
      expect(dataNoExif(jpegComExif()), isNull);
    });

    test('APP1 que não é EXIF é ignorado', () {
      // O mesmo marcador carrega XMP, que tem outro formato dentro.
      final Uint8List b = jpegComExif(
        original: '2026:04:15 08:42:10',
        assinaturaValida: false,
      );
      expect(dataNoExif(b), isNull);
    });

    test('não é JPEG, não tem resposta', () {
      expect(
        dataNoExif(Uint8List.fromList(<int>[0x89, 0x50, 0x4E, 0x47])),
        isNull,
      );
      expect(dataNoExif(Uint8List(0)), isNull);
      expect(dataNoExif(Uint8List.fromList(<int>[0xFF, 0xD8])), isNull);
    });

    test('arquivo cortado no meio não derruba a leitura', () {
      final Uint8List inteiro = jpegComExif(original: '2026:04:15 08:42:10');
      for (int corte = 0; corte < inteiro.length; corte++) {
        expect(
          () => dataNoExif(Uint8List.sublistView(inteiro, 0, corte)),
          returnsNormally,
          reason: 'cortado em $corte bytes',
        );
      }
    });
  });

  group('o texto de data do EXIF', () {
    test('o relógio que nunca foi acertado não vira data', () {
      expect(dataDoTextoExif('0000:00:00 00:00:00'), isNull);
    });

    test('data impossível não é arredondada para a seguinte', () {
      // `DateTime(2026, 2, 31)` devolve 3 de março sem reclamar.
      expect(dataDoTextoExif('2026:02:31 10:00:00'), isNull);
      expect(dataDoTextoExif('2026:13:01 10:00:00'), isNull);
      expect(dataDoTextoExif('2026:04:15 25:00:00'), isNull);
    });

    test('29 de fevereiro em ano bissexto é data de verdade', () {
      expect(dataDoTextoExif('2028:02:29 10:00:00'), DateTime(2028, 2, 29, 10));
    });

    test('texto curto ou com letra no lugar do número devolve nulo', () {
      expect(dataDoTextoExif(null), isNull);
      expect(dataDoTextoExif('2026:04:15'), isNull);
      expect(dataDoTextoExif('abcd:ef:gh ij:kl:mn'), isNull);
    });
  });

  group('a data no cabeçalho de um vídeo', () {
    test('lê a hora da gravação', () {
      final DateTime quando = DateTime(2026, 5, 20, 14, 30, 5);
      final Uint8List b = mp4Com(quando);
      expect(dataNoMp4(deBytes(b), b.length), quando);
    });

    test('lê igual na versão de 64 bits do cabeçalho', () {
      final DateTime quando = DateTime(2026, 5, 20, 14, 30, 5);
      final Uint8List b = mp4Com(quando, versao1: true);
      expect(dataNoMp4(deBytes(b), b.length), quando);
    });

    test('gravador sem relógio marca zero, e zero não é data', () {
      final Uint8List b = mp4Com(DateTime(2026), cru: 0);
      expect(dataNoMp4(deBytes(b), b.length), isNull);
    });

    test('arquivo sem moov não tem resposta', () {
      final Uint8List b = _caixa('ftyp', List<int>.filled(16, 0));
      expect(dataNoMp4(deBytes(b), b.length), isNull);
    });

    test('caixa com tamanho impossível não vira laço infinito', () {
      // Tamanho zero dentro de uma caixa aninhada já travou leitor de MP4 de
      // gente grande.
      final Uint8List b = Uint8List.fromList(<int>[
        0, 0, 0, 0, 0x6D, 0x6F, 0x6F, 0x76, // moov de tamanho 0
        0, 0, 0, 0, 0x6D, 0x76, 0x68, 0x64, // mvhd de tamanho 0
      ]);
      expect(() => dataNoMp4(deBytes(b), b.length), returnsNormally);
    });
  });

  group('a data de um lote de arquivos', () {
    late Directory pasta;

    setUp(() async {
      pasta = await Directory.systemTemp.createTemp('lote');
    });

    tearDown(() async {
      if (pasta.existsSync()) await pasta.delete(recursive: true);
    });

    Future<String> foto(String nome, String? quando) async {
      final File f = File(p.join(pasta.path, '$nome.jpg'));
      await f.writeAsBytes(jpegComExif(original: quando));
      return f.path;
    }

    test('o dia que mais se repete ganha, e não o mais antigo', () async {
      // Dez fotos de ontem e uma de três anos atrás descrevem ontem. A regra
      // do "mais antigo" mandaria o lote inteiro para a pasta errada.
      final List<String> caminhos = <String>[
        await foto('a', '2026:08:12 10:00:00'),
        await foto('b', '2026:08:12 11:00:00'),
        await foto('c', '2023:01:05 09:00:00'),
      ];
      final DataDoLote lote = await dataDoLote(
        caminhos,
        naoAntesDe: DateTime(2020),
        agora: DateTime(2026, 8, 13),
      );
      expect(lote.quando, DateTime(2026, 8, 12, 10));
      expect(lote.lida, isTrue);
      expect(lote.variosDias, isTrue);
    });

    test('lote de um dia só não avisa nada', () async {
      final List<String> caminhos = <String>[
        await foto('a', '2026:08:12 10:00:00'),
        await foto('b', '2026:08:12 18:00:00'),
      ];
      final DataDoLote lote = await dataDoLote(
        caminhos,
        naoAntesDe: DateTime(2020),
        agora: DateTime(2026, 8, 13),
      );
      expect(lote.quando, DateTime(2026, 8, 12, 10));
      expect(lote.variosDias, isFalse);
    });

    test(
      'sem data legível, vale hoje, e o aplicativo diz que foi palpite',
      () async {
        final List<String> caminhos = <String>[await foto('a', null)];
        final DateTime agora = DateTime(2026, 8, 13, 9);
        final DataDoLote lote = await dataDoLote(
          caminhos,
          naoAntesDe: DateTime(2020),
          agora: agora,
        );
        expect(lote.quando, agora);
        expect(lote.lida, isFalse);
        expect(lote.diasDiferentes, 0);
      },
    );

    test('data anterior ao nascimento é descartada, não corrigida', () async {
      // Câmera com relógio zerado grava 1980. Uma foto que diz ser anterior
      // ao nascimento não cabe em pasta de idade nenhuma.
      final List<String> caminhos = <String>[
        await foto('a', '1980:01:01 00:00:00'),
      ];
      final DateTime agora = DateTime(2026, 8, 13, 9);
      final DataDoLote lote = await dataDoLote(
        caminhos,
        naoAntesDe: DateTime(2026, 4, 15),
        agora: agora,
      );
      expect(lote.quando, agora);
      expect(lote.lida, isFalse);
    });

    test('data no futuro também é descartada', () async {
      final List<String> caminhos = <String>[
        await foto('a', '2030:01:01 00:00:00'),
      ];
      final DateTime agora = DateTime(2026, 8, 13, 9);
      final DataDoLote lote = await dataDoLote(
        caminhos,
        naoAntesDe: DateTime(2020),
        agora: agora,
      );
      expect(lote.quando, agora);
      expect(lote.lida, isFalse);
    });

    test(
      'arquivo que sumiu entre escolher e enviar não derruba o envio',
      () async {
        final DateTime agora = DateTime(2026, 8, 13, 9);
        final DataDoLote lote = await dataDoLote(
          <String>[p.join(pasta.path, 'nao-existe.jpg')],
          naoAntesDe: DateTime(2020),
          agora: agora,
        );
        expect(lote.quando, agora);
        expect(lote.lida, isFalse);
      },
    );

    test('a hora do disparo é guardada junto, e não só o dia', () async {
      // A hora é o que dá ordem estável aos arquivos dentro da pasta do
      // Drive, porque o nome deles começa pela data e hora.
      final List<String> caminhos = <String>[
        await foto('a', '2026:08:12 15:47:03'),
      ];
      final DataDoLote lote = await dataDoLote(
        caminhos,
        naoAntesDe: DateTime(2020),
        agora: DateTime(2026, 8, 13),
      );
      expect(lote.quando, DateTime(2026, 8, 12, 15, 47, 3));
    });
  });
}
