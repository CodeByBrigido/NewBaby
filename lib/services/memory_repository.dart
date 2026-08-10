import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/l10n/informacoes.dart';
import '../core/utils/age_calculator.dart';
import '../core/utils/error_text.dart';
import '../core/utils/formatters.dart';
import '../models/baby_profile.dart';
import '../models/entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'drive_service.dart';
import 'firestore_service.dart';

import 'media_optimizer.dart';
import 'thumbnail_service.dart';

/// Um arquivo escolhido pelo usuário, esperando para ser otimizado e enviado.
@immutable
class PendingFile {
  const PendingFile({
    required this.path,
    required this.kind,
    this.mimeType,
    this.name,
  });

  final String path;
  final EntryType kind;
  final String? mimeType;
  final String? name;
}

/// Progresso de um envio, para a barra da linha do tempo.
@immutable
class UploadProgress {
  const UploadProgress({
    required this.entryId,
    required this.status,
    this.done = 0,
    this.total = 0,
    this.message,
  });

  final String entryId;
  final UploadStatus status;
  final int done;
  final int total;
  final String? message;

  double? get fraction => total == 0 ? null : (done / total).clamp(0.0, 1.0);
}

/// Orquestra o caminho completo de uma memória: escolher → otimizar →
/// criar a pasta certa → enviar ao Drive → registrar na linha do tempo.
///
/// A entrada é gravada no Firestore **antes** do upload. Assim ela aparece
/// na hora, com a miniatura local, e o envio acontece em segundo plano - que
/// é o que faz o aplicativo parecer instantâneo mesmo com internet ruim.
class MemoryRepository {
  MemoryRepository({
    required this.firestore,
    required this.drive,
    required this.optimizer,
    required this.thumbnails,
  });

  final FirestoreService firestore;
  final DriveService drive;
  final MediaOptimizer optimizer;
  final ThumbnailStore thumbnails;

  static const Uuid _uuid = Uuid();

  final StreamController<UploadProgress> _progress =
      StreamController<UploadProgress>.broadcast();

  /// Acompanha os envios em andamento.
  Stream<UploadProgress> get progress => _progress.stream;

  // -------------------------------------------------- informacoes.txt

  /// Nome do arquivo legível na pasta da cápsula.
  ///
  /// Sem acento no nome de propósito: ele é digitado em endereço, aparece em
  /// terminal e viaja entre sistemas de arquivos que ainda tratam acento de
  /// formas diferentes. O conteúdo tem acento; o nome não precisa.
  static const String infoFileName = 'Informacoes.txt';

  /// Reescreve o `Informacoes.txt` na pasta da cápsula.
  ///
  /// Chamado no cadastro e a cada medição de crescimento. Reescreve o arquivo
  /// inteiro, e não acrescenta linha: o arquivo é uma fotografia do estado
  /// atual, e assim uma medição corrigida ou apagada aparece corrigida em vez
  /// de deixar rastro contraditório.
  ///
  /// **Falhar aqui não pode derrubar nada.** O Firestore é a fonte da
  /// verdade, e este arquivo é uma cópia legível: perder uma gravação dele
  /// custa um arquivo desatualizado até a próxima medição, e não um dado.
  /// Por isso o `catch` é largo e o retorno é o perfil que entrou.
  Future<BabyProfile> escreverInformacoes(
    String uid,
    BabyProfile profile,
  ) async {
    final String? rootId = profile.rootFolderId;
    if (rootId == null || rootId.isEmpty) return profile;

    try {
      final List<Entry> medicoes = await firestore.loadEntriesOfType(
        uid,
        EntryType.growth,
      );
      final String texto = informacoesDaCrianca(
        profile: profile,
        growth: medicoes,
        now: DateTime.now(),
      );
      final String id = await drive.upsertTextFile(
        folderId: rootId,
        name: infoFileName,
        content: texto,
        knownFileId: profile.infoFileId,
      );

      // Só grava no Firestore quando o id mudou, que é a primeira vez e o
      // caso raro de o arquivo ter sido apagado à mão no Drive. Nas outras
      // vezes é uma escrita que não muda nada.
      if (id == profile.infoFileId) return profile;
      final BabyProfile atualizado = profile.copyWith(infoFileId: id);
      await firestore.saveProfile(uid, atualizado);
      return atualizado;
    } on Object catch (e) {
      debugPrint('Informacoes.txt não foi atualizado: $e');
      return profile;
    }
  }

