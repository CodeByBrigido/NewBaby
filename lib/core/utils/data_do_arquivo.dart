/// Quando a mídia foi feita, lido do próprio arquivo.
///
/// Uma foto tirada hoje e uma foto de três anos atrás chegam ao aplicativo
/// pelo mesmo caminho, e quem sabe a diferença é o arquivo. A câmera grava a
/// hora do disparo no EXIF; o celular grava a hora da gravação no cabeçalho
/// do MP4. Ler dali poupa a pessoa de escolher a data em cada envio, que é a
/// parte do trabalho que faz alguém desistir de trazer o acervo antigo.
///
/// É Dart puro, sem plugin nenhum, por dois motivos. O primeiro é que dá
/// para testar cada caso com bytes montados à mão, e formato de arquivo é
/// exatamente o tipo de coisa que só se descobre quebrada no aparelho de
/// alguém. O segundo é que uma dependência a mais aqui seria uma
/// dependência a mais para declarar na política de privacidade.
///
/// Nada disto é obrigatório: quando o arquivo não diz nada, ou diz algo
/// impossível, a resposta é `null` e quem chamou decide o que fazer. Um
/// palpite errado sobre a data manda a memória para a pasta da idade errada,
/// e isso é pior do que perguntar.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Lê uma fatia do arquivo. Existe para o mesmo código andar sobre um
/// arquivo de verdade e sobre bytes montados num teste.
typedef LerBytes = Uint8List Function(int posicao, int quantidade);

/// Segundos entre 01/01/1904 e 01/01/1970.
///
/// O MP4 conta o tempo a partir de 1904, herança do QuickTime.
const int _epocaDoMp4 = 2082844800;

/// O quanto do arquivo precisa ser lido para achar o EXIF.
///
/// O bloco APP1 tem no máximo 64 KB e vem logo no começo, às vezes depois de
/// um APP0 curto. 192 KB cobre isso com folga e continua sendo uma leitura
/// barata mesmo numa foto de dezenas de megabytes.
const int _cabecalhoDeFoto = 192 * 1024;

/// A data de captura de um arquivo, ou `null` se ele não souber dizer.
Future<DateTime?> dataDeCaptura(String caminho) async {
  final File arquivo = File(caminho);
  try {
    if (!await arquivo.exists()) return null;
    final String extensao = p.extension(caminho).toLowerCase();

    if (extensao == '.jpg' || extensao == '.jpeg') {
      final RandomAccessFile leitor = await arquivo.open();
      try {
        final int quanto = await leitor.length();
        final Uint8List inicio = await leitor.read(
          quanto < _cabecalhoDeFoto ? quanto : _cabecalhoDeFoto,
        );
        return dataNoExif(inicio);
      } finally {
        await leitor.close();
      }
    }

    if (extensao == '.mp4' || extensao == '.mov' || extensao == '.m4v') {
      final RandomAccessFile leitor = await arquivo.open();
      try {
        final int tamanho = await leitor.length();
        return dataNoMp4((int posicao, int quantidade) {
          leitor.setPositionSync(posicao);
          return leitor.readSync(quantidade);
        }, tamanho);
      } finally {
        await leitor.close();
      }
    }

    return null;
  } on FileSystemException catch (e) {
    // Arquivo que sumiu entre escolher e enviar, ou sem permissão de
    // leitura. Não é motivo para derrubar o envio: sem data lida, vale a de
    // hoje, e a pessoa confirma na tela seguinte como sempre.
    debugPrint('Não foi possível ler a data de $caminho: $e');
    return null;
  } on Object catch (e) {
    debugPrint('Data de captura ilegível em $caminho: $e');
    return null;
  }
}

// ------------------------------------------------------------------ EXIF

