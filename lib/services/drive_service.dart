import 'dart:async';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;

import '../models/entry.dart';
import 'auth_service.dart';

/// Quanto do Drive já foi usado, para a tela de Estatísticas.
class DriveQuota {
  const DriveQuota({required this.usedBytes, required this.limitBytes});
  final int usedBytes;
  final int? limitBytes;

  /// Fração de 0 a 1, ou `null` quando a conta não tem limite definido.
  double? get fraction {
    final int? limit = limitBytes;
    if (limit == null || limit <= 0) return null;
    return (usedBytes / limit).clamp(0.0, 1.0);
  }
}

/// Tudo que o aplicativo faz no Google Drive.
///
/// O Drive é só o armazém: a estrutura de pastas existe para que, daqui a
/// muitos anos, o acervo continue navegável mesmo sem o aplicativo.
class DriveService {
  DriveService(this._auth);

  final AuthService _auth;

  static const String rootFolderName = 'Meu Bebê';
  static const String _folderMime = 'application/vnd.google-apps.folder';

  /// Pastas de primeiro nível criadas no primeiro acesso.
  static const List<String> topLevelFolders = <String>[
    'Fotos',
    'Vídeos',
    'Cartas',
    'Desenhos',
    'Documentos',
    'Crescimento',
  ];

  Future<T> _withApi<T>(Future<T> Function(drive.DriveApi api) action) async {
    final gapis.AuthClient client = await _auth.driveClient();
    try {
      return await action(drive.DriveApi(client));
    } finally {
      client.close();
    }
  }

  /// Cria (ou reencontra) `Meu Bebê` e as seis pastas de categoria.
  ///
  /// As pastas de idade — `Semana 07`, `Mês 14` — **não** são criadas aqui:
  /// seriam mais de cem chamadas no primeiro acesso. Elas nascem sob demanda
  /// em [ensureAgeFolder], no primeiro conteúdo daquela idade.
  Future<String> ensureRootStructure() async {
    return _withApi((drive.DriveApi api) async {
      final String rootId = await _ensureFolder(api, rootFolderName, null);
      await Future.wait(
        topLevelFolders.map((String name) => _ensureFolder(api, name, rootId)),
      );
      return rootId;
    });
  }

  /// Pasta de uma categoria (`Fotos`, `Cartas`, ...) dentro de `Meu Bebê`.
  Future<String> ensureCategoryFolder(String rootId, String category) {
    return _withApi(
      (drive.DriveApi api) => _ensureFolder(api, category, rootId),
    );
  }

  /// Pasta de idade dentro de uma categoria: `Fotos/Semana 07`.
  Future<String> ensureAgeFolder({
    required String rootId,
    required String category,
    required String bucketName,
  }) {
    return _withApi((drive.DriveApi api) async {
      final String categoryId = await _ensureFolder(api, category, rootId);
      return _ensureFolder(api, bucketName, categoryId);
    });
  }

  Future<String> _ensureFolder(
    drive.DriveApi api,
    String name,
    String? parentId,
  ) async {
    final String escaped = name.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    final String parentClause = parentId == null
        ? "'root' in parents"
        : "'$parentId' in parents";

    final drive.FileList found = await api.files.list(
      q:
          "name = '$escaped' and mimeType = '$_folderMime' "
          'and $parentClause and trashed = false',
      $fields: 'files(id)',
      pageSize: 1,
    );
    final List<drive.File>? files = found.files;
    if (files != null && files.isNotEmpty && files.first.id != null) {
      return files.first.id!;
    }

    final drive.File created = await api.files.create(
      drive.File(
        name: name,
        mimeType: _folderMime,
        parents: parentId == null ? null : <String>[parentId],
      ),
      $fields: 'id',
    );
    final String? id = created.id;
    if (id == null) {
      throw StateError('O Google Drive não devolveu o id da pasta "$name".');
    }
    return id;
  }

