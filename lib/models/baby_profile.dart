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
    this.premium = false,
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

  /// Se esta conta tem a licença que libera criar carta, desenho, documento
  /// e crescimento.
  ///
  /// **A licença é da conta que faz login**, e não do aparelho nem de quem
  /// pagou. Três filhos que entram no mesmo celular são três contas, e cada
  /// uma responde por si. Por isso o valor mora aqui, no perfil daquela
  /// criança, e não no que a biblioteca de faturamento devolve: ela responde
  /// pela conta da Play Store do aparelho, que é outra pessoa.
  ///
  /// Ausente quer dizer plano básico. Toda conta que existe hoje entra assim,
  /// sem migração nenhuma, e continua podendo ler tudo e mandar foto e vídeo.
  ///
  /// **O aplicativo ainda não escreve este campo**, e por isso ele está fora
  /// do [toMap]. Hoje ele é virado à mão no Firebase Console, que é como o
  /// portão se testa sem depender da loja; quando o faturamento entrar, quem
  /// escreve é a confirmação da compra, por um caminho próprio. Enquanto
  /// estiver fora do [toMap], o `merge` do perfil preserva o que já está
  /// gravado, e salvar o cadastro não apaga a licença de ninguém.
  final bool premium;

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
    bool? premium,
    // Apagar um campo opcional precisa ser dito, porque passar `null` num
    // `copyWith` quer dizer "não mexe". Sem estes, quem apagasse o peso na
    // tela de editar veria o valor antigo voltar sozinho ao salvar.
    bool clearWeight = false,
    bool clearHeight = false,
    bool clearHospital = false,
  }) {
    return BabyProfile(
      name: name ?? this.name,
      birth: birth ?? this.birth,
      gender: gender ?? this.gender,
      birthWeightGrams: clearWeight
          ? null
          : (birthWeightGrams ?? this.birthWeightGrams),
      birthHeightCm: clearHeight ? null : (birthHeightCm ?? this.birthHeightCm),
      hospital: clearHospital ? null : (hospital ?? this.hospital),
      photoDriveId: photoDriveId ?? this.photoDriveId,
      rootFolderId: rootFolderId ?? this.rootFolderId,
      infoFileId: infoFileId ?? this.infoFileId,
      premium: premium ?? this.premium,
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
      premium: map['premium'] == true,
    );
  }

  static DateTime? _toDate(Object? value) => switch (value) {
    Timestamp t => t.toDate(),
    DateTime d => d,
    String s => DateTime.tryParse(s),
    _ => null,
  };
}
