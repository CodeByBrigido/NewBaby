import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/features/profile/delete_account_screen.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/state/providers.dart';

/// O aviso antes de apagar a conta.
///
/// É o último ponto em que dá para voltar atrás. Depois dele não há backup,
/// não há período de carência e não há pedido que reverta: o índice do
/// servidor some e a permissão do Drive é revogada. Um toque a mais aqui
/// custa um segundo; um toque a menos custa a infância inteira de alguém.
void main() {
  final BabyProfile maria = BabyProfile(
    name: 'Maria Silva',
    gender: BabyGender.girl,
    birth: DateTime(2026, 4, 15),
  );

  Widget tela({BabyProfile? perfil}) => ProviderScope(
    overrides: [
      uidProvider.overrideWithValue('uid-de-teste'),
      profileProvider.overrideWith(
        (Ref _) => Stream<BabyProfile?>.value(perfil),
      ),
    ],
    child: const MaterialApp(home: DeleteAccountScreen()),
  );

  final Finder botao = find.widgetWithText(FilledButton, S.deleteAccount);

  /// O botão fica no fim da rolagem, depois da escolha sobre o Drive: numa
  /// tela de teste ele nasce fora do campo de visão.
  Future<void> tocarEmApagar(WidgetTester t) async {
    await t.scrollUntilVisible(botao, 200);
    await t.pumpAndSettle();
    await t.tap(botao);
    await t.pumpAndSettle();
  }

  group('nada é apagado sem passar pelo aviso', () {
    testWidgets('tocar em apagar abre o aviso, e não apaga', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(tela(perfil: maria));
      await t.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);

      await tocarEmApagar(t);

      expect(
        find.byType(AlertDialog),
        findsOneWidget,
        reason: 'O botão vermelho não pode apagar direto',
      );
      // Ainda em "Apagar...", e não em "Apagando...": a exclusão não
      // começou. Se ela tivesse começado, o botão já teria trocado.
      expect(find.text(S.deleteAccountWorking), findsNothing);
    });

    testWidgets('cancelar fecha o aviso e não apaga nada', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(tela(perfil: maria));
      await t.pumpAndSettle();

      await tocarEmApagar(t);
      await t.tap(find.text('Cancelar'));
      await t.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(S.deleteAccountWorking), findsNothing);
      expect(
        botao,
        findsOneWidget,
        reason: 'A tela continua de pé, com nada apagado',
      );
    });
  });

  group('o aviso diz o que precisa dizer', () {
    testWidgets('abre pela frase que não pode ser desfeita', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(tela(perfil: maria));
      await t.pumpAndSettle();
      await tocarEmApagar(t);

      final Copy copy = Copy.of(maria);
      expect(find.text(copy.deleteConfirmTitle), findsOneWidget);
      expect(find.text(copy.deleteConfirmBody), findsOneWidget);
      expect(find.text(copy.deleteConfirmAction), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    test('a irreversibilidade vem primeiro, e não no fim', () {
      // No fim de três parágrafos ela vira letra miúda. Quem fecha a caixa
      // no automático lê a primeira linha, e é ela que precisa avisar.
      final String corpo = Copy.of(maria).deleteConfirmBody;
      expect(corpo.split('\n').first, contains('não pode ser desfeito'));
      expect(corpo, contains('backup'));
    });

    test('a pergunta diz o nome da criança', () {
      // "Apagar a conta?" é uma caixa de diálogo qualquer. "Apagar a
      // cápsula da Maria?" é uma pergunta que se lê antes de responder.
      expect(Copy.of(maria).deleteConfirmTitle, contains('Maria'));
      expect(Copy.of(maria).deleteConfirmBody, contains('Maria'));
    });

    test('sem cadastro, a frase se vira sem referente', () {
      // A conta pode ser apagada antes de existir cadastro. A frase é
      // reescrita, em vez de cair num "da criança" desajeitado no título.
      final Copy sem = Copy.generic;
      expect(sem.deleteConfirmTitle, 'Apagar a conta?');
      expect(sem.deleteConfirmBody, contains('não pode ser desfeito'));
      expect(sem.deleteConfirmBody, isNot(contains('null')));
    });

    test('o botão diz o que faz', () {
      // "Sim" e "Confirmar" servem para qualquer coisa, e por isso são
      // tocados no automático.
      final String acao = Copy.of(maria).deleteConfirmAction;
      expect(acao.toLowerCase(), contains('apagar'));
      expect(acao.toLowerCase(), isNot(anyOf(contains('sim'), 'confirmar')));
    });

    test('o aviso não repete o cartão que está acima dele', () {
      // Um aviso que repete o que a pessoa acabou de ler é um aviso que ela
      // pula, e a repetição foi o defeito que motivou este texto.
      expect(Copy.of(maria).deleteConfirmBody, isNot(S.deleteAccountBody));
    });

    test('só um controle no aplicativo carrega o rótulo que apaga', () {
      // O item do Perfil e o botão vermelho levam o mesmo nome porque a
      // página pública ensina esse caminho pelo nome. O botão no fim da
      // leitura, não: dois controles idênticos com efeitos diferentes é
      // como se aperta o errado.
      expect(S.goToDeleteAccount, isNot(S.deleteAccount));
      expect(S.goToDeleteAccount.toLowerCase(), contains('exclusão'));
    });

    test('nenhum dos textos usa travessão', () {
      for (final String texto in <String>[
        Copy.of(maria).deleteConfirmTitle,
        Copy.of(maria).deleteConfirmBody,
        Copy.of(maria).deleteConfirmAction,
        Copy.generic.deleteConfirmTitle,
        Copy.generic.deleteConfirmBody,
      ]) {
        expect(texto, isNot(contains('—')), reason: texto);
      }
    });
  });
}
