import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/baby_profile.dart';
import '../models/entry.dart';

/// Índice de tudo que existe no aplicativo.
///
/// O Firestore guarda apenas metadados — nenhum byte de foto passa por aqui.
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

  /// Ids do Firestore não aceitam `/`, então o caminho vira um identificador.
  static String _slug(String key) =>
      key.replaceAll('/', '__').replaceAll(RegExp(r'\s+'), '_');
}
