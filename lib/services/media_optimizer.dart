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
/// * foto - metade da resolução, qualidade visual preservada;
/// * vídeo - sempre 720p com bitrate otimizado;
/// * o original permanece no celular e o temporário é apagado após o envio.
class MediaOptimizer {
  MediaOptimizer({this.imageQuality = 88});

  /// 88 mantém a foto visualmente idêntica com um arquivo bem menor.
  final int imageQuality;

  /// Abaixo disso reduzir pela metade estraga a foto sem economizar nada.
  static const int _minDimension = 640;

  Future<Directory> _workDir() async {
    final Directory base = await getTemporaryDirectory();
    final Directory dir = Directory(p.join(base.path, 'meu_bebe_envio'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Uma cópia reduzida da imagem, para caber num documento do Firestore.
  ///
  /// Existe porque quem foi convidado não alcança o Drive: o escopo
  /// `drive.file` não enxerga arquivos que o aplicativo dela não criou. Então
  /// a imagem que ela vê precisa vir do Firestore, e um documento do
  /// Firestore não passa de 1 MiB.
  ///
  /// A qualidade cede até caber, e nunca o contrário. Uma foto que não coube
  /// é uma foto que a avó não vê; uma foto um pouco mais comprimida é uma
  /// foto que ela vê. Devolve `null` só se nem no pior aperto couber, o que
  /// na prática não acontece com foto de celular.
  Future<File?> derive(
    File source, {
    required int maxDimension,
    required int maxBytes,
    int quality = 80,
  }) async {
    final Directory dir = await _workDir();
    // Três tentativas, cada uma cedendo qualidade. Mais que isso é gastar
    // processamento para ganhar quilobytes que ninguém percebe.
    for (final int q in <int>[quality, quality - 20, quality - 35]) {
      if (q < 20) break;
      final String target = p.join(
        dir.path,
        '${DateTime.now().microsecondsSinceEpoch}_d$q.jpg',
      );
      try {
        final XFile? result = await FlutterImageCompress.compressAndGetFile(
          source.path,
          target,
          quality: q,
          minWidth: maxDimension,
          minHeight: maxDimension,
          keepExif: false,
          format: CompressFormat.jpeg,
        );
        if (result == null) continue;
        final File file = File(result.path);
        if (await file.length() <= maxBytes) return file;
        await file.delete();
      } on Exception catch (e) {
        debugPrint('Cópia reduzida falhou em q$q: $e');
      }
    }
    return null;
  }

  /// Reduz a foto para ~50% da resolução original.
  Future<OptimizedMedia> optimizeImage(File source) async {
    final int originalBytes = await source.length();
    final Directory dir = await _workDir();
    final String target = p.join(
      dir.path,
      '${DateTime.now().microsecondsSinceEpoch}_${p.basenameWithoutExtension(source.path)}.jpg',
    );

    final (int, int)? size = _readSize(source);
    // Sem as dimensões não dá para calcular a metade; o compressor então
    // trabalha só com a qualidade, que já reduz bastante.
    final int targetWidth = size == null ? 0 : (size.$1 / 2).round();
    final int targetHeight = size == null ? 0 : (size.$2 / 2).round();
    final bool worthResizing =
        size != null && (size.$1 > _minDimension || size.$2 > _minDimension);

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      source.path,
      target,
      quality: imageQuality,
      minWidth: worthResizing ? targetWidth : (size?.$1 ?? 1080),
      minHeight: worthResizing ? targetHeight : (size?.$2 ?? 1080),
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
      throw const MediaOptimizationException(
        'Não foi possível comprimir esta foto.',
      );
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

  /// Converte o vídeo para 720p com bitrate otimizado.
  Future<OptimizedMedia> optimizeVideo(File source) async {
    final int originalBytes = await source.length();

    final MediaInfo? info = await VideoCompress.compressVideo(
      source.path,
      quality: VideoQuality.Res1280x720Quality,
      includeAudio: true,
      // O vídeo original é da família: nunca apagamos nada da galeria.
      deleteOrigin: false,
    );

    final String? path = info?.path;
    if (path == null) {
      throw const MediaOptimizationException(
        'Não foi possível converter este vídeo.',
      );
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
