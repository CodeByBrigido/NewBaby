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

  /// Pede o consentimento do Drive quando ele faltar, com a tela do Google.
  ///
  /// Só para o "Tentar de novo": o caminho normal do envio não pode abrir
  /// tela nenhuma. Veja [AuthService.garantirPermissaoDoDrive].
  Future<void> garantirPermissao() => _auth.garantirPermissaoDoDrive();

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

  /// Encontra ou cria a pasta da cápsula.
  ///
  /// Três tentativas, nesta ordem, e a ordem é o que impede o acervo de se
  /// partir em pedaços:
  ///
  /// 1. o id guardado no Firestore, que é o caminho normal;
  /// 2. **procurar pelo nome**, para o caso de o id não existir mais deste
  ///    lado: reinstalar o aplicativo, entrar de novo depois de apagar a
  ///    conta, ou cadastrar numa conta que já tinha usado o aplicativo;
  /// 3. só então criar.
  ///
  /// O passo 2 faltava, e o resultado aparecia no Drive da pessoa como uma
  /// fila de pastas com o mesmo nome, uma por tentativa de cadastro, cada
  /// uma com um pedaço da infância dentro.
  ///
  /// Procurar aqui **não** é bisbilhotar o Drive de ninguém. O escopo é
  /// `drive.file`, então esta consulta só enxerga o que este aplicativo
  /// criou: uma pasta com este nome feita por outra pessoa, ou pelo próprio
  /// dono à mão, é invisível para ela. A restrição é do servidor do Google,
  /// não uma promessa nossa.
  Future<String> _ensureRootFolder(drive.DriveApi api, String? knownId) async {
    if (knownId != null && knownId.isNotEmpty) {
      try {
        final drive.File existing =
            await api.files.get(knownId, $fields: 'id,trashed') as drive.File;
        final String? id = existing.id;
        if (existing.trashed != true && id != null) return id;
      } on drive.DetailedApiRequestError catch (e) {
        // 404 é a pasta apagada de vez: cabe procurar outra. Qualquer outro
        // erro é rede ou permissão, e seguir adiante aí seria duplicar o
        // acervo da pessoa por causa de uma falha passageira.
        if (e.status != 404) rethrow;
      }
    }

    final String? encontrada = await _procurarRaiz(api);
    if (encontrada != null) return encontrada;

    return _createFolder(api, rootFolderName, null);
  }

  /// A cápsula que já existe nesta conta, se existir.
  ///
  /// Sem filtro de pasta-mãe de propósito: quem arrastou a cápsula para
  /// dentro de outra pasta do próprio Drive continua com a mesma cápsula, e
  /// exigir que ela esteja na raiz criaria uma segunda.
  ///
  /// Entre várias, a mais antiga. É a que tem mais chance de guardar o
  /// acervo de verdade; as outras nasceram das tentativas seguintes.
  Future<String?> _procurarRaiz(drive.DriveApi api) async {
    final String escaped = rootFolderName
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'");

    final drive.FileList found = await api.files.list(
      q:
          "name = '$escaped' and mimeType = '$_folderMime' "
          'and trashed = false',
      orderBy: 'createdTime',
      $fields: 'files(id)',
      pageSize: 1,
    );
    final List<drive.File>? files = found.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }

  /// Pasta de uma categoria (`Fotos`, `Cartas`, ...) dentro da cápsula.
  Future<String> ensureCategoryFolder(String rootId, String category) {
    return _withApi(
      (drive.DriveApi api) => _ensureFolder(api, category, rootId),
    );
  }

  /// Percorre (criando o que faltar) uma sequência de subpastas.
  ///
  /// `['Fotos', 'Ano 0', 'Mês 07']` devolve o id da última.
  ///
  /// Cria sob demanda, nível a nível, e nunca em lote: o primeiro acesso de
  /// uma criança de cinco anos precisaria de mais de sessenta chamadas para
  /// criar pastas que talvez nunca recebam nada. A pasta do período nasce
  /// junto com o primeiro conteúdo dele, e é por isso que não há pasta vazia
  /// no Drive de quem acabou de se cadastrar.
  /// Devolve um id por nível, e não só o do fim: quem chama guarda todos no
  /// cache, e é isso que permite mais tarde perguntar se o **ano** ficou
  /// vazio depois de o último mês dele sair.
  Future<List<String>> ensureFolderPath(String rootId, List<String> caminho) {
    return _withApi((drive.DriveApi api) async {
      final List<String> ids = <String>[];
      String id = rootId;
      for (final String nome in caminho) {
        id = await _ensureFolder(api, nome, id);
        ids.add(id);
      }
      return ids;
    });
  }

  /// Muda um arquivo de pasta, sem copiar nem reenviar.
  ///
  /// O Drive guarda a pasta como uma propriedade do arquivo, então mover é
  /// trocar essa propriedade: o conteúdo não sobe de novo, o id continua o
  /// mesmo, e tudo que o aplicativo guardou sobre ele continua valendo.
  ///
  /// Devolve `false` quando o arquivo já estava no destino, para quem chama
  /// poder contar o que de fato mudou.
  Future<bool> moverPara(String fileId, String destinoId) {
    return _withApi((drive.DriveApi api) async {
      final drive.File atual =
          await api.files.get(fileId, $fields: 'parents') as drive.File;
      final List<String> pais = atual.parents ?? const <String>[];
      if (pais.length == 1 && pais.single == destinoId) return false;

      await api.files.update(
        drive.File(),
        fileId,
        addParents: destinoId,
        // Sai de todas as anteriores. Um arquivo com duas pastas-mãe aparece
        // nos dois lugares no Drive, e a bagunça que a reorganização veio
        // desfazer voltaria em dobro.
        removeParents: pais.where((String p) => p != destinoId).join(','),
        $fields: 'id',
      );
      return true;
    });
  }

  /// Se a pasta não tem mais nada dentro, contando o que está na lixeira
  /// como fora.
  Future<bool> pastaVazia(String folderId) {
    return _withApi((drive.DriveApi api) async {
      final drive.FileList filhos = await api.files.list(
        q: "'$folderId' in parents and trashed = false",
        $fields: 'files(id)',
        pageSize: 1,
      );
      return (filhos.files ?? const <drive.File>[]).isEmpty;
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
