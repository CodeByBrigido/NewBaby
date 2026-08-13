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

  group('trocar de conta vai direto ao seletor', () {
    test('não existe mais texto de aviso para mostrar antes', () {
      // O aviso contava que a troca recarrega a linha do tempo. É uma
      // espera de segundos que se explica sozinha, e nada se perde no
      // caminho: desistir no seletor deixa tudo como estava, porque a
      // limpeza só acontece depois de a entrada dar certo.
      //
      // O teste olha a tela, e não a constante: uma constante apagada
      // some do compilador sozinha, mas uma caixa de diálogo reintroduzida
      // com texto escrito na hora passaria despercebida.
      final String fonte = File(
        'lib/features/profile/profile_screen.dart',
      ).readAsStringSync();

      final int troca = fonte.indexOf('_switchAccount(BuildContext');
      // Termina onde o método termina, e não lá adiante: um trecho largo
      // demais reprovaria por causa de um `confirm` de outra coisa.
      final int fim = fonte.indexOf('Widget build(', troca);
      expect(troca, isNot(-1));
      expect(
        fonte.substring(troca, fim),
        isNot(contains('confirm(')),
        reason: 'Trocar de conta não pede confirmação nenhuma.',
      );
    });
  });

  group('o botão de contas', () {
    test('está no plural, que é o que conta a existência de outras', () {
      // Um ícone sozinho não diz que mais de uma conta cabe aqui, e quem tem
      // dois filhos precisa descobrir isso sem procurar.
      expect(S.accountsLabel, 'CONTAS');
      expect(S.accountsLabel, S.accountsLabel.toUpperCase());
    });
  });
}
