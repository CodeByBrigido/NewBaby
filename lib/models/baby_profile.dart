import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../core/utils/age_calculator.dart';

/// Cadastro inicial da bebê. Documento único em `users/{uid}/perfil/bebe`.
@immutable
class BabyProfile {
  const BabyProfile({
    required this.name,
    required this.birth,
    this.birthWeightGrams,
    this.birthHeightCm,
    this.hospital,
    this.photoDriveId,
    this.rootFolderId,
  });

  /// Nome completo, usado em toda a interface.
  final String name;

  /// Data **e hora** de nascimento. A hora aparece no perfil; os cálculos de
  /// idade usam apenas o dia.
  final DateTime birth;

  final int? birthWeightGrams;
  final double? birthHeightCm;
  final String? hospital;

  /// Foto do nascimento já enviada ao Drive.
  final String? photoDriveId;

  /// Id da pasta `Meu Bebê` no Drive, raiz de toda a estrutura.
  final String? rootFolderId;

  /// Primeiro nome — o que aparece nos cabeçalhos.
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
    int? birthWeightGrams,
    double? birthHeightCm,
    String? hospital,
    String? photoDriveId,
    String? rootFolderId,
  }) {
    return BabyProfile(
      name: name ?? this.name,
      birth: birth ?? this.birth,
      birthWeightGrams: birthWeightGrams ?? this.birthWeightGrams,
      birthHeightCm: birthHeightCm ?? this.birthHeightCm,
      hospital: hospital ?? this.hospital,
      photoDriveId: photoDriveId ?? this.photoDriveId,
      rootFolderId: rootFolderId ?? this.rootFolderId,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'nome': name,
    'nascimento': Timestamp.fromDate(birth),
    'pesoGramas': birthWeightGrams,
    'alturaCm': birthHeightCm,
    'hospital': hospital,
    'fotoDriveId': photoDriveId,
    'pastaRaizId': rootFolderId,
  };

  static BabyProfile fromMap(Map<String, Object?> map) {
    return BabyProfile(
      name: (map['nome'] as String?) ?? '',
      birth: _toDate(map['nascimento']) ?? DateTime.now(),
      birthWeightGrams: (map['pesoGramas'] as num?)?.toInt(),
      birthHeightCm: (map['alturaCm'] as num?)?.toDouble(),
      hospital: map['hospital'] as String?,
      photoDriveId: map['fotoDriveId'] as String?,
      rootFolderId: map['pastaRaizId'] as String?,
    );
  }

  static DateTime? _toDate(Object? value) => switch (value) {
    Timestamp t => t.toDate(),
    DateTime d => d,
    String s => DateTime.tryParse(s),
    _ => null,
  };
}
