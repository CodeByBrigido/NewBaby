import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/entry.dart';

Entry entryOf({
  EntryType type = EntryType.photo,
  String? title,
  String? description,
  List<EntryFile> files = const <EntryFile>[],
  GrowthData? growth,
}) {
  return Entry(
    id: 'e1',
    type: type,
    date: DateTime(2027, 4, 22),
    createdAt: DateTime(2027, 4, 22),
    ageDays: 90,
    bucketKey: 'M04',
    bucketName: 'Semana 13',
    title: title,
    description: description,
    files: files,
    growth: growth,
  );
}

EntryFile fileOf({
  String name = 'foto.jpg',
  String mime = 'image/jpeg',
  int bytes = 1024,
}) {
  return EntryFile(driveId: 'd1', name: name, mimeType: mime, sizeBytes: bytes);
}

void main() {
  group('pasta de cada tipo no Drive', () {
    test('só fotos e vídeos são separados por idade', () {
      expect(EntryType.photo.bucketsByAge, isTrue);
      expect(EntryType.video.bucketsByAge, isTrue);
      expect(EntryType.letter.bucketsByAge, isFalse);
      expect(EntryType.document.bucketsByAge, isFalse);
      expect(EntryType.growth.bucketsByAge, isFalse);
      expect(EntryType.drawing.bucketsByAge, isFalse);
    });

    test('os nomes das pastas seguem a especificação', () {
      expect(EntryType.photo.folder, 'Fotos');
      expect(EntryType.video.folder, 'Vídeos');
      expect(EntryType.letter.folder, 'Cartas');
      expect(EntryType.drawing.folder, 'Desenhos');
      expect(EntryType.document.folder, 'Documentos');
      expect(EntryType.growth.folder, 'Crescimento');
    });
  });

  group('título exibido na linha do tempo', () {
    test('usa o título quando existe', () {
      expect(entryOf(title: 'Primeiro sorriso').headline, 'Primeiro sorriso');
    });

    test('cartas recebem o prefixo "Carta:"', () {
      expect(
        entryOf(type: EntryType.letter, title: 'Para minha filha').headline,
        'Carta: Para minha filha',
      );
    });

    test('sem título, o texto muda com a quantidade de fotos', () {
      expect(entryOf(files: <EntryFile>[fileOf()]).headline, 'Foto adicionada');
      expect(
        entryOf(files: <EntryFile>[fileOf(), fileOf()]).headline,
        'Fotos adicionadas',
      );
    });

    test('documento sem título cai no nome do arquivo', () {
      expect(
        entryOf(
          type: EntryType.document,
          files: <EntryFile>[fileOf(name: 'Certidão.pdf')],
        ).headline,
        'Certidão.pdf',
      );
    });
  });

  group('busca', () {
    test('junta título, descrição e nomes de arquivo em minúsculas', () {
      final Entry entry = entryOf(
        title: 'Primeiro Sorriso',
        description: 'Na Casa da Vovó',
        files: <EntryFile>[fileOf(name: 'IMG_001.jpg')],
      );
      expect(entry.searchable, contains('primeiro sorriso'));
      expect(entry.searchable, contains('vovó'));
      expect(entry.searchable, contains('img_001.jpg'));
      expect(entry.searchable, isNot(contains('Primeiro')));
    });
  });

  group('arquivos', () {
    test('extensão em maiúsculas para o cartão de documento', () {
      expect(fileOf(name: 'Certidão.pdf').extensionLabel, 'PDF');
      expect(fileOf(name: 'trabalho.docx').extensionLabel, 'DOCX');
      expect(fileOf(name: 'sem_extensao').extensionLabel, 'ARQ');
    });

    test('reconhece imagem, vídeo e pdf pelo mime', () {
      expect(fileOf(mime: 'image/jpeg').isImage, isTrue);
      expect(fileOf(mime: 'video/mp4').isVideo, isTrue);
      expect(fileOf(mime: 'application/pdf').isPdf, isTrue);
    });

    test('soma os bytes de todos os arquivos da entrada', () {
      final Entry entry = entryOf(
        files: <EntryFile>[fileOf(bytes: 1000), fileOf(bytes: 2500)],
      );
      expect(entry.totalBytes, 3500);
    });
  });

  group('serialização', () {
    test('vai e volta do formato do Firestore sem perder nada', () {
      final Entry original = entryOf(
        type: EntryType.growth,
        title: 'Consulta',
        description: 'Pediatra',
        files: <EntryFile>[fileOf(name: 'peso.jpg', bytes: 4096)],
        growth: const GrowthData(weightGrams: 5800, heightCm: 61),
      );

      final Entry restored = Entry.fromMap('e1', original.toMap());

      expect(restored.type, EntryType.growth);
      expect(restored.title, 'Consulta');
      expect(restored.description, 'Pediatra');
      expect(restored.bucketKey, 'M04');
      expect(restored.ageDays, 90);
      expect(restored.files.single.name, 'peso.jpg');
      expect(restored.files.single.sizeBytes, 4096);
      expect(restored.growth?.weightGrams, 5800);
      expect(restored.growth?.heightCm, 61);
      expect(restored.date, original.date);
    });

    test('um documento incompleto não derruba a leitura', () {
      final Entry restored = Entry.fromMap('x', <String, Object?>{});
      expect(restored.id, 'x');
      expect(restored.files, isEmpty);
      expect(restored.status, EntryStatus.active);
    });
  });

  group('estados de envio', () {
    test('pendente, otimizando e enviando contam como ocupados', () {
      expect(UploadStatus.pending.isBusy, isTrue);
      expect(UploadStatus.optimizing.isBusy, isTrue);
      expect(UploadStatus.uploading.isBusy, isTrue);
      expect(UploadStatus.ready.isBusy, isFalse);
      expect(UploadStatus.failed.isBusy, isFalse);
    });

    test('um valor desconhecido volta como pronto, sem quebrar a tela', () {
      expect(UploadStatus.fromId('outra_coisa'), UploadStatus.ready);
      expect(EntryStatus.fromId(null), EntryStatus.active);
    });
  });
}
