import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../core/l10n/strings.dart';

/// Tipo de memória guardada. Define ícone, cor, pasta no Drive e como o
/// item é desenhado na linha do tempo.
enum EntryType {
  birth('nascimento', 'Meu Bebê'),
  photo('foto', 'Fotos'),
  video('video', 'Vídeos'),
  audio('audio', 'Áudios'),
  letter('carta', 'Cartas'),
  drawing('desenho', 'Desenhos'),
  document('documento', 'Documentos'),
  growth('crescimento', 'Crescimento');

  const EntryType(this.id, this.folder);

  /// Valor gravado no Firestore.
  final String id;

  /// Pasta de primeiro nível dentro da pasta da cápsula.
  final String folder;

  /// Como o tipo é contado numa frase: "5 fotos e 1 vídeo".
  ///
  /// Fica no modelo, e não junto dos ícones, porque é palavra e não desenho:
  /// o resumo de um dia precisa disto sem depender de nada de tela.
  String get one => switch (this) {
    EntryType.birth => 'nascimento',
    EntryType.photo => 'foto',
    EntryType.video => 'vídeo',
    EntryType.audio => 'áudio',
    EntryType.letter => 'carta',
    EntryType.drawing => 'desenho',
    EntryType.document => 'documento',
    EntryType.growth => 'medição',
  };

  String get many => switch (this) {
    EntryType.birth => 'nascimentos',
    EntryType.photo => 'fotos',
    EntryType.video => 'vídeos',
    EntryType.audio => 'áudios',
    EntryType.letter => 'cartas',
    EntryType.drawing => 'desenhos',
    EntryType.document => 'documentos',
    EntryType.growth => 'medições',
  };

  /// Se o conteúdo é organizado em subpastas por idade (`Semana 07`).
  /// Cartas, documentos e crescimento ficam direto na pasta da categoria.
  bool get bucketsByAge =>
      this == EntryType.photo ||
      this == EntryType.video ||
      this == EntryType.audio;

  static EntryType fromId(String? id) => values.firstWhere(
    (EntryType t) => t.id == id,
    orElse: () => EntryType.photo,
  );

  /// O que a avó, a tia e o padrinho enxergam.
  ///
  /// Cartas ficam de fora. Quem escreve para a filha ler aos dezoito anos
  /// não está escrevendo para a família inteira, e uma carta que a avó lê
  /// antes deixa de ser uma carta para virar um recado. Desenhos e áudios
  /// também ficam de fora, por não constarem da lista combinada: o padrão
  /// seguro é não mostrar o que ninguém pediu para mostrar.
  ///
  /// Esta lista **precisa** bater com `tipoVisivelParaFamilia` em
  /// `firebase/firestore.rules`. Ela aqui é o que a consulta pede; a de lá é
  /// o que o servidor concede. Se as duas divergirem, a consulta é recusada
  /// inteira e a linha do tempo do familiar fica vazia - falha barulhenta,
  /// de propósito, em vez de silenciosa.
  static const List<EntryType> familyVisible = <EntryType>[
    EntryType.birth,
    EntryType.photo,
    EntryType.video,
    EntryType.document,
    EntryType.growth,
  ];

  bool get isFamilyVisible => familyVisible.contains(this);
}

/// Estágio do envio ao Drive. A entrada aparece na linha do tempo antes de o
/// upload terminar, então a interface precisa saber em que pé ele está.
enum UploadStatus {
  pending('pendente'),
  optimizing('otimizando'),
  uploading('enviando'),
  ready('pronto'),
  failed('erro');

  const UploadStatus(this.id);
  final String id;

  bool get isDone => this == UploadStatus.ready;
  bool get isBusy =>
      this == UploadStatus.pending ||
      this == UploadStatus.optimizing ||
      this == UploadStatus.uploading;

  String get label => switch (this) {
    UploadStatus.pending => S.uploadPending,
    UploadStatus.optimizing => S.uploadOptimizing,
    UploadStatus.uploading => S.uploadSending,
    UploadStatus.ready => '',
    UploadStatus.failed => S.uploadFailed,
  };

  static UploadStatus fromId(String? id) => values.firstWhere(
    (UploadStatus s) => s.id == id,
    orElse: () => UploadStatus.ready,
  );
}

/// Situação do item: visível na linha do tempo ou na lixeira.
enum EntryStatus {
  active('ativo'),
  trashed('lixeira');

  const EntryStatus(this.id);
  final String id;

  static EntryStatus fromId(String? id) => values.firstWhere(
    (EntryStatus s) => s.id == id,
    orElse: () => EntryStatus.active,
  );
}

