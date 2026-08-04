import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// Quem está olhando a cápsula.
///
/// Não é uma preferência nem uma configuração: é uma constatação, feita na
/// abertura do aplicativo a partir do que existe no Firestore. Quem tem um
/// vínculo é família; quem não tem é dono da própria cápsula.
enum CapsuleRole {
  /// O pai ou a mãe, na própria cápsula. Escreve, apaga, convida.
  owner,

  /// A avó, a tia, o padrinho. Só lê, e só parte.
  family,
}

/// O estado de um convite.
///
/// Um convite não é apagado quando usado: vira `used`, e fica. A cápsula é
/// uma coisa de vinte anos, e daqui a vinte anos alguém vai querer saber
/// quem entrou e quando.
enum InviteStatus {
  pending('pending'),
  used('used'),
  revoked('revoked');

  const InviteStatus(this.id);
  final String id;

  static InviteStatus fromId(String? id) => values.firstWhere(
    (InviteStatus s) => s.id == id,
    orElse: () => InviteStatus.revoked,
  );
}

/// O convite que o pai ou a mãe cria para uma pessoa específica.
///
/// O id do documento **é** o código. Ninguém lista a coleção, então só
/// alcança o documento quem já recebeu o código pela mão - e mesmo assim as
/// regras ainda exigem ser o email convidado.
@immutable
class FamilyInvite {
  const FamilyInvite({
    required this.code,
    required this.ownerUid,
    required this.folderId,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  /// O código. É o id do documento, não um campo dentro dele.
  final String code;

  final String ownerUid;

  /// A pasta da cápsula no Drive, que o convite também libera.
  final String folderId;

  /// Para quem o convite vale. Um código que serve para qualquer email é um
  /// código que vaza uma vez e vale para sempre.
  final String email;

  /// Como a pessoa é chamada em casa: "Vó Maria". Aparece na lista de quem
  /// tem acesso, para o pai reconhecer sem decifrar endereços de email.
  final String name;

  final DateTime createdAt;
  final DateTime expiresAt;
  final InviteStatus status;

  bool isExpiredAt(DateTime now) => expiresAt.isBefore(now);

  bool usableAt(DateTime now) =>
      status == InviteStatus.pending && !isExpiredAt(now);

  Map<String, Object?> toMap() => <String, Object?>{
    'ownerUid': ownerUid,
    'folderId': folderId,
    'email': email,
    'nome': name,
    'criadoEm': Timestamp.fromDate(createdAt),
    'expiraEm': Timestamp.fromDate(expiresAt),
    'status': status.id,
  };

  static FamilyInvite fromMap(String code, Map<String, Object?> map) =>
      FamilyInvite(
        code: code,
        ownerUid: (map['ownerUid'] as String?) ?? '',
        folderId: (map['folderId'] as String?) ?? '',
        email: (map['email'] as String?) ?? '',
        name: (map['nome'] as String?) ?? '',
        createdAt: _date(map['criadoEm']) ?? DateTime.now(),
        expiresAt: _date(map['expiraEm']) ?? DateTime.now(),
        status: InviteStatus.fromId(map['status'] as String?),
      );
}

/// O vínculo, do lado de quem foi convidado.
///
/// Um documento por familiar, com o uid dele como id. É o que o aplicativo
/// lê na abertura para saber qual cápsula abrir, e é por isso que ele não
/// precisa perguntar nada a ninguém depois do primeiro acesso.
@immutable
class FamilyLink {
  const FamilyLink({
    required this.ownerUid,
    required this.folderId,
    required this.email,
    required this.code,
    required this.createdAt,
  });

  final String ownerUid;
  final String folderId;
  final String email;
  final String code;
  final DateTime createdAt;

  Map<String, Object?> toMap() => <String, Object?>{
    'ownerUid': ownerUid,
    'folderId': folderId,
    // Fixo. O papel existe no documento para as regras conferirem, não para
    // o aplicativo escolher: um dia pode haver outro papel, e nesse dia a
    // regra do servidor é que decide.
    'role': 'viewer',
    'email': email,
    'codigo': code,
    'criadoEm': Timestamp.fromDate(createdAt),
  };

  static FamilyLink? fromMap(Map<String, Object?>? map) {
    if (map == null) return null;
    final String owner = (map['ownerUid'] as String?) ?? '';
    if (owner.isEmpty) return null;
    return FamilyLink(
      ownerUid: owner,
      folderId: (map['folderId'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      code: (map['codigo'] as String?) ?? '',
      createdAt: _date(map['criadoEm']) ?? DateTime.now(),
    );
  }
}

DateTime? _date(Object? value) => switch (value) {
  Timestamp() => value.toDate(),
  DateTime() => value,
  _ => null,
};

/// Gera um código de convite legível em voz alta.
///
/// Isso importa mais do que parece: o código vai ser ditado por telefone
/// para uma avó de setenta anos. Então nada de `0`/`O`, `1`/`I`/`L`, nem
/// letras minúsculas, e os grupos de quatro existem para poder repetir
/// devagar, "A-B-C-D, pausa".
///
/// São 30 símbolos em 10 posições, o que dá muito mais combinações do que
/// alguém conseguiria tentar - e as regras ainda exigem o email certo, então
/// adivinhar o código não abre nada sozinho.
String generateInviteCode([Random? random]) {
  const String alfabeto = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  final Random r = random ?? Random.secure();
  String bloco(int n) => List<String>.generate(
    n,
    (_) => alfabeto[r.nextInt(alfabeto.length)],
  ).join();
  return '${bloco(2)}-${bloco(4)}-${bloco(4)}';
}

/// Quanto tempo um convite vale.
///
/// Curto de propósito. Um código que fica válido para sempre é um código que
/// alguém encontra numa conversa antiga daqui a três anos.
const Duration inviteLifetime = Duration(days: 7);
