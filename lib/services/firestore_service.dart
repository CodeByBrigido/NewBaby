import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/baby_profile.dart';
import '../models/entry.dart';
import '../models/suggestion_progress.dart';

/// Índice de tudo que existe no aplicativo.
///
/// Como o cache offline fica no aparelho, a linha do tempo abre instantânea e
/// a busca acontece sem rede, sem nunca varrer as pastas do Drive.
class FirestoreService {
  FirestoreService(this._db);

  final FirebaseFirestore _db;

  static const String _users = 'users';
  static const String _profile = 'perfil';
  static const String _profileDoc = 'bebe';
  static const String _entries = 'entradas';
  static const String _folders = 'pastas';
  static const String _suggestions = 'sugestoes';
  static const String _thumbnails = 'miniaturas';
  static const String _images = 'imagens';

  DocumentReference<Map<String, Object?>> _user(String uid) =>
      _db.collection(_users).doc(uid);

  DocumentReference<Map<String, Object?>> _profileRef(String uid) =>
      _user(uid).collection(_profile).doc(_profileDoc);

  CollectionReference<Map<String, Object?>> _entriesRef(String uid) =>
      _user(uid).collection(_entries);

  // ---------------------------------------------------------------- perfil

  Stream<BabyProfile?> watchProfile(String uid) {
    return _profileRef(uid).snapshots().map((
      DocumentSnapshot<Map<String, Object?>> doc,
    ) {
      final Map<String, Object?>? data = doc.data();
      if (!doc.exists || data == null) return null;
      return BabyProfile.fromMap(data);
    });
  }

  Future<BabyProfile?> loadProfile(String uid) async {
    final DocumentSnapshot<Map<String, Object?>> doc = await _profileRef(
      uid,
    ).get();
    final Map<String, Object?>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return BabyProfile.fromMap(data);
  }

  Future<void> saveProfile(String uid, BabyProfile profile) =>
      _profileRef(uid).set(profile.toMap(), SetOptions(merge: true));

  // --------------------------------------------------------------- entradas

  /// Todas as entradas ativas, da mais recente para a mais antiga.
  ///
  /// A coleção inteira é acompanhada de uma vez: um acervo familiar tem
  /// milhares de itens, não milhões, e tê-los em memória é o que permite
  /// busca instantânea e agrupamentos sem consultar o servidor de novo.
  Stream<List<Entry>> watchEntries(String uid) {
    return _entriesRef(uid)
        .where('status', isEqualTo: EntryStatus.active.id)
        .orderBy('data', descending: true)
        .snapshots()
        .map(_toEntries);
  }

  Stream<List<Entry>> watchTrash(String uid) {
    return _entriesRef(uid)
        .where('status', isEqualTo: EntryStatus.trashed.id)
        .orderBy('excluidoEm', descending: true)
        .snapshots()
        .map(_toEntries);
  }

