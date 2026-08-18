import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/features/home/painel_do_bebe.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';

import 'fonte_de_verdade.dart';

/// O painel do topo da tela inicial.
///
/// Ele trocou um cartão de três blocos de texto com a foto pequena de lado
/// por uma foto grande e centralizada, com o nome e a idade abaixo. O que
/// estes testes prendem é justamente o que se perde fácil numa mexida de
/// layout: que o texto não voltou a crescer, e que a idade continua exata.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
  });

  Future<void> montar(
    WidgetTester tester, {
    String nome = 'Maria',
    BabyGender? sexo = BabyGender.girl,
    DateTime? nascimento,
    DateTime? hoje,
    double largura = 360,
  }) async {
    tester.view.physicalSize = Size(largura * 3, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final BabyProfile perfil = BabyProfile(
      name: nome,
      birth: nascimento ?? DateTime(2026, 11, 2),
      gender: sexo,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.build(AppPalette.of(sexo)),
          home: Scaffold(
            body: PainelDoBebe(
              profile: perfil,
              idade: AgeCalculator.ageAt(
                perfil.birth,
                hoje ?? DateTime(2028, 8, 16),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('o que o painel mostra', () {
    testWidgets('o nome e a idade, e nada além disso', (
      WidgetTester tester,
    ) async {
      await montar(tester);

      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('1 ano, 9 meses e 14 dias'), findsOneWidget);

      // A saudação saiu de propósito. Ela não diz nada sobre a criança, muda
      // três vezes por dia sem que nada tenha acontecido, e ocupava a linha
      // mais visível da tela.
      for (final String saudacao in <String>[
        'Bom dia',
        'Boa tarde',
        'Boa noite',
      ]) {
        expect(find.textContaining(saudacao), findsNothing);
      }
      // E a frase de ligação também: com a foto e o nome ali, "Hoje a Maria
      // está com" é uma linha inteira para apresentar um número.
      expect(find.textContaining('está com'), findsNothing);
    });

    testWidgets('os dias aparecem mesmo depois de um ano', (
      WidgetTester tester,
    ) async {
      // Fora daqui os dias somem a partir de um ano, porque poluem. No painel
      // eles ficam: é a única tela em que a idade é o assunto, e quem abre o
      // aplicativo todo dia repara no dia que virou.
      await montar(tester, hoje: DateTime(2028, 11, 2));
      expect(find.text('2 anos e 0 dias'), findsOneWidget);
    });

    testWidgets('no dia do nascimento não inventa idade', (
      WidgetTester tester,
    ) async {
      await montar(tester, hoje: DateTime(2026, 11, 2));
      expect(find.text('No nascimento'), findsOneWidget);
    });
  });

  group('o que não pode quebrar', () {
    testWidgets('a idade mais longa cabe numa linha só', (
      WidgetTester tester,
    ) async {
      // `20 anos, 10 meses e 30 dias` é o caso pedido para conferir. Se ela
      // quebrar, o painel muda de altura e o desenho inteiro se desloca.
      await montar(
        tester,
        nascimento: DateTime(2005, 1, 2),
        hoje: DateTime(2025, 12, 1),
      );

      final Finder idade = find.text('20 anos, 10 meses e 29 dias');
      expect(idade, findsOneWidget);
      expect(tester.getSize(idade).height, lessThan(24));
    });

    testWidgets('nome comprido não vaza do painel', (
      WidgetTester tester,
    ) async {
      await montar(tester, nome: 'Maria Eduarda Brigido de Albuquerque');

      final Rect painel = tester.getRect(find.byType(PainelDoBebe));
      final Rect texto = tester.getRect(
        find.text('Maria Eduarda Brigido de Albuquerque'),
      );
      expect(texto.left, greaterThanOrEqualTo(painel.left));
      expect(texto.right, lessThanOrEqualTo(painel.right));
    });

    testWidgets('num telefone estreito continua inteiro', (
      WidgetTester tester,
    ) async {
      await montar(tester, largura: 320);
      expect(tester.takeException(), isNull);
      expect(find.text('Maria'), findsOneWidget);
    });
  });

  group('o fundo acompanha o cadastro', () {
    testWidgets('cada sexo pinta o seu, e sem sexo também tem painel', (
      WidgetTester tester,
    ) async {
      for (final BabyGender? sexo in <BabyGender?>[
        BabyGender.girl,
        BabyGender.boy,
        null,
      ]) {
        await montar(tester, sexo: sexo);
        expect(find.byType(PainelDoBebe), findsOneWidget, reason: '$sexo');
        expect(tester.takeException(), isNull, reason: '$sexo');
      }
    });
  });
}
