import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/models/entry.dart';

Entry photoEntry({String? title, String? description}) {
  return Entry(
    id: 'e1',
    type: EntryType.photo,
    date: DateTime(2027, 4, 10),
    createdAt: DateTime(2027, 4, 10),
    ageDays: 78,
    bucketKey: 'S12',
    bucketName: 'Semana 12',
    title: title,
    description: description,
    files: <EntryFile>[
      const EntryFile(
        driveId: 'd1',
        name: '2027-04-10_101500.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 2048,
      ),
    ],
  );
}

void main() {
  group('marcos', () {
    test('os marcos sugeridos cobrem os citados na especificação', () {
      for (final String expected in <String>[
        'Primeira foto',
        'Primeiro banho',
        'Primeiro passeio',
        'Primeira viagem',
        'Primeiro sorriso',
        'Primeiro dente',
        'Primeiros passos',
      ]) {
        expect(
          S.milestoneSuggestions,
          contains(expected),
          reason: '"$expected" está na especificação e sumiu das sugestões.',
        );
      }
    });

    test('sem marco, a foto mostra o texto genérico', () {
      expect(photoEntry().headline, 'Foto adicionada');
    });

    test('com marco, é ele que aparece na linha do tempo', () {
      expect(
        photoEntry(title: 'Primeiro sorriso').headline,
        'Primeiro sorriso',
      );
    });

    test('o marco entra no índice de busca', () {
      final Entry entry = photoEntry(
        title: 'Primeiro sorriso',
        description: 'Na casa da vovó',
      );
      expect(entry.searchable, contains('primeiro sorriso'));
      expect(entry.searchable, contains('vovó'));
      // O nome do arquivo no Drive permite buscar pela data também.
      expect(entry.searchable, contains('2027-04-10'));
    });

    test('apagar o marco tira o texto do índice de busca', () {
      // É a diferença entre remontar a entrada e usar copyWith, que
      // manteria o valor antigo quando o novo é nulo.
      final Entry cleared = Entry(
        id: 'e1',
        type: EntryType.photo,
        date: DateTime(2027, 4, 10),
        createdAt: DateTime(2027, 4, 10),
        ageDays: 78,
        bucketKey: 'S12',
        bucketName: 'Semana 12',
        files: photoEntry().files,
      );
      expect(cleared.searchable, isNot(contains('sorriso')));
      expect(cleared.headline, 'Foto adicionada');
    });
  });
}