  // ------------------------------------------------------------ cadastro

  /// Cria a estrutura de pastas e grava o cadastro inicial.
  Future<BabyProfile> setUpBaby({
    required String uid,
    required BabyProfile profile,
    File? birthPhoto,
  }) async {
    final String rootId = await drive.ensureRootStructure(
      knownRootId: profile.rootFolderId,
    );
    BabyProfile saved = profile.copyWith(rootFolderId: rootId);
    await firestore.saveProfile(uid, saved);

    // O nascimento é o primeiro item da linha do tempo, sempre.
    await _createBirthEntry(uid, saved);

    // O arquivo legível nasce junto da pasta, ainda sem medição nenhuma.
    // Quem abrir o Drive no dia seguinte ao cadastro já encontra o nome, a
    // data de nascimento e o peso, e não só uma pasta com fotos.
    saved = await escreverInformacoes(uid, saved);

    if (birthPhoto != null) {
      try {
        await addFiles(
          uid: uid,
          profile: saved,
          type: EntryType.photo,
          files: <PendingFile>[
            PendingFile(path: birthPhoto.path, kind: EntryType.photo),
          ],
          date: saved.birth,
          title: 'Primeira foto',
        );
        // Aqui não adianta gravar `photoDriveId`: `addFiles` volta antes de
        // o envio terminar, então o id ainda é vazio. O avatar é derivado
        // das entradas (veja `avatarPhotoProvider`) e aparece sozinho quando
        // o envio conclui. O campo continua no cadastro para quando houver
        // escolha manual de foto de perfil.
      } on Exception catch (e) {
        // O cadastro não pode falhar por causa da foto; ela pode ser
        // adicionada depois pela linha do tempo.
        debugPrint('Foto de nascimento não enviada: $e');
      }
    }

    return saved;
  }

  Future<void> _createBirthEntry(String uid, BabyProfile profile) async {
    final DateTime birth = profile.birth;
    final AgeBucket bucket = AgeCalculator.bucketAt(birth, birth);
    await firestore.createEntry(
      uid,
      Entry(
        id: '',
        type: EntryType.birth,
        date: birth,
        createdAt: DateTime.now(),
        ageDays: 0,
        bucketKey: bucket.key,
        bucketName: bucket.folderName,
        title: 'Nascimento',
        description: profile.hospital,
        growth:
            profile.birthWeightGrams != null && profile.birthHeightCm != null
            ? GrowthData(
                weightGrams: profile.birthWeightGrams!,
                heightCm: profile.birthHeightCm!,
              )
            : null,
      ),
    );
  }

  // -------------------------------------------------------------- envios