  List<Entry> _toEntries(QuerySnapshot<Map<String, Object?>> snapshot) {
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, Object?>> d) =>
              Entry.fromMap(d.id, d.data()),
        )
        .toList();
  }

  /// Todas as entradas ativas de um tipo, numa leitura só.
  ///
  /// Serve ao `Informacoes.txt`, que precisa da lista de medições no momento
  /// de escrever. Uma consulta pontual, e não o stream da linha do tempo:
  /// escrever o arquivo não pode depender de a tela estar aberta.
  Future<List<Entry>> loadEntriesOfType(String uid, EntryType type) async {
    final QuerySnapshot<Map<String, Object?>> snap = await _entriesRef(uid)
        .where('tipo', isEqualTo: type.id)
        .where('status', isEqualTo: EntryStatus.active.id)
        .get();
    return _toEntries(snap);
  }

  /// Cria a entrada já visível na linha do tempo, antes do upload terminar.
  Future<String> createEntry(String uid, Entry entry) async {
    final DocumentReference<Map<String, Object?>> ref = entry.id.isEmpty
        ? _entriesRef(uid).doc()
        : _entriesRef(uid).doc(entry.id);
    await ref.set(entry.toMap());
    return ref.id;
  }

  Future<void> updateEntry(String uid, Entry entry) => _entriesRef(
    uid,
  ).doc(entry.id).set(entry.toMap(), SetOptions(merge: true));

  Future<void> patchEntry(
    String uid,
    String entryId,
    Map<String, Object?> data,
  ) => _entriesRef(uid).doc(entryId).update(data);

  Future<Entry?> loadEntry(String uid, String entryId) async {
    final DocumentSnapshot<Map<String, Object?>> doc = await _entriesRef(
      uid,
    ).doc(entryId).get();
    final Map<String, Object?>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return Entry.fromMap(doc.id, data);
  }

  /// Move para a lixeira. O arquivo no Drive é tratado à parte, pelo
  /// repositório, para que os dois lados fiquem coerentes.
  Future<void> moveToTrash(String uid, String entryId) =>
      patchEntry(uid, entryId, <String, Object?>{
        'status': EntryStatus.trashed.id,
        'excluidoEm': Timestamp.fromDate(DateTime.now()),
      });

  Future<void> restoreFromTrash(String uid, String entryId) => patchEntry(
    uid,
    entryId,
    <String, Object?>{'status': EntryStatus.active.id, 'excluidoEm': null},
  );

  Future<void> deleteEntry(String uid, String entryId) =>
      _entriesRef(uid).doc(entryId).delete();

  // ------------------------------------------------- cache de pastas Drive

  /// Id da pasta do Drive já criada para aquela chave (`Fotos/Semana 07`).
  ///
  /// Evita uma consulta ao Drive a cada envio: depois da primeira vez, o
  /// caminho vira uma leitura local do cache do Firestore.
  Future<String?> folderId(String uid, String key) async {
    final DocumentSnapshot<Map<String, Object?>> doc = await _user(
      uid,
    ).collection(_folders).doc(_slug(key)).get();
    return doc.data()?['driveId'] as String?;
  }

  Future<void> rememberFolder(String uid, String key, String driveId) =>
      _user(uid).collection(_folders).doc(_slug(key)).set(<String, Object?>{
        'caminho': key,
        'driveId': driveId,
        'criadoEm': Timestamp.fromDate(DateTime.now()),
      });

  /// Todas as pastas já criadas, do caminho para o id do Drive.
  ///
  /// Serve à reorganização do acervo, que precisa saber o que existe hoje
  /// para descobrir o que ainda está na estrutura antiga. É a lista completa
  /// numa leitura só, e não uma consulta por caminho: são poucas dezenas de
  /// documentos, e perguntar um a um custaria uma ida ao servidor por pasta.
  Future<Map<String, String>> allFolders(String uid) async {
    final QuerySnapshot<Map<String, Object?>> tudo = await _user(
      uid,
    ).collection(_folders).get();

    return <String, String>{
      for (final QueryDocumentSnapshot<Map<String, Object?>> d in tudo.docs)
        if (d.data()['caminho'] case final String caminho)
          if (d.data()['driveId'] case final String driveId
              when driveId.isNotEmpty)
            caminho: driveId,
    };
  }

  /// Esquece uma pasta do cache, com as subpastas dela.
  ///
  /// O cache é indexado pelo caminho, então tudo que começa pelo mesmo
  /// prefixo pertence à mesma árvore: apagar `Áudios` precisa levar junto
  /// `Áudios/Semana 09`, senão sobra um id apontando para pasta na lixeira.
  Future<void> forgetFolderTree(String uid, String key) async {
    final String prefixo = _slug(key);
    final QuerySnapshot<Map<String, Object?>> tudo = await _user(
      uid,
    ).collection(_folders).get();

    final WriteBatch batch = _db.batch();
    bool algum = false;
    for (final QueryDocumentSnapshot<Map<String, Object?>> d in tudo.docs) {
      if (d.id == prefixo || d.id.startsWith('${prefixo}__')) {
        batch.delete(d.reference);
        algum = true;
      }
    }
    if (algum) await batch.commit();
  }

  /// Ids do Firestore não aceitam `/`, então o caminho vira um identificador.
  static String _slug(String key) =>
      key.replaceAll('/', '__').replaceAll(RegExp(r'\s+'), '_');

  // ------------------------------------------------------- apagar tudo

  /// Todas as coleções que o aplicativo cria sob `users/{uid}`.
  ///
  /// `miniaturas` e `imagens` continuam aqui mesmo depois de o
  /// compartilhamento familiar ter saído: quem instalou a versão de teste tem
  /// documentos gravados nelas, e sem esta varredura "apagar minha conta e
  /// meus dados" deixaria rastro em silêncio. É uma promessa feita à Play
  /// Store, e ela não pode depender de a função ainda existir.
  static const List<String> _allCollections = <String>[
    _profile,
    _entries,
    _folders,
    _suggestions,
    _thumbnails,
    _images,
  ];

  /// Apaga as entradas de um tipo que saiu do produto.
  ///
  /// `EntryType.fromId` cai em `photo` quando não reconhece o valor. Sem esta
  /// limpeza, toda gravação de voz feita antes de o áudio sair apareceria na
  /// linha do tempo como foto, com um `.m4a` que a galeria tentaria desenhar.
  ///
  /// Devolve quantas apagou, e zero é a resposta normal: quem nunca gravou
  /// nada, ou quem já passou por aqui, não paga nada além de uma consulta.
  Future<int> deleteEntriesOfType(String uid, String tipo) async {
    final QuerySnapshot<Map<String, Object?>> achadas = await _entriesRef(
      uid,
    ).where('tipo', isEqualTo: tipo).get();
    if (achadas.docs.isEmpty) return 0;

    final WriteBatch batch = _db.batch();
    for (final QueryDocumentSnapshot<Map<String, Object?>> d in achadas.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    return achadas.docs.length;
  }

  /// A mesma lista, para o teste da política de privacidade.
  ///
  /// A política enumera o que fica no servidor. Coleção nova é dado novo, e
  /// dado novo tem que aparecer no texto antes de existir: expor a lista faz
  /// o teste falhar em vez de o documento envelhecer em silêncio.
  static List<String> get debugCollections => _allCollections;

  /// Um lote do Firestore aceita 500 operações; 300 deixa margem.
  static const int _deleteBatchSize = 300;

  // ------------------------------------------------------------ sugestões

  /// O que a pessoa já resolveu ou marcou no catálogo de sugestões.
  ///
  /// Um documento por sugestão, com o id do catálogo como chave. Guardar só
  /// o que foi tocado mantém a coleção pequena: quem nunca dispensou nada
  /// não tem documento nenhum.
  Stream<Map<String, SuggestionProgress>> watchSuggestions(String uid) {
    return _user(uid)
        .collection(_suggestions)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, Object?>> snap) =>
              <String, SuggestionProgress>{
                for (final QueryDocumentSnapshot<Map<String, Object?>> doc
                    in snap.docs)
                  doc.id: SuggestionProgress.fromMap(doc.data()),
              },
        );
  }

  Future<void> saveSuggestion(
    String uid,
    String id,
    SuggestionProgress progress,
  ) => _user(uid)
      .collection(_suggestions)
      .doc(id)
      .set(progress.toMap(), SetOptions(merge: true));

  /// Apaga tudo o que existe sob `users/{uid}`, sem deixar rastro.
  ///
  /// O Firestore não apaga subcoleções junto com o documento pai, então cada
  /// coleção é varrida explicitamente. As leituras vão direto ao servidor: o
  /// cache local diria "não há mais nada" enquanto os documentos continuariam
  /// lá, e a promessa de exclusão precisa valer no servidor.
  Future<void> deleteAllUserData(String uid) async {
    for (final String name in _allCollections) {
      await _deleteCollection(_user(uid).collection(name));
    }
    await _user(uid).delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, Object?>> collection,
  ) async {
    while (true) {
      final QuerySnapshot<Map<String, Object?>> page = await collection
          .limit(_deleteBatchSize)
          .get(const GetOptions(source: Source.server));
      if (page.docs.isEmpty) return;

      final WriteBatch batch = _db.batch();
      for (final QueryDocumentSnapshot<Map<String, Object?>> doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (page.docs.length < _deleteBatchSize) return;
    }
  }
}
