import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/drive_service.dart';
import 'package:meu_bebe/services/firestore_service.dart';
import 'package:meu_bebe/services/media_optimizer.dart';
import 'package:meu_bebe/services/memory_repository.dart';
import 'package:meu_bebe/services/thumbnail_service.dart';

/// A carta e o arquivo dela no Drive.
///
/// Duas coisas apareciam erradas na pasta de quem usa o aplicativo: escrever
/// uma carta deixava **duas** iguais lá dentro, e apagar a carta no
/// aplicativo não apagava nenhuma delas.
void main() {
  // O nome do arquivo da carta começa pela data, e formatar data sem
  // isto lança. Sem esta linha o teste da falha do Drive passava pelo
  // motivo errado: quem derrubava a gravação era o locale.
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final BabyProfile perfil = BabyProfile(
    name: 'Maria',
    birth: DateTime(2027, 1, 22),
    rootFolderId: 'raiz',
  );

  MemoryRepository comDrive(_DriveFalso drive, _FirestoreFalso firestore) =>
      MemoryRepository(
        firestore: firestore,
        drive: drive,
        optimizer: _OtimizadorFalso(),
        thumbnails: _SemMiniaturas(),
      );

  /// Os dois dublês anotam no mesmo caderno, senão não dá para comparar a
  /// ordem entre uma chamada do Drive e uma do Firestore.
  ({_DriveFalso drive, _FirestoreFalso firestore, List<String> passos}) par({
    bool driveFalha = false,
  }) {
    final List<String> passos = <String>[];
    return (
      drive: _DriveFalso(passos, falha: driveFalha),
      firestore: _FirestoreFalso(passos),
      passos: passos,
    );
  }

  group('escrever uma carta', () {
    test('o arquivo é gravado antes de a carta entrar no índice', () async {
      // A ordem é o conserto das duas cartas iguais no Drive.
      //
      // Com o índice primeiro, o Firestore avisava quem escuta ainda sem o
      // `arquivoTextoId`, a fila de cartas atrasadas via uma carta sem
      // arquivo e gravava um `.txt`, e a gravação daqui gravava outro. Com o
      // arquivo primeiro, não existe instante nenhum em que a carta pareça
      // atrasada.
      final ({
        _DriveFalso drive,
        _FirestoreFalso firestore,
        List<String> passos,
      })
      p = par();

      await comDrive(p.drive, p.firestore).addLetter(
        uid: 'u',
        profile: perfil,
        title: 'Para quando você crescer',
        message: 'Hoje você bateu palmas.',
      );

      expect(p.passos, <String>[
        'upsertTextFile',
        'createEntry',
      ], reason: 'O arquivo primeiro, e o índice depois.');
    });

    test('a carta já nasce sabendo o id do arquivo', () async {
      // É esta a propriedade que fecha a janela: quem escuta o índice nunca
      // vê a carta sem arquivo, então ninguém tenta gravar um segundo.
      final ({
        _DriveFalso drive,
        _FirestoreFalso firestore,
        List<String> passos,
      })
      p = par();
      final Entry carta = await comDrive(
        p.drive,
        p.firestore,
      ).addLetter(uid: 'u', profile: perfil, title: 'Oi', message: 'Tudo bem?');

      expect(carta.textFileId, 'texto-1');
      expect(p.firestore.criadas.single.textFileId, 'texto-1');
    });

    test('um só arquivo, e não dois', () async {
      final ({
        _DriveFalso drive,
        _FirestoreFalso firestore,
        List<String> passos,
      })
      p = par();
      await comDrive(
        p.drive,
        p.firestore,
      ).addLetter(uid: 'u', profile: perfil, title: 'Oi', message: 'Olá.');

      expect(p.drive.textos, hasLength(1));
    });

    test('o Drive falhando, a carta é guardada assim mesmo', () async {
      // O texto já está no índice e é de lá que o aplicativo lê. Derrubar a
      // gravação da carta porque o Drive recusou seria perder a memória para
      // salvar a cópia dela.
      final ({
        _DriveFalso drive,
        _FirestoreFalso firestore,
        List<String> passos,
      })
      p = par(driveFalha: true);
      final Entry carta = await comDrive(
        p.drive,
        p.firestore,
      ).addLetter(uid: 'u', profile: perfil, title: 'Oi', message: 'Olá.');

      expect(carta.textFileId, isNull);
      expect(p.firestore.criadas, hasLength(1));
      // E fica pendente de propósito: é assim que a fila de atrasadas a
      // encontra na próxima abertura e termina o serviço.
      expect(p.firestore.criadas.single.textFileId, isNull);
    });
  });

  group('o que a lixeira precisa alcançar', () {
    Entry carta({
      String? texto,
      List<EntryFile> anexos = const <EntryFile>[],
    }) => Entry(
      id: 'c1',
      type: EntryType.letter,
      date: DateTime(2027, 5, 2),
      createdAt: DateTime(2027, 5, 2),
      ageDays: 100,
      bucketKey: 'S15',
      bucketName: 'Semana 15',
      textFileId: texto,
      files: anexos,
    );

    test('o .txt da carta entra na conta', () {
      // O defeito relatado: apagar a carta no aplicativo e ela continuar no
      // Drive. A lixeira percorria só os anexos, e a carta guarda o arquivo
      // dela fora dos anexos.
      expect(
        MemoryRepository.arquivosNoDrive(carta(texto: 'texto-1')),
        <String>['texto-1'],
      );
    });

    test('anexos e .txt convivem', () {
      expect(
        MemoryRepository.arquivosNoDrive(
          carta(
            texto: 'texto-1',
            anexos: <EntryFile>[
              const EntryFile(
                driveId: 'foto-1',
                name: 'a.jpg',
                mimeType: 'image/jpeg',
                sizeBytes: 1,
              ),
            ],
          ),
        ),
        <String>['foto-1', 'texto-1'],
      );
    });

    test('o que ainda não subiu não vira id vazio na lista', () {
      // Entrada criada antes de o envio terminar tem `driveId` vazio, e
      // mandar isso para o Drive seria uma chamada que só pode falhar.
      expect(
        MemoryRepository.arquivosNoDrive(
          carta(
            texto: '',
            anexos: <EntryFile>[
              const EntryFile(
                driveId: '',
                name: 'a.jpg',
                mimeType: 'image/jpeg',
                sizeBytes: 1,
              ),
            ],
          ),
        ),
        isEmpty,
      );
    });
  });
}