  /// Envia um arquivo já otimizado para dentro de [folderId].
  ///
  /// Usa upload retomável: vídeos de alguns minutos não cabem numa única
  /// requisição e a conexão do celular cai com frequência.
  Future<EntryFile> uploadFile({
    required File file,
    required String folderId,
    required String name,
    required String mimeType,
    int? width,
    int? height,
    int? durationSeconds,
    String? originalPath,
    void Function(int sent, int total)? onProgress,
  }) async {
    final int length = await file.length();
    final Stream<List<int>> stream = onProgress == null
        ? file.openRead()
        : _trackProgress(file.openRead(), length, onProgress);

    return _withApi((drive.DriveApi api) async {
      final drive.File created = await api.files.create(
        drive.File(name: name, parents: <String>[folderId]),
        uploadMedia: drive.Media(stream, length, contentType: mimeType),
        uploadOptions: drive.ResumableUploadOptions(),
        $fields: 'id,name,size,mimeType',
      );
      final String? id = created.id;
      if (id == null) {
        throw StateError('O Google Drive não devolveu o id de "$name".');
      }
      return EntryFile(
        driveId: id,
        name: created.name ?? name,
        mimeType: created.mimeType ?? mimeType,
        sizeBytes: int.tryParse(created.size ?? '') ?? length,
        width: width,
        height: height,
        durationSeconds: durationSeconds,
        localPath: originalPath,
      );
    });
  }

  Stream<List<int>> _trackProgress(
    Stream<List<int>> source,
    int total,
    void Function(int sent, int total) onProgress,
  ) async* {
    int sent = 0;
    await for (final List<int> chunk in source) {
      sent += chunk.length;
      onProgress(sent, total);
      yield chunk;
    }
  }

  /// Baixa o conteúdo de um arquivo — usado para abrir documentos e
  /// compartilhar mídia.
  Future<File> downloadTo(String driveId, File target) async {
    final gapis.AuthClient client = await _auth.driveClient();
    try {
      final drive.DriveApi api = drive.DriveApi(client);
      final drive.Media media =
          await api.files.get(
                driveId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      await target.parent.create(recursive: true);
      final IOSink sink = target.openWrite();
      try {
        await media.stream.pipe(sink);
      } finally {
        await sink.close();
      }
      return target;
    } finally {
      client.close();
    }
  }

  /// URL de leitura direta do arquivo. Precisa acompanhar [authHeaders].
  static Uri mediaUrl(String driveId) =>
      Uri.parse('https://www.googleapis.com/drive/v3/files/$driveId?alt=media');

  /// Cabeçalho `Authorization` para exibir imagens e tocar vídeos do Drive
  /// direto no aplicativo, sem baixar antes.
  Future<Map<String, String>> authHeaders() async {
    final gapis.AuthClient client = await _auth.driveClient();
    try {
      return <String, String>{
        'Authorization':
            '${client.credentials.accessToken.type} '
            '${client.credentials.accessToken.data}',
      };
    } finally {
      client.close();
    }
  }

  /// Miniatura gerada pelo próprio Drive. Serve de reserva quando a
  /// miniatura local não existe (outro aparelho, app reinstalado).
  Future<String?> thumbnailLink(String driveId) async {
    return _withApi((drive.DriveApi api) async {
      final drive.File file =
          await api.files.get(driveId, $fields: 'thumbnailLink') as drive.File;
      return file.thumbnailLink;
    });
  }

  /// Manda para a lixeira do Drive (reversível por 30 dias).
  Future<void> setTrashed(String driveId, {required bool trashed}) {
    return _withApi(
      (drive.DriveApi api) =>
          api.files.update(drive.File(trashed: trashed), driveId),
    );
  }

  Future<void> deleteForever(String driveId) {
    return _withApi((drive.DriveApi api) => api.files.delete(driveId));
  }

  Future<DriveQuota> quota() {
    return _withApi((drive.DriveApi api) async {
      final drive.About about = await api.about.get($fields: 'storageQuota');
      final drive.AboutStorageQuota? q = about.storageQuota;
      return DriveQuota(
        usedBytes: int.tryParse(q?.usage ?? '') ?? 0,
        limitBytes: int.tryParse(q?.limit ?? ''),
      );
    });
  }

  /// Baixa bytes de uma URL do Drive (miniatura) com autenticação.
  Future<List<int>> fetchBytes(Uri url) async {
    final gapis.AuthClient client = await _auth.driveClient();
    try {
      final http.Response response = await client.get(url);
      if (response.statusCode != 200) {
        throw StateError('Falha ao baixar (${response.statusCode}).');
      }
      return response.bodyBytes;
    } finally {
      client.close();
    }
  }
}
