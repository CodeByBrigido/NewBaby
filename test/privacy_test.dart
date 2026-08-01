import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/drive_service.dart';
import 'package:meu_bebe/services/memory_repository.dart';

/// Testes das decisões de privacidade que não dão para ver na tela.
///
/// Cada um aqui existe porque a falha correspondente seria silenciosa: o
/// aplicativo continuaria funcionando perfeitamente enquanto vazasse algo.
void main() {
  Entry letterOf({String? title, String? description}) => Entry(
    id: 'e1',
    type: EntryType.letter,
    date: DateTime(2027, 4, 10),
    createdAt: DateTime(2027, 4, 10),
    ageDays: 78,
    bucketKey: 'S12',
    bucketName: 'Semana 12',
    title: title,
    description: description,
  );

  group('o texto das cartas não é duplicado no Firestore', () {
    test('o documento gravado não tem campo de busca', () {
      final Map<String, Object?> map = letterOf(
        title: 'Para quando você crescer',
        description: 'Hoje você riu pela primeira vez.',
      ).toMap();

      expect(map.containsKey('busca'), isFalse);
      // O texto continua indo uma vez só, no campo que a tela lê.
      expect(map['descricao'], 'Hoje você riu pela primeira vez.');
    });

    test('a busca continua funcionando, calculada em memória', () {
      final Entry entry = letterOf(
        title: 'Primeiro Sorriso',
        description: 'Na Casa da Vovó',
      );
      expect(entry.searchable, contains('primeiro sorriso'));
      expect(entry.searchable, contains('vovó'));
    });

    test('ler de volta um documento antigo, com o campo, não quebra', () {
      // Instalações anteriores gravaram `busca`; o campo agora é ignorado.
      final Entry entry = Entry.fromMap('e1', <String, Object?>{
        'tipo': 'carta',
        'titulo': 'Carta',
        'descricao': 'Texto',
        'busca': 'carta texto',
      });
      expect(entry.title, 'Carta');
      expect(entry.description, 'Texto');
    });
  });

  group('o caminho do arquivo no aparelho não é gravado', () {
    test('sem caminho local, o campo vai nulo', () {
      final Map<String, Object?> map = const EntryFile(
        driveId: 'abc',
        name: '2027-04-10_143500.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
      ).toMap();

      expect(map['caminhoLocal'], isNull);
    });
  });

  group('nome de arquivo vindo do Drive', () {
    test('barras e ".." não escapam da pasta de downloads', () {
      expect(
        MemoryRepository.safeFileName('../../databases/firestore.db'),
        'firestore.db',
      );
      expect(MemoryRepository.safeFileName('/etc/passwd'), 'passwd');
      expect(
        MemoryRepository.safeFileName(r'..\..\windows\system32'),
        'system32',
      );
    });

    test('um nome que vira vazio ganha substituto', () {
      expect(MemoryRepository.safeFileName('..'), 'arquivo');
      expect(MemoryRepository.safeFileName('   '), 'arquivo');
      expect(MemoryRepository.safeFileName('/'), 'arquivo');
    });

    test('um nome comum passa intacto', () {
      expect(
        MemoryRepository.safeFileName('Certidão de nascimento.pdf'),
        'Certidão de nascimento.pdf',
      );
    });
  });

  group('o token do Drive só sai para o Google', () {
    test('aceita os domínios de mídia do Google', () {
      for (final String url in <String>[
        'https://lh3.googleusercontent.com/abc=s600',
        'https://www.googleapis.com/drive/v3/files/1',
        'https://drive.google.com/thumbnail',
      ]) {
        expect(
          DriveService.isTrustedMediaHost(Uri.parse(url)),
          isTrue,
          reason: '$url deveria ser aceito.',
        );
      }
    });

    test('recusa qualquer outro destino', () {
      for (final String url in <String>[
        'https://exemplo.com/roubo',
        // O truque clássico: o domínio do Google como prefixo do nome.
        'https://google.com.invasor.net/x',
        // Sufixo colado, sem o ponto separando.
        'https://naogoogle.com/x',
        // Sem TLS o token viajaria em texto claro.
        'http://lh3.googleusercontent.com/abc',
      ]) {
        expect(
          DriveService.isTrustedMediaHost(Uri.parse(url)),
          isFalse,
          reason: '$url deveria ser recusado.',
        );
      }
    });
  });
}
