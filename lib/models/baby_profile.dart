import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../core/utils/age_calculator.dart';
import 'baby_gender.dart';

/// Cadastro inicial da criança. Documento único em
/// `users/{uid}/perfil/bebe`.
@immutable
class BabyProfile {
  const BabyProfile({
    required this.name,
    required this.birth,
    this.gender,
    this.birthWeightGrams,
    this.birthHeightCm,
    this.hospital,
    this.photoDriveId,
    this.rootFolderId,
    this.infoFileId,
  });

  /// Nome completo, usado em toda a interface.
  final String name;

  /// Data **e hora** de nascimento. A hora aparece no perfil; os cálculos de
  /// idade usam apenas o dia.
  final DateTime birth;

  /// Menino ou menina - define a concordância dos textos. `null` em
  /// cadastros antigos, e aí a interface usa a forma neutra.
  final BabyGender? gender;

  final int? birthWeightGrams;
  final double? birthHeightCm;
  final String? hospital;

  /// Foto do nascimento já enviada ao Drive.
  final String? photoDriveId;

  /// Id da pasta da cápsula no Drive, raiz de toda a estrutura.
  ///
  /// É por este id que a pasta é reencontrada: o aplicativo nunca procura
  /// nada na raiz do Drive de quem instalou.
  final String? rootFolderId;

  /// Id do `Informacoes.txt` na pasta da cápsula.
  ///
  /// Guardado para que o arquivo seja **atualizado** a cada mudança, e não
  /// recriado: sem o id, um ano de uso deixaria trezentas cópias empilhadas
  /// na pasta.
  final String? infoFileId;

  /// Primeiro nome - o que aparece nos cabeçalhos.
  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  DateTime get birthDay => AgeCalculator.dayOf(birth);

  /// Idade hoje (ou em [now], nos testes).
  Age ageNow([DateTime? now]) =>
      AgeCalculator.ageAt(birth, now ?? DateTime.now());

  Age ageAt(DateTime date) => AgeCalculator.ageAt(birth, date);

  AgeBucket bucketAt(DateTime date) => AgeCalculator.bucketAt(birth, date);

  BabyProfile copyWith({
    String? name,
    DateTime? birth,
    BabyGender? gender,
    int? birthWeightGrams,
    double? birthHeightCm,
    String? hospital,
    String? photoDriveId,
    String? rootFolderId,
    String? infoFileId,
  }) {
    return BabyProfile(
      name: name ?? this.name,
      birth: birth ?? this.birth,
      gender: gender ?? this.gender,
      birthWeightGrams: birthWeightGrams ?? this.birthWeightGrams,
      birthHeightCm: birthHeightCm ?? this.birthHeightCm,
      hospital: hospital ?? this.hospital,
      photoDriveId: photoDriveId ?? this.photoDriveId,
      rootFolderId: rootFolderId ?? this.rootFolderId,
      infoFileId: infoFileId ?? this.infoFileId,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'nome': name,
    'nascimento': Timestamp.fromDate(birth),
    'genero': gender?.id,
    'pesoGramas': birthWeightGrams,
    'alturaCm': birthHeightCm,
    'hospital': hospital,
    'fotoDriveId': photoDriveId,
    'pastaRaizId': rootFolderId,
    'arquivoInfoId': infoFileId,
  };

  static BabyProfile fromMap(Map<String, Object?> map) {
    return BabyProfile(
      name: (map['nome'] as String?) ?? '',
      birth: _toDate(map['nascimento']) ?? DateTime.now(),
      gender: BabyGender.fromId(map['genero'] as String?),
      birthWeightGrams: (map['pesoGramas'] as num?)?.toInt(),
      birthHeightCm: (map['alturaCm'] as num?)?.toDouble(),
      hospital: map['hospital'] as String?,
      photoDriveId: map['fotoDriveId'] as String?,
      rootFolderId: map['pastaRaizId'] as String?,
      infoFileId: map['arquivoInfoId'] as String?,
    );
  }

  static DateTime? _toDate(Object? value) => switch (value) {
    Timestamp t => t.toDate(),
    DateTime d => d,
    String s => DateTime.tryParse(s),
    _ => null,
  };
}
