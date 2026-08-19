import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/premium/porta_do_premium.dart';
import 'package:meu_bebe/features/shell/add_sheet.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/state/providers.dart';

import 'fonte_de_verdade.dart';

/// A folha "O que você deseja adicionar?" com o portão do Premium ligado.
///
/// É a tela onde a regra encosta na pessoa. Ela precisa dizer a verdade duas
/// vezes: antes do toque, com o cadeado, e depois do toque, com o convite que
/// explica o plano. Uma opção que parece disponível e falha ao ser tocada é
/// pior que uma opção visivelmente trancada.
void main() {
  setUpAll(carregarFonteDeVerdade);

  Future<void> abrir(WidgetTester tester, {required bool premium}) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(
            (Ref _) => Stream<BabyProfile?>.value(
              BabyProfile(
                name: 'Maria',
                birth: DateTime(2026, 4, 15),
                gender: BabyGender.girl,
                premium: premium,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(AppPalette.girl),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: ElevatedButton(
                  onPressed: () => showAddSheet(context),
                  child: const Text('mais'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('mais'));
    await tester.pumpAndSettle();
  }

  group('o cadeado', () {
    testWidgets('sem licença, aparece nos quatro que dependem dela', (
      WidgetTester tester,
    ) async {
      await abrir(tester, premium: false);

      // Quatro cadeados: carta, desenho, documento e crescimento. Foto e
      // vídeo ficam limpos, porque nunca foram pagos.
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(4));
      expect(find.text(S.addPhoto), findsOneWidget);
      expect(find.text(S.addVideo), findsOneWidget);
    });

    testWidgets('com licença, não aparece nenhum', (WidgetTester tester) async {
      await abrir(tester, premium: true);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });
  });

  group('o toque numa opção trancada', () {
    testWidgets('abre o convite, e não o seletor', (WidgetTester tester) async {
      await abrir(tester, premium: false);

      await tester.tap(find.text(S.addLetter));
      await tester.pumpAndSettle();

      expect(find.byType(ConvitePremium), findsOneWidget);
      expect(find.text(tituloDoConvite(EntryType.letter)), findsOneWidget);
    });

    testWidgets('a folha fecha antes do convite', (WidgetTester tester) async {
      // Duas coisas modais na mesma pilha é o que já fez a janela do envio
      // não aparecer neste mesmo arquivo. Aqui a folha sai de cena primeiro.
      await abrir(tester, premium: false);

      await tester.tap(find.text(S.addGrowth));
      await tester.pumpAndSettle();

      expect(find.text(S.addQuestion), findsNothing);
      expect(find.byType(ConvitePremium), findsOneWidget);
    });
  });
}
