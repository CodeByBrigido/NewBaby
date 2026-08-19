import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/utils/formatters.dart';

/// O aplicativo em duas línguas.
///
/// A completude da tradução é garantida pelo compilador: `TextosEn implements
/// Textos` não compila com um texto faltando. O que o compilador **não** pega
/// é uma tradução preguiçosa, que implementa o membro devolvendo a frase em
/// português. É disso que este arquivo cuida.
void main() {
  /// O nome da pasta no Drive, que atravessa as duas línguas sem mudar.
  const String pastaDoDrive = 'Meu Bebê - Cápsula do Tempo';

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await initializeDateFormatting('en');
  });

  tearDown(() => definirTextos(textosPt));

  group('nenhuma frase ficou em português no inglês', () {
    test('nenhum caractere que só existe em português', () {
      // Uma frase esquecida em português quase sempre traz um destes. Não
      // pega tudo (uma frase sem acento passaria), mas pega o caso comum a
      // custo zero, e pega justamente o que acontece quando alguém acrescenta
      // um texto novo com pressa.
      final String fonte = File(
        'lib/core/l10n/textos_en.dart',
      ).readAsStringSync();

      final List<String> suspeitas = <String>[];
      for (final String linha in fonte.split('\n')) {
        final String limpa = linha.trimLeft();
        // Os comentários deste arquivo são em português de propósito: quem
        // mantém o código lê português.
        if (limpa.startsWith('//')) continue;
        // A única exceção, e ela é obrigatória: o nome da pasta no Google
        // Drive não se traduz. Traduzi-lo faria o aplicativo procurar uma
        // pasta com outro nome e deixar para trás tudo o que a família já
        // guardou. O teste seguinte cobra que ele continue lá.
        if (linha.contains(pastaDoDrive)) continue;
        if (RegExp('[ãõçâêôáéíóúàÃÕÇÂÊÔÁÉÍÓÚÀ]').hasMatch(linha)) {
          suspeitas.add(linha.trim());
        }
      }

      expect(
        suspeitas,
        isEmpty,
        reason:
            'Frase em português dentro da implementação inglesa:\n'
            '${suspeitas.join("\n")}',
      );
    });

    test('a exceção é o nome da pasta do Drive, e é de propósito', () {
      // Traduzir o nome da pasta faria o aplicativo procurar uma pasta com
      // outro nome e deixar para trás tudo o que a família já guardou.
      definirTextos(textosEn);
      expect(S.deleteAccountDriveQuestion, contains(pastaDoDrive));
    });
  });

  group('a troca alcança tudo', () {
    test('os textos da interface', () {
      definirTextos(textosPt);
      expect(S.timeline, 'Linha do Tempo');
      expect(S.save, 'Salvar');

      definirTextos(textosEn);
      expect(S.timeline, 'Timeline');
      expect(S.save, 'Save');
    });

    test('as listas, e não só as frases soltas', () {
      definirTextos(textosEn);
      expect(S.milestoneSuggestions, contains('First smile'));
      expect(S.letterStarters.first, startsWith('Today I want'));
    });

    test('as datas mudam de ordem, e não só de idioma', () {
      final DateTime dia = DateTime(2027, 4, 10);

      definirTextos(textosPt);
      expect(Fmt.date(dia), '10/04/2027');
      expect(Fmt.longDate(dia), '10 de abril de 2027');

      definirTextos(textosEn);
      expect(Fmt.date(dia), '04/10/2027');
      expect(Fmt.longDate(dia), 'April 10, 2027');
    });

    test('o cabeçalho de hoje e ontem', () {
      final DateTime hoje = DateTime(2027, 4, 10);

      definirTextos(textosEn);
      expect(Fmt.timelineDay(hoje, now: hoje), 'Today');
      expect(
        Fmt.timelineDay(hoje.subtract(const Duration(days: 1)), now: hoje),
        'Yesterday',
      );
    });

    test('as contagens concordam em cada língua', () {
      definirTextos(textosPt);
      expect(S.contarDias(1), '1 dia');
      expect(S.contarDias(5), '5 dias');

      definirTextos(textosEn);
      expect(S.contarDias(1), '1 day');
      expect(S.contarDias(5), '5 days');
    });

    test('a saudação pela hora', () {
      definirTextos(textosEn);
      expect(Fmt.greeting(DateTime(2027, 4, 10, 9)), 'Good morning');
      expect(Fmt.greeting(DateTime(2027, 4, 10, 20)), 'Good evening');
    });

    test('há quanto tempo, com a marca no lado certo da frase', () {
      // O português põe a marca antes ("há 3 dias") e o inglês depois
      // ("3 days ago"). Por isso a frase inteira vem da língua, e não só o
      // número.
      definirTextos(textosPt);
      expect(Fmt.ago(3), 'há 3 dias');

      definirTextos(textosEn);
      expect(Fmt.ago(3), '3 days ago');
    });

    test('os ordinais, inclusive os que fogem da regra', () {
      definirTextos(textosEn);
      expect(Fmt.ordinal(1), 'first');
      expect(Fmt.ordinal(11), '11th');
      expect(Fmt.ordinal(21), '21st');
      expect(Fmt.ordinal(22), '22nd');
      expect(Fmt.ordinal(23), '23rd');
      expect(Fmt.ordinal(112), '112th');
    });
  });

  group('o que não pode mudar de língua', () {
    test('o carimbo do nome de arquivo no Drive', () {
      // Ele ordena a pasta. Duas convenções na mesma pasta acabam com a
      // ordem por nome.
      final DateTime d = DateTime(2027, 4, 10, 14, 35);

      definirTextos(textosPt);
      final String pt = Fmt.fileStamp(d);
      definirTextos(textosEn);
      expect(Fmt.fileStamp(d), pt);
      expect(pt, '2027-04-10_143500');
    });
  });

  group('o padrão', () {
    test('sem ninguém escolher, é português', () {
      expect(S.timeline, 'Linha do Tempo');
    });
  });
}
