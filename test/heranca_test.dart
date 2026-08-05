import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/features/profile/about_screen.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/drive_service.dart';

/// As instruções de herança precisam continuar verdadeiras.
///
/// É o único texto do aplicativo que ninguém relê: quem instala hoje só vai
/// segui-lo daqui a vinte anos, quando não houver mais a quem perguntar. Se o
/// nome da pasta ou a organização mudarem no código, o texto vira um mapa
/// para um lugar que não existe mais, e ninguém percebe até ser tarde.
void main() {
  AgeBucket balde(AgeBucketUnit unit, int index) => AgeBucket(
    unit: unit,
    index: index,
    start: DateTime(2027, 1, 22),
    end: DateTime(2027, 1, 28),
  );

  group('o caminho até a cápsula confere com o que o código faz', () {
    test('a pasta citada é a pasta que o aplicativo cria', () {
      expect(
        Heranca.comoEntregar(Copy.generic),
        contains(DriveService.rootFolderName),
      );
    });

    test('as pastas de primeiro nível são as reais', () {
      for (final EntryType tipo in <EntryType>[
        EntryType.photo,
        EntryType.video,
        EntryType.audio,
      ]) {
        expect(Heranca.comoEstaOrganizado, contains(tipo.folder));
      }
    });

    test('os exemplos de pasta por idade saem do próprio gerador', () {
      expect(
        Heranca.comoEstaOrganizado,
        contains(balde(AgeBucketUnit.week, 7).folderName),
      );
      expect(
        Heranca.comoEstaOrganizado,
        contains(balde(AgeBucketUnit.month, 14).folderName),
      );
      expect(
        Heranca.comoEstaOrganizado,
        contains(balde(AgeBucketUnit.year, 3).folderName),
      );
    });

    test('nenhum tipo sem arquivo é apresentado como pasta do Drive', () {
      // Cartas e medidas não geram upload, então não existe pasta "Cartas"
      // no Drive de ninguém.
      for (final EntryType tipo in EntryType.values) {
        if (tipo.bucketsByAge) continue;
        expect(
          Heranca.comoEstaOrganizado,
          isNot(contains(tipo.folder)),
          reason: tipo.folder,
        );
      }
    });
  });

  group('a frase fala da criança pelo nome', () {
    test('com nome cadastrado, o nome aparece', () {
      final Copy c = Copy.of(
        BabyProfile(
          name: 'Maria Eduarda',
          birth: DateTime(2027, 1, 22),
          gender: BabyGender.girl,
        ),
      );
      expect(Heranca.comoEntregar(c), contains('até a Maria'));
    });

    test('sem cadastro, a frase é outra e não fica capenga', () {
      final String texto = Heranca.comoEntregar(Copy.generic);
      expect(texto, isNot(contains('até ')));
      expect(texto, contains('vai ser entregue'));
    });
  });

  group('a ressalva não pode sumir', () {
    test('o texto diz o que ainda depende do aplicativo', () {
      // Enquanto a exportação da 8c não existir, "o acervo continua lá" vale
      // para os arquivos e não para o texto das cartas. Dizer só a primeira
      // metade seria prometer mais do que o produto entrega.
      expect(Heranca.oQueAindaDepende, contains('cartas'));
      expect(Heranca.oQueAindaDepende, contains('medidas'));
    });
  });
}
