import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
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

  group('os dois nomes do aplicativo', () {
    // São dois de propósito: o Android corta o rótulo embaixo do ícone por
    // volta do 11º caractere, então o nome completo viraria "Meu Bebê: C...".
    // O curto fica no ícone; o completo, na loja e na tela de entrada.

    test('o curto cabe embaixo do ícone', () {
      expect(S.appName.length, lessThanOrEqualTo(12));
    });

    test('o completo cabe no título da Play Store', () {
      // A Play recusa título com mais de 30 caracteres.
      expect(S.appFullName.length, lessThanOrEqualTo(30));
    });

    test('o completo começa pelo curto, para ser a mesma marca', () {
      expect(S.appFullName, startsWith(S.appName));
      expect(S.appFullName, contains(S.appSubtitle));
    });

    test('o rótulo do ícone no Android é o nome curto', () {
      final String manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(manifest, contains('android:label="${S.appName}"'));
    });
  });

  group('o que o aplicativo pede ao Android', () {
    final String manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    test('não pede alarme exato', () {
      // O alarme exato é apresentado pelo sistema com cara de coisa séria e
      // auditado pelo Google Play. Um lembrete de tirar uma foto pode chegar
      // meia hora depois e continua valendo, então os lembretes são
      // agendados em modo inexato. Se alguém trocar o modo de agendamento,
      // este teste é o que avisa que a conta de permissão mudou junto.
      // A busca é pela declaração, não pela palavra: o comentário do próprio
      // manifesto explica por que ela não está lá, e citar o nome não é pedir.
      for (final String nome in <String>[
        'SCHEDULE_EXACT_ALARM',
        'USE_EXACT_ALARM',
      ]) {
        expect(
          manifest,
          isNot(
            contains(
              '<uses-permission android:name="android.permission.$nome"',
            ),
          ),
          reason: nome,
        );
      }
    });

    test('os lembretes sobrevivem a reiniciar o celular', () {
      expect(manifest, contains('RECEIVE_BOOT_COMPLETED'));
      expect(manifest, contains('ScheduledNotificationBootReceiver'));
    });

    test('o desugaring está ligado, senão o build Android nem compila', () {
      final String gradle = File(
        'android/app/build.gradle.kts',
      ).readAsStringSync();
      expect(gradle, contains('isCoreLibraryDesugaringEnabled = true'));
      expect(gradle, contains('coreLibraryDesugaring('));
    });
  });

  test('o corpo da carta cabe num documento do Firestore', () {
    // Um documento inteiro não passa de 1 MiB. O corpo é o campo que pode
    // crescer; em UTF-8 o pior caso é 4 bytes por caractere.
    expect(Limits.description * 4, lessThan(1024 * 1024));
  });
}
