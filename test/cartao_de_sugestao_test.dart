import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/moments/moments_screen.dart';
import 'package:meu_bebe/models/suggestion.dart';

/// O cartão de sugestão precisa oferecer o "sim", e não só o "agora não".
///
/// O defeito, visto no aparelho: o cartão aparecia na tela inicial com o
/// título, a nota e um único botão, "Agora não". Quem abria o aplicativo
/// recebia uma sugestão sem nenhuma forma de aceitá-la, e a leitura natural
/// disso é cobrança.
///
/// A causa não estava no cartão, e sim no tema. Os botões do aplicativo são
/// de largura cheia, e para isso o tema usa `minimumSize: Size.fromHeight`,
/// que é `Size(double.infinity, altura)`. Uma largura mínima infinita não
/// pode ser medida dentro de uma `Row`: o "Registrar" falhava no layout e
/// não chegava a ser pintado.
///
/// O que torna esse defeito perigoso é o silêncio dele. Em compilação de
/// depuração a asserção grita; no APK instalado as asserções não rodam, o
/// botão simplesmente não existe, e nada nos testes de então olhava para
/// isso. Foi preciso alguém instalar e estranhar.
void main() {
  Widget montar({required bool compact}) {
    const Suggestion s = Suggestion(
      id: 'corte-de-cabelo',
      title: 'O primeiro corte de cabelo',
      note: 'Antes e depois, se der.',
      trigger: AgeWindow(365, 900),
    );

    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.build(AppPalette.girl),
        home: Scaffold(
          body: SuggestionCard(
            active: const ActiveSuggestion(suggestion: s, checked: <String>{}),
            copy: Copy.of(null),
            compact: compact,
          ),
        ),
      ),
    );
  }

  group('o cartão de sugestão', () {
    testWidgets('mostra os dois botões, e o de aceitar tem tamanho', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(montar(compact: true));
      await tester.pumpAndSettle();

      expect(find.text('Agora não'), findsOneWidget);
      expect(find.text('Registrar'), findsOneWidget);

      // Estar na árvore não basta: o botão quebrado também estava lá, com
      // largura zero e sem nunca ser pintado. O que prova que ele existe na
      // tela é ter tamanho e caber nela.
      final Size tamanho = tester.getSize(find.byType(FilledButton));
      expect(
        tamanho.width,
        greaterThan(0),
        reason: 'o botão de registrar não chegou a ser medido',
      );
      expect(tamanho.height, greaterThan(0));
      expect(tamanho.width.isFinite, isTrue);
    });

    testWidgets('o botão de aceitar é o maior dos dois', (
      WidgetTester tester,
    ) async {
      // A ação que o cartão quer é registrar. Dar o mesmo peso aos dois
      // botões faria a recusa parecer a escolha esperada.
      await tester.pumpWidget(montar(compact: true));
      await tester.pumpAndSettle();

      final double aceitar = tester.getSize(find.byType(FilledButton)).width;
      final double recusar = tester.getSize(find.byType(TextButton)).width;
      expect(aceitar, greaterThan(recusar));
    });

    testWidgets('na tela inicial o cartão diz o que é', (
      WidgetTester tester,
    ) async {
      // Na tela de Momentos a barra do topo já apresenta o assunto. Na
      // inicial o cartão cai entre a idade e o acervo, e um título solto
      // como "O primeiro corte de cabelo" não diz se aquilo é um aviso, uma
      // cobrança ou algo que o aplicativo acha que já aconteceu.
      await tester.pumpWidget(montar(compact: true));
      await tester.pumpAndSettle();
      expect(find.text('Momento para registrar'), findsOneWidget);
    });

    testWidgets('na tela de Momentos ele não se repete', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(montar(compact: false));
      await tester.pumpAndSettle();
      expect(find.text('Momento para registrar'), findsNothing);
      expect(find.text('Registrar'), findsOneWidget);
    });
  });
}
