import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Os dados do cadastro, só para consulta.
class BabyInfoScreen extends ConsumerWidget {
  const BabyInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => context.push(Routes.babyInfoEdit),
          ),
        ],
        title: Text(Copy.of(profile).babyInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x8,
                Space.x16,
                Space.x32,
              ),
              children: <Widget>[
                SoftCard(
                  child: Column(
                    children: <Widget>[
                      _Row(label: S.fullName, value: profile.name),
                      const Divider(height: 26),
                      _Row(
                        label: S.birthDate,
                        value: Fmt.longDate(profile.birth),
                      ),
                      const Divider(height: 26),
                      _Row(label: S.birthTime, value: Fmt.time(profile.birth)),
                      if (profile.birthWeightGrams != null) ...<Widget>[
                        const Divider(height: 26),
                        _Row(
                          label: S.birthWeight,
                          value: Fmt.weight(profile.birthWeightGrams!),
                        ),
                      ],
                      if (profile.birthHeightCm != null) ...<Widget>[
                        const Divider(height: 26),
                        _Row(
                          label: S.birthHeight,
                          value: Fmt.height(profile.birthHeightCm!),
                        ),
                      ],
                      if (profile.hospital != null) ...<Widget>[
                        const Divider(height: 26),
                        _Row(label: 'Hospital', value: profile.hospital!),
                      ],
                      const Divider(height: 26),
                      // Com os dias, quebrada onde a frase permite.
                      //
                      // Numa linha só ela não cabe: `20 anos, 11 meses e 30
                      // dias` pede 378 px e o cartão tem 288. Encolher a
                      // fonte até caber daria 10,7 px, abaixo dos 12 px que
                      // são o menor tamanho da escala, e naquele tamanho o
                      // texto deixa de ser legível de braço estendido.
                      //
                      // Então a idade quebra em duas linhas, mas no lugar
                      // certo: "20 anos, 11 meses" em cima e "e 2 dias"
                      // embaixo, as duas em tamanho normal. É a mesma quebra
                      // do painel da tela inicial.
                      _Row(
                        label: S.currentAge,
                        value: profile
                            .ageNow()
                            .detailedLines(alwaysShowDays: true)
                            .join('\n'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    // Rótulo em cima, valor embaixo, os dois centralizados.
    //
    // Antes era rótulo à esquerda e valor à direita, na mesma linha, e não
    // cabia: os rótulos daqui são longos ("Data de nascimento", "Altura ao
    // nascer") e ocupavam 216 dos 288 px do cartão, deixando menos de
    // sessenta para o valor. Até `10/04/2026` quebrava em duas linhas.
    //
    // Empilhado, o valor tem a largura inteira do cartão, e a data por
    // extenso e a idade cabem numa linha num telefone comum.
    //
    // **Sem `maxLines`, e isso é decisão.** Forçar linha única aqui trocaria
    // a quebra por reticências, e num telefone estreito de 320 dp a data
    // sairia cortada. Espremer um dado em duas linhas é feio; escondê-lo
    // atrás de "..." é perder a informação que a pessoa veio ler.
    return Column(
      children: <Widget>[
        Text(label, style: text.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: Space.x4),
        Text(value, style: text.titleSmall, textAlign: TextAlign.center),
      ],
    );
  }
}
