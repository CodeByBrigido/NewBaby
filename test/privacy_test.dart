import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/error_text.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/auth_service.dart';
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

  group('a foto da galeria nunca é apagada', () {
    // O seletor copia o arquivo escolhido para o cache do aplicativo e
    // devolve esse caminho. A cópia é apagada depois do envio; o original,
    // que está na galeria, jamais. Esta é a checagem que separa as duas
    // coisas — e errar aqui significa apagar a foto de alguém.
    const String cache = '/data/user/0/br.com.brigido.meu_bebe/cache';

    test('a cópia do seletor é reconhecida', () {
      expect(
        MemoryRepository.isInsideAppCache(cache, '$cache/a1b2/IMG_0001.jpg'),
        isTrue,
      );
    });

    test('o arquivo da galeria não é', () {
      for (final String path in <String>[
        '/storage/emulated/0/DCIM/Camera/IMG_20260801.jpg',
        '/storage/emulated/0/Pictures/foto.jpg',
        '/data/user/0/outro.app/cache/x.jpg',
        // Prefixo parecido, diretório diferente.
        '/data/user/0/br.com.brigido.meu_bebe/cache-outro/x.jpg',
      ]) {
        expect(
          MemoryRepository.isInsideAppCache(cache, path),
          isFalse,
          reason: '$path não pode ser apagado.',
        );
      }
    });

    test('não dá para sair do cache com ".."', () {
      expect(
        MemoryRepository.isInsideAppCache(
          cache,
          '$cache/../../../../storage/emulated/0/DCIM/Camera/IMG.jpg',
        ),
        isFalse,
      );
    });

    test('o próprio cache não conta como estando dentro de si', () {
      expect(MemoryRepository.isInsideAppCache(cache, cache), isFalse);
    });
  });

  group('mensagens de erro não carregam detalhe interno', () {
    test('caminho de arquivo não chega à tela', () {
      final String message = userMessage(
        const FileSystemException(
          'Cannot open file',
          '/storage/emulated/0/Android/data/br.com.brigido.meu_bebe/files/x.jpg',
        ),
      );
      expect(message, isNot(contains('/storage')));
      expect(message, isNot(contains('br.com.brigido')));
      expect(message, 'Não foi possível ler o arquivo no aparelho.');
    });

    test('detalhe de rede vira uma frase que ajuda', () {
      final String message = userMessage(
        const SocketException('Failed host lookup: firestore.googleapis.com'),
      );
      expect(message, isNot(contains('googleapis')));
      expect(message, contains('conexão'));
    });

    test('exceção desconhecida não expõe o toString', () {
      final String message = userMessage(
        StateError('token=ya29.SEGREDO id=1a2b3c'),
      );
      expect(message, isNot(contains('ya29')));
      expect(message, isNot(contains('1a2b3c')));
    });

    test('mensagem já escrita para o usuário é preservada', () {
      // Estas nascem prontas; traduzi-las de novo pioraria a experiência.
      expect(
        userMessage(const AuthFailure('Login cancelado.')),
        'Login cancelado.',
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
