import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/l10n/informacoes.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';

/// O arquivo legível que fica na pasta do Drive.
///
/// As fotos já sobreviviam sem o aplicativo: são arquivos numa pasta. O
/// cadastro e o crescimento não, porque só existiam no índice. Este arquivo
/// fecha esse buraco, e por isso ele precisa estar certo mesmo nos casos em
/// que o cadastro está pela metade.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final BabyProfile maria = BabyProfile(
    name: 'Maria',
    birth: DateTime(2026, 4, 15, 8, 42),
    gender: BabyGender.girl,
    birthWeightGrams: 3250,
    birthHeightCm: 49,
    hospital: 'Hospital Santa Joana',
  );

  Entry medicao(DateTime quando, int gramas, double cm) => Entry(
    id: 'g-${quando.millisecondsSinceEpoch}',
    type: EntryType.growth,
    date: quando,
    createdAt: quando,
    ageDays: quando.difference(DateTime(2026, 4, 15)).inDays,
    bucketKey: 'M01',
    bucketName: 'Mês 01',
    growth: GrowthData(weightGrams: gramas, heightCm: cm),
  );

  String gerar({BabyProfile? profile, List<Entry> growth = const <Entry>[]}) =>
      informacoesDaCrianca(
        profile: profile ?? maria,
        growth: growth,
        now: DateTime(2026, 6, 20, 10, 5),
      );

  group('o cadastro', () {
    test('sai por extenso, na ordem que uma pessoa leria', () {
      final String texto = gerar();
      expect(texto, contains('Nome: Maria'));
      expect(texto, contains('Sexo: Menina'));
      expect(texto, contains('Nascimento: 15/04/2026'));
      expect(texto, contains('Hora: 08:42'));
      expect(texto, contains('Peso ao nascer: 3,250 kg'));
      expect(texto, contains('Altura ao nascer: 49 cm'));
      expect(texto, contains('Hospital: Hospital Santa Joana'));
    });

    test('a hora some quando ela não foi informada', () {
      // O cadastro guarda meia-noite quando ninguém escolhe hora. Escrever
      // "00:00" seria inventar que a criança nasceu à meia-noite, e quem ler
      // isso daqui a vinte anos não tem como saber que é preenchimento.
      final String texto = gerar(
        profile: BabyProfile(name: 'Alex', birth: DateTime(2026, 4, 15)),
      );
      expect(texto, isNot(contains('Hora:')));
      expect(texto, contains('Nascimento: 15/04/2026'));
    });

    test('campo em branco não vira linha vazia', () {
      // Um cadastro sem sexo, sem peso, sem altura e sem hospital continua
      // gerando um arquivo legível, e não um formulário com buracos.
      final String texto = gerar(
        profile: BabyProfile(name: 'Alex', birth: DateTime(2026, 4, 15)),
      );
      for (final String rotulo in <String>[
        'Sexo:',
        'Peso ao nascer:',
        'Altura ao nascer:',
        'Hospital:',
      ]) {
        expect(texto, isNot(contains(rotulo)), reason: rotulo);
      }
      expect(texto, contains('Nome: Alex'));
    });

    test('hospital só com espaços conta como não preenchido', () {
      final String texto = gerar(
        profile: BabyProfile(
          name: 'Alex',
          birth: DateTime(2026, 4, 15),
          hospital: '   ',
        ),
      );
      expect(texto, isNot(contains('Hospital:')));
    });
  });

  group('o crescimento', () {
    test('cada medição traz data, idade, peso e altura', () {
      final String texto = gerar(
        growth: <Entry>[medicao(DateTime(2026, 5, 15), 4100, 54)],
      );
      expect(texto, contains('Data: 15/05/2026'));
      expect(texto, contains('Idade: 1 mês'));
      expect(texto, contains('Peso: 4,100 kg'));
      expect(texto, contains('Altura: 54 cm'));
    });

    test('as medições saem em ordem de data, não de digitação', () {
      // Quem registra pode lançar uma medição antiga depois de uma recente.
      // No arquivo isso precisa aparecer em ordem, senão o crescimento parece
      // ter ido e voltado.
      final String texto = gerar(
        growth: <Entry>[
          medicao(DateTime(2026, 6, 15), 4900, 57),
          medicao(DateTime(2026, 5, 15), 4100, 54),
        ],
      );
      expect(
        texto.indexOf('15/05/2026'),
        lessThan(texto.indexOf('15/06/2026')),
      );
    });

    test('sem medição nenhuma, a seção diz isso em vez de ficar vazia', () {
      final String texto = gerar();
      expect(texto, contains('REGISTROS DE CRESCIMENTO'));
      expect(texto, contains('Nenhuma medição registrada até aqui.'));
    });

    test('entrada de crescimento sem dado é ignorada', () {
      // Defensivo: uma entrada do tipo crescimento sem `growth` seria um
      // registro corrompido, e o arquivo não pode quebrar por causa dela.
      final Entry vazia = Entry(
        id: 'x',
        type: EntryType.growth,
        date: DateTime(2026, 5, 15),
        createdAt: DateTime(2026, 5, 15),
        ageDays: 30,
        bucketKey: 'M01',
        bucketName: 'Mês 01',
      );
      expect(
        gerar(growth: <Entry>[vazia]),
        contains('Nenhuma medição registrada até aqui.'),
      );
    });
  });

  group('o rodapé', () {
    test('diz quando o arquivo foi escrito', () {
      expect(gerar(), contains('Última atualização: 20/06/2026 10:05'));
    });

    test('explica de onde o arquivo veio', () {
      // Quem encontrar este arquivo daqui a vinte anos pode não fazer ideia
      // do que ele é. Uma frase resolve.
      expect(gerar(), contains('Meu Bebê: Cápsula do Tempo'));
    });

    test('não usa travessão', () {
      expect(gerar(), isNot(contains('—')));
    });
  });

  group('o nome da pasta no Drive', () {
    AgeBucket balde(DateTime nascimento, DateTime quando) =>
        AgeCalculator.bucketAt(nascimento, quando);

    final DateTime nascimento = DateTime(2026, 4, 15);

    test('o primeiro ano inteiro é uma pasta só', () {
      // 52 pastas de semana fazem sentido para quem registra e nenhum para
      // quem folheia o acervo daqui a vinte anos.
      expect(
        balde(nascimento, DateTime(2026, 4, 16)).driveFolderName,
        'Primeiro Ano',
      );
      expect(
        balde(nascimento, DateTime(2027, 4, 14)).driveFolderName,
        'Primeiro Ano',
      );
    });

    test('do primeiro ao segundo aniversário é "1 Ano"', () {
      expect(balde(nascimento, DateTime(2027, 4, 15)).driveFolderName, '1 Ano');
      expect(balde(nascimento, DateTime(2028, 4, 14)).driveFolderName, '1 Ano');
    });

    test('daí em diante o plural entra', () {
      expect(
        balde(nascimento, DateTime(2028, 4, 15)).driveFolderName,
        '2 Anos',
      );
      expect(balde(nascimento, DateTime(2031, 6, 1)).driveFolderName, '5 Anos');
    });

    test('o nome do Drive e o da interface são independentes', () {
      // Se alguém colapsar os dois num só, a galeria perde a semana ou o
      // Drive ganha 52 pastas por ano. Este teste é a única coisa que
      // registra que a separação foi de propósito.
      final AgeBucket b = balde(nascimento, DateTime(2026, 6, 1));
      expect(b.folderName, 'Semana 07');
      expect(b.driveFolderName, 'Primeiro Ano');
    });
  });
}
