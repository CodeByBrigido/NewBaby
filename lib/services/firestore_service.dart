import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../models/baby_profile.dart';
import '../models/entry.dart';
import '../models/family_access.dart';
import '../models/suggestion_progress.dart';

/// Uma pessoa com acesso à cápsula, do ponto de vista de quem convidou.
@immutable
class FamilyMember {
  const FamilyMember({required this.uid, required this.link});

  final String uid;
  final FamilyLink? link;
}

/// Índice de tudo que existe no aplicativo.
///
/// O Firestore guarda apenas metadados - nenhum byte de foto passa por aqui.
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
  static const String _shareCodes = 'shareCodes';
  static const String _familyAccess = 'familyAccess';

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

  /// A mesma linha do tempo, vista por quem foi convidado.
  ///
  /// Os três filtros não são conveniência de tela: são o que as regras do
  /// servidor exigem. No Firestore a regra é avaliada contra a **consulta**,
  /// não contra cada documento devolvido, então uma consulta mais larga não
  /// traz menos resultados: ela é recusada inteira. Se um filtro sair daqui,
  /// a linha do tempo do familiar fica vazia, e `firebase/teste` reprova.
  ///
  /// O `whereIn` aceita até 30 valores; são cinco.
  Stream<List<Entry>> watchFamilyEntries(String ownerUid) {
    return _entriesRef(ownerUid)
        .where('status', isEqualTo: EntryStatus.active.id)
        .where('lacradoAte', isNull: true)
        .where(
          'tipo',
          whereIn: EntryType.familyVisible
              .map((EntryType t) => t.id)
              .toList(growable: false),
        )
        .orderBy('data', descending: true)
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

  // ------------------------------------------------------- apagar tudo

  /// Todas as coleções que o aplicativo cria sob `users/{uid}`.
  static const List<String> _allCollections = <String>[
    _profile,
    _entries,
    _folders,
    _suggestions,
  ];

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

  // -------------------------------------------------- convites e vínculos

  /// Cria o convite. O código vira o id do documento.
  ///
  /// Guardar o código como id, e não como campo, é o que permite negar a
  /// listagem da coleção inteira: sem `list`, só chega ao documento quem já
  /// sabe o código, e mesmo assim as regras ainda exigem o email certo.
  Future<void> createInvite(FamilyInvite invite) =>
      _db.collection(_shareCodes).doc(invite.code).set(invite.toMap());

  /// Lê um convite pelo código.
  ///
  /// Devolve `null` quando o código não existe **e também** quando existe mas
  /// não é para esta pessoa: as regras negam a leitura, e o aplicativo não
  /// tem por que distinguir os dois casos para quem está digitando. Dizer
  /// "esse código existe, mas não é seu" já é contar demais.
  Future<FamilyInvite?> loadInvite(String code) async {
    try {
      final DocumentSnapshot<Map<String, Object?>> doc = await _db
          .collection(_shareCodes)
          .doc(code)
          .get();
      final Map<String, Object?>? data = doc.data();
      if (!doc.exists || data == null) return null;
      return FamilyInvite.fromMap(doc.id, data);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return null;
      rethrow;
    }
  }

  /// Os convites que esta pessoa criou, do mais novo para o mais antigo.
  Stream<List<FamilyInvite>> watchInvitesOf(String ownerUid) {
    return _db
        .collection(_shareCodes)
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((QuerySnapshot<Map<String, Object?>> snap) {
          final List<FamilyInvite> lista = snap.docs
              .map(
                (QueryDocumentSnapshot<Map<String, Object?>> d) =>
                    FamilyInvite.fromMap(d.id, d.data()),
              )
              .toList();
          lista.sort(
            (FamilyInvite a, FamilyInvite b) =>
                b.createdAt.compareTo(a.createdAt),
          );
          return lista;
        });
  }

  Future<void> setInviteStatus(String code, InviteStatus status) => _db
      .collection(_shareCodes)
      .doc(code)
      .update(<String, Object?>{'status': status.id});

  /// O vínculo desta conta, quando existe.
  ///
  /// É a primeira pergunta que o aplicativo faz depois do login, e a resposta
  /// decide tudo o que vem depois: cápsula própria ou cápsula de outra
  /// pessoa, modo de escrita ou modo de leitura.
  Stream<FamilyLink?> watchFamilyLink(String uid) => _db
      .collection(_familyAccess)
      .doc(uid)
      .snapshots()
      .map(
        (DocumentSnapshot<Map<String, Object?>> d) =>
            FamilyLink.fromMap(d.data()),
      );

  /// Resgata o código: grava o vínculo e marca o convite como usado.
  ///
  /// Os dois passos são separados de propósito. O vínculo vem primeiro
  /// porque é ele que dá acesso; se marcar o convite falhar, a pessoa já
  /// entrou e o pior que acontece é um convite que continua constando como
  /// pendente. Na ordem inversa, uma falha deixaria a pessoa de fora com o
  /// código queimado.
  Future<void> redeemInvite({
    required String uid,
    required FamilyLink link,
  }) async {
    await _db.collection(_familyAccess).doc(uid).set(link.toMap());
    await setInviteStatus(link.code, InviteStatus.used);
  }

  /// Quem tem acesso à cápsula desta pessoa.
  Stream<List<FamilyMember>> watchFamilyMembers(String ownerUid) => _db
      .collection(_familyAccess)
      .where('ownerUid', isEqualTo: ownerUid)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, Object?>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, Object?>> d) =>
                  FamilyMember(uid: d.id, link: FamilyLink.fromMap(d.data())),
            )
            .toList(),
      );

  /// Tira o acesso de alguém, ou sai da cápsula por conta própria.
  ///
  /// Isto derruba o lado do Firestore. O lado do Drive é tratado pelo
  /// repositório, porque são duas permissões separadas e uma não sabe da
  /// outra.
  Future<void> removeFamilyAccess(String uid) =>
      _db.collection(_familyAccess).doc(uid).delete();

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