/// A data de disparo gravada no EXIF de um JPEG.
///
/// Recebe o começo do arquivo, e não o arquivo inteiro: o EXIF mora nos
/// primeiros quilobytes.
@visibleForTesting
DateTime? dataNoExif(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) return null;

  int pos = 2;
  while (pos + 4 <= bytes.length) {
    if (bytes[pos] != 0xFF) return null;
    final int marcador = bytes[pos + 1];

    // Marcadores sem tamanho.
    if (marcador == 0x01 || (marcador >= 0xD0 && marcador <= 0xD9)) {
      pos += 2;
      continue;
    }
    // Começou a imagem comprimida: daqui para a frente não há mais metadado.
    if (marcador == 0xDA) return null;

    final int tamanho = (bytes[pos + 2] << 8) | bytes[pos + 3];
    if (tamanho < 2) return null;

    if (marcador == 0xE1) {
      final int inicio = pos + 4;
      final int fim = inicio + tamanho - 2 < bytes.length
          ? inicio + tamanho - 2
          : bytes.length;
      final DateTime? achada = _dataNoApp1(bytes, inicio, fim);
      if (achada != null) return achada;
    }

    pos += 2 + tamanho;
  }
  return null;
}

DateTime? _dataNoApp1(Uint8List bytes, int inicio, int fim) {
  // "Exif\0\0" separa o APP1 do EXIF de um APP1 de XMP, que tem outro dono.
  const List<int> assinatura = <int>[0x45, 0x78, 0x69, 0x66, 0x00, 0x00];
  if (inicio + assinatura.length > fim) return null;
  for (int i = 0; i < assinatura.length; i++) {
    if (bytes[inicio + i] != assinatura[i]) return null;
  }

  final int tiff = inicio + assinatura.length;
  if (tiff + 8 > fim) return null;

  final bool pequeno = bytes[tiff] == 0x49 && bytes[tiff + 1] == 0x49;
  final bool grande = bytes[tiff] == 0x4D && bytes[tiff + 1] == 0x4D;
  if (!pequeno && !grande) return null;

  int u16(int o) =>
      pequeno ? bytes[o] | (bytes[o + 1] << 8) : (bytes[o] << 8) | bytes[o + 1];
  int u32(int o) => pequeno
      ? bytes[o] |
            (bytes[o + 1] << 8) |
            (bytes[o + 2] << 16) |
            (bytes[o + 3] << 24)
      : (bytes[o] << 24) |
            (bytes[o + 1] << 16) |
            (bytes[o + 2] << 8) |
            bytes[o + 3];

  if (u16(tiff + 2) != 42) return null;

  /// O texto ASCII de uma entrada de IFD, se ela for mesmo texto.
  String? texto(int entrada) {
    if (entrada + 12 > fim) return null;
    if (u16(entrada + 2) != 2) return null; // tipo 2 = ASCII
    final int quantos = u32(entrada + 4);
    // "AAAA:MM:DD HH:MM:SS" tem 19 caracteres, e mais o terminador.
    if (quantos < 19) return null;
    final int onde = quantos <= 4 ? entrada + 8 : tiff + u32(entrada + 8);
    if (onde < 0 || onde + 19 > fim) return null;
    return String.fromCharCodes(bytes, onde, onde + 19);
  }

  /// Percorre um IFD procurando as etiquetas pedidas.
  Map<int, int> entradas(int ifd, Set<int> procuradas) {
    final Map<int, int> achadas = <int, int>{};
    if (ifd < tiff || ifd + 2 > fim) return achadas;
    final int quantas = u16(ifd);
    // Um IFD legítimo não tem milhares de entradas; o limite protege contra
    // um arquivo corrompido virar uma varredura enorme.
    if (quantas > 512) return achadas;
    for (int i = 0; i < quantas; i++) {
      final int entrada = ifd + 2 + i * 12;
      if (entrada + 12 > fim) break;
      final int etiqueta = u16(entrada);
      if (procuradas.contains(etiqueta)) achadas[etiqueta] = entrada;
    }
    return achadas;
  }

  const int etiquetaDataDoArquivo = 0x0132; // DateTime
  const int etiquetaPonteiroExif = 0x8769; // Exif IFD
  const int etiquetaDataOriginal = 0x9003; // DateTimeOriginal
  const int etiquetaDataDigitalizada = 0x9004; // DateTimeDigitized

  final Map<int, int> ifd0 = entradas(tiff + u32(tiff + 4), <int>{
    etiquetaDataDoArquivo,
    etiquetaPonteiroExif,
  });

  // A ordem importa. `DateTimeOriginal` é quando o obturador disparou;
  // `DateTime` é quando o arquivo foi gravado, e um editor de imagem
  // reescreve esse sem tocar naquele.
  final int? ponteiro = ifd0[etiquetaPonteiroExif];
  if (ponteiro != null && ponteiro + 12 <= fim) {
    final Map<int, int> sub = entradas(tiff + u32(ponteiro + 8), <int>{
      etiquetaDataOriginal,
      etiquetaDataDigitalizada,
    });
    for (final int etiqueta in <int>[
      etiquetaDataOriginal,
      etiquetaDataDigitalizada,
    ]) {
      final int? entrada = sub[etiqueta];
      if (entrada == null) continue;
      final DateTime? data = dataDoTextoExif(texto(entrada));
      if (data != null) return data;
    }
  }

  final int? entrada = ifd0[etiquetaDataDoArquivo];
  return entrada == null ? null : dataDoTextoExif(texto(entrada));
}

