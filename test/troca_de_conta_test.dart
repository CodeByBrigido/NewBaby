import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';

/// Trocar de conta é trocar de filho.
///
/// Cada criança tem a própria conta do Google, e é ela que a criança recebe
/// quando crescer. Por isso não existe "perfil dentro da conta": trocar de
/// filho é trocar de autenticação, e o isolamento entre os irmãos é o mesmo
/// que separa duas famílias, imposto pelo servidor.
///
/// O que este arquivo protege é a **ordem** das duas operações, que é onde
/// mora o erro caro.
void main() {
  group('a ordem entre entrar e limpar', () {
    // Lê o corpo do método de verdade. Um teste que espelhasse a sequência
    // aqui dentro passaria mesmo depois de alguém inverter as duas linhas no
    // serviço, que é justamente o erro que este arquivo existe para pegar.
    final String fonte = File(
      'lib/services/session_service.dart',
    ).readAsStringSync();
    final int inicio = fonte.indexOf('Future<void> switchAccount()');
    final String corpo = fonte.substring(
      inicio,
      fonte.indexOf('}', inicio) + 1,
    );

    test('o método existe e faz as duas coisas', () {
      expect(inicio, greaterThan(0), reason: 'switchAccount sumiu');
      expect(corpo, contains('auth.signIn()'));
      expect(corpo, contains('_wipeLocalData()'));
    });

    test('o seletor do Google vem antes da limpeza', () {
      // Limpar primeiro faria um toque em "cancelar" no seletor do Google
      // custar a sessão inteira: a pessoa ficaria deslogada por ter mudado
      // de ideia. Entrar primeiro deixa a desistência sem custo, porque
      // `signIn` lança e a limpeza nunca é alcançada.
      expect(
        corpo.indexOf('auth.signIn()'),
        lessThan(corpo.indexOf('_wipeLocalData()')),
        reason:
            'Entrar precisa vir antes de limpar, senão desistir no seletor '
            'do Google custa a sessão.',
      );
    });
  });

  group('o aviso antes de trocar', () {
    test('explica a consequência, e não só a ação', () {
      // A troca apaga o cache local, então a linha do tempo recarrega. Sem
      // dizer isso, a primeira troca parece que o aplicativo travou.
      expect(S.switchAccountHint, contains('conta do Google'));
      expect(S.switchAccountHint, contains('apagado'));
      expect(S.switchAccountHint, contains('carregar'));
    });

    test('nenhum texto usa travessão', () {
      for (final String t in <String>[
        S.switchAccount,
        S.switchAccountAction,
        S.switchAccountHint,
      ]) {
        expect(t, isNot(contains('—')));
      }
    });
  });
}