  /// Cria uma entrada com arquivos e dispara o envio em segundo plano.
  ///
  /// Retorna assim que a entrada existe no Firestore - a interface não
  /// espera o upload.
  Future<Entry> addFiles({
    required String uid,
    required BabyProfile profile,
    required EntryType type,
    required List<PendingFile> files,
    DateTime? date,
    String? title,
    String? description,
  }) async {
    final DateTime when = date ?? DateTime.now();
    final Age age = AgeCalculator.ageAt(profile.birth, when);
    final AgeBucket bucket = AgeCalculator.bucketAt(profile.birth, when);
    final String entryId = _uuid.v4();

    // Placeholders com o caminho local: a miniatura aparece imediatamente,
    // antes de existir qualquer id do Drive.
    final List<EntryFile> placeholders = files
        .map(
          (PendingFile f) => EntryFile(
            driveId: '',
            name: f.name ?? p.basename(f.path),
            mimeType: f.mimeType ?? _guessMime(f.path, type),
            sizeBytes: 0,
            localPath: f.path,
          ),
        )
        .toList();

    final Entry entry = Entry(
      id: entryId,
      type: type,
      date: when,
      createdAt: DateTime.now(),
      ageDays: age.totalDays,
      bucketKey: bucket.key,
      bucketName: bucket.folderName,
      title: title,
      description: description,
      files: placeholders,
      uploadStatus: UploadStatus.pending,
    );

    await firestore.createEntry(uid, entry);
    unawaited(_processUpload(uid, profile, entry, files, bucket));
    return entry;
  }

  Future<void> _processUpload(
    String uid,
    BabyProfile profile,
    Entry entry,
    List<PendingFile> pending,
    AgeBucket bucket,
  ) async {
    final List<OptimizedMedia> temporaries = <OptimizedMedia>[];
    try {
      _emit(entry.id, UploadStatus.optimizing);
      await firestore.patchEntry(uid, entry.id, <String, Object?>{
        'uploadStatus': UploadStatus.optimizing.id,
      });

      final String folderId = await _resolveFolder(
        uid: uid,
        profile: profile,
        type: entry.type,
        bucket: bucket,
      );

      _emit(entry.id, UploadStatus.uploading, total: pending.length);
      await firestore.patchEntry(uid, entry.id, <String, Object?>{
        'uploadStatus': UploadStatus.uploading.id,
      });

      final List<EntryFile> uploaded = <EntryFile>[];
      for (int i = 0; i < pending.length; i++) {
        final PendingFile item = pending[i];
        final OptimizedMedia media = await _optimize(item, entry.type);
        temporaries.add(media);

        final EntryFile file = await drive.uploadFile(
          file: media.file,
          folderId: folderId,
          name: _driveFileName(entry.date, item, media, i),
          mimeType: media.mimeType,
          width: media.width,
          height: media.height,
          durationSeconds: media.durationSeconds,
        );

        final File? thumb = media.thumbnail;
        if (thumb != null) await thumbnails.store(file.driveId, thumb);

        uploaded.add(file);
        _emit(
          entry.id,
          UploadStatus.uploading,
          done: i + 1,
          total: pending.length,
        );
      }

      await firestore.patchEntry(uid, entry.id, <String, Object?>{
        // A lista substitui os placeholders: com os ids definitivos do Drive
        // e sem o `caminhoLocal`, que só fazia falta enquanto o envio não
        // tinha terminado.
        'arquivos': uploaded.map((EntryFile f) => f.toMap()).toList(),
        'uploadStatus': UploadStatus.ready.id,
        'erro': null,
      });
      _emit(
        entry.id,
        UploadStatus.ready,
        done: pending.length,
        total: pending.length,
      );

      // Só depois de o Firestore já ter os ids do Drive: a partir daqui a
      // miniatura vem do cache por driveId e a cópia do seletor não faz
      // mais falta. Antes disso ela ainda é a fonte da imagem na tela.
      for (final PendingFile item in pending) {
        await _discardPickedCopy(item.path);
      }
    } on Exception catch (e) {
      // A mensagem é traduzida antes de sair daqui. O texto cru da exceção
      // traz caminho de arquivo e id do Drive, e este campo não é passageiro:
      // fica gravado no Firestore, ou seja, no servidor de quem publicou.
      final String message = userMessage(e, context: 'Envio de ${entry.id}');
      await firestore.patchEntry(uid, entry.id, <String, Object?>{
        'uploadStatus': UploadStatus.failed.id,
        'erro': message,
      });
      _emit(entry.id, UploadStatus.failed, message: message);
    } finally {
      // O comprimido é descartável; o original do usuário nunca é tocado.
      for (final OptimizedMedia media in temporaries) {
        if (media.file.path != media.originalPath) await media.dispose();
      }
    }
  }

