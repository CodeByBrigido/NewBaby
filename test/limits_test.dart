import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/utils/limits.dart';

/// Os limites de texto existem em dois lugares: no `Limits`, que a interface
/// usa para não deixar a pessoa escrever além do permitido, e nas regras do
/// Firestore, que recusam quem não passou pela interface.
///
/// A regra do servidor é a que vale - ela não pode depender de o cliente se
/// comportar. Mas se os dois saírem de sincronia, alguém escreve à vontade e
/// só descobre o limite na hora de salvar, com uma mensagem genérica. Este
/// teste existe para que essa divergência apareça aqui, e não lá.
void main() {
  final String rules = File('firebase/firestore.rules').readAsStringSync();

  int limitInRules(String field) {
    final RegExpMatch? match = RegExp(
      "textUpTo\\('$field',\\s*(\\d+)\\)",
    ).firstMatch(rules);
    expect(
      match,
      isNotNull,
      reason:
          'O campo "$field" não é mais limitado em firebase/firestore.rules. '
          'Se ele deixou de existir, tire-o também do Limits.',
    );
    return int.parse(match!.group(1)!);
  }

  group('a interface e as regras do Firestore combinam', () {
    test('nome da criança', () {
      expect(Limits.babyName, limitInRules('nome'));
    });

    test('hospital', () {
      expect(Limits.hospital, limitInRules('hospital'));
    });

    test('título', () {
      expect(Limits.title, limitInRules('titulo'));
    });

    test('descrição e corpo da carta', () {
      expect(Limits.description, limitInRules('descricao'));
    });
  });

  test('o corpo da carta cabe num documento do Firestore', () {
    // Um documento inteiro não passa de 1 MiB. O corpo é o campo que pode
    // crescer; em UTF-8 o pior caso é 4 bytes por caractere.
    expect(Limits.description * 4, lessThan(1024 * 1024));
  });
}
