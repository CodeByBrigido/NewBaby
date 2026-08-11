import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/account_deletion.dart';
import 'package:meu_bebe/core/l10n/privacy_policy.dart';
import 'package:meu_bebe/core/router/app_router.dart';
import 'package:meu_bebe/features/profile/documento.dart';

/// Os dois documentos dentro do aplicativo.
///
/// A política e a exclusão de conta não são letra miúda de rodapé: são o que
/// alguém lê para decidir se entrega o registro de um filho, e o que lê
/// depois para saber como desfazer. Um texto que só existe atrás do login
/// chega tarde para a única decisão que ele deveria informar.
void main() {
  group('os dois abrem sem sessão', () {
    test('a política e a exclusão estão na lista de telas públicas', () {
      // É o que faz os links do rodapé da tela de entrada funcionarem. Sem
      // isto o roteador devolve a pessoa para o login no meio da leitura.
      expect(Routes.semSessao, contains(Routes.privacy));
      expect(Routes.semSessao, contains(Routes.accountDeletion));
    });

    test('nada além dos documentos e da entrada abre sem sessão', () {
      // A lista é um buraco na única trava de sessão do aplicativo. Ela
      // precisa ser curta, e crescer só de propósito.
      expect(
        Routes.semSessao,
        <String>[
          Routes.login,
          Routes.intro,
          Routes.privacy,
          Routes.accountDeletion,
        ],
        reason:
            'Rota nova aqui é tela lida por quem não entrou: confira '
            'que ela não mostra nem escreve dado nenhum.',
      );
    });
  });

  group('a marcação dos textos vira formatação, e não asterisco', () {
    // Os documentos são escritos uma vez e saem em três lugares: a tela, o
    // Markdown do repositório e a página HTML. O `**negrito**` é a notação
    // dos outros dois, e sem conversão ele vaza para a tela.
    const TextStyle forte = TextStyle(fontWeight: FontWeight.w600);

    String juntar(String texto) => ParagrafoDoDocumento.pedacos(
      texto,
      forte,
    ).map((InlineSpan s) => (s as TextSpan).text ?? '').join();

    test('o texto sobrevive inteiro à conversão', () {
      for (final PrivacySection s in <PrivacySection>[
        ...privacyPolicy,
        ...accountDeletionPage,
      ]) {
        for (final String p in s.body) {
          expect(juntar(p), p.replaceAll('**', ''), reason: p);
        }
      }
    });

    test('o trecho marcado sai em negrito, e só ele', () {
      final List<InlineSpan> pedacos = ParagrafoDoDocumento.pedacos(
        'as fotos **não são apagadas**, e pronto',
        forte,
      );
      expect(pedacos.map((InlineSpan s) => (s as TextSpan).text), <String>[
        'as fotos ',
        'não são apagadas',
        ', e pronto',
      ]);
      expect((pedacos[0] as TextSpan).style, isNull);
      expect((pedacos[1] as TextSpan).style, forte);
      expect((pedacos[2] as TextSpan).style, isNull);
    });

    test('um texto sem marcação nenhuma passa direto', () {
      final List<InlineSpan> pedacos = ParagrafoDoDocumento.pedacos(
        'sem nada aqui',
        forte,
      );
      expect(pedacos, hasLength(1));
      expect((pedacos.single as TextSpan).style, isNull);
    });

    test('nenhum asterisco chega à tela', () {
      for (final PrivacySection s in <PrivacySection>[
        ...privacyPolicy,
        ...accountDeletionPage,
      ]) {
        for (final String p in s.body) {
          expect(juntar(p), isNot(contains('*')), reason: p);
        }
      }
    });
  });

  group('a tela desenha o documento', () {
    testWidgets('mostra o título, a data e as seções', (WidgetTester t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: TelaDeDocumento(
            titulo: 'Exclusão de conta e de dados',
            data: '11 de agosto de 2026',
            secoes: <PrivacySection>[
              PrivacySection(
                title: 'O que é apagado',
                body: <String>['Tudo **sem exceção**:', '• o cadastro'],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Exclusão de conta e de dados'), findsOneWidget);
      expect(
        find.text('Última atualização: 11 de agosto de 2026'),
        findsOneWidget,
      );
      expect(find.text('O que é apagado'), findsOneWidget);
      // O marcador vira o bullet à esquerda, e não faz parte do texto.
      expect(find.text('•'), findsOneWidget);
      expect(t.widget<Text>(find.byType(Text).last).data, isNot(contains('•')));
    });

    testWidgets('sem ação embaixo, não desenha botão nenhum', (
      WidgetTester t,
    ) async {
      // A mesma tela é lida da entrada, por quem ainda não tem conta.
      // Oferecer ali um botão de apagar seria oferecer apagar o que não
      // existe.
      await t.pumpWidget(
        const MaterialApp(
          home: TelaDeDocumento(
            titulo: 'Política de privacidade',
            data: 'hoje',
            secoes: <PrivacySection>[
              PrivacySection(title: 'Em resumo', body: <String>['Nada.']),
            ],
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
