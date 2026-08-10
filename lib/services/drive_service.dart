import 'dart:async';
import 'dart:convert';
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
///
/// ## O que este aplicativo NÃO alcança
///
/// O único escopo pedido é `drive.file` (veja [AuthService.driveScopes]), que
/// dá acesso **por arquivo, apenas ao que o próprio aplicativo criou**. Uma
/// pasta que já existia na conta é invisível daqui: não aparece em listagem
/// nenhuma, e um `files.get` no id dela responde 404. Isso não é uma escolha
/// do nosso código, é o que o Google impõe no servidor - o token que
/// recebemos não carrega permissão para o resto do Drive.
///
/// Por isso também nada aqui consulta a raiz do Drive. O id da pasta da
/// cápsula é guardado no Firestore e reaproveitado; quando falta, a pasta é
/// criada, nunca procurada. Uma consequência: se a pessoa já tiver uma pasta
/// com o mesmo nome, feita à mão, o aplicativo não a enxerga e cria a sua.
class DriveService {
  DriveService(this._auth);

  final AuthService _auth;

  /// A pasta única onde tudo do aplicativo vive, na raiz do Drive.
  ///
  /// O nome é distintivo de propósito: nada do aplicativo é criado fora
  /// daqui, e quem abrir o Drive precisa reconhecer de imediato o que é da
  /// cápsula e o que é dele.
  static const String rootFolderName = 'Meu Bebê - Cápsula do Tempo';
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

  /// Cria (ou reencontra) a pasta da cápsula e as seis de categoria.
  ///
  /// As pastas de idade - `Semana 07`, `Mês 14` - **não** são criadas aqui:
  /// seriam mais de cem chamadas no primeiro acesso. Elas nascem sob demanda
  /// em [ensureAgeFolder], no primeiro conteúdo daquela idade.
  Future<String> ensureRootStructure({String? knownRootId}) async {
    return _withApi((drive.DriveApi api) async {
      final String rootId = await _ensureRootFolder(api, knownRootId);
      await Future.wait(
        topLevelFolders.map((String name) => _ensureFolder(api, name, rootId)),
      );
      return rootId;
    });
  }

  /// Encontra ou cria a pasta da cápsula **sem consultar a raiz do Drive**.
  ///
  /// O id vem do Firestore, que é onde ele fica guardado desde o cadastro.
  /// Se ainda não existe, a pasta é criada direto. Em nenhum momento o
  /// aplicativo pergunta ao Drive o que mais existe na raiz da conta.
  Future<String> _ensureRootFolder(drive.DriveApi api, String? knownId) async {
    if (knownId != null && knownId.isNotEmpty) {
      try {
        final drive.File existing =
            await api.files.get(knownId, $fields: 'id,trashed') as drive.File;
        final String? id = existing.id;
        if (existing.trashed != true && id != null) return id;
      } on drive.DetailedApiRequestError catch (e) {
        // 404 é a pasta apagada de vez: cabe criar outra. Qualquer outro
        // erro é rede ou permissão, e criar uma segunda pasta aí seria
        // duplicar o acervo da pessoa por causa de uma falha passageira.
        if (e.status != 404) rethrow;
      }
    }
    return _createFolder(api, rootFolderName, null);
  }

  /// Pasta de uma categoria (`Fotos`, `Cartas`, ...) dentro da cápsula.
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

  /// Subpasta dentro da cápsula: `Fotos`, `Semana 07`.
  ///
  /// A busca aqui é sempre limitada a um `parentId` que o próprio aplicativo
  /// criou - nunca à raiz da conta. E, mesmo assim, o `drive.file` já
  /// devolveria apenas o que é nosso.
  Future<String> _ensureFolder(
    drive.DriveApi api,
    String name,
    String parentId,
  ) async {
    final String escaped = name.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

    final drive.FileList found = await api.files.list(
      q:
          "name = '$escaped' and mimeType = '$_folderMime' "
          "and '$parentId' in parents and trashed = false",
      $fields: 'files(id)',
      pageSize: 1,
    );
    final List<drive.File>? files = found.files;
    if (files != null && files.isNotEmpty && files.first.id != null) {
      return files.first.id!;
    }

    return _createFolder(api, name, parentId);
  }

