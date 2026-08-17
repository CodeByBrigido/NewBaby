import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/drive_service.dart';
import 'package:meu_bebe/services/firestore_service.dart';
import 'package:meu_bebe/services/media_optimizer.dart';
import 'package:meu_bebe/services/memory_repository.dart';
import 'package:meu_bebe/services/thumbnail_service.dart';

/// A mudança da organização do Drive, e a limpeza das pastas que esvaziam.
///
/// O acervo guardado nas versões anteriores está em `Fotos/Semana 07`. A
/// organização passou a ser `Fotos/Ano 0/Mês 01`, e as duas convivendo seriam
/// pior que qualquer uma sozinha: metade da infância numa convenção e metade
/// na outra, sem nada em lugar nenhum dizendo qual é qual.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final BabyProfile perfil = BabyProfile(
    name: 'Maria',
    birth: DateTime(2026, 4, 15),
    rootFolderId: 'raiz',
  );

  Entry foto(
    DateTime quando, {
    String id = 'e1',
    List<String> arquivos = const <String>['f1'],
  }) => Entry(
    id: id,
    type: EntryType.photo,
    date: quando,
    createdAt: quando,
    ageDays: 0,
    bucketKey: 'S01',
    bucketName: 'Semana 01',
    files: <EntryFile>[
      for (final String a in arquivos)
        EntryFile(
          driveId: a,
          name: '$a.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1,
        ),
    ],
  );

  group('qual chave é da organização antiga', () {
    test('dois níveis é antigo', () {
      // `Fotos/Semana 07`, `Vídeos/Mês 14`.
      expect(MemoryRepository.daOrganizacaoAntiga('Fotos/Semana 07'), isTrue);
      expect(MemoryRepository.daOrganizacaoAntiga('Vídeos/Mês 14'), isTrue);
    });

    test('`Cartas/Ano 3` também é antigo, e é a pegadinha', () {
      // Começa por `Ano `, igual à organização nova, e ainda assim é o
      // formato velho. Olhar o prefixo em vez do número de níveis erraria
      // exatamente aqui, e o acervo da criança de três anos ficaria para trás.
      expect(MemoryRepository.daOrganizacaoAntiga('Cartas/Ano 3'), isTrue);
    });

    test('três níveis é a organização nova', () {
      expect(
        MemoryRepository.daOrganizacaoAntiga('Fotos/Ano 0/Mês 07'),
        isFalse,
      );
    });

    test('um nível é a pasta da categoria, e ela fica', () {
      // `Documentos` e `Crescimento` nascem no cadastro e não têm idade.
      expect(MemoryRepository.daOrganizacaoAntiga('Documentos'), isFalse);
    });
  });

  group('o caminho de uma memória', () {
    test('foto entra em ano e mês', () {
      expect(
        MemoryRepository.caminhoDaPasta(
          birth: perfil.birth,
          type: EntryType.photo,
          quando: DateTime(2027, 7, 20),
        ),
        <String>['Fotos', 'Ano 1', 'Mês 03'],
      );
    });

    test('documento fica na categoria, sem idade nenhuma', () {
      // Uma certidão não pertence a um mês da vida: vale a vida inteira.
      expect(
        MemoryRepository.caminhoDaPasta(
          birth: perfil.birth,
          type: EntryType.document,
          quando: DateTime(2027, 7, 20),
        ),
        <String>['Documentos'],
      );
    });
  });

  group('a mudança de lugar', () {
    test('sem chave antiga, não há o que fazer', () async {
      // A marca de "já rodou" é o próprio dado. Sem isso seria preciso
      // gravar um campo novo no cadastro, que as regras do servidor ainda
      // não conhecem.
      final _DriveFalso drive = _DriveFalso();
      final int movidos =
          await _repo(
            drive,
            _FirestoreFalso(
              pastas: <String, String>{'Fotos/Ano 0/Mês 01': 'p1'},
            ),
          ).reorganizarODrive(
            uid: 'u',
            profile: perfil,
            entradas: <Entry>[foto(DateTime(2026, 6, 1))],
          );

      expect(movidos, 0);
      expect(drive.movidos, isEmpty);
    });

    test('o arquivo vai para a pasta do ano e do mês', () async {
      final _DriveFalso drive = _DriveFalso();
      final int movidos =
          await _repo(
            drive,
            _FirestoreFalso(
              pastas: <String, String>{'Fotos/Semana 07': 'velha'},
            ),
          ).reorganizarODrive(
            uid: 'u',
            profile: perfil,
            entradas: <Entry>[foto(DateTime(2026, 6, 1))],
          );

      expect(movidos, 1);
      expect(drive.movidos.single.$1, 'f1');
      expect(drive.criadas.single, <String>['Fotos', 'Ano 0', 'Mês 01']);
    });

    test('move, e não reenvia', () async {
      // No Drive a pasta é uma propriedade do arquivo. O id continua o
      // mesmo, então tudo que o índice guardou sobre ele continua valendo.
      final _DriveFalso drive = _DriveFalso();
      await _repo(
        drive,
        _FirestoreFalso(pastas: <String, String>{'Fotos/Semana 07': 'velha'}),
      ).reorganizarODrive(
        uid: 'u',
        profile: perfil,
        entradas: <Entry>[foto(DateTime(2026, 6, 1))],
      );

      expect(drive.enviados, isEmpty, reason: 'nada pode subir de novo');
    });

    test('a pasta antiga vazia vai para a lixeira', () async {
      final _DriveFalso drive = _DriveFalso();
      final _FirestoreFalso firestore = _FirestoreFalso(
        pastas: <String, String>{'Fotos/Semana 07': 'velha'},
      );
      await _repo(drive, firestore).reorganizarODrive(
        uid: 'u',
        profile: perfil,
        entradas: <Entry>[foto(DateTime(2026, 6, 1))],
      );

      expect(drive.paraALixeira, contains('velha'));
      expect(firestore.esquecidas, contains('Fotos/Semana 07'));
    });

    test('a pasta antiga com algo dentro permanece', () async {
      // Sobra ali o que o índice não conhece. Apagar às cegas o que este
      // aplicativo não sabe explicar seria apagar memória de alguém.
      final _DriveFalso drive = _DriveFalso(vazias: false);
      await _repo(
        drive,
        _FirestoreFalso(pastas: <String, String>{'Fotos/Semana 07': 'velha'}),
      ).reorganizarODrive(
        uid: 'u',
        profile: perfil,
        entradas: <Entry>[foto(DateTime(2026, 6, 1))],
      );

      expect(drive.paraALixeira, isEmpty);
    });

    test('documento não muda de lugar', () async {
      final _DriveFalso drive = _DriveFalso();
      await _repo(
        drive,
        _FirestoreFalso(pastas: <String, String>{'Fotos/Semana 07': 'velha'}),
      ).reorganizarODrive(
        uid: 'u',
        profile: perfil,
        entradas: <Entry>[
          Entry(
            id: 'd1',
            type: EntryType.document,
            date: DateTime(2026, 6, 1),
            createdAt: DateTime(2026, 6, 1),
            ageDays: 0,
            bucketKey: 'S07',
            bucketName: 'Semana 07',
            files: const <EntryFile>[
              EntryFile(
                driveId: 'doc1',
                name: 'a.pdf',
                mimeType: 'application/pdf',
                sizeBytes: 1,
              ),
            ],
          ),
        ],
      );

      expect(drive.movidos, isEmpty);
    });

    test('um arquivo que falha não impede os outros', () async {
      // O que ficou para trás é reencontrado na próxima abertura, porque a
      // chave antiga só é esquecida depois da passagem inteira.
      final _DriveFalso drive = _DriveFalso(recusa: 'f1');
      final int movidos =
          await _repo(
            drive,
            _FirestoreFalso(
              pastas: <String, String>{'Fotos/Semana 07': 'velha'},
            ),
          ).reorganizarODrive(
            uid: 'u',
            profile: perfil,
            entradas: <Entry>[
              foto(DateTime(2026, 6, 1), arquivos: <String>['f1']),
              foto(DateTime(2026, 7, 1), id: 'e2', arquivos: <String>['f2']),
            ],
          );

      expect(movidos, 1);
      expect(drive.movidos.single.$1, 'f2');
    });
  });

  group('a pasta que esvaziou', () {
    test('some quando a última mídia sai', () async {
      // O relato: enviar uma foto criava a pasta do período, apagar a foto
      // deixava a pasta lá, vazia, para sempre.
      final _DriveFalso drive = _DriveFalso();
      final _FirestoreFalso firestore = _FirestoreFalso(
        pastas: <String, String>{
          'Fotos/Ano 0/Mês 01': 'mes',
          'Fotos/Ano 0': 'ano',
        },
      );

      await _repo(
        drive,
        firestore,
      ).limparPastaDoPeriodo('u', perfil, foto(DateTime(2026, 6, 1)));

      // O mês e também o ano: o ano que perdeu o último mês ficou vazio
      // igual, e deixá-lo seria trocar uma sobra por outra.
      expect(drive.paraALixeira, <String>['mes', 'ano']);
    });

    test('permanece quando ainda há outra mídia', () async {
      final _DriveFalso drive = _DriveFalso(vazias: false);
      await _repo(
        drive,
        _FirestoreFalso(pastas: <String, String>{'Fotos/Ano 0/Mês 01': 'mes'}),
      ).limparPastaDoPeriodo('u', perfil, foto(DateTime(2026, 6, 1)));

      expect(drive.paraALixeira, isEmpty);
    });

    test('a pasta da categoria nunca é apagada', () async {
      // `Fotos` nasce no cadastro e faz parte do desenho do acervo mesmo
      // vazia. Só os períodos somem.
      final _DriveFalso drive = _DriveFalso();
      await _repo(
        drive,
        _FirestoreFalso(
          pastas: <String, String>{
            'Fotos/Ano 0/Mês 01': 'mes',
            'Fotos/Ano 0': 'ano',
            'Fotos': 'categoria',
          },
        ),
      ).limparPastaDoPeriodo('u', perfil, foto(DateTime(2026, 6, 1)));

      expect(drive.paraALixeira, isNot(contains('categoria')));
    });

    test('documento não tem pasta de período para limpar', () async {
      final _DriveFalso drive = _DriveFalso();
      await _repo(
        drive,
        _FirestoreFalso(pastas: <String, String>{'Documentos': 'd'}),
      ).limparPastaDoPeriodo(
        'u',
        perfil,
        Entry(
          id: 'd1',
          type: EntryType.document,
          date: DateTime(2026, 6, 1),
          createdAt: DateTime(2026, 6, 1),
          ageDays: 0,
          bucketKey: 'S07',
          bucketName: 'Semana 07',
        ),
      );

      expect(drive.paraALixeira, isEmpty);
    });
  });
}

