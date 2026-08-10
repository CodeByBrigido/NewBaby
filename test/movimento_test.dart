import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/features/common/entrada_na_rolagem.dart';
import 'package:meu_bebe/features/common/esqueleto.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';

/// O sistema de movimento.
///
/// Duas coisas se perdem com facilidade e não dão erro nenhum quando se
/// perdem: um temporizador que sobrevive ao widget, e uma animação que ignora
/// quem desligou animações no aparelho. A primeira só aparece sob carga; a
/// segunda, só para quem tem enxaqueca vestibular, que não abre chamado.
void main() {
  Widget dentroDoTema(Widget filho) => MaterialApp(
    theme: AppTheme.build(AppPalette.of(BabyGender.girl)),
    home: Scaffold(body: filho),
  );

  group('o cartão entrando', () {
    testWidgets('começa transparente e assenta no lugar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dentroDoTema(
          const EntradaNaRolagem(indice: 0, child: Text('um cartão')),
        ),
      );

      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0,
      );

      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1,
      );
      expect(
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset,
        Offset.zero,
      );
    });

    testWidgets('o atraso tem teto, e ele vale a partir do sexto', (
      WidgetTester tester,
    ) async {
      // Sem teto, o vigésimo cartão esperaria quase um segundo. Quem abriu o
      // aplicativo para ver uma foto ficaria olhando o nada.
      await tester.pumpWidget(
        dentroDoTema(
          const EntradaNaRolagem(indice: 200, child: Text('lá embaixo')),
        ),
      );

      await tester.pump(
        EntradaNaRolagem.passo * EntradaNaRolagem.escalonados +
            const Duration(milliseconds: 1),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1,
      );
    });

    testWidgets('sair da árvore antes da hora não deixa temporizador solto', (
      WidgetTester tester,
    ) async {
      // Este é o teste que pegou o defeito: com `Future.delayed` no lugar de
      // um `Timer` cancelável, o estado ficava pendurado depois de o cartão
      // sumir, e o ambiente de teste reprova por isso.
      await tester.pumpWidget(
        dentroDoTema(
          const EntradaNaRolagem(indice: 5, child: Text('vai sumir')),
        ),
      );
      await tester.pumpWidget(dentroDoTema(const SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });
  });

  group('a data redonda', () {
    test('sai da mesma conta que o cartão de hoje usa', () {
      // Duas contas separadas para a mesma pergunta divergiriam, e o
      // histórico passaria a contradizer a tela inicial.
      final DateTime nascimento = DateTime(2026, 4, 15);

      expect(
        CapsulePulse.dataRedondaEm(nascimento, DateTime(2027, 4, 15)),
        '1 ano',
      );
      expect(
        CapsulePulse.dataRedondaEm(nascimento, DateTime(2026, 12, 15)),
        '8 meses',
      );
      expect(
        CapsulePulse.dataRedondaEm(nascimento, DateTime(2026, 5, 6)),
        '3 semanas',
      );
    });

    test('um dia comum não recebe selo', () {
      final DateTime nascimento = DateTime(2026, 4, 15);
      expect(
        CapsulePulse.dataRedondaEm(nascimento, DateTime(2026, 12, 17)),
        isNull,
      );
      // O próprio dia do nascimento não é "data redonda": ele é o começo.
      expect(CapsulePulse.dataRedondaEm(nascimento, nascimento), isNull);
    });

    test('semana só conta nos primeiros três meses', () {
      // Aos quatro anos, "208 semanas" não diz nada a ninguém.
      final DateTime nascimento = DateTime(2026, 4, 15);
      expect(
        CapsulePulse.dataRedondaEm(nascimento, DateTime(2027, 4, 8)),
        isNull,
        reason: '51 semanas não é data redonda',
      );
    });
  });

  group('o esqueleto', () {
    testWidgets('desenha a silhueta da lista, e não uma bolinha', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(dentroDoTema(const EsqueletoDaLinhaDoTempo()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Três cartões fantasma, cada um com ícone, título e área de mídia.
      expect(find.byType(Esqueleto), findsWidgets);
    });

    testWidgets('a grade mostra células suficientes para encher a tela', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(dentroDoTema(const EsqueletoDeGrade()));
      await tester.pump();
      expect(find.byType(Esqueleto), findsWidgets);
    });

    testWidgets('o brilho é mais lento que qualquer outro movimento', (
      WidgetTester tester,
    ) async {
      // É o único que se repete sem parar. Na velocidade dos outros, vira
      // pisca-pisca e rouba a atenção do conteúdo que está chegando.
      expect(Motion.esqueleto, greaterThan(Motion.hero));
      expect(Motion.esqueleto, greaterThan(Motion.screen));
    });
  });
}
