import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';

/// O que o aplicativo grava tem de caber no que as regras aceitam.
///
/// As regras do Firestore validam com `hasOnly`, uma lista fechada de
/// campos. Gravar **um** campo fora dela faz o servidor recusar o documento
/// inteiro, e o aplicativo mostra "o servidor recusou a gravação" sem
/// nenhuma pista de qual campo sobrou.
///
/// Este teste nasceu de um estrago real. O campo `ordem` foi acrescentado ao
/// modelo e às regras no mesmo commit, mas as regras moram no servidor e são
/// publicadas por um fluxo à parte, que só roda quando os segredos do
/// Firebase existem. O aplicativo saiu na frente das regras, passou a
/// escrever `'ordem': null` em toda entrada, e o servidor recusou tudo:
/// nenhuma foto, nenhuma carta, nenhuma medição. Nada disso aparece em
/// teste de widget nem no `analyze`.
///
/// São duas guardas diferentes, e as duas fazem falta:
///
/// 1. **Nenhum campo escrito fora da lista das regras.** Pega o
///    esquecimento de atualizar um dos dois arquivos.
/// 2. **Nada de campo novo com valor nulo.** Pega o caso pior, em que os
///    dois arquivos combinam entre si e mesmo assim o aparelho para de
///    gravar, porque a regra publicada ainda é a antiga.
void main() {
  /// Os campos que uma função `hasOnly([...])` das regras permite.
  Set<String> permitidosEm(String funcao) {
    final String regras = File('firebase/firestore.rules').readAsStringSync();
    final int inicio = regras.indexOf('function $funcao()');
    expect(inicio, isNot(-1), reason: 'não achei `$funcao` nas regras');

    final int lista = regras.indexOf('hasOnly([', inicio);
    final int fim = regras.indexOf('])', lista);
    expect(lista, isNot(-1), reason: '`$funcao` não usa `hasOnly`');

    final String cru = regras.substring(lista + 'hasOnly(['.length, fim);
    return <String>{
      for (final RegExpMatch m in RegExp(r"'([^']+)'").allMatches(cru))
        m.group(1)!,
    };
  }

  final Entry entradaSimples = Entry(
    id: 'e1',
    type: EntryType.letter,
    date: DateTime(2027, 4, 10),
    createdAt: DateTime(2027, 4, 10),
    ageDays: 0,
    bucketKey: 'S01',
    bucketName: 'Semana 01',
    title: 'Para quando você crescer',
  );

  group('uma entrada', () {
    test('só grava campos que as regras conhecem', () {
      final Set<String> permitidos = permitidosEm('isValidEntry');
      final Set<String> gravados = entradaSimples
          .copyWith(ordem: 3)
          .toMap()
          .keys
          .toSet();

      expect(
        gravados.difference(permitidos),
        isEmpty,
        reason:
            'campo gravado que as regras recusam. Acrescente-o ao `hasOnly` '
            'de `isValidEntry` e publique as regras antes de soltar o APK.',
      );
    });

    test('não grava campo novo com valor nulo', () {
      // A guarda que faltava, e a única que teria evitado o estrago.
      //
      // Campo nulo ocupa uma chave no documento igual a qualquer outro. Um
      // campo novo escrito como nulo em toda entrada faz o aparelho parar de
      // gravar no instante em que o APK sai antes das regras novas, e o
      // caminho de volta é publicar regra, não reinstalar aplicativo.
      //
      // Os nulos abaixo são de antes, e podem ficar: as regras que estão no
      // servidor já os conhecem, então não há risco em mantê-los. A lista é
      // fechada de propósito. Um nome novo aqui é uma decisão que exige
      // publicar as regras **antes** de o APK sair, e este teste força quem
      // acrescentar a parar e escrever isso.
      const Set<String> nulosDeAntes = <String>{
        'descricao',
        'arquivoTextoId',
        'crescimento',
        'excluidoEm',
        'erro',
        'lacradoAte',
      };

      final Set<String> nulos = entradaSimples
          .toMap()
          .entries
          .where((MapEntry<String, Object?> e) => e.value == null)
          .map((MapEntry<String, Object?> e) => e.key)
          .toSet();

      expect(
        nulos.difference(nulosDeAntes),
        isEmpty,
        reason:
            'campo novo gravado como nulo. Use `if (campo != null)` no '
            '`toMap`: assim ele só existe em quem o tem, e as regras antigas '
            'continuam aceitando todo o resto.',
      );
    });

    test('quem foi arrastado grava a ordem, e os outros não', () {
      expect(entradaSimples.toMap().containsKey('ordem'), isFalse);
      expect(entradaSimples.copyWith(ordem: 0).toMap()['ordem'], 0);
    });
  });

  group('o cadastro', () {
    test('só grava campos que as regras conhecem', () {
      final Set<String> permitidos = permitidosEm('isValidProfile');
      final BabyProfile perfil = BabyProfile(
        name: 'Sara',
        birth: DateTime(2026, 4, 10),
        gender: BabyGender.girl,
      );

      expect(perfil.toMap().keys.toSet().difference(permitidos), isEmpty);
    });
  });
}