  /// Apaga a cópia que o seletor deixou no cache do aplicativo.
  ///
  /// O `image_picker` e o `file_picker` não entregam o arquivo da galeria:
  /// eles copiam para `{cache}/{uuid}/{nome}` e devolvem esse caminho. A cópia
  /// tem a resolução original e ninguém a apaga - sem isto, cada foto
  /// escolhida deixa uma segunda via inteira no aparelho, para sempre.
  ///
  /// Só apaga o que está **dentro** do diretório temporário do aplicativo. O
  /// arquivo da galeria nunca é tocado: é dele que a promessa "o original
  /// continua no celular, intacto" depende.
  ///
  /// Em envio que falhou isto não roda: o caminho é o que o reenvio usa.
  /// Se [path] está mesmo dentro do cache do aplicativo.
  ///
  /// É a única coisa que separa "apagar a cópia do seletor" de "apagar a foto
  /// da família". Fica isolada e testada por isso.
  static bool isInsideAppCache(String cacheRoot, String path) =>
      p.isWithin(cacheRoot, path);

  Future<void> _discardPickedCopy(String path) async {
    try {
      final Directory temp = await getTemporaryDirectory();
      if (!isInsideAppCache(temp.path, path)) return;

      final File file = File(path);
      if (!await file.exists()) return;
      await file.delete();

      // Cada escolha ganha uma pasta com um uuid; vazia, ela só ocupa espaço.
      final Directory parent = file.parent;
      if (isInsideAppCache(temp.path, parent.path) &&
          await parent.list().isEmpty) {
        await parent.delete();
      }
    } on FileSystemException catch (e) {
      debugPrint('Cópia do seletor não pôde ser apagada: $e');
    }
  }

  /// Reenvia uma entrada que falhou, reaproveitando os arquivos originais.
  Future<void> retry(String uid, BabyProfile profile, Entry entry) async {
    final List<PendingFile> pending = entry.files
        .where((EntryFile f) => f.localPath != null)
        .map(
          (EntryFile f) => PendingFile(
            path: f.localPath!,
            kind: entry.type,
            mimeType: f.mimeType,
            name: f.name,
          ),
        )
        .toList();

    if (pending.length != entry.files.length) {
      // Os originais estão em outro aparelho - não há como reenviar daqui.
      await firestore.patchEntry(uid, entry.id, <String, Object?>{
        'uploadStatus': UploadStatus.failed.id,
        'erro':
            'Os arquivos originais não estão neste aparelho. '
            'Reenvie a partir do celular onde eles foram escolhidos.',
      });
      return;
    }

    final AgeBucket bucket = AgeCalculator.bucketAt(profile.birth, entry.date);
    await _processUpload(uid, profile, entry, pending, bucket);
  }

  Future<OptimizedMedia> _optimize(PendingFile item, EntryType type) {
    final File file = File(item.path);
    return switch (type) {
      EntryType.video => optimizer.optimizeVideo(file),
      EntryType.photo || EntryType.drawing => optimizer.optimizeImage(file),
      _ => optimizer.passthrough(
        file,
        item.mimeType ?? _guessMime(item.path, type),
      ),
    };
  }

  /// Encontra (ou cria) a pasta de destino, guardando o id para a próxima vez.
  Future<String> _resolveFolder({
    required String uid,
    required BabyProfile profile,
    required EntryType type,
    required AgeBucket bucket,
  }) async {
    final String rootId =
        profile.rootFolderId ??
        await drive.ensureRootStructure(knownRootId: profile.rootFolderId);

    final String key = type.bucketsByAge
        ? '${type.folder}/${bucket.folderName}'
        : type.folder;

    final String? cached = await firestore.folderId(uid, key);
    if (cached != null && cached.isNotEmpty) return cached;

    final String folderId = type.bucketsByAge
        ? await drive.ensureAgeFolder(
            rootId: rootId,
            category: type.folder,
            bucketName: bucket.folderName,
          )
        : await drive.ensureCategoryFolder(rootId, type.folder);

    await firestore.rememberFolder(uid, key, folderId);
    return folderId;
  }

