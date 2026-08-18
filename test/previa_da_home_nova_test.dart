@Tags(<String>['previa'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/features/common/widgets.dart';
import 'package:meu_bebe/features/home/painel_do_bebe.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';

import 'fonte_de_verdade.dart';

/// A tela inicial com o painel novo, e o resto como está hoje.
///
/// **O que é real aqui:** o `PainelDoBebe` de verdade, e a grade do Acervo
/// montada com os mesmos ícones, rótulos e cores por tipo que a tela usa.
///
/// **O que é encenação:** as fotos recentes, que sem rede não chegam do
/// Drive, e a foto de perfil, que cai nas iniciais.
///
/// Roda à mão:
/// `flutter test --run-skipped --update-goldens test/previa_da_home_nova_test.dart`
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
    await carregarIconesDoMaterial();
  });

  for (final (String nome, BabyGender? sexo, String crianca)
      in <(String, BabyGender?, String)>[
        ('menina', BabyGender.girl, 'Maria'),
        ('menino', BabyGender.boy, 'Pedro'),
      ]) {
    testWidgets('previa da home nova, $nome', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final BabyProfile perfil = BabyProfile(
        name: crianca,
        birth: DateTime(2026, 11, 2),
        gender: sexo,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.build(AppPalette.of(sexo)),
            home: _Tela(perfil: perfil),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(_Tela),
        matchesGoldenFile('previa/home-nova-$nome.png'),
      );
    });
  }
}

class _Tela extends StatelessWidget {
  const _Tela({required this.perfil});

  final BabyProfile perfil;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Bebê'),
        leading: const Icon(Icons.menu),
        actions: const <Widget>[
          Icon(Icons.search),
          SizedBox(width: Space.x16),
          Icon(Icons.insert_chart_outlined),
          SizedBox(width: Space.x12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x16,
          Space.x8,
          Space.x16,
          Space.scrollEnd,
        ),
        children: <Widget>[
          PainelDoBebe(
            profile: perfil,
            idade: AgeCalculator.ageAt(perfil.birth, DateTime(2028, 8, 16)),
          ),
          const SizedBox(height: Space.x16),
          const SectionHeader(title: 'Acervo'),
          const _Atalhos(),
          const SizedBox(height: Space.x24),
          SectionHeader(
            title: 'Fotos recentes',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Ver todas'),
            ),
          ),
          const _Recentes(),
        ],
      ),
    );
  }
}

/// A grade do Acervo como está hoje, sem nenhuma mudança.
class _Atalhos extends StatelessWidget {
  const _Atalhos();

  @override
  Widget build(BuildContext context) {
    const List<EntryType> tipos = <EntryType>[
      EntryType.photo,
      EntryType.video,
      EntryType.letter,
      EntryType.drawing,
      EntryType.document,
      EntryType.growth,
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: Space.x12,
      mainAxisSpacing: Space.x12,
      childAspectRatio: 1.05,
      children: <Widget>[
        for (final EntryType tipo in tipos)
          Material(
            color: tipo.soft(context),
            borderRadius: Radii.buttonR,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(tipo.icon, color: tipo.accent(context), size: 26),
                const SizedBox(height: Space.x8),
                Text(
                  tipo.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.cores.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Recentes extends StatelessWidget {
  const _Recentes();

  @override
  Widget build(BuildContext context) {
    final List<Color> tons = <Color>[
      context.cores.primarySoft,
      context.cores.accentSoft,
      context.cores.surfaceMuted,
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: Space.x8,
      mainAxisSpacing: Space.x8,
      children: <Widget>[
        for (int i = 0; i < 6; i++)
          Container(
            decoration: BoxDecoration(
              color: tons[i % tons.length],
              borderRadius: Radii.fieldR,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.photo_outlined,
              color: context.cores.textSecondary.withValues(alpha: 0.35),
              size: 24,
            ),
          ),
      ],
    );
  }
}
