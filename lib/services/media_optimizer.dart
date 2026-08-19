import '../core/l10n/strings.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_size_getter/image_size_getter.dart' as isg;
import 'package:image_size_getter/file_input.dart' as isg;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

/// Resultado de uma otimização: o arquivo **temporário** que será enviado.
///
/// O original nunca sai do aparelho e nunca é alterado. O arquivo aqui dentro
/// é descartável - sempre chame [dispose] depois do upload.
class OptimizedMedia {
  OptimizedMedia({
    required this.file,
    required this.mimeType,
    required this.originalPath,
    required this.originalBytes,
    this.width,
    this.height,
    this.durationSeconds,
    this.thumbnail,
  });

  final File file;
  final String mimeType;

  /// Caminho do arquivo original, que segue intacto na galeria.
  final String originalPath;
  final int originalBytes;

  final int? width;
  final int? height;
  final int? durationSeconds;

  /// Miniatura local para a linha do tempo aparecer instantaneamente.
  final File? thumbnail;

  int get bytes => file.existsSync() ? file.lengthSync() : 0;

  /// Apaga o temporário. A miniatura fica: ela é o cache de exibição.
  Future<void> dispose() async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (e) {
      debugPrint('Não foi possível apagar o temporário: $e');
    }
  }
}

/// Comprime fotos e vídeos antes do upload, sem perguntar nada ao usuário.
///
/// Regras fixas, vindas da especificação:
/// * foto - teto de [maxLongEdge] no lado maior, qualidade visual preservada;
/// * vídeo - sempre 540p com bitrate otimizado;
/// * o original permanece no celular e o temporário é apagado após o envio.
class MediaOptimizer {
  MediaOptimizer({this.imageQuality = 78});

  /// 78 é o piso: abaixo disso o JPEG começa a deixar marca visível em pele
  /// e em céu, que é metade do que uma cápsula guarda.
  ///
  /// Quem faz o trabalho de encolher aqui é o teto de resolução, e não este
  /// número. Espremer a qualidade deixa a foto suja; tirar pixels que
  /// ninguém vai olhar só a deixa menor.
  final int imageQuality;

  /// O maior lado, em pixels, de uma foto guardada na cápsula.
  ///
  /// A regra antiga era "metade do original", e ela era proporcional à
  /// câmera em vez de ser proporcional ao que a foto precisa ser. Numa
  /// câmera de 48 MP a metade ainda tinha 12 MP e pesava megabytes; numa
  /// foto que já chegou reduzida pelo WhatsApp a metade estragava o pouco
  /// que restava. Um teto faz toda foto cair na mesma faixa, venha da
  /// câmera que vier.
  ///
  /// 960 porque o teto só serve para o que passa dele, e 1600 não passava
  /// de quase nada: as fotos que chegam aqui já vinham menores que isso, o
  /// teto não encostava nelas, e o arquivo saía **maior** que na regra
  /// antiga da metade. Um teto que não corta ninguém não é um teto.
  ///
  /// 960 ainda enche a tela de um celular e imprime 10x15 cm. Aqui é o
  /// único número a mexer: subir para 1280 devolve detalhe, descer para 800
  /// economiza outro tanto.
  static const int maxLongEdge = 960;

