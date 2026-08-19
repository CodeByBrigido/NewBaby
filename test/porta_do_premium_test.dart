import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/premium/porta_do_premium.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';

import 'fonte_de_verdade.dart';

/// O portão do plano Premium.
///
/// A regra que estes testes prendem, e que é decisão de produto de 18/08/2026:
/// **a licença é da conta que faz login**. Nada aqui pergunta ao aparelho nem
/// à conta da Play Store, e por isso o portão inteiro é testável sem loja
/// nenhuma, tanto aqui quanto no aparelho, virando o campo no console.
///
/// A outra metade da regra é o que o portão **não** faz: ler nunca é
/// bloqueado, e foto e vídeo nunca são bloqueados.
void main() {
  setUpAll(carregarFonteDeVerdade);

  BabyProfile perfil({bool premium = false}) => BabyProfile(
    name: 'Maria',
    birth: DateTime(2026, 4, 15),
    gender: BabyGender.girl,
    premium: premium,
  );

  group('quais tipos dependem da licença', () {
    test('os quatro que só esta cápsula tem', () {
      expect(exigeLicenca(EntryType.letter), isTrue);
      expect(exigeLicenca(EntryType.drawing), isTrue);
      expect(exigeLicenca(EntryType.document), isTrue);
      expect(exigeLicenca(EntryType.growth), isTrue);
    });

    test('foto e vídeo nunca', () {
      // Cobrar por isto seria cobrar pelo que qualquer galeria faz de graça.
      expect(exigeLicenca(EntryType.photo), isFalse);
      expect(exigeLicenca(EntryType.video), isFalse);
      expect(exigeLicenca(EntryType.birth), isFalse);
    });

    test('todo tipo tem uma resposta', () {
      // Um tipo novo no enum precisa de uma decisão explícita, e não do
      // silêncio de um `default` que o deixaria livre por engano.
      for (final EntryType t in EntryType.values) {
        expect(() => exigeLicenca(t), returnsNormally, reason: t.id);
      }
    });
  });

  group('quem pode criar', () {
    test('sem licença, os quatro estão fechados', () {
      for (final EntryType t in <EntryType>[
        EntryType.letter,
        EntryType.drawing,
        EntryType.document,
        EntryType.growth,
      ]) {
        expect(podeCriar(perfil(), t), isFalse, reason: t.id);
      }
    });

    test('com licença, todos abertos', () {
      for (final EntryType t in EntryType.values) {
        expect(podeCriar(perfil(premium: true), t), isTrue, reason: t.id);
      }
    });

    test('sem licença, foto e vídeo seguem abertos', () {
      expect(podeCriar(perfil(), EntryType.photo), isTrue);
      expect(podeCriar(perfil(), EntryType.video), isTrue);
    });

    test('sem perfil nenhum, o que é livre continua livre', () {
      // Acontece no instante entre entrar e o perfil chegar do Firestore.
      // Travar tudo aí seria um portão que fecha por lentidão de rede.
      expect(podeCriar(null, EntryType.photo), isTrue);
      expect(podeCriar(null, EntryType.letter), isFalse);
    });
  });

  group('o perfil e o campo da licença', () {
    test('ausente quer dizer plano básico', () {
      // Toda conta que existe hoje entra assim, sem migração nenhuma.
      final BabyProfile p = BabyProfile.fromMap(<String, Object?>{
        'nome': 'Maria',
      });
      expect(p.premium, isFalse);
    });

    test('lido do documento', () {
      final BabyProfile p = BabyProfile.fromMap(<String, Object?>{
        'nome': 'Maria',
        'premium': true,
      });
      expect(p.premium, isTrue);
    });

    test('qualquer coisa que não seja verdadeiro é plano básico', () {
      for (final Object? valor in <Object?>[null, false, 'sim', 1]) {
        final BabyProfile p = BabyProfile.fromMap(<String, Object?>{
          'nome': 'Maria',
          'premium': valor,
        });
        expect(p.premium, isFalse, reason: '$valor');
      }
    });

    test('o aplicativo não escreve a licença', () {
      // Este é o teste que protege a licença de quem pagou. O perfil é
      // gravado com `merge`, então um `premium` no `toMap` sobrescreveria com
      // `false` o valor que a compra gravou, toda vez que alguém corrigisse o
      // nome da criança na tela de editar.
      expect(perfil(premium: true).toMap().containsKey('premium'), isFalse);
    });

    test('copyWith preserva a licença', () {
      final BabyProfile p = perfil(premium: true).copyWith(name: 'Maria Souza');
      expect(p.premium, isTrue);
    });
  });

  group('o texto do convite', () {
    test('diz o preço, quem cobra e o que não se perde', () {
      final List<String> linhas = corpoDoConvite(
        EntryType.letter,
        Copy.of(perfil()),
      );
      final String tudo = linhas.join(' ');
      expect(tudo, contains('anual'));
      expect(tudo, contains('Google Play'));
      expect(tudo, contains('continua'));
    });

    test('fala pelo nome da criança, com a concordância certa', () {
      expect(
        corpoDoConvite(EntryType.letter, Copy.of(perfil())).first,
        contains('da Maria'),
      );
    });

    test('sem nome, a frase continua inteira', () {
      final String linha = corpoDoConvite(EntryType.letter, Copy.generic).first;
      expect(linha, isNot(contains('  ')));
      expect(linha, isNot(contains(' de .')));
    });

    test('a lista não repete o que acabou de ser barrado', () {
      // "Guardar cartas ... junto com as cartas" é a frase tropeçando.
      expect(osOutrosDoPlano(EntryType.letter), isNot(contains('cartas')));
      expect(osOutrosDoPlano(EntryType.growth), isNot(contains('crescimento')));
      expect(
        corpoDoConvite(EntryType.letter, Copy.of(perfil())).first,
        'Guardar cartas na cápsula da Maria faz parte do Premium, junto com '
        'os desenhos, os documentos e o crescimento.',
      );
    });

    test('os outros três aparecem sempre, com e antes do último', () {
      for (final EntryType t in <EntryType>[
        EntryType.letter,
        EntryType.drawing,
        EntryType.document,
        EntryType.growth,
      ]) {
        final String lista = osOutrosDoPlano(t);
        expect(lista.split(', ').length, 2, reason: t.id);
        expect(lista, contains(' e '), reason: t.id);
      }
    });

    test('sem travessão em lugar nenhum', () {
      for (final EntryType type in EntryType.values) {
        final String tudo =
            tituloDoConvite(type) +
            corpoDoConvite(type, Copy.of(perfil())).join(' ');
        expect(tudo, isNot(contains('—')), reason: type.id);
      }
    });

    test('o título nomeia o que foi barrado', () {
      expect(tituloDoConvite(EntryType.letter), contains('cartas'));
      expect(tituloDoConvite(EntryType.drawing), contains('desenhos'));
      expect(tituloDoConvite(EntryType.document), contains('documentos'));
      expect(tituloDoConvite(EntryType.growth), contains('crescimento'));
    });
  });

  group('o convite na tela', () {
    Future<void> montar(WidgetTester tester, EntryType type) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: Scaffold(
            body: ConvitePremium(type: type, copy: Copy.of(perfil())),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('mostra o título e as três explicações', (
      WidgetTester tester,
    ) async {
      await montar(tester, EntryType.letter);
      expect(find.text(tituloDoConvite(EntryType.letter)), findsOneWidget);
      for (final String linha in corpoDoConvite(
        EntryType.letter,
        Copy.of(perfil()),
      )) {
        expect(find.text(linha), findsOneWidget);
      }
    });

    testWidgets('não oferece botão de assinar enquanto não há caixa', (
      WidgetTester tester,
    ) async {
      // O faturamento é a segunda metade da fase e só pode ser construído com
      // o pacote já numa faixa da Play Store. Um botão de assinar que não
      // assina seria pior que a ausência dele.
      await montar(tester, EntryType.letter);
      expect(find.text('Entendi'), findsOneWidget);
      expect(find.textContaining('Assinar'), findsNothing);
    });
  });

  group('a porta, de ponta a ponta', () {
    /// Monta um botão que só segue se a porta deixar, e conta as passagens.
    Future<int Function()> montarPorta(
      WidgetTester tester, {
      required bool premium,
      required EntryType type,
    }) async {
      int passou = 0;
      final BabyProfile p = perfil(premium: premium);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (await liberadoParaCriar(context, p, type)) passou++;
                  },
                  child: const Text('criar'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return () => passou;
    }

    testWidgets('sem licença, para e explica', (WidgetTester tester) async {
      final int Function() passagens = await montarPorta(
        tester,
        premium: false,
        type: EntryType.letter,
      );

      await tester.tap(find.text('criar'));
      await tester.pumpAndSettle();

      expect(find.byType(ConvitePremium), findsOneWidget);
      expect(passagens(), 0);
    });

    testWidgets('com licença, passa direto e sem popup', (
      WidgetTester tester,
    ) async {
      final int Function() passagens = await montarPorta(
        tester,
        premium: true,
        type: EntryType.letter,
      );

      await tester.tap(find.text('criar'));
      await tester.pumpAndSettle();

      expect(find.byType(ConvitePremium), findsNothing);
      expect(passagens(), 1);
    });

    testWidgets('sem licença, a foto passa igual', (WidgetTester tester) async {
      final int Function() passagens = await montarPorta(
        tester,
        premium: false,
        type: EntryType.photo,
      );

      await tester.tap(find.text('criar'));
      await tester.pumpAndSettle();

      expect(find.byType(ConvitePremium), findsNothing);
      expect(passagens(), 1);
    });

    testWidgets('fechar o convite não deixa passar', (
      WidgetTester tester,
    ) async {
      // Fechar o popup não é consentimento: quem fecha continua no básico.
      final int Function() passagens = await montarPorta(
        tester,
        premium: false,
        type: EntryType.growth,
      );

      await tester.tap(find.text('criar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();

      expect(find.byType(ConvitePremium), findsNothing);
      expect(passagens(), 0);
    });
  });
}
