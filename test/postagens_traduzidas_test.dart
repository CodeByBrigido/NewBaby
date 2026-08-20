import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// As 46 postagens do blog, nas seis línguas.
///
/// O português mora na raiz de `assets/inspiracoes/` e é ele quem decide
/// quais postagens existem. Cada língua tem uma subpasta com os mesmos ids.
///
/// O carregador cai no português quando falta uma tradução, então uma
/// tradução esquecida não quebra o aplicativo: ela aparece em português.
/// É justamente por isso que este teste existe. Sem ele, o esquecimento é
/// silencioso, e "silencioso" foi como o aplicativo passou meses com metade
/// das telas em português.
void main() {
  const String raiz = 'assets/inspiracoes';
  const List<String> linguas = <String>['en', 'es', 'fr', 'de', 'it'];

  List<String> idsEm(String pasta) {
    final Directory d = Directory(pasta);
    if (!d.existsSync()) return <String>[];
    return d
        .listSync()
        .whereType<File>()
        .map((File f) => f.uri.pathSegments.last)
        .where((String n) => n.endsWith('.json'))
        .map((String n) => n.substring(0, n.length - '.json'.length))
        .toList()
      ..sort();
  }

  Map<String, Object?> ler(String caminho) =>
      (jsonDecode(File(caminho).readAsStringSync()) as Map<Object?, Object?>)
          .cast<String, Object?>();

  final List<String> ptIds = idsEm(raiz);

  test('o português continua sendo a lista de verdade', () {
    expect(ptIds, isNotEmpty);
    expect(ptIds.toSet(), hasLength(ptIds.length), reason: 'id repetido');
  });

  for (final String lingua in linguas) {
    group('as postagens em $lingua', () {
      final List<String> ids = idsEm('$raiz/$lingua');

      test('cobrem exatamente os mesmos ids do português', () {
        final Set<String> faltando = ptIds.toSet().difference(ids.toSet());
        final Set<String> sobrando = ids.toSet().difference(ptIds.toSet());
        expect(
          faltando,
          isEmpty,
          reason:
              'Sem tradução em $lingua (o aplicativo mostra em português): '
              '${faltando.join(", ")}',
        );
        expect(
          sobrando,
          isEmpty,
          reason:
              'Tradução em $lingua sem original na raiz, e por isso nunca '
              'lida: ${sobrando.join(", ")}',
        );
      });

      test('mantêm o gatilho igual ao do português', () {
        // O texto muda de língua; **quando** a postagem aparece, não. Um
        // "quando" divergente faria a mesma postagem chegar com idades
        // diferentes conforme a língua, e o catálogo deixaria de ser o
        // mesmo produto.
        for (final String id in ids) {
          if (!ptIds.contains(id)) continue;
          final Map<String, Object?> pt = ler('$raiz/$id.json');
          final Map<String, Object?> outra = ler('$raiz/$lingua/$id.json');
          for (final String campo in <String>['tipo', 'registrar', 'quando']) {
            expect(
              jsonEncode(outra[campo]),
              jsonEncode(pt[campo]),
              reason: '$lingua/$id: o campo "$campo" divergiu do português',
            );
          }
        }
      });

      test('têm título, resumo e seções com conteúdo', () {
        for (final String id in ids) {
          final Map<String, Object?> m = ler('$raiz/$lingua/$id.json');
          expect((m['titulo'] as String?)?.trim(), isNotEmpty, reason: id);
          expect((m['resumo'] as String?)?.trim(), isNotEmpty, reason: id);
          final List<Object?> secoes =
              m['secoes'] as List<Object?>? ?? const <Object?>[];
          expect(secoes, isNotEmpty, reason: id);
          for (final Object? s in secoes) {
            final Map<String, Object?> secao = (s! as Map<Object?, Object?>)
                .cast<String, Object?>();
            expect(
              (secao['titulo'] as String?)?.trim(),
              isNotEmpty,
              reason: id,
            );
            final bool temTexto =
                (secao['texto'] as String?)?.trim().isNotEmpty ?? false;
            final bool temItens =
                (secao['itens'] as List<Object?>?)?.isNotEmpty ?? false;
            expect(
              temTexto || temItens,
              isTrue,
              reason: '$lingua/$id: seção "${secao['titulo']}" vazia',
            );
          }
        }
      });

      test('não ficaram em português', () {
        // Não é lista de palavras: é o texto do próprio original. Se o
        // título ou o resumo saíram idênticos ao português, a tradução não
        // aconteceu. Nomes próprios e datas podem coincidir, mas um resumo
        // inteiro igual, não.
        for (final String id in ids) {
          if (!ptIds.contains(id)) continue;
          final Map<String, Object?> pt = ler('$raiz/$id.json');
          final Map<String, Object?> outra = ler('$raiz/$lingua/$id.json');
          expect(
            outra['resumo'],
            isNot(pt['resumo']),
            reason: '$lingua/$id: o resumo é o português, letra por letra',
          );
        }
      });
    });
  }

  test('o pubspec declara todas as subpastas de língua', () {
    // Declarar uma pasta no Flutter não alcança as subpastas dela. Sem a
    // linha, o AssetManifest não enxerga a tradução e todo mundo lê em
    // português, sem nenhum erro aparecendo.
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    for (final String lingua in linguas) {
      expect(
        pubspec,
        contains('assets/inspiracoes/$lingua/'),
        reason: 'Falta declarar assets/inspiracoes/$lingua/ no pubspec.yaml',
      );
    }
  });
}
