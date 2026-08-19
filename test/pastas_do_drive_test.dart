import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/nomes_de_pasta.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/drive_service.dart';
import 'package:meu_bebe/services/memory_repository.dart';

/// A língua das pastas no Google Drive.
///
/// A regra, e ela é diferente da do resto do aplicativo: **a interface troca
/// de língua quando a pessoa quiser, as pastas não trocam nunca.** Elas já
/// existem, já têm arquivos dentro, e a pessoa já as viu. Renomeá-las porque
/// alguém mexeu num ajuste seria mexer no acervo de alguém sem pedir.
void main() {
  tearDown(() => definirTextos(textosPt));

  group('a convenção fica presa à cápsula, não à interface', () {
    test('a cápsula guarda a língua com que nasceu', () {
      final BabyProfile p = BabyProfile(
        name: 'Maria',
        birth: DateTime(2026, 11, 2),
        idiomaDasPastas: 'en',
      );
      expect(p.idiomaDasPastas, 'en');
    });

    test('trocar o idioma da interface não muda o caminho da pasta', () {
      final DateTime nascimento = DateTime(2026, 11, 2);
      final DateTime quando = DateTime(2027, 6, 10);

      // A cápsula nasceu em inglês.
      final NomesDePasta nomes = NomesDePasta.de('en');

      definirTextos(textosPt);
      final List<String> lendoEmPortugues = MemoryRepository.caminhoDaPasta(
        birth: nascimento,
        type: EntryType.photo,
        quando: quando,
        nomes: nomes,
      );

      definirTextos(textosEn);
      final List<String> lendoEmIngles = MemoryRepository.caminhoDaPasta(
        birth: nascimento,
        type: EntryType.photo,
        quando: quando,
        nomes: nomes,
      );

      expect(lendoEmPortugues, lendoEmIngles);
      expect(lendoEmPortugues, <String>['Photos', 'Year 0', 'Month 07']);
    });

    test('e a cápsula portuguesa continua portuguesa em tela inglesa', () {
      definirTextos(textosEn);
      expect(
        MemoryRepository.caminhoDaPasta(
          birth: DateTime(2026, 11, 2),
          type: EntryType.letter,
          quando: DateTime(2027, 6, 10),
          nomes: NomesDePasta.pt,
        ),
        <String>['Cartas', 'Ano 0', 'Mês 07'],
      );
    });
  });

  group('os dois cenários, letra por letra', () {
    // Cada um percorre a vida inteira da cápsula: criar, guardar coisa nova
    // meses depois, e trocar o idioma no meio.
    void cenario({
      required String criouEm,
      required Textos lendoDepoisEm,
      required List<String> esperado,
    }) {
      final BabyProfile perfil = BabyProfile(
        name: 'Bebê',
        birth: DateTime(2026, 11, 2),
        idiomaDasPastas: criouEm,
      );

      // Meses depois, com a interface noutra língua.
      definirTextos(lendoDepoisEm);

      expect(
        MemoryRepository.caminhoDaPasta(
          birth: perfil.birth,
          type: EntryType.photo,
          quando: DateTime(2027, 6, 10),
          nomes: MemoryRepository.nomesDe(perfil),
        ),
        esperado,
      );
    }

    test('Alberto criou em português e trocou para inglês', () {
      // A pasta continua sendo lida em português, porque foi assim que
      // nasceu. A interface dele está em inglês, e isso não muda nada aqui.
      cenario(
        criouEm: 'pt',
        lendoDepoisEm: textosEn,
        esperado: <String>['Fotos', 'Ano 0', 'Mês 07'],
      );
    });

    test('Glen criou em inglês e trocou para português', () {
      // O espelho do anterior, e o que estava quebrado: a pasta de topo
      // nascia em inglês no cadastro, mas a primeira foto ia para uma
      // `Fotos` nova, criada em português ao lado da `Photos`.
      cenario(
        criouEm: 'en',
        lendoDepoisEm: textosPt,
        esperado: <String>['Photos', 'Year 0', 'Month 07'],
      );
    });

    test('e trocar de idioma quantas vezes for não move a pasta', () {
      final BabyProfile perfil = BabyProfile(
        name: 'Bebê',
        birth: DateTime(2026, 11, 2),
        idiomaDasPastas: 'en',
      );

      // Guardados como texto: um `Set` de listas compara por identidade, e
      // quatro listas iguais mas distintas passariam por quatro respostas
      // diferentes.
      final List<String> caminhos = <String>[];
      for (final Textos lingua in <Textos>[
        textosPt,
        textosEn,
        textosPt,
        textosEn,
      ]) {
        definirTextos(lingua);
        caminhos.add(
          MemoryRepository.caminhoDaPasta(
            birth: perfil.birth,
            type: EntryType.letter,
            quando: DateTime(2028, 3, 5),
            nomes: MemoryRepository.nomesDe(perfil),
          ).join('/'),
        );
      }

      expect(caminhos.toSet(), hasLength(1));
      expect(caminhos.first, 'Letters/Year 1/Month 04');
    });

    test('a convenção sai do perfil, e o perfil não muda sozinho', () {
      // É o que garante que "todas as chamadas são baseadas na criação":
      // nomesDe lê o perfil, e nada na troca de idioma escreve nele.
      final BabyProfile perfil = BabyProfile(
        name: 'Bebê',
        birth: DateTime(2026, 11, 2),
        idiomaDasPastas: 'en',
      );

      definirTextos(textosPt);
      expect(MemoryRepository.nomesDe(perfil).codigo, 'en');
      definirTextos(textosEn);
      expect(MemoryRepository.nomesDe(perfil).codigo, 'en');
    });

    test('cápsula antiga, sem o campo, é lida como portuguesa', () {
      final BabyProfile perfil = BabyProfile(
        name: 'Bebê',
        birth: DateTime(2026, 11, 2),
      );
      definirTextos(textosEn);
      expect(MemoryRepository.nomesDe(perfil).codigo, 'pt');
      expect(
        MemoryRepository.caminhoDaPasta(
          birth: perfil.birth,
          type: EntryType.photo,
          quando: DateTime(2027, 6, 10),
          nomes: MemoryRepository.nomesDe(perfil),
        ),
        <String>['Fotos', 'Ano 0', 'Mês 07'],
      );
    });
  });

  group('as duas convenções', () {
    test('cada tipo tem pasta nas duas línguas', () {
      for (final EntryType t in EntryType.values) {
        for (final NomesDePasta n in NomesDePasta.todas) {
          expect(
            MemoryRepository.pastaDoTipo(t, n),
            isNotEmpty,
            reason: '${t.id} em ${n.codigo}',
          );
        }
      }
    });

    test('nenhum nome se repete entre tipos diferentes', () {
      // Dois tipos na mesma pasta misturariam as fotos com os desenhos.
      for (final NomesDePasta n in NomesDePasta.todas) {
        final List<String> pastas = <String>[
          for (final EntryType t in EntryType.values)
            if (t != EntryType.birth) MemoryRepository.pastaDoTipo(t, n),
        ];
        expect(pastas.toSet(), hasLength(pastas.length), reason: n.codigo);
      }
    });

    test('o mês vem com dois dígitos, para a pasta ordenar por nome', () {
      for (final NomesDePasta n in NomesDePasta.todas) {
        expect(n.mesNumero(7), endsWith('07'), reason: n.codigo);
        expect(n.mesNumero(11), endsWith('11'), reason: n.codigo);
      }
    });

    test('a lista de topo acompanha a convenção', () {
      expect(DriveService.pastasDeTopo(NomesDePasta.en), contains('Photos'));
      expect(DriveService.pastasDeTopo(NomesDePasta.pt), contains('Fotos'));
    });
  });

  group('a escolha feita no cadastro', () {
    test('em inglês, a cápsula nasce com pastas em inglês', () {
      // É o caminho que o cadastro segue: a língua ativa no momento de criar
      // vira o `idiomaDasPastas` do perfil, e é ele que nomeia as pastas.
      definirTextos(textosEn);
      final NomesDePasta nomes = NomesDePasta.de(emIngles ? 'en' : 'pt');
      expect(nomes.raiz, 'My Baby - Time Capsule');
      expect(DriveService.pastasDeTopo(nomes), contains('Letters'));
    });

    test('em português, nasce com pastas em português', () {
      definirTextos(textosPt);
      final NomesDePasta nomes = NomesDePasta.de(emIngles ? 'en' : 'pt');
      expect(nomes.raiz, 'Meu Bebê - Cápsula do Tempo');
      expect(DriveService.pastasDeTopo(nomes), contains('Cartas'));
    });

    test('o perfil guarda a escolha, e ela sobrevive ao copyWith', () {
      // Guardar é o que impede a língua das pastas de mudar depois. Perder
      // isso num copyWith faria uma edição de cadastro trocar a convenção.
      final BabyProfile p = BabyProfile(
        name: 'Maria',
        birth: DateTime(2026, 11, 2),
        idiomaDasPastas: 'en',
      ).copyWith(name: 'Maria Souza');
      expect(p.idiomaDasPastas, 'en');
    });

    test('e sobrevive à ida e volta do Firestore', () {
      final BabyProfile p = BabyProfile.fromMap(
        BabyProfile(
          name: 'Maria',
          birth: DateTime(2026, 11, 2),
          idiomaDasPastas: 'en',
        ).toMap(),
      );
      expect(p.idiomaDasPastas, 'en');
    });
  });

  group('nenhum caminho é construído sem a convenção', () {
    test('toda chamada de caminhoDaPasta passa nomes', () {
      // Este é o teste que teria pegado o defeito de verdade. O parâmetro
      // `nomes` tem valor padrão, e o padrão é o português: qualquer chamada
      // que o esqueça compila, roda, e cria pastas portuguesas dentro de uma
      // cápsula inglesa, ao lado das certas.
      //
      // A varredura é do texto, e não de tipo, porque o compilador não tem
      // como cobrar um parâmetro que tem padrão.
      for (final String caminho in <String>[
        'lib/services/memory_repository.dart',
        'lib/features/shell/add_sheet.dart',
      ]) {
        final String fonte = File(caminho).readAsStringSync();
        int de = 0;
        while (true) {
          final int i = fonte.indexOf('caminhoDaPasta(', de);
          if (i < 0) break;
          de = i + 1;
          // A declaração não é chamada.
          if (fonte.startsWith('static List<String> caminhoDaPasta(', i - 20)) {
            continue;
          }
          final int fecha = fonte.indexOf(');', i);
          final String chamada = fonte.substring(i, fecha);
          expect(
            chamada,
            contains('nomes:'),
            reason:
                'Chamada sem `nomes:` em $caminho, perto do caractere $i. '
                'Sem ele o caminho sai em português dentro de uma cápsula '
                'que pode ter nascido em outra língua.',
          );
        }
      }
    });
  });

  group('as cápsulas que já existem', () {
    test('sem o campo, a convenção é a portuguesa', () {
      // Todas as cápsulas criadas antes de haver mais de uma língua são
      // portuguesas: era a única que existia. Devolver outra coisa aqui faria
      // o aplicativo procurar uma pasta que não existe.
      expect(NomesDePasta.de(null).codigo, 'pt');
      expect(NomesDePasta.de('').codigo, 'pt');
    });

    test('código desconhecido também cai no português', () {
      // Perfil gravado por uma versão futura, lido por uma antiga.
      expect(NomesDePasta.de('de').codigo, 'pt');
    });

    test('o nome que os documentos públicos citam continua o mesmo', () {
      // A página de exclusão ensina a achar a pasta pelo nome, e ela cita o
      // português. Mudar esta constante quebraria essa instrução.
      expect(DriveService.rootFolderName, NomesDePasta.pt.raiz);
    });
  });

  group('o caminho por idade', () {
    test('segue a convenção da cápsula, e não a da interface', () {
      final DateTime nascimento = DateTime(2026, 11, 2);
      final DateTime quando = DateTime(2029, 1, 2);

      expect(
        AgeCalculator.caminhoNoDrive(nascimento, quando, NomesDePasta.en),
        <String>['Year 2', 'Month 02'],
      );
      expect(
        AgeCalculator.caminhoNoDrive(nascimento, quando, NomesDePasta.pt),
        <String>['Ano 2', 'Mês 02'],
      );
    });
  });
}
