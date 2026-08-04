import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/inspiration.dart';
import 'package:meu_bebe/services/inspiration_source.dart';

/// O feed de inspirações.
///
/// A regra mais importante aqui não é técnica, é de produto: **nada pode
/// dizer o que uma criança deveria estar fazendo.** Uma tabela de
/// desenvolvimento numa tela de memórias transforma um álbum em avaliação, e
/// quem lê "aos seis meses já senta" com um filho que ainda não senta ganha
/// uma angústia que não pediu. A varredura abaixo reprova o CI se algum
/// texto novo escorregar para esse tom.
void main() {
  final List<Inspiration> catalogo =
      (jsonDecode(File('assets/inspiracoes.json').readAsStringSync())
              as List<Object?>)
          .whereType<Map<String, Object?>>()
          .map(Inspiration.fromMap)
          .toList();

  group('o conteúdo é bem formado', () {
    test('carrega inteiro', () {
      expect(catalogo, isNotEmpty);
      for (final Inspiration i in catalogo) {
        expect(i.id.trim(), isNotEmpty);
        expect(i.title.trim(), isNotEmpty);
        expect(i.body.trim(), isNotEmpty);
      }
    });

    test('nenhum id repetido', () {
      final List<String> ids = catalogo.map((Inspiration i) => i.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('as faixas de idade fazem sentido', () {
      for (final Inspiration i in catalogo) {
        expect(i.fromDays, lessThan(i.toDays), reason: i.id);
        expect(i.fromDays, greaterThanOrEqualTo(0), reason: i.id);
      }
    });

    test('cada texto cabe num cartão', () {
      // Texto longo demais vira artigo, e artigo vira rolagem sem fim.
      for (final Inspiration i in catalogo) {
        expect(i.title.length, lessThanOrEqualTo(60), reason: i.id);
        expect(i.body.length, lessThanOrEqualTo(320), reason: i.id);
      }
    });
  });

  group('nada aqui diz o que a criança deveria fazer', () {
    test('nenhum texto usa linguagem de cobrança ou de tabela', () {
      const List<String> proibidos = <String>[
        'deveria',
        'já deve',
        'tem que estar',
        'atrasad',
        'normal para a idade',
        'esperado para',
        'se não estiver',
        'consulte um médico',
        'diagnóstic',
      ];
      for (final Inspiration i in catalogo) {
        final String texto = '${i.title} ${i.body}'.toLowerCase();
        for (final String p in proibidos) {
          expect(
            texto,
            isNot(contains(p)),
            reason:
                '"${i.id}" fala como tabela de desenvolvimento. Este é um '
                'aplicativo de memórias, não de avaliação.',
          );
        }
      }
    });
  });

  group('a idade escolhe o que aparece', () {
    test('recém-nascido não recebe sugestão de bicicleta nem de escola', () {
      final List<String> ids = pickForAge(
        catalogo,
        10,
      ).map((Inspiration i) => i.id).toList();
      expect(ids, isNot(contains('escola-primeiro-dia')));
      expect(ids, isNot(contains('tres-anos-cozinha')));
    });

    test('quem faz um ano recebe o preparo da festa', () {
      expect(
        pickForAge(catalogo, 340).map((Inspiration i) => i.id),
        contains('primeiro-ano-preparo'),
      );
    });

    test('e deixa de receber depois que a festa passa', () {
      expect(
        pickForAge(catalogo, 500).map((Inspiration i) => i.id),
        isNot(contains('primeiro-ano-preparo')),
      );
    });

    test('sempre sobra alguma coisa, em qualquer idade', () {
      // Feed vazio faria a aba parecer quebrada.
      for (final int dias in <int>[
        0,
        30,
        100,
        200,
        365,
        500,
        800,
        1500,
        2000,
      ]) {
        expect(
          pickForAge(catalogo, dias),
          isNotEmpty,
          reason: 'Nada para mostrar aos $dias dias.',
        );
      }
    });
  });

  group('a ordem', () {
    test('o que foi escrito para esta fase vem antes', () {
      // Aos 340 dias, o preparo do primeiro aniversário (300-400) é mais
      // certeiro que "filme os avós" (0-6000), que vale a vida inteira.
      final List<Inspiration> lista = pickForAge(catalogo, 340);
      final int preparo = lista.indexWhere(
        (Inspiration i) => i.id == 'primeiro-ano-preparo',
      );
      final int avos = lista.indexWhere(
        (Inspiration i) => i.id == 'qualquer-idade-avos',
      );
      expect(preparo, lessThan(avos));
    });

    test('não dança entre uma abertura e outra', () {
      // Ordem instável faria a pessoa achar que perdeu algo que já leu.
      final List<String> a = pickForAge(
        catalogo,
        200,
      ).map((Inspiration i) => i.id).toList();
      final List<String> b = pickForAge(
        catalogo,
        200,
      ).map((Inspiration i) => i.id).toList();
      expect(a, b);
    });
  });

  group('a fonte é trocável', () {
    test('a interface não conhece asset nenhum', () {
      // Se um dia o conteúdo vier de um servidor, isto continua valendo.
      const InspirationSource fonte = AssetInspirationSource();
      expect(fonte, isA<InspirationSource>());
    });
  });
}