  /// Nome estável e ordenável dentro da pasta: `2027-04-22_143500_1.jpg`.
  String _driveFileName(
    DateTime date,
    PendingFile item,
    OptimizedMedia media,
    int index,
  ) {
    final String stamp = Fmt.fileStamp(date);
    final String extension = p.extension(
      media.file.path.isEmpty ? item.path : media.file.path,
    );
    final String suffix = index == 0 ? '' : '_${index + 1}';
    return '$stamp$suffix${extension.isEmpty ? '' : extension}';
  }

  // -------------------------------------------------- entradas sem arquivo

  /// Carta: o texto vai para o índice e também para um `.txt` no Drive.
  ///
  /// O arquivo existe por um motivo só, e é o mais importante do produto: sem
  /// ele, a carta é a única memória que morre junto com o aplicativo. Foto e
  /// vídeo já sobrevivem sozinhos, porque são arquivos numa pasta.
  Future<Entry> addLetter({
    required String uid,
    required BabyProfile profile,
    required String title,
    required String message,
    DateTime? date,
  }) async {
    final Entry carta = await _addTextEntry(
      uid: uid,
      profile: profile,
      type: EntryType.letter,
      title: title,
      description: message,
      date: date,
    );
    return escreverCarta(uid, profile, carta);
  }

  /// Grava (ou regrava) o `.txt` de uma carta na pasta da idade dela.
  ///
  /// Como o `Informacoes.txt`, falhar aqui não derruba nada: o texto já está
  /// no índice e é de lá que o aplicativo lê. O arquivo é a cópia que
  /// sobrevive ao aplicativo, e ele se conserta na próxima edição.
  Future<Entry> escreverCarta(
    String uid,
    BabyProfile profile,
    Entry carta,
  ) async {
    if (carta.type != EntryType.letter) return carta;

    try {
      final AgeBucket bucket = AgeCalculator.bucketAt(
        profile.birth,
        carta.date,
      );
      final String pasta = await _resolveFolder(
        uid: uid,
        profile: profile,
        type: EntryType.letter,
        bucket: bucket,
      );

      final String id = await drive.upsertTextFile(
        folderId: pasta,
        name: _nomeDaCarta(carta),
        content: textoDaCarta(carta: carta, profile: profile),
        knownFileId: carta.textFileId,
      );

      if (id == carta.textFileId) return carta;
      await firestore.patchEntry(uid, carta.id, <String, Object?>{
        'arquivoTextoId': id,
      });
      return carta.copyWith(textFileId: id);
    } on Object catch (e) {
      debugPrint('A carta não foi gravada no Drive: $e');
      return carta;
    }
  }

  /// `2027-04-22_Para quando voce crescer.txt`
  ///
  /// A data na frente para ordenar dentro da pasta, e o título depois para
  /// dar para saber o que é sem abrir. O saneamento é o mesmo do download:
  /// nome de arquivo vindo de texto que a pessoa digitou não pode carregar
  /// barra nem `..`.
  String _nomeDaCarta(Entry carta) {
    final String titulo = (carta.title ?? 'Carta').trim();
    final String limpo = titulo
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final String base = limpo.isEmpty ? 'Carta' : limpo;
    final String curto = base.length <= 60 ? base : base.substring(0, 60);
    return '${Fmt.fileStamp(carta.date).split('_').first}_$curto.txt';
  }