/// `2026:04:15 08:42:10` vira uma data. Devolve `null` para qualquer outra
/// coisa, incluindo o `0000:00:00 00:00:00` que algumas câmeras gravam
/// quando o relógio nunca foi acertado.
@visibleForTesting
DateTime? dataDoTextoExif(String? texto) {
  if (texto == null || texto.length < 19) return null;
  final int? ano = int.tryParse(texto.substring(0, 4));
  final int? mes = int.tryParse(texto.substring(5, 7));
  final int? dia = int.tryParse(texto.substring(8, 10));
  final int? hora = int.tryParse(texto.substring(11, 13));
  final int? minuto = int.tryParse(texto.substring(14, 16));
  final int? segundo = int.tryParse(texto.substring(17, 19));
  if (ano == null ||
      mes == null ||
      dia == null ||
      hora == null ||
      minuto == null ||
      segundo == null) {
    return null;
  }
  if (ano < 1900 || mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;
  if (hora > 23 || minuto > 59 || segundo > 60) return null;

  final DateTime montada = DateTime(ano, mes, dia, hora, minuto, segundo);
  // 31 de fevereiro vira 3 de março quando se monta sem conferir.
  if (montada.month != mes || montada.day != dia) return null;
  return montada;
}

// ------------------------------------------------------------------- MP4

/// A hora de criação gravada no cabeçalho `mvhd` de um MP4.
///
/// O arquivo é uma árvore de caixas, cada uma com tamanho e tipo. A que
/// interessa é `moov/mvhd`, e ela pode estar no começo ou no fim do arquivo,
/// dependendo de quem gravou. Por isso a leitura é por pedaços e não de uma
/// vez: um vídeo de meia hora não cabe na memória.
@visibleForTesting
DateTime? dataNoMp4(LerBytes ler, int tamanho) {
  final ({int inicio, int fim})? moov = _caixa(ler, 0, tamanho, 'moov');
  if (moov == null) return null;

  final ({int inicio, int fim})? mvhd = _caixa(
    ler,
    moov.inicio,
    moov.fim,
    'mvhd',
  );
  if (mvhd == null || mvhd.inicio + 12 > mvhd.fim) return null;

  final int versao = ler(mvhd.inicio, 1)[0];
  final int criacao;
  if (versao == 1) {
    if (mvhd.inicio + 12 > mvhd.fim) return null;
    final Uint8List d = ler(mvhd.inicio + 4, 8);
    int valor = 0;
    for (int i = 0; i < 8; i++) {
      valor = (valor << 8) | d[i];
    }
    criacao = valor;
  } else {
    final Uint8List d = ler(mvhd.inicio + 4, 4);
    criacao = (d[0] << 24) | (d[1] << 16) | (d[2] << 8) | d[3];
  }

  // Zero é o que fica quando o gravador não soube a hora.
  if (criacao <= _epocaDoMp4) return null;
  return DateTime.fromMillisecondsSinceEpoch(
    (criacao - _epocaDoMp4) * 1000,
    isUtc: true,
  ).toLocal();
}

/// Acha uma caixa pelo tipo, entre [de] e [ate], e devolve onde o conteúdo
/// dela começa e termina.
({int inicio, int fim})? _caixa(LerBytes ler, int de, int ate, String tipo) {
  int pos = de;
  while (pos + 8 <= ate) {
    final Uint8List cabeca = ler(pos, 8);
    if (cabeca.length < 8) return null;

    int tamanho =
        (cabeca[0] << 24) | (cabeca[1] << 16) | (cabeca[2] << 8) | cabeca[3];
    final String nome = String.fromCharCodes(cabeca, 4, 8);
    int conteudo = pos + 8;

    if (tamanho == 1) {
      // Caixa grande: o tamanho de verdade vem nos 8 bytes seguintes.
      if (pos + 16 > ate) return null;
      final Uint8List largo = ler(pos + 8, 8);
      tamanho = 0;
      for (int i = 0; i < 8; i++) {
        tamanho = (tamanho << 8) | largo[i];
      }
      conteudo = pos + 16;
    } else if (tamanho == 0) {
      // Vai até o fim do arquivo.
      tamanho = ate - pos;
    }

    if (tamanho < 8 || pos + tamanho > ate) return null;
    if (nome == tipo) {
      return (inicio: conteudo, fim: pos + tamanho);
    }
    pos += tamanho;
  }
  return null;
}

// ------------------------------------------------------------------- lote

/// O que um lote de arquivos escolhidos diz sobre quando aconteceu.
@immutable
class DataDoLote {
  const DataDoLote({
    required this.quando,
    required this.lida,
    required this.diasDiferentes,
  });

  /// A data que vale para o lote.
  final DateTime quando;

  /// Se ela saiu dos arquivos ou é só o dia de hoje, por falta de resposta.
  final bool lida;

  /// Quantos dias distintos apareceram entre os arquivos escolhidos.
  ///
  /// Mais de um significa que uma data só não descreve o lote, e quem está
  /// enviando precisa saber disso antes de confirmar.
  final int diasDiferentes;

  bool get variosDias => diasDiferentes > 1;
}

/// Lê a data de cada arquivo e resume o lote numa data só.
///
/// A escolhida é a do dia que mais se repete, e a mais antiga entre empates.
/// Pegar simplesmente a mais antiga erraria o caso comum de alguém escolher
/// dez fotos de ontem e uma de três anos atrás: as dez é que descrevem o
/// lote.
///
/// Datas fora do intervalo possível são descartadas em vez de corrigidas.
/// Câmera com relógio zerado grava 1980, e uma foto que diz ser anterior ao
/// nascimento não pode ir para pasta de idade nenhuma.
Future<DataDoLote> dataDoLote(
  List<String> caminhos, {
  required DateTime naoAntesDe,
  DateTime? agora,
}) async {
  final DateTime fim = agora ?? DateTime.now();
  final List<DateTime> lidas = <DateTime>[];

  for (final String caminho in caminhos) {
    final DateTime? data = await dataDeCaptura(caminho);
    if (data == null) continue;
    if (data.isBefore(naoAntesDe) || data.isAfter(fim)) continue;
    lidas.add(data);
  }

  if (lidas.isEmpty) {
    return DataDoLote(quando: fim, lida: false, diasDiferentes: 0);
  }

  final Map<DateTime, List<DateTime>> porDia = <DateTime, List<DateTime>>{};
  for (final DateTime data in lidas) {
    porDia
        .putIfAbsent(
          DateTime(data.year, data.month, data.day),
          () => <DateTime>[],
        )
        .add(data);
  }

  final List<DateTime> dias = porDia.keys.toList()
    ..sort((DateTime a, DateTime b) {
      final int peso = porDia[b]!.length.compareTo(porDia[a]!.length);
      return peso != 0 ? peso : a.compareTo(b);
    });

  final List<DateTime> doDia = porDia[dias.first]!..sort();
  return DataDoLote(
    quando: doDia.first,
    lida: true,
    diasDiferentes: dias.length,
  );
}