/// Um arquivo enviado ao Drive, com o mínimo necessário para exibi-lo sem
/// precisar consultar o Drive de novo.
@immutable
class EntryFile {
  const EntryFile({
    required this.driveId,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    this.width,
    this.height,
    this.durationSeconds,
    this.localPath,
  });

  final String driveId;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final int? width;
  final int? height;
  final int? durationSeconds;

  /// Caminho do arquivo original no aparelho de quem enviou. Serve para
  /// mostrar a miniatura instantaneamente antes do upload terminar; some
  /// naturalmente em outros aparelhos.
  final String? localPath;

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');
  bool get isAudio => mimeType.startsWith('audio/');
  bool get isPdf => mimeType == 'application/pdf';

  Duration? get duration =>
      durationSeconds == null ? null : Duration(seconds: durationSeconds!);

  /// Extensão em maiúsculas para o cartão de documento (`PDF`, `DOCX`).
  String get extensionLabel {
    final int dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return 'ARQ';
    return name.substring(dot + 1).toUpperCase();
  }

  EntryFile copyWith({String? driveId, int? sizeBytes, String? localPath}) {
    return EntryFile(
      driveId: driveId ?? this.driveId,
      name: name,
      mimeType: mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width,
      height: height,
      durationSeconds: durationSeconds,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'driveId': driveId,
    'nome': name,
    'mime': mimeType,
    'bytes': sizeBytes,
    'largura': width,
    'altura': height,
    'duracaoS': durationSeconds,
    'caminhoLocal': localPath,
  };

  static EntryFile fromMap(Map<String, Object?> map) => EntryFile(
    driveId: (map['driveId'] as String?) ?? '',
    name: (map['nome'] as String?) ?? '',
    mimeType: (map['mime'] as String?) ?? 'application/octet-stream',
    sizeBytes: (map['bytes'] as num?)?.toInt() ?? 0,
    width: (map['largura'] as num?)?.toInt(),
    height: (map['altura'] as num?)?.toInt(),
    durationSeconds: (map['duracaoS'] as num?)?.toInt(),
    localPath: map['caminhoLocal'] as String?,
  );
}

/// Peso e altura de um registro de crescimento.
@immutable
class GrowthData {
  const GrowthData({required this.weightGrams, required this.heightCm});

  final int weightGrams;
  final double heightCm;

  Map<String, Object?> toMap() => <String, Object?>{
    'pesoGramas': weightGrams,
    'alturaCm': heightCm,
  };

