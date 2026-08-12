import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';

/// A escolha da foto de perfil.
///
/// A foto sai das memórias já guardadas, e não da galeria do celular. Subir
/// uma imagem que existisse só como avatar criaria um arquivo sem lugar na
/// linha do tempo, órfão de data e de contexto, que ninguém encontraria de
/// novo. Tudo o que representa a criança aqui já está no Drive dela.
void main() {
  final BabyProfile maria = BabyProfile(
    name: 'Maria Silva',
    gender: BabyGender.girl,
    birth: DateTime(2026, 4, 15),
  );

  group('a escolha fica guardada no cadastro', () {
    test('escolher uma foto grava o id dela', () {
      final BabyProfile com = maria.copyWith(photoDriveId: 'drive-123');
      expect(com.photoDriveId, 'drive-123');
      expect(com.toMap()['fotoDriveId'], 'drive-123');
    });

    test('voltar para automática limpa o id, e não o mantém', () {
      // `copyWith` ignora nulo, então voltar ao automático precisa gravar
      // string vazia. Passar nulo aqui deixaria a foto antiga fixada para
      // sempre, e o botão "Automática" não faria nada.
      final BabyProfile com = maria.copyWith(photoDriveId: 'drive-123');
      final BabyProfile sem = com.copyWith(photoDriveId: '');

      expect(sem.photoDriveId, isEmpty);
      expect(com.copyWith().photoDriveId, 'drive-123');
    });

    test('nada mais do cadastro muda junto', () {
      final BabyProfile com = maria.copyWith(photoDriveId: 'drive-123');
      expect(com.name, maria.name);
      expect(com.birth, maria.birth);
      expect(com.gender, maria.gender);
    });
  });
}
