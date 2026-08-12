import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/baby_profile.dart';
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
  final List<Inspiration> catalogo = parseInspirations(
    File('assets/inspiracoes.json').readAsStringSync(),
  );

  BabyProfile nascidaEm(DateTime birth) =>
      BabyProfile(name: 'Maria Eduarda', birth: birth);

  List<String> idsEm(DateTime birth, DateTime hoje) => pickFor(
    all: catalogo,
    profile: nascidaEm(birth),
    now: hoje,
  ).map((ActiveInspiration a) => a.inspiration.id).toList();

  group('o conteúdo é bem formado', () {
    test('carrega inteiro', () {
      expect(catalogo.length, greaterThanOrEqualTo(30));
      for (final Inspiration i in catalogo) {
        expect(i.id.trim(), isNotEmpty);
        expect(i.title.trim(), isNotEmpty);
        expect(i.summary.trim(), isNotEmpty, reason: i.id);
      }
    });

    test('nenhum id repetido', () {
      final List<String> ids = catalogo.map((Inspiration i) => i.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('o resumo cabe num cartão', () {
      // Resumo longo vira artigo no meio da lista, e a lista deixa de ser
      // navegável. O texto longo tem lugar próprio: as seções.
      for (final Inspiration i in catalogo) {
        expect(i.title.length, lessThanOrEqualTo(60), reason: i.id);
        expect(i.summary.length, lessThanOrEqualTo(230), reason: i.id);
      }
    });

    test('toda seção tem título e alguma coisa dentro', () {
      for (final Inspiration i in catalogo) {
        for (final InspirationSection s in i.sections) {
          expect(s.title.trim(), isNotEmpty, reason: i.id);
          expect(
            s.body.trim().isNotEmpty || s.bullets.isNotEmpty,
            isTrue,
            reason: '${i.id} / ${s.title} está vazia.',
          );
        }
      }
    });

    test('os destaques são poucos', () {
      // Se tudo é destaque, nada é.
      final int destaques = catalogo
          .where((Inspiration i) => i.highlight)
          .length;
      expect(destaques, lessThan(catalogo.length ~/ 3));
    });

    test('todo destaque tem texto longo para justificar o convite', () {
      for (final Inspiration i in catalogo.where(
        (Inspiration i) => i.highlight,
      )) {
        expect(
          i.hasArticle,
          isTrue,
          reason: '"${i.id}" é destaque mas abre um cartão sem conteúdo.',
        );
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
        'diagnóstic',
      ];
      for (final Inspiration i in catalogo) {
        final String texto = <String>[
          i.title,
          i.summary,
          for (final InspirationSection s in i.sections) ...<String>[
            s.title,
            s.body,
            ...s.bullets,
          ],
        ].join(' ').toLowerCase();

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

    test('o conteúdo que encosta em saúde manda procurar quem sabe', () {
      final Inspiration alimentar = catalogo.firstWhere(
        (Inspiration i) => i.id == 'introducao-alimentar-preparo',
      );
      final String texto = alimentar.sections
          .map((InspirationSection s) => '${s.title} ${s.body}')
          .join(' ')
          .toLowerCase();
      expect(
        texto,
        contains('pediatra'),
        reason:
            'Qualquer coisa perto de alimentação precisa apontar para a '
            'pediatra, não para o aplicativo.',
      );
    });
  });

  group('a contagem regressiva do aniversário', () {
    final DateTime birth = DateTime(2026, 3, 10);

    test('as ideias da festa chegam três semanas antes', () {
      expect(
        idsEm(birth, DateTime(2027, 2, 20)),
        contains('primeiro-aniversario-ideias'),
      );
    });

    test('não chegam cedo demais', () {
      expect(
        idsEm(birth, DateTime(2027, 1, 10)),
        isNot(contains('primeiro-aniversario-ideias')),
      );
    });

    test('somem no dia seguinte à festa', () {
      // Ideia de festa depois da festa é piada.
      expect(
        idsEm(birth, DateTime(2027, 3, 11)),
        isNot(contains('primeiro-aniversario-ideias')),
      );
    });

    test('a retrospectiva vem antes, porque dá trabalho', () {
      expect(
        idsEm(birth, DateTime(2027, 1, 25)),
        contains('retrospectiva-primeiro-ano'),
      );
    });

    test('o segundo aniversário tem conteúdo próprio', () {
      expect(
        idsEm(birth, DateTime(2028, 2, 25)),
        contains('segundo-aniversario'),
      );
      expect(
        idsEm(birth, DateTime(2028, 2, 25)),
        isNot(contains('primeiro-aniversario-ideias')),
      );
    });

    test('nascida em 29 de fevereiro também recebe a contagem', () {
      final DateTime bissexto = DateTime(2028, 2, 29);
      expect(
        idsEm(bissexto, DateTime(2029, 2, 20)),
        contains('primeiro-aniversario-ideias'),
      );
    });
  });

  group('as datas do calendário', () {
    test('o Natal chega perto do Natal, e só na primeira vez', () {
      final DateTime birth = DateTime(2026, 6, 1);
      expect(
        idsEm(birth, DateTime(2026, 12, 10)),
        contains('primeiro-natal-ideias'),
      );
      expect(
        idsEm(birth, DateTime(2027, 12, 10)),
        isNot(contains('primeiro-natal-ideias')),
      );
    });

    test('o Carnaval segue a data móvel', () {
      // Carnaval de 2027: 9 de fevereiro.
      final DateTime birth = DateTime(2026, 6, 1);
      expect(
        idsEm(birth, DateTime(2027, 2, 1)),
        contains('primeiro-carnaval-ideias'),
      );
      expect(
        idsEm(birth, DateTime(2027, 1, 5)),
        isNot(contains('primeiro-carnaval-ideias')),
      );
    });
  });

  group('a idade escolhe o resto', () {
    final DateTime birth = DateTime(2026, 3, 10);

    test('recém-nascido não recebe cozinha nem escola', () {
      final List<String> ids = idsEm(
        birth,
        birth.add(const Duration(days: 10)),
      );
      expect(ids, isNot(contains('tres-anos-cozinha')));
      expect(ids, isNot(contains('escola-primeiro-dia')));
    });

    test('sempre sobra alguma coisa, em qualquer idade', () {
      // Feed vazio faria a aba parecer quebrada.
      for (final int dias in <int>[
        0,
        15,
        45,
        100,
        200,
        300,
        400,
        600,
        900,
        1200,
        1800,
        2400,
      ]) {
        expect(
          idsEm(birth, birth.add(Duration(days: dias))),
          isNotEmpty,
          reason: 'Nada para mostrar aos $dias dias.',
        );
      }
    });
  });

  group('a ordem', () {
    test('o que tem data marcada vem antes do que vale a fase toda', () {
      final List<ActiveInspiration> lista = pickFor(
        all: catalogo,
        profile: nascidaEm(DateTime(2026, 3, 10)),
        now: DateTime(2027, 2, 20),
      );
      expect(lista.first.hasDeadline, isTrue);
      expect(lista.first.inspiration.id, 'primeiro-aniversario-ideias');
      expect(lista.last.hasDeadline, isFalse);
    });

    test('não dança entre uma abertura e outra', () {
      // Ordem instável faria a pessoa achar que perdeu algo que já leu.
      final DateTime birth = DateTime(2026, 3, 10);
      expect(
        idsEm(birth, DateTime(2026, 9, 1)),
        idsEm(birth, DateTime(2026, 9, 1)),
      );
    });
  });

  group('a fonte é trocável', () {
    test('a interface não conhece asset nenhum', () {
      const InspirationSource fonte = AssetInspirationSource();
      expect(fonte, isA<InspirationSource>());
    });
  });

  group('as leituras relacionadas', () {
    List<ActiveInspiration> ativasEm(DateTime birth, DateTime hoje) =>
        pickFor(all: catalogo, profile: nascidaEm(birth), now: hoje);

    test('nunca sugere a própria', () {
      final List<ActiveInspiration> ativas = ativasEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 2, 20),
      );
      for (final ActiveInspiration a in ativas) {
        expect(
          relatedTo(a, ativas).map((ActiveInspiration r) => r.inspiration.id),
          isNot(contains(a.inspiration.id)),
        );
      }
    });

    test('só sugere o que vale hoje', () {
      // Mandar alguém ler sobre algo que só faz sentido daqui a dois anos é
      // pior que não sugerir nada.
      final DateTime birth = DateTime(2026, 3, 10);
      final DateTime hoje = DateTime(2026, 5, 1);
      final List<ActiveInspiration> ativas = ativasEm(birth, hoje);
      final Set<String> idsAtivos = ativas
          .map((ActiveInspiration a) => a.inspiration.id)
          .toSet();

      for (final ActiveInspiration r in relatedTo(ativas.first, ativas)) {
        expect(idsAtivos, contains(r.inspiration.id));
      }
    });

    test('prefere o mesmo assunto', () {
      final List<ActiveInspiration> ativas = ativasEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 2, 20),
      );
      final ActiveInspiration festa = ativas.firstWhere(
        (ActiveInspiration a) =>
            a.inspiration.id == 'primeiro-aniversario-ideias',
      );
      expect(
        relatedTo(festa, ativas).first.inspiration.kind,
        festa.inspiration.kind,
      );
    });

    test('no máximo três, e sempre as mesmas', () {
      final List<ActiveInspiration> ativas = ativasEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 2, 20),
      );
      final List<ActiveInspiration> a = relatedTo(ativas.first, ativas);
      expect(a.length, lessThanOrEqualTo(3));
      expect(
        a.map((ActiveInspiration r) => r.inspiration.id),
        relatedTo(
          ativas.first,
          ativas,
        ).map((ActiveInspiration r) => r.inspiration.id),
      );
    });

    test('uma das três é sempre de outro assunto', () {
      // Três do mesmo tema prendem quem entrou por uma ideia de foto num
      // corredor de ideias de foto. A vaga reservada é a janela: é por ela
      // que alguém descobre que existe uma seção sobre cartas.
      final List<ActiveInspiration> ativas = ativasEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 2, 20),
      );

      for (final ActiveInspiration a in ativas) {
        final List<ActiveInspiration> perto = relatedTo(a, ativas);
        final bool haOutroAssunto = ativas.any(
          (ActiveInspiration o) =>
              o.inspiration.id != a.inspiration.id &&
              o.inspiration.kind != a.inspiration.kind,
        );
        if (!haOutroAssunto || perto.length < 3) continue;

        expect(
          perto.any(
            (ActiveInspiration r) => r.inspiration.kind != a.inspiration.kind,
          ),
          isTrue,
          reason: 'A postagem ${a.inspiration.id} só oferece o próprio tema',
        );
      }
    });

    test('a saída não é sempre a mesma postagem', () {
      // Presa ao id, e não fixa: se fosse a mesma para todas, a "janela"
      // viraria outra parede, com o mesmo cartaz pendurado.
      final List<ActiveInspiration> ativas = ativasEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 2, 20),
      );
      final Set<String> saidas = <String>{};
      for (final ActiveInspiration a in ativas) {
        final List<ActiveInspiration> perto = relatedTo(a, ativas);
        for (final ActiveInspiration r in perto) {
          if (r.inspiration.kind != a.inspiration.kind) {
            saidas.add(r.inspiration.id);
          }
        }
      }
      expect(saidas.length, greaterThan(1));
    });

    test('uma lista com um item só não sugere nada', () {
      final List<ActiveInspiration> ativas = ativasEm(
        DateTime(2026, 3, 10),
        DateTime(2027, 2, 20),
      );
      expect(
        relatedTo(ativas.first, <ActiveInspiration>[ativas.first]),
        isEmpty,
      );
    });
  });
}