  static GrowthData? fromMap(Map<String, Object?>? map) {
    if (map == null) return null;
    return GrowthData(
      weightGrams: (map['pesoGramas'] as num?)?.toInt() ?? 0,
      heightCm: (map['alturaCm'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Uma entrada da linha do tempo. É a unidade de tudo no aplicativo: uma
/// carta, um registro de crescimento ou um lote de fotos do mesmo momento.
@immutable
class Entry {
  const Entry({
    required this.id,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.ageDays,
    required this.bucketKey,
    required this.bucketName,
    this.title,
    this.description,
    this.files = const <EntryFile>[],
    this.growth,
    this.status = EntryStatus.active,
    this.uploadStatus = UploadStatus.ready,
    this.deletedAt,
    this.errorMessage,
    this.sealedUntil,
  });

  final String id;
  final EntryType type;

  /// Data do acontecimento - é ela que ordena a linha do tempo e escolhe a
  /// pasta de idade, não a data em que o registro foi criado.
  final DateTime date;
  final DateTime createdAt;

  /// Idade em dias na data do evento; guardada para não recalcular ao listar.
  final int ageDays;

  /// Chave e nome da pasta de idade (`S07` / `Semana 07`).
  final String bucketKey;
  final String bucketName;

  final String? title;
  final String? description;
  final List<EntryFile> files;
  final GrowthData? growth;
  final EntryStatus status;
  final UploadStatus uploadStatus;
  final DateTime? deletedAt;
  final String? errorMessage;

  /// Guardado para ser aberto só a partir desta data.
  ///
  /// **Isto é um lacre, não um cofre.** O conteúdo continua no Firestore e no
  /// Drive de quem gravou, legível por quem tiver a conta. É a mesma natureza
  /// da cápsula do tempo enterrada no quintal: dá para desenterrar antes da
  /// hora, e não desenterrar é a graça.
  ///
  /// Poderia ser criptografia de verdade. Não é, de propósito: uma chave
  /// perdida em vinte anos apagaria a memória para sempre, e num acervo feito
  /// para durar décadas esse risco é maior que o de alguém espiar o próprio
  /// presente.
  final DateTime? sealedUntil;

  /// Se ainda não chegou a hora de abrir.
  bool isSealedAt([DateTime? now]) {
    final DateTime? until = sealedUntil;
    if (until == null) return false;
    return until.isAfter(now ?? DateTime.now());
  }

  bool get isTrashed => status == EntryStatus.trashed;
  bool get hasFiles => files.isNotEmpty;
  EntryFile? get coverFile => files.isEmpty ? null : files.first;

  int get totalBytes =>
      files.fold(0, (int sum, EntryFile f) => sum + f.sizeBytes);

  /// Cabeçalho do cartão na linha do tempo.
  String get headline {
    final String? t = title?.trim();
    if (t != null && t.isNotEmpty) {
      return type == EntryType.letter ? '${S.letterPrefix} $t' : t;
    }
    return switch (type) {
      EntryType.birth => S.birth,
      EntryType.photo => files.length > 1 ? S.photosAdded : S.photoAdded,
      EntryType.video => S.videoAdded,
      EntryType.audio => S.audioAdded,
      EntryType.letter => S.letters,
      EntryType.drawing => S.drawingAdded,
      EntryType.document => files.firstOrNull?.name ?? S.documentAdded,
      EntryType.growth => S.growthRecord,
    };
  }

  /// Texto usado pela busca - comparado já em minúsculas.
  ///
  /// É calculado na hora, a partir do objeto que já está em memória, e **não**
  /// é gravado no Firestore. Guardar uma cópia do texto lá significaria uma
  /// segunda via do corpo inteiro de cada carta no banco de quem publica o
  /// aplicativo, sem nada em troca: a busca nunca leu esse campo.
  String get searchable => <String?>[
    title,
    description,
    bucketName,
    ...files.map((EntryFile f) => f.name),
  ].whereType<String>().join(' ').toLowerCase();

  Entry copyWith({
    String? title,
    String? description,
    DateTime? date,
    List<EntryFile>? files,
    GrowthData? growth,
    EntryStatus? status,
    UploadStatus? uploadStatus,
    DateTime? deletedAt,
    String? errorMessage,
    int? ageDays,
    String? bucketKey,
    String? bucketName,
    DateTime? sealedUntil,
    bool clearError = false,
    bool clearSeal = false,
  }) {
    return Entry(
      id: id,
      type: type,
      date: date ?? this.date,
      createdAt: createdAt,
      ageDays: ageDays ?? this.ageDays,
      bucketKey: bucketKey ?? this.bucketKey,
      bucketName: bucketName ?? this.bucketName,
      title: title ?? this.title,
      description: description ?? this.description,
      files: files ?? this.files,
      growth: growth ?? this.growth,
      status: status ?? this.status,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sealedUntil: clearSeal ? null : (sealedUntil ?? this.sealedUntil),
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'tipo': type.id,
    'data': Timestamp.fromDate(date),
    'criadoEm': Timestamp.fromDate(createdAt),
    'idadeDias': ageDays,
    'balde': bucketKey,
    'baldeNome': bucketName,
    'titulo': title,
    'descricao': description,
    'arquivos': files.map((EntryFile f) => f.toMap()).toList(),
    'crescimento': growth?.toMap(),
    'status': status.id,
    'uploadStatus': uploadStatus.id,
    'excluidoEm': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    'erro': errorMessage,
    'lacradoAte': sealedUntil == null ? null : Timestamp.fromDate(sealedUntil!),
  };

  static Entry fromMap(String id, Map<String, Object?> map) {
    return Entry(
      id: id,
      type: EntryType.fromId(map['tipo'] as String?),
      date: _toDate(map['data']) ?? DateTime.now(),
      createdAt: _toDate(map['criadoEm']) ?? DateTime.now(),
      ageDays: (map['idadeDias'] as num?)?.toInt() ?? 0,
      bucketKey: (map['balde'] as String?) ?? '',
      bucketName: (map['baldeNome'] as String?) ?? '',
      title: map['titulo'] as String?,
      description: map['descricao'] as String?,
      files: ((map['arquivos'] as List<Object?>?) ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> m) =>
                EntryFile.fromMap(m.cast<String, Object?>()),
          )
          .toList(),
      growth: GrowthData.fromMap(
        (map['crescimento'] as Map<Object?, Object?>?)?.cast<String, Object?>(),
      ),
      status: EntryStatus.fromId(map['status'] as String?),
      uploadStatus: UploadStatus.fromId(map['uploadStatus'] as String?),
      deletedAt: _toDate(map['excluidoEm']),
      errorMessage: map['erro'] as String?,
      sealedUntil: _toDate(map['lacradoAte']),
    );
  }

  static DateTime? _toDate(Object? value) => switch (value) {
    Timestamp t => t.toDate(),
    DateTime d => d,
    String s => DateTime.tryParse(s),
    _ => null,
  };
}