MemoryRepository _repo(_DriveFalso drive, _FirestoreFalso firestore) =>
    MemoryRepository(
      firestore: firestore,
      drive: drive,
      optimizer: _OtimizadorFalso(),
      thumbnails: _SemMiniaturas(),
    );

class _FirestoreFalso implements FirestoreService {
  _FirestoreFalso({Map<String, String> pastas = const <String, String>{}})
    : pastas = <String, String>{...pastas};

  final Map<String, String> pastas;
  final List<String> esquecidas = <String>[];

  @override
  Future<Map<String, String>> allFolders(String uid) async => pastas;

  @override
  Future<String?> folderId(String uid, String key) async => pastas[key];

  @override
  Future<void> rememberFolder(String uid, String key, String driveId) async {
    pastas[key] = driveId;
  }

  @override
  Future<void> forgetFolderTree(String uid, String key) async {
    esquecidas.add(key);
    pastas.removeWhere((String k, _) => k == key || k.startsWith('$key/'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} não era esperado');
}

class _DriveFalso implements DriveService {
  _DriveFalso({this.vazias = true, this.recusa});

  /// O que `pastaVazia` responde.
  final bool vazias;

  /// Um arquivo que o Drive se recusa a mover.
  final String? recusa;

  final List<(String, String)> movidos = <(String, String)>[];
  final List<List<String>> criadas = <List<String>>[];
  final List<String> paraALixeira = <String>[];
  final List<String> enviados = <String>[];

  int _proxima = 0;

  @override
  Future<bool> moverPara(String fileId, String destinoId) async {
    if (fileId == recusa) throw StateError('o Drive recusou');
    movidos.add((fileId, destinoId));
    return true;
  }

  @override
  Future<List<String>> ensureFolderPath(
    String rootId,
    List<String> caminho,
  ) async {
    criadas.add(caminho);
    return <String>[for (final String _ in caminho) 'nova-${_proxima++}'];
  }

  @override
  Future<bool> pastaVazia(String folderId) async => vazias;

  @override
  Future<void> setTrashed(String driveId, {required bool trashed}) async {
    if (trashed) paraALixeira.add(driveId);
  }

  @override
  Future<String> ensureRootStructure({String? knownRootId}) async => 'raiz';

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} não era esperado');
}

class _OtimizadorFalso implements MediaOptimizer {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} não era esperado');
}

class _SemMiniaturas implements ThumbnailStore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} não era esperado');
}