  /// Registro de crescimento, com foto opcional.
  Future<Entry> addGrowth({
    required String uid,
    required BabyProfile profile,
    required int weightGrams,
    required double heightCm,
    DateTime? date,
    File? photo,
  }) async {
    final DateTime when = date ?? DateTime.now();
    if (photo == null) {
      final Entry medicao = await _addTextEntry(
        uid: uid,
        profile: profile,
        type: EntryType.growth,
        date: when,
        growth: GrowthData(weightGrams: weightGrams, heightCm: heightCm),
      );
      // Depois de gravar, e não antes: o arquivo lista as medições que
      // existem, e escrever antes deixaria a última de fora.
      await escreverInformacoes(uid, profile);
      return medicao;
    }

    final Entry entry = await addFiles(
      uid: uid,
      profile: profile,
      type: EntryType.growth,
      files: <PendingFile>[
        PendingFile(path: photo.path, kind: EntryType.photo),
      ],
      date: when,
    );
    final GrowthData growth = GrowthData(
      weightGrams: weightGrams,
      heightCm: heightCm,
    );
    await firestore.patchEntry(uid, entry.id, <String, Object?>{
      'crescimento': growth.toMap(),
    });
    await escreverInformacoes(uid, profile);
    return entry.copyWith(growth: growth);
  }

  Future<Entry> _addTextEntry({
    required String uid,
    required BabyProfile profile,
    required EntryType type,
    String? title,
    String? description,
    GrowthData? growth,
    DateTime? date,
  }) async {
    final DateTime when = date ?? DateTime.now();
    final Age age = AgeCalculator.ageAt(profile.birth, when);
    final AgeBucket bucket = AgeCalculator.bucketAt(profile.birth, when);

    final Entry entry = Entry(
      id: _uuid.v4(),
      type: type,
      date: when,
      createdAt: DateTime.now(),
      ageDays: age.totalDays,
      bucketKey: bucket.key,
      bucketName: bucket.folderName,
      title: title,
      description: description,
      growth: growth,
    );
    await firestore.createEntry(uid, entry);
    return entry;
  }

  /// Muda o título/marco e a descrição de qualquer entrada.
  ///
  /// Serve tanto para editar uma carta quanto para marcar depois que aquele
  /// lote de fotos era o "Primeiro sorriso" - é assim que os marcos entram
  /// na linha do tempo sem atrapalhar o envio em dois toques.
  Future<void> updateDetails(
    String uid,
    Entry entry, {
    required String title,
    required String description,
    DateTime? sealedUntil,
    bool changeSeal = false,
    BabyProfile? profile,
  }) async {
    final String? newTitle = title.trim().isEmpty ? null : title.trim();
    final String? newDescription = description.trim().isEmpty
        ? null
        : description.trim();

    // `null` apaga o campo no Firestore, e a busca é recalculada em memória a
    // partir do que sobrou - não há índice gravado para sair de sincronia.
    await firestore.patchEntry(uid, entry.id, <String, Object?>{
      'titulo': newTitle,
      'descricao': newDescription,
      // Só entra no patch quando a pessoa mexeu no lacre; sem isso, salvar
      // um título tiraria sem querer uma data de abertura já escolhida.
      if (changeSeal)
        'lacradoAte': sealedUntil == null
            ? null
            : Timestamp.fromDate(sealedUntil),
    });

    // Editar a carta precisa alcançar o Drive, senão o arquivo lá fora fica
    // com a versão antiga e as duas cópias passam a discordar. O perfil vem
    // por parâmetro porque só quem edita carta precisa dele.
    if (entry.type == EntryType.letter && profile != null) {
      await escreverCarta(
        uid,
        profile,
        entry.copyWith(title: newTitle, description: newDescription),
      );
    }
  }

  // ------------------------------------------------------------- lixeira

  /// Move a entrada e seus arquivos para a lixeira, dos dois lados.
  Future<void> moveToTrash(String uid, Entry entry) async {
    await firestore.moveToTrash(uid, entry.id);
    await _setDriveTrashed(entry, trashed: true);
  }

  Future<void> restore(String uid, Entry entry) async {
    await firestore.restoreFromTrash(uid, entry.id);
    await _setDriveTrashed(entry, trashed: false);
  }

