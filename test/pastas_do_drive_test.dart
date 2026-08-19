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
