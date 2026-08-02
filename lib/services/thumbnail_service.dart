import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'drive_service.dart';

/// Onde a interface busca miniaturas.
///
/// A abstração existe para que as telas possam ser montadas em teste sem
/// Firebase nem Google Drive por trás.
abstract interface class ThumbnailStore {
  /// Guarda a miniatura gerada durante o envio.
  Future<void> store(String driveId, File thumbnail);

  /// Miniatura já disponível localmente, sem tocar na rede.
  Future<File?> cached(String driveId);

  /// Miniatura local ou, se não houver, a que o próprio Drive gerou.
  Future<File?> resolve(String driveId);

  Future<void> clear();
}

/// Miniaturas em disco, indexadas pelo id do arquivo no Drive.
///
/// No aparelho que enviou, a miniatura é gravada no momento do envio e a
/// linha do tempo nunca espera a rede. Em outro aparelho, ela é buscada uma
/// vez no Drive e fica em cache para sempre.
class ThumbnailService implements ThumbnailStore {
  ThumbnailService(this._drive);

  final DriveService _drive;

  /// Evita que duas células da mesma grade baixem a mesma miniatura.
  final Map<String, Future<File?>> _inFlight = <String, Future<File?>>{};

  Directory? _dir;

  Future<Directory> _cacheDir() async {
    final Directory? cached = _dir;
    if (cached != null) return cached;
    final Directory base = await getApplicationSupportDirectory();
    final Directory dir = Directory(p.join(base.path, 'miniaturas'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return _dir = dir;
  }

  Future<File> _fileFor(String driveId) async {
    final Directory dir = await _cacheDir();
    return File(p.join(dir.path, '$driveId.jpg'));
  }

  @override
  Future<void> store(String driveId, File thumbnail) async {
    try {
      final File target = await _fileFor(driveId);
      await thumbnail.copy(target.path);
    } on FileSystemException catch (e) {
      debugPrint('Não foi possível guardar a miniatura: $e');
    }
  }

  @override
  Future<File?> cached(String driveId) async {
    final File file = await _fileFor(driveId);
    return await file.exists() ? file : null;
  }

  @override
  Future<File?> resolve(String driveId) {
    return _inFlight.putIfAbsent(driveId, () async {
      try {
        final File? local = await cached(driveId);
        if (local != null) return local;

        final String? link = await _drive.thumbnailLink(driveId);
        if (link == null) return null;

        // Os links do Drive vêm num tamanho pequeno; `=s600` pede uma versão
        // boa o suficiente para a grade e para o cartão da linha do tempo.
        final Uri url = Uri.parse(
          link.replaceFirst(RegExp(r'=s\d+$'), '=s600'),
        );
        final List<int> bytes = await _drive.fetchBytes(url);

        final File target = await _fileFor(driveId);
        await target.writeAsBytes(bytes, flush: true);
        return target;
      } on Exception catch (e) {
        debugPrint('Miniatura indisponível para $driveId: $e');
        return null;
      } finally {
        // Deixa uma nova tentativa possível se algo falhou.
        scheduleMicrotask(() => _inFlight.remove(driveId));
      }
    });
  }

  @override
  Future<void> clear() async {
    try {
      final Directory dir = await _cacheDir();
      if (await dir.exists()) await dir.delete(recursive: true);
      _dir = null;
    } on FileSystemException catch (e) {
      debugPrint('Cache de miniaturas já estava limpo: $e');
    }
  }
}