  Future<void> deleteForever(String uid, Entry entry) async {
    for (final EntryFile file in entry.files) {
      if (file.driveId.isEmpty) continue;
      try {
        await drive.deleteForever(file.driveId);
      } on Exception catch (e) {
        // Um arquivo já removido no Drive não deve travar a limpeza.
        debugPrint('Arquivo ${file.driveId} não pôde ser removido: $e');
      }
    }
    await firestore.deleteEntry(uid, entry.id);
  }

  Future<void> _setDriveTrashed(Entry entry, {required bool trashed}) async {
    for (final EntryFile file in entry.files) {
      if (file.driveId.isEmpty) continue;
      try {
        await drive.setTrashed(file.driveId, trashed: trashed);
      } on Exception catch (e) {
        debugPrint('Lixeira do Drive falhou para ${file.driveId}: $e');
      }
    }
  }

  // ------------------------------------------------------------ downloads

  /// Pasta dos arquivos baixados para visualizar ou compartilhar.
  static const String _downloadsFolder = 'meu_bebe_downloads';

  Future<Directory> _downloadsDir() async {
    final Directory base = await getTemporaryDirectory();
    return Directory(p.join(base.path, _downloadsFolder));
  }

  /// Reduz um nome vindo do Drive a algo que pode virar nome de arquivo.
  ///
  /// Nomes no Drive aceitam barra e `..`. Usados direto num `p.join`, seriam
  /// interpretados como caminho e a gravação sairia da pasta de downloads -
  /// inclusive por cima de arquivos internos do aplicativo.
  static String safeFileName(String name) {
    // `p.basename('/')` devolve `/`, então o separador ainda é retirado
    // depois - o resultado precisa não conter caminho nenhum.
    final String base = p
        .basename(name.replaceAll(r'\', '/'))
        .replaceAll('/', '')
        .trim();
    if (base.isEmpty || base == '.' || base == '..') return 'arquivo';
    return base;
  }

  /// Baixa um arquivo para o cache, para visualizar ou compartilhar.
  Future<File> localCopy(EntryFile file) async {
    final Directory base = await _downloadsDir();
    final File target = File(
      p.join(base.path, file.driveId, safeFileName(file.name)),
    );
    if (await target.exists()) return target;
    return drive.downloadTo(file.driveId, target);
  }

  /// Apaga os arquivos baixados para leitura e compartilhamento.
  ///
  /// É aqui que ficam documentos abertos pelo aplicativo - certidão, cartão
  /// de vacina -, então o botão "Limpar cache" precisa alcançar esta pasta.
  Future<void> clearDownloads() async {
    try {
      final Directory dir = await _downloadsDir();
      if (await dir.exists()) await dir.delete(recursive: true);
    } on FileSystemException catch (e) {
      debugPrint('Cache de downloads já estava limpo: $e');
    }
  }

  void _emit(
    String entryId,
    UploadStatus status, {
    int done = 0,
    int total = 0,
    String? message,
  }) {
    if (_progress.isClosed) return;
    _progress.add(
      UploadProgress(
        entryId: entryId,
        status: status,
        done: done,
        total: total,
        message: message,
      ),
    );
  }

  String _guessMime(String path, EntryType type) {
    final String ext = p.extension(path).toLowerCase();
    return switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.heic' || '.heif' => 'image/heic',
      '.webp' => 'image/webp',
      '.gif' => 'image/gif',
      '.mp4' => 'video/mp4',
      '.mov' => 'video/quicktime',
      // O gravador do aplicativo produz AAC em contêiner MP4.
      '.pdf' => 'application/pdf',
      '.doc' => 'application/msword',
      '.docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      _ => switch (type) {
        EntryType.document => 'application/octet-stream',
        _ => 'image/jpeg',
      },
    };
  }

  void dispose() => _progress.close();
}
