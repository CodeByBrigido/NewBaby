import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'drive_service.dart';
import 'firestore_service.dart';

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
/// linha do tempo nunca espera a rede. Em outro aparelho, ela vem do
/// Firestore, e só em último caso do Drive.
///
/// A ordem das três fontes não é arbitrária:
///
/// 1. **Disco.** Instantâneo, e é o caso de quase toda abertura.
/// 2. **Firestore.** Funciona para qualquer pessoa que possa ler a entrada,
///    inclusive quem foi convidado - e é a única que funciona para ela. O
///    escopo `drive.file` não alcança arquivos que este aplicativo não criou
///    naquele aparelho, então para o familiar o passo 3 sempre responderia
///    404.
/// 3. **Drive.** Só para quem é dono. Cobre o acervo antigo, gravado antes
///    de as miniaturas passarem pelo Firestore.
class ThumbnailService implements ThumbnailStore {
  ThumbnailService({
    required this.drive,
    required this.firestore,
    required String? capsuleOwner,
    required this.canUseDrive,
  }) : _owner = capsuleOwner;

  final DriveService drive;
  final FirestoreService firestore;

  /// De quem é a cápsula aberta: é sob ela que as miniaturas vivem.
  final String? _owner;

  /// Falso para quem foi convidado. Não é economia, é a única saída: a
  /// chamada ao Drive responderia 404 e ainda gastaria uma ida à rede por
  /// imagem, em toda rolagem.
  final bool canUseDrive;

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

  /// A miniatura guardada no Firestore, já copiada para o disco.
  ///
  /// Copiar para o disco importa: sem isso, cada rolagem da grade cobraria
  /// uma leitura do Firestore por imagem. Assim a segunda abertura é local.
  Future<File?> _doFirestore(String driveId) async {
    final String? uid = _owner;
    if (uid == null) return null;

    final Uint8List? bytes = await firestore.loadThumbnail(uid, driveId);
    if (bytes == null || bytes.isEmpty) return null;

    final File target = await _fileFor(driveId);
    await target.writeAsBytes(bytes, flush: true);
    return target;
  }

  @override
  Future<File?> resolve(String driveId) {
    return _inFlight.putIfAbsent(driveId, () async {
      try {
        final File? local = await cached(driveId);
        if (local != null) return local;

        final File? doFirestore = await _doFirestore(driveId);
        if (doFirestore != null) return doFirestore;

        if (!canUseDrive) return null;

        final String? link = await drive.thumbnailLink(driveId);
        if (link == null) return null;

        // Os links do Drive vêm num tamanho pequeno; `=s600` pede uma versão
        // boa o suficiente para a grade e para o cartão da linha do tempo.
        final Uri url = Uri.parse(
          link.replaceFirst(RegExp(r'=s\d+$'), '=s600'),
        );
        final List<int> bytes = await drive.fetchBytes(url);

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
