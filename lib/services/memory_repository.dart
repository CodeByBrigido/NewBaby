import '../core/l10n/strings.dart';
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
    unawaited(_processUpload(uid, profile, entry, files));
    return entry;
  }

  Future<void> _processUpload(
    String uid,
    BabyProfile profile,
    Entry entry,
    List<PendingFile> pending,
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
        quando: entry.date,
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

  /// Corrige o cadastro e reescreve o `Informacoes.txt`.
  ///
  /// As duas coisas juntas de propósito: o `.txt` é a versão legível do
  /// cadastro para quem abrir o Drive sem o aplicativo, e um cadastro
  /// corrigido no Firestore com o arquivo antigo no Drive são duas verdades
  /// diferentes sobre a mesma criança. Numa cápsula de vinte anos, a que
  /// sobrevive é a do arquivo.
  Future<void> atualizarCadastro(String uid, BabyProfile profile) async {
    await firestore.saveProfile(uid, profile);
    await escreverInformacoes(uid, profile);
  }

  /// Troca o nome que a lista mostra, sem tocar no arquivo do Drive.
  ///
  /// São duas coisas diferentes de propósito. O arquivo no Drive mantém o
  /// nome com que foi enviado, porque é ele que a pessoa vai reconhecer se
  /// um dia abrir a pasta sem o aplicativo; o título é como ela quer chamar
  /// aquilo aqui dentro. `IMG_20240412_093311.pdf` não é nome de certidão.
  Future<void> renomear(String uid, String entryId, String titulo) {
    final String limpo = titulo.trim();
    return firestore.patchEntry(uid, entryId, <String, Object?>{
      'titulo': limpo.isEmpty ? null : limpo,
    });
  }

  /// Grava a ordem escolhida à mão, uma posição por documento.
  ///
  /// Recebe a lista inteira já na ordem final, e não "moveu de 3 para 1".
  /// Regravar todos é mais escrita, e é o que garante que a lista no
  /// aparelho e a do Firestore não possam discordar depois de dois
  /// arrastões seguidos.
  Future<void> reordenar(String uid, List<Entry> naOrdem) async {
    await Future.wait(<Future<void>>[
      for (int i = 0; i < naOrdem.length; i++)
        if (naOrdem[i].ordem != i)
          firestore.patchEntry(uid, naOrdem[i].id, <String, Object?>{
            'ordem': i,
          }),
    ]);
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
        'erro': S.errOriginalsMissingFull,
      });
      return;
    }

    // O arquivo escolhido é uma cópia no cache do aplicativo, e o Android
    // limpa cache quando o armazenamento aperta. Sem esta conferência o
    // reenvio morria lá na frente, com uma mensagem sobre caminho de arquivo
    // que não diz a ninguém o que fazer, e o item ficava tentando para
    // sempre uma coisa impossível.
    for (final PendingFile item in pending) {
      if (!File(item.path).existsSync()) {
        await firestore.patchEntry(uid, entry.id, <String, Object?>{
          'uploadStatus': UploadStatus.failed.id,
          'erro': S.errFileGoneFull,
        });
        return;
      }
    }

    // Tentar de novo é a pessoa olhando para a tela e pedindo, então aqui a
    // permissão do Drive pode ser pedida com a tela do Google. Sem isto, um
    // envio que falhou por falta de consentimento repetia o mesmo erro para
    // sempre: o envio comum não abre tela nenhuma, e portanto não tinha como
    // resolver o que estava faltando.
    //
    // O `try` não é enfeite. Sem ele, recusar a tela do Google jogava a
    // exceção para fora do reenvio inteiro, e a tela não mostrava nada:
    // o botão parecia não fazer efeito nenhum.
    try {
      await drive.garantirPermissao();
    } on Exception catch (e) {
      final String message = userMessage(e, context: 'Reenvio de ${entry.id}');
      await firestore.patchEntry(uid, entry.id, <String, Object?>{
        'uploadStatus': UploadStatus.failed.id,
        'erro': message,
      });
      _emit(entry.id, UploadStatus.failed, message: message);
      return;
    }

    await _processUpload(uid, profile, entry, pending);
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

  /// Onde uma memória daquele tipo e daquela data mora dentro da cápsula.
  ///
  /// `['Fotos', 'Ano 0', 'Mês 07']`, `['Documentos']`.
  ///
  /// Documento e crescimento ficam direto na pasta da categoria: uma
  /// certidão não pertence a uma idade, ela vale a vida inteira.
  static List<String> caminhoDaPasta({
    required DateTime birth,
    required EntryType type,
    required DateTime quando,
  }) => <String>[
    type.folder,
    if (type.bucketsByAge) ...AgeCalculator.caminhoNoDrive(birth, quando),
  ];

  /// Se esta chave do cache aponta para a organização antiga do Drive.
  ///
  /// A antiga tinha um nível de idade só, com o nome que a galeria usa:
  /// `Fotos/Semana 07`, `Vídeos/Mês 14`, `Cartas/Ano 3`. A nova tem dois,
  /// e o primeiro deles sempre começa por `Ano `: `Fotos/Ano 0/Mês 07`.
  ///
  /// `Cartas/Ano 3` é o caso que obriga a olhar o número de níveis, e não só
  /// o prefixo: ele começa por `Ano ` e ainda assim é antigo.
  @visibleForTesting
  static bool daOrganizacaoAntiga(String chave) => chave.split('/').length == 2;

  /// Encontra (ou cria) a pasta de destino, guardando os ids para a próxima
  /// vez.
  Future<String> _resolveFolder({
    required String uid,
    required BabyProfile profile,
    required EntryType type,
    required DateTime quando,
  }) async {
    final String rootId =
        profile.rootFolderId ??
        await drive.ensureRootStructure(knownRootId: profile.rootFolderId);

    final List<String> caminho = caminhoDaPasta(
      birth: profile.birth,
      type: type,
      quando: quando,
    );

    final String? cached = await firestore.folderId(uid, caminho.join('/'));
    if (cached != null && cached.isNotEmpty) return cached;

    final List<String> ids = await drive.ensureFolderPath(rootId, caminho);
    // Um registro por nível, e não só o do fim. É o que deixa a limpeza
    // saber, mais tarde, qual é o id do `Ano 0` para conferir se ele ficou
    // vazio depois de o último mês sair.
    for (int i = 0; i < caminho.length; i++) {
      await firestore.rememberFolder(
        uid,
        caminho.sublist(0, i + 1).join('/'),
        ids[i],
      );
    }
    return ids.last;
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
  /// O arquivo é gravado **antes** do índice, e a ordem é o conserto de um
  /// defeito que aparecia no Drive como duas cartas iguais.
  ///
  /// Gravar o índice primeiro abria uma janela: o Firestore avisa quem
  /// escuta assim que a escrita entra no cache local, a linha do tempo
  /// recebia a carta ainda sem `arquivoTextoId`, e [CartasAtrasadas] a
  /// tratava como carta antiga sem arquivo e gravava um `.txt`. Ao mesmo
  /// tempo, a gravação daqui também estava a caminho, com o mesmo
  /// `knownFileId` vazio. Duas criações, dois arquivos na pasta.
  ///
  /// Invertendo, a carta só chega ao índice quando já tem o id do arquivo, e
  /// não existe instante nenhum em que ela pareça atrasada. Quando o Drive
  /// falha, o id vem nulo, a carta é gravada assim mesmo e aí sim a fila de
  /// atrasadas cuida dela na próxima abertura - que é exatamente o caso para
  /// o qual essa fila foi feita.
  Future<Entry> addLetter({
    required String uid,
    required BabyProfile profile,
    required String title,
    required String message,
    DateTime? date,
  }) async {
    final DateTime when = date ?? DateTime.now();
    final Age age = AgeCalculator.ageAt(profile.birth, when);
    final AgeBucket bucket = AgeCalculator.bucketAt(profile.birth, when);

    final Entry carta = Entry(
      id: _uuid.v4(),
      type: EntryType.letter,
      date: when,
      createdAt: DateTime.now(),
      ageDays: age.totalDays,
      bucketKey: bucket.key,
      bucketName: bucket.folderName,
      title: title,
      description: message,
    );

    final String? arquivo = await _gravarTextoDaCarta(uid, profile, carta);
    final Entry completa = arquivo == null
        ? carta
        : carta.copyWith(textFileId: arquivo);
    await firestore.createEntry(uid, completa);
    return completa;
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

    final String? id = await _gravarTextoDaCarta(uid, profile, carta);
    if (id == null || id == carta.textFileId) return carta;
    await firestore.patchEntry(uid, carta.id, <String, Object?>{
      'arquivoTextoId': id,
    });
    return carta.copyWith(textFileId: id);
  }

  /// Grava o `.txt` e devolve o id, ou `null` quando o Drive não colaborou.
  ///
  /// Não toca no Firestore: quem chama decide se cria a entrada com o id
  /// junto ([addLetter]) ou se corrige uma que já existe ([escreverCarta]).
  Future<String?> _gravarTextoDaCarta(
    String uid,
    BabyProfile profile,
    Entry carta,
  ) async {
    try {
      final String pasta = await _resolveFolder(
        uid: uid,
        profile: profile,
        type: EntryType.letter,
        quando: carta.date,
      );

      return await drive.upsertTextFile(
        folderId: pasta,
        name: _nomeDaCarta(carta),
        content: textoDaCarta(carta: carta, profile: profile),
        knownFileId: carta.textFileId,
      );
    } on Object catch (e) {
      debugPrint('A carta não foi gravada no Drive: $e');
      return null;
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
  Future<void> moveToTrash(
    String uid,
    Entry entry, {
    BabyProfile? profile,
  }) async {
    await firestore.moveToTrash(uid, entry.id);
    await _setDriveTrashed(entry, trashed: true);
    if (profile != null) await limparPastaDoPeriodo(uid, profile, entry);
  }

  /// Devolve a memória à linha do tempo e ao lugar dela no Drive.
  ///
  /// Precisa reencontrar a pasta, e não só tirar o arquivo da lixeira: se
  /// aquela era a última mídia do período, a pasta foi para a lixeira junto.
  /// Um arquivo restaurado dentro de uma pasta na lixeira continua invisível,
  /// e a pessoa veria a memória voltar no aplicativo e não voltar no Drive.
  Future<void> restore(String uid, Entry entry, {BabyProfile? profile}) async {
    await firestore.restoreFromTrash(uid, entry.id);
    await _setDriveTrashed(entry, trashed: false);
    if (profile == null || !entry.type.bucketsByAge) return;

    try {
      final String destino = await _resolveFolder(
        uid: uid,
        profile: profile,
        type: entry.type,
        quando: entry.date,
      );
      for (final String fileId in arquivosNoDrive(entry)) {
        await drive.moverPara(fileId, destino);
      }
    } on Object catch (e) {
      debugPrint('A memória voltou ao índice mas não à pasta: $e');
    }
  }

  /// Apaga a pasta do período quando a última memória dela sai.
  ///
  /// O relato que originou isto: enviar uma foto criava a pasta daquele
  /// período, apagar a foto deixava a pasta lá, vazia, para sempre. Um acervo
  /// de vinte anos acumularia uma pasta por período em que alguém guardou e
  /// desistiu, e a organização por idade só serve enquanto uma pasta que
  /// existe significa que há algo dentro.
  ///
  /// Sobe do mês para o ano, porque o ano que perdeu o último mês também
  /// ficou vazio. Para na pasta da categoria (`Fotos`), que nasce no cadastro
  /// e faz parte do desenho do acervo mesmo vazia.
  ///
  /// Confere antes de apagar, e é isso que o pedido pedia: pasta com outra
  /// mídia dentro permanece.
  Future<void> limparPastaDoPeriodo(
    String uid,
    BabyProfile profile,
    Entry entry,
  ) async {
    if (!entry.type.bucketsByAge) return;

    final List<String> caminho = caminhoDaPasta(
      birth: profile.birth,
      type: entry.type,
      quando: entry.date,
    );

    for (int n = caminho.length; n > 1; n--) {
      final String chave = caminho.sublist(0, n).join('/');
      try {
        final String? id = await firestore.folderId(uid, chave);
        if (id == null || id.isEmpty) return;
        if (!await drive.pastaVazia(id)) return;
        await drive.setTrashed(id, trashed: true);
        await firestore.forgetFolderTree(uid, chave);
      } on Object catch (e) {
        // Sobra de pasta é feiura, não perda: não vale derrubar nada.
        debugPrint('A pasta $chave não pôde ser limpa: $e');
        return;
      }
    }
  }

  Future<void> deleteForever(String uid, Entry entry) async {
    for (final String driveId in arquivosNoDrive(entry)) {
      try {
        await drive.deleteForever(driveId);
      } on Exception catch (e) {
        // Um arquivo já removido no Drive não deve travar a limpeza.
        debugPrint('Arquivo $driveId não pôde ser removido: $e');
      }
    }
    await firestore.deleteEntry(uid, entry.id);
  }

  Future<void> _setDriveTrashed(Entry entry, {required bool trashed}) async {
    for (final String driveId in arquivosNoDrive(entry)) {
      try {
        await drive.setTrashed(driveId, trashed: trashed);
      } on Exception catch (e) {
        debugPrint('Lixeira do Drive falhou para $driveId: $e');
      }
    }
  }

  /// Tudo que esta entrada tem no Drive, anexos e `.txt` da carta.
  ///
  /// A carta guarda o arquivo dela em `textFileId`, fora de `files`, porque
  /// na tela ela não é anexo: é a própria carta em outro formato. Só que a
  /// lixeira e o apagar percorriam apenas `files`, e o resultado era o que se
  /// via no Drive: a pessoa apagava a carta no aplicativo e o `.txt`
  /// continuava lá, sozinho, sem nada no aplicativo que soubesse dele. Numa
  /// cápsula que a criança vai abrir daqui a vinte anos, uma carta que os
  /// pais decidiram apagar não pode ser a que sobrevive.
  @visibleForTesting
  static List<String> arquivosNoDrive(Entry entry) => <String>[
    for (final EntryFile f in entry.files)
      if (f.driveId.isNotEmpty) f.driveId,
    if (entry.textFileId case final String texto when texto.isNotEmpty) texto,
  ];

  // ------------------------------------------- reorganização do acervo

  bool _reorganizando = false;

  /// Move o acervo já guardado para a organização por ano e mês.
  ///
  /// O Drive de quem usou as versões anteriores tem `Fotos/Semana 07` e
  /// `Vídeos/Mês 14`. A organização nova é `Fotos/Ano 0/Mês 01`, e as duas
  /// convivendo seriam pior que qualquer uma das duas sozinha: metade da
  /// infância numa convenção e metade na outra, sem nada escrito em lugar
  /// nenhum dizendo qual é qual.
  ///
  /// **Move, não copia.** No Drive a pasta é uma propriedade do arquivo, e
  /// mover é trocar essa propriedade: nada sobe de novo, o id continua o
  /// mesmo, e tudo que o índice guardou sobre aquele arquivo continua
  /// valendo. Não existe janela em que o arquivo esteja em dois lugares nem
  /// em nenhum.
  ///
  /// **Sem marca de "já rodou".** A marca é o próprio dado: enquanto houver
  /// chave antiga no cache de pastas, há trabalho. Isso evita gravar um
  /// campo novo no cadastro, que as regras do servidor ainda não conhecem, e
  /// tem a propriedade de sempre terminar o serviço: uma migração
  /// interrompida pela rede continua na abertura seguinte, de onde parou.
  ///
  /// Devolve quantos arquivos mudaram de lugar.
  Future<int> reorganizarODrive({
    required String uid,
    required BabyProfile profile,
    required List<Entry> entradas,
  }) async {
    if (_reorganizando) return 0;

    final Map<String, String> pastas = await firestore.allFolders(uid);
    final List<String> antigas = pastas.keys
        .where(daOrganizacaoAntiga)
        .toList();
    if (antigas.isEmpty) return 0;

    _reorganizando = true;
    try {
      int movidos = 0;

      // Guiada pelo índice, e não pela listagem do Drive: é o índice que sabe
      // a data de cada memória, e é a data que decide a pasta. O nome do
      // arquivo até começa pela data, mas ler a pasta de destino de um nome
      // de arquivo seria confiar num texto onde existe um campo.
      for (final Entry entrada in entradas) {
        if (!entrada.type.bucketsByAge) continue;
        final List<String> arquivos = arquivosNoDrive(entrada);
        if (arquivos.isEmpty) continue;

        try {
          final String destino = await _resolveFolder(
            uid: uid,
            profile: profile,
            type: entrada.type,
            quando: entrada.date,
          );
          for (final String fileId in arquivos) {
            if (await drive.moverPara(fileId, destino)) movidos++;
          }
          // `Object`, e não `Exception`: o próprio `DriveService` lança
          // `StateError` quando o Google devolve uma resposta sem id, e
          // `StateError` não é `Exception`. Com o filtro estreito, uma
          // pasta que o Drive se recusou a criar derrubava a passagem
          // inteira e o resto do acervo ficava para trás.
        } on Object catch (e) {
          // Um arquivo que não move não pode parar os outros: o que ficou
          // para trás é reencontrado na próxima abertura, porque a chave
          // antiga continua no cache.
          debugPrint('A memória ${entrada.id} não foi movida: $e');
        }
      }

      for (final String chave in antigas) {
        try {
          final String id = pastas[chave]!;
          // Só vai para a lixeira se estiver mesmo vazia. Sobra ali o que o
          // índice não conhece, e apagar às cegas o que este aplicativo não
          // sabe explicar seria apagar memória de alguém.
          if (await drive.pastaVazia(id)) {
            await drive.setTrashed(id, trashed: true);
          }
          await firestore.forgetFolderTree(uid, chave);
        } on Object catch (e) {
          debugPrint('A pasta antiga $chave continua lá: $e');
        }
      }

      return movidos;
    } finally {
      _reorganizando = false;
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