  Future<String> _createFolder(
    drive.DriveApi api,
    String name,
    String? parentId,
  ) async {
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

  /// Cria ou atualiza um arquivo de texto, sempre pelo id quando ele existe.
  ///
  /// Devolve o id, que o chamador guarda no Firestore. É por isso que o
  /// arquivo é atualizado e não recriado: sem o id, cada gravação deixaria
  /// uma cópia nova na pasta e em um ano a pessoa teria trezentos
  /// `Informacoes.txt` empilhados.
  ///
  /// Um id que não existe mais (arquivo apagado à mão no Drive) responde 404,
  /// e aí um arquivo novo é criado. Qualquer outro erro sobe: criar um
  /// segundo arquivo por causa de uma falha de rede seria duplicar em
  /// silêncio.
  Future<String> upsertTextFile({
    required String folderId,
    required String name,
    required String content,
    String? knownFileId,
  }) async {
    final List<int> bytes = utf8.encode(content);
    // `text/plain; charset=utf-8` de propósito: sem o charset, o Drive
    // mostra acento quebrado na visualização dele, e o arquivo existe
    // justamente para ser lido lá dentro.
    const String mime = 'text/plain; charset=utf-8';

    return _withApi((drive.DriveApi api) async {
      if (knownFileId != null && knownFileId.isNotEmpty) {
        try {
          final drive.File atualizado = await api.files.update(
            drive.File(),
            knownFileId,
            uploadMedia: drive.Media(
              Stream<List<int>>.value(bytes),
              bytes.length,
              contentType: mime,
            ),
            $fields: 'id',
          );
          final String? id = atualizado.id;
          if (id != null) return id;
        } on drive.DetailedApiRequestError catch (e) {
          if (e.status != 404) rethrow;
        }
      }

      final drive.File criado = await api.files.create(
        drive.File(name: name, parents: <String>[folderId]),
        uploadMedia: drive.Media(
          Stream<List<int>>.value(bytes),
          bytes.length,
          contentType: mime,
        ),
        $fields: 'id',
      );
      final String? id = criado.id;
      if (id == null) {
        throw StateError('O Google Drive não devolveu o id de "$name".');
      }
      return id;
    });
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
        // `localPath` fica de fora de propósito: depois que o arquivo está no
        // Drive, guardar o caminho no aparelho de quem enviou só serviria
        // para gravar no banco algo como
        // `/storage/emulated/0/DCIM/Camera/IMG_20260801.jpg`, expondo a
        // estrutura de pastas do celular. A miniatura já foi salva sob o
        // `driveId`, então a exibição instantânea não depende mais disso.
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

  /// Baixa o conteúdo de um arquivo - usado para abrir documentos e
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

  /// Domínios para os quais é aceitável mandar o token de acesso do Drive.
  ///
  /// O cliente do `googleapis_auth` cola `Authorization: Bearer <token>` em
  /// **qualquer** requisição que passe por ele, sem olhar o destino. Como a
  /// URL da miniatura vem de dentro de uma resposta do servidor, e não do
  /// nosso código, ela é conferida antes de o token sair do aparelho.
  static const List<String> _allowedHosts = <String>[
    'google.com',
    'googleapis.com',
    'googleusercontent.com',
  ];

  /// Se é seguro mandar o token de acesso para este endereço.
  static bool isTrustedMediaHost(Uri url) {
    if (url.scheme != 'https') return false;
    final String host = url.host.toLowerCase();
    return _allowedHosts.any(
      (String allowed) => host == allowed || host.endsWith('.$allowed'),
    );
  }

  /// Baixa bytes de uma URL do Drive (miniatura) com autenticação.
  Future<List<int>> fetchBytes(Uri url) async {
    if (!isTrustedMediaHost(url)) {
      throw StateError('Endereço de miniatura fora do Google: ${url.host}');
    }

    final gapis.AuthClient client = await _auth.driveClient();
    try {
      // Sem seguir redirecionamento: o `package:http` repassa os cabeçalhos
      // ao seguir um 302, e é exatamente assim que um token vazaria para
      // fora do Google sem ninguém perceber.
      final http.Request request = http.Request('GET', url)
        ..followRedirects = false;
      final http.StreamedResponse response = await client.send(request);
      if (response.statusCode != 200) {
        throw StateError('Falha ao baixar (${response.statusCode}).');
      }
      return await response.stream.toBytes();
    } finally {
      client.close();
    }
  }
}