  Future<Directory> _workDir() async {
    final Directory base = await getTemporaryDirectory();
    final Directory dir = Directory(p.join(base.path, 'meu_bebe_envio'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// As dimensões com que a foto vai ser guardada.
  ///
  /// Só reduz. Uma foto que já cabe no teto sai como entrou: aumentar
  /// inventaria pixels que a câmera nunca registrou e ainda cobraria espaço
  /// por eles.
  ///
  /// A proporção é preservada, e o arredondamento nunca passa do original -
  /// é o que garante que o compressor, que trabalha com uma escala só, não
  /// receba um alvo maior do que a imagem que ele tem em mãos.
  @visibleForTesting
  static (int, int) archiveSize(
    int width,
    int height, {
    int longEdge = maxLongEdge,
  }) {
    final int maior = width > height ? width : height;
    if (maior <= longEdge) return (width, height);
    final double escala = longEdge / maior;
    return (
      (width * escala).round().clamp(1, width),
      (height * escala).round().clamp(1, height),
    );
  }

  /// Reduz a foto ao teto de [maxLongEdge] no lado maior.
  Future<OptimizedMedia> optimizeImage(File source) async {
    final int originalBytes = await source.length();
    final Directory dir = await _workDir();
    final String target = p.join(
      dir.path,
      '${DateTime.now().microsecondsSinceEpoch}_${p.basenameWithoutExtension(source.path)}.jpg',
    );

    final (int, int)? size = _readSize(source);
    // `minWidth`/`minHeight` são um piso, e não um teto: o compressor usa
    // uma escala só, `max(1, min(w/minWidth, h/minHeight))`, então entregar
    // as dimensões já calculadas é o que faz o alvo valer. Sem as dimensões
    // do original não há o que calcular, e o 1080 nos dois lados deixa o
    // lado menor em 1080 - fica maior que o teto, mas é o pior caso de um
    // caminho raro, e errar para cima preserva a foto.
    final (int, int) alvo = size == null
        ? (1080, 1080)
        : archiveSize(size.$1, size.$2);

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      source.path,
      target,
      quality: imageQuality,
      minWidth: alvo.$1,
      minHeight: alvo.$2,
      // O EXIF é descartado de propósito. Ele carrega latitude e longitude,
      // ou seja, o endereço de casa, da creche e da maternidade dentro de
      // cada foto - e vai junto no dia em que alguém compartilhar o arquivo.
      //
      // A orientação não depende disso: `autoCorrectionAngle` já é `true` por
      // padrão e gira a imagem antes de gravar, então a foto tirada de lado
      // continua saindo em pé.
      keepExif: false,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw MediaOptimizationException(S.errPhotoCompress);
    }

    final File compressed = File(result.path);
    final (int, int)? finalSize = _readSize(compressed);

    return OptimizedMedia(
      file: compressed,
      mimeType: 'image/jpeg',
      originalPath: source.path,
      originalBytes: originalBytes,
      width: finalSize?.$1,
      height: finalSize?.$2,
      // A própria foto comprimida serve de miniatura local.
      thumbnail: compressed,
    );
  }

  /// Converte o vídeo para 540p com bitrate otimizado.
  ///
  /// Um degrau abaixo dos 720p de antes, e o arquivo cai por volta da
  /// metade: a biblioteca calcula o bitrate a partir da área da imagem, e
  /// 960x540 tem 44% menos pixels que 1280x720.
  ///
  /// O degrau seguinte, `Res640x480Quality`, não é 480p em vídeo de celular.
  /// Ele limita o lado maior a 640, e num vídeo deitado, que é o formato de
  /// quase tudo que se filma, isso dá 640x360. É pouco demais para uma
  /// gravação que alguém vai assistir numa televisão daqui a vinte anos, e
  /// por isso a parada é aqui.
  Future<OptimizedMedia> optimizeVideo(File source) async {
    final int originalBytes = await source.length();

    final MediaInfo? info = await VideoCompress.compressVideo(
      source.path,
      quality: VideoQuality.Res960x540Quality,
      includeAudio: true,
      // O vídeo original é da família: nunca apagamos nada da galeria.
      deleteOrigin: false,
    );

    final String? path = info?.path;
    if (path == null) {
      throw MediaOptimizationException(S.errVideoConvert);
    }

    File? thumb;
    try {
      thumb = await VideoCompress.getFileThumbnail(source.path, quality: 70);
    } on Exception catch (e) {
      debugPrint('Miniatura do vídeo indisponível: $e');
    }

    return OptimizedMedia(
      file: File(path),
      mimeType: 'video/mp4',
      originalPath: source.path,
      originalBytes: originalBytes,
      width: info?.width,
      height: info?.height,
      durationSeconds: info?.duration == null
          ? null
          : (info!.duration! / 1000).round(),
      thumbnail: thumb,
    );
  }

  /// Documentos vão como estão: comprimir um PDF ou uma certidão
  /// escaneada arriscaria a legibilidade do que importa.
  Future<OptimizedMedia> passthrough(File source, String mimeType) async {
    final int bytes = await source.length();
    return OptimizedMedia(
      file: source,
      mimeType: mimeType,
      originalPath: source.path,
      originalBytes: bytes,
    );
  }

  /// Limpa o que as bibliotecas deixaram para trás.
  Future<void> clearCaches() async {
    try {
      await VideoCompress.deleteAllCache();
    } on Exception catch (e) {
      debugPrint('Cache de vídeo já estava limpo: $e');
    }
    try {
      final Directory dir = await _workDir();
      if (await dir.exists()) await dir.delete(recursive: true);
    } on FileSystemException catch (e) {
      debugPrint('Cache de envio já estava limpo: $e');
    }
  }

  /// Lê largura e altura pelo cabeçalho do arquivo, sem decodificar a
  /// imagem inteira na memória.
  static (int, int)? _readSize(File file) {
    try {
      final isg.Size size = isg.ImageSizeGetter.getSizeResult(
        isg.FileInput(file),
      ).size;
      if (size.width <= 0 || size.height <= 0) return null;
      // `needRotate` indica que o EXIF gira a foto: as dimensões visíveis
      // são as invertidas.
      return size.needRotate
          ? (size.height, size.width)
          : (size.width, size.height);
    } on Exception catch (e) {
      debugPrint('Não foi possível ler as dimensões: $e');
      return null;
    }
  }
}

class MediaOptimizationException implements Exception {
  const MediaOptimizationException(this.message);
  final String message;

  @override
  String toString() => message;
}