/// Anota a ordem em que o repositório chama cada coisa.
///
/// A ordem é o objeto do teste, e não um detalhe: o defeito das duas cartas
/// era exatamente uma ordem trocada.
class _FirestoreFalso implements FirestoreService {
  _FirestoreFalso(this.passos);

  final List<String> passos;
  final List<Entry> criadas = <Entry>[];

  @override
  Future<String> createEntry(String uid, Entry entry) async {
    passos.add('createEntry');
    criadas.add(entry);
    return entry.id;
  }

  @override
  Future<String?> folderId(String uid, String key) async => null;

  @override
  Future<void> rememberFolder(String uid, String key, String driveId) async {}

  @override
  Future<void> patchEntry(
    String uid,
    String entryId,
    Map<String, Object?> data,
  ) async {
    passos.add('patchEntry');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} não era esperado');
}

class _DriveFalso implements DriveService {
  _DriveFalso(this.passos, {this.falha = false});

  final List<String> passos;

  /// Simula o Drive recusando a gravação.
  final bool falha;

  final List<String> textos = <String>[];
  int _proximo = 0;

  @override
  Future<String> upsertTextFile({
    required String folderId,
    required String name,
    required String content,
    String? knownFileId,
  }) async {
    passos.add('upsertTextFile');
    if (falha) throw StateError('o Drive recusou');
    textos.add(name);
    return 'texto-${++_proximo}';
  }

  @override
  Future<List<String>> ensureFolderPath(
    String rootId,
    List<String> caminho,
  ) async => <String>[for (final String _ in caminho) 'pasta'];

  @override
  Future<String> ensureCategoryFolder(String rootId, String category) async =>
      'pasta';

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
