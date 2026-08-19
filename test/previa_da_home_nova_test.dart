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
import 'package:meu_bebe/core/utils/formatters.dart';
import 'package:meu_bebe/features/common/widgets.dart';
import 'package:meu_bebe/features/home/painel_do_bebe.dart';
import 'package:meu_bebe/features/home/proximo_marco.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
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
          const _Ideia(),
          const SizedBox(height: Space.x24),
          const _FazUmTempo(),
          const SizedBox(height: Space.x16),
          CartaoDoProximoMarco(
            genero: perfil.gender,
            pulse: CapsulePulse.from(
              profile: perfil,
              entries: const <Entry>[],
              now: DateTime(2028, 8, 21),
            ),
          ),
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

/// O cartão de ideia do carrossel, com o conteúdo encenado.
class _Ideia extends StatelessWidget {
  const _Ideia();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(Space.x16),
          decoration: BoxDecoration(
            color: context.cores.surface,
            borderRadius: Radii.cardR,
            boxShadow: Shadows.level1,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Sobrancelha('Um momento para guardar'),
                    const SizedBox(height: Space.x8),
                    Text(
                      'Os primeiros anos passam rápido',
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: Space.x4),
                    Text(
                      'Ideias simples para criar memórias que ficam.',
                      style: text.bodySmall?.copyWith(
                        color: context.cores.textSecondary,
                      ),
                    ),
                    const SizedBox(height: Space.x16),
                    Row(
                      children: <Widget>[
                        Text(
                          'Ver inspiração',
                          style: text.labelLarge?.copyWith(
                            color: context.cores.primary,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: context.cores.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.x12),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: context.cores.accentSoft,
                  borderRadius: Radii.fieldR,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: context.cores.accent,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A lista "Faz um tempo", com os números encenados.
class _FazUmTempo extends StatelessWidget {
  const _FazUmTempo();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    const List<(EntryType, int)> linhas = <(EntryType, int)>[
      (EntryType.photo, 23),
      (EntryType.video, 4),
      (EntryType.letter, 45),
      (EntryType.growth, 400),
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: Radii.cardR,
        boxShadow: Shadows.level1,
      ),
      padding: const EdgeInsets.fromLTRB(
        Space.x16,
        Space.x16,
        Space.x8,
        Space.x8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Sobrancelha('Faz um tempo'),
          const SizedBox(height: Space.x4),
          for (final (EntryType tipo, int dias) in linhas)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.x8,
                vertical: Space.x12,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tipo.soft(context),
                          borderRadius: Radii.fieldR,
                        ),
                        child: Icon(
                          tipo.icon,
                          size: 20,
                          color: tipo.accent(context),
                        ),
                      ),
                      const SizedBox(width: Space.x12),
                      Expanded(
                        child: Text(
                          tipo.label,
                          style: text.bodyMedium?.copyWith(
                            color: context.cores.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        Fmt.tempoDesde(
                          DateTime(2028, 8, 18).subtract(Duration(days: dias)),
                          agora: DateTime(2028, 8, 18),
                        ),
                        style: text.bodySmall?.copyWith(
                          color: context.cores.textSecondary,
                        ),
                      ),
                      const SizedBox(width: Space.x8),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: context.cores.muted,
                      ),
                    ],
                  ),
                  if (tipo != linhas.last.$1) ...<Widget>[
                    const SizedBox(height: Space.x12),
                    Divider(height: 1, color: context.cores.divider),
                  ],
                ],
              ),
            ),
        ],
      ),
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
