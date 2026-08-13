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

  group('a carta não sai do aplicativo', () {
    test('a tela de leitura não tem botão de compartilhar', () {
      // Foto e vídeo têm, e devem ter: são arquivos que a família manda para
      // a avó. Carta é outra coisa. Ela é escrita para uma pessoa só e para
      // ser lida daqui a muitos anos, e um botão que a joga num aplicativo
      // de mensagens hoje convida a fazer dela outra coisa.
      //
      // O teste olha o código, e não a tela, porque a falha aqui chegaria
      // como um `import` conveniente num dia de pressa.
      final String fonte = File(
        'lib/features/letters/letter_screen.dart',
      ).readAsStringSync();

      expect(fonte, isNot(contains('share_plus')));
      expect(fonte, isNot(contains('SharePlus')));
      expect(fonte, isNot(contains('S.share')));
    });
  });

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

  group('o aplicativo não alcança o resto do Google Drive', () {
    // Esta é a garantia mais importante do projeto e a mais fácil de perder
    // sem querer: basta alguém acrescentar um escopo para "resolver" um
    // problema de acesso, e o aplicativo passa a poder ler a conta inteira
    // de quem instalou. Aqui isso falha o CI.

    test('o único escopo pedido é o drive.file', () {
      expect(AuthService.driveScopes, <String>[
        'https://www.googleapis.com/auth/drive.file',
      ]);
    });

    test('nenhum escopo amplo do Drive aparece', () {
      const List<String> proibidos = <String>[
        'auth/drive', // acesso total
        'drive.readonly',
        'drive.metadata',
        'drive.appdata',
        'drive.photos.readonly',
      ];
      for (final String scope in AuthService.driveScopes) {
        for (final String proibido in proibidos) {
          final bool isExactDriveFile =
              scope == 'https://www.googleapis.com/auth/drive.file';
          if (proibido == 'auth/drive' && isExactDriveFile) continue;
          expect(
            scope.contains(proibido),
            isFalse,
            reason: '"$scope" daria acesso além do que o app cria.',
          );
        }
      }
    });

    test('tudo vive numa pasta única e identificável', () {
      expect(DriveService.rootFolderName, 'Meu Bebê - Cápsula do Tempo');
      // Dois-pontos quebram nome de arquivo no Windows, e quem sincroniza
      // o Drive no computador teria problema. O nome do app usa dois-pontos;
      // o da pasta, hífen.
      expect(DriveService.rootFolderName, isNot(contains(':')));
    });

    test('nenhum código consulta a raiz do Drive', () {
      // Sob o drive.file uma busca na raiz já devolveria só o que é nosso,
      // então isto não é sobre vazamento: é sobre o aplicativo nem sequer
      // perguntar o que existe na conta de quem instalou.
      final List<String> offenders = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))
          .where((File f) => f.readAsStringSync().contains("'root' in parents"))
          .map((File f) => f.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason:
            'A cápsula é reencontrada pelo id guardado no Firestore e, na '
            'falta dele, pelo nome. Nunca perguntando ao Drive o que existe '
            'na raiz da conta. Veja DriveService._ensureRootFolder.',
      );
    });

    test('a cápsula é procurada antes de ser criada', () {
      // Sem esta ordem, cada reinstalação criava outra pasta com o mesmo
      // nome. Aconteceu de verdade: oito pastas "Meu Bebê - Cápsula do
      // Tempo" no mesmo Drive, cada uma com um pedaço da infância dentro,
      // e nenhuma com o acervo inteiro.
      //
      // Procurar é seguro: sob o drive.file a consulta só devolve o que
      // este aplicativo criou, e a restrição é do servidor do Google.
      final String fonte = File(
        'lib/services/drive_service.dart',
      ).readAsStringSync();

      final int corpo = fonte.indexOf('Future<String> _ensureRootFolder');
      expect(corpo, greaterThan(-1));

      final int procura = fonte.indexOf('_procurarRaiz(api)', corpo);
      final int cria = fonte.indexOf(
        '_createFolder(api, rootFolderName',
        corpo,
      );

      expect(procura, greaterThan(-1), reason: 'A busca pelo nome sumiu');
      expect(
        procura,
        lessThan(cria),
        reason:
            'Criar antes de procurar é o que enche o Drive de pastas '
            'repetidas a cada reinstalação',
      );
    });
  });

  group('a foto da galeria nunca é apagada', () {
    // O seletor copia o arquivo escolhido para o cache do aplicativo e
    // devolve esse caminho. A cópia é apagada depois do envio; o original,
    // que está na galeria, jamais. Esta é a checagem que separa as duas
    // coisas - e errar aqui significa apagar a foto de alguém.
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
