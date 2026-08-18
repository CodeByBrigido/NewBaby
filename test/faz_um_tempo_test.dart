import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/home/faz_um_tempo.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
import 'package:meu_bebe/models/entry.dart';

import 'fonte_de_verdade.dart';

/// A lista de quanto tempo faz que cada tipo não recebe nada.
///
/// Ela entrou no lugar da grade de atalhos do Acervo. O que estes testes
/// prendem é o que a lista promete: dizer a verdade sobre o que está parado,
/// sem virar cobrança e sem inventar número para o que nunca aconteceu.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
  });

  final DateTime hoje = DateTime(2028, 8, 18);

  Future<void> montar(
    WidgetTester tester,
    Map<EntryType, int> diasAtras,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final BabyProfile perfil = BabyProfile(
      name: 'Maria',
      birth: DateTime(2026, 11, 2),
    );

    final CapsulePulse pulse = CapsulePulse.from(
      profile: perfil,
      now: hoje,
      entries: <Entry>[
        for (final MapEntry<EntryType, int> e in diasAtras.entries)
          Entry(
            id: e.key.id,
            type: e.key,
            date: hoje.subtract(Duration(days: e.value)),
            createdAt: hoje,
            ageDays: 0,
            bucketKey: 'S01',
            bucketName: 'Semana 01',
          ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: Scaffold(body: FazUmTempo(pulse: pulse)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('o que a lista mostra', () {
    testWidgets('os quatro tipos que se repetem, e só eles', (
      WidgetTester tester,
    ) async {
      await montar(tester, <EntryType, int>{});

      for (final String nome in <String>[
        'Fotos',
        'Vídeos',
        'Cartas',
        'Crescimento',
      ]) {
        expect(find.text(nome), findsOneWidget, reason: nome);
      }

      // Documento e desenho ficam de fora: uma certidão se guarda uma vez na
      // vida, e cobrar desenho de um bebê seria pedir o impossível.
      expect(find.text('Documentos'), findsNothing);
      expect(find.text('Desenhos'), findsNothing);
    });

    testWidgets('cada tipo com o seu tempo, na unidade certa', (
      WidgetTester tester,
    ) async {
      await montar(tester, <EntryType, int>{
        EntryType.photo: 23,
        EntryType.video: 4,
        EntryType.letter: 45,
        EntryType.growth: 400,
      });

      expect(find.text('23 dias'), findsOneWidget);
      expect(find.text('4 dias'), findsOneWidget);
      expect(find.text('1 mês'), findsOneWidget);
      expect(find.text('1 ano'), findsOneWidget);
    });

    testWidgets('o que nunca aconteceu não vira número', (
      WidgetTester tester,
    ) async {
      // "Ainda não", e não "nunca": as duas dizem o mesmo sobre o passado e
      // coisas opostas sobre o futuro.
      await montar(tester, <EntryType, int>{EntryType.photo: 2});

      expect(find.text('ainda não'), findsNWidgets(3));
      expect(find.text('0 dias'), findsNothing);
    });

    testWidgets('registro de hoje não diz que faz tempo', (
      WidgetTester tester,
    ) async {
      await montar(tester, <EntryType, int>{EntryType.photo: 0});
      expect(find.text('hoje'), findsOneWidget);
    });
  });

  group('a ordem', () {
    testWidgets('é sempre a mesma, e não pela demora', (
      WidgetTester tester,
    ) async {
      // Uma lista que se reordena a cada abertura obriga a reler tudo para
      // achar a linha que interessa.
      await montar(tester, <EntryType, int>{
        EntryType.photo: 300,
        EntryType.video: 1,
        EntryType.letter: 200,
        EntryType.growth: 2,
      });

      final double foto = tester.getTopLeft(find.text('Fotos')).dy;
      final double video = tester.getTopLeft(find.text('Vídeos')).dy;
      final double carta = tester.getTopLeft(find.text('Cartas')).dy;
      final double crescimento = tester.getTopLeft(find.text('Crescimento')).dy;

      expect(foto, lessThan(video));
      expect(video, lessThan(carta));
      expect(carta, lessThan(crescimento));
    });
  });
}
