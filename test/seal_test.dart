import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/entry.dart';

/// O lacre: guardado agora, para abrir depois.
///
/// **Não é criptografia, e isso é deliberado.** O conteúdo continua no
/// Firestore e no Drive de quem gravou, legível por quem tiver a conta. É a
/// mesma natureza da cápsula enterrada no quintal: dá para desenterrar antes
/// da hora, e não desenterrar é a graça.
///
/// Poderia ser um cofre de verdade. Não é porque uma chave perdida em vinte
/// anos apagaria a memória para sempre, e num acervo feito para durar
/// décadas esse risco é maior que o de alguém espiar o próprio presente.
///
/// O que estes testes garantem é o que a interface promete: enquanto a data
/// não chega, o aplicativo não mostra.
void main() {
  Entry carta({DateTime? sealedUntil}) => Entry(
    id: 'c1',
    type: EntryType.letter,
    date: DateTime(2027, 4, 10),
    createdAt: DateTime(2027, 4, 10),
    ageDays: 78,
    bucketKey: 'S12',
    bucketName: 'Semana 12',
    title: 'Para quando você crescer',
    description: 'Hoje você riu pela primeira vez.',
    sealedUntil: sealedUntil,
  );

  group('quando o lacre vale', () {
    test('antes da data, está lacrado', () {
      final Entry e = carta(sealedUntil: DateTime(2045, 1, 22));
      expect(e.isSealedAt(DateTime(2027, 4, 10)), isTrue);
    });

    test('no instante da abertura, deixa de estar', () {
      final DateTime abre = DateTime(2045, 1, 22);
      expect(carta(sealedUntil: abre).isSealedAt(abre), isFalse);
    });

    test('depois da data, aberto para sempre', () {
      final Entry e = carta(sealedUntil: DateTime(2045, 1, 22));
      expect(e.isSealedAt(DateTime(2045, 1, 23)), isFalse);
      expect(e.isSealedAt(DateTime(2099, 1, 1)), isFalse);
    });

    test('sem data, nunca esteve lacrado', () {
      expect(carta().isSealedAt(DateTime(2027, 4, 10)), isFalse);
    });
  });

  group('o lacre sobrevive à ida e volta do Firestore', () {
    test('vai e volta com a data intacta', () {
      final DateTime abre = DateTime(2045, 1, 22);
      final Entry lida = Entry.fromMap('c1', carta(sealedUntil: abre).toMap());
      expect(lida.sealedUntil, abre);
      expect(lida.isSealedAt(DateTime(2030, 1, 1)), isTrue);
    });

    test('entrada antiga, sem o campo, continua legível', () {
      // Tudo o que foi gravado antes desta versão não tem `lacradoAte`.
      final Entry antiga = Entry.fromMap('c1', <String, Object?>{
        'tipo': 'carta',
        'titulo': 'Carta',
      });
      expect(antiga.sealedUntil, isNull);
      expect(antiga.isSealedAt(DateTime(2027, 1, 1)), isFalse);
    });

    test('sem lacre, o campo vai nulo e não sobra lixo', () {
      expect(carta().toMap()['lacradoAte'], isNull);
    });
  });

  group('mexer numa entrada não tira o lacre por acidente', () {
    // Este é o erro que apagaria um presente: alguém corrige um título em
    // 2030 e a carta dos 18 anos abre sozinha.
    test('copyWith carrega o lacre adiante', () {
      final Entry e = carta(sealedUntil: DateTime(2045, 1, 22));
      expect(e.copyWith(title: 'Outro título').sealedUntil, e.sealedUntil);
    });

    test('tirar o lacre exige dizer isso explicitamente', () {
      final Entry e = carta(sealedUntil: DateTime(2045, 1, 22));
      expect(e.copyWith(clearSeal: true).sealedUntil, isNull);
    });
  });

  group('o tipo áudio entrou inteiro', () {
    test('vai e volta pelo Firestore', () {
      expect(EntryType.fromId('audio'), EntryType.audio);
      expect(EntryType.audio.id, 'audio');
    });

    test('é organizado por idade, como foto e vídeo', () {
      expect(EntryType.audio.bucketsByAge, isTrue);
    });

    test('tem pasta própria no Drive', () {
      expect(EntryType.audio.folder, 'Áudios');
      final Set<String> pastas = EntryType.values
          .map((EntryType t) => t.folder)
          .toSet();
      expect(
        pastas.length,
        EntryType.values.length,
        reason: 'Dois tipos na mesma pasta embaralhariam o acervo.',
      );
    });

    test('as palavras de contagem existem', () {
      expect(EntryType.audio.one, 'áudio');
      expect(EntryType.audio.many, 'áudios');
    });

    test('um arquivo de áudio é reconhecido como tal', () {
      const EntryFile f = EntryFile(
        driveId: 'a1',
        name: 'voz.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: 1024,
      );
      expect(f.isAudio, isTrue);
      expect(f.isImage, isFalse);
      expect(f.isVideo, isFalse);
    });
  });
}
