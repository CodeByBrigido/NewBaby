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
            tooltip: S.edit,
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
                        _Row(label: S.hospital, value: profile.hospital!),
                      ],
                      const Divider(height: 26),
                      // Completa e numa linha só.
                      //
                      // Cheguei a quebrá-la em duas por ter medido errado. A
                      // conta vinha de um teste de widget, e no `flutter test`
                      // a fonte é um substituto em que todo caractere ocupa um
                      // em: `i` e `W` medem igual. Ali a frase parecia pedir
                      // 378 px; com a Plus Jakarta Sans de verdade ela pede
                      // 179, contra os 288 do cartão.
                      _Row(
                        label: S.currentAge,
                        value: profile.ageNow().detailedLabel(
                          alwaysShowDays: true,
                        ),
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
    // Lado a lado não cabia. Os rótulos daqui são longos, e "Data de
    // nascimento" come 114 dos 288 px do cartão: sobram 158 para o valor, e
    // a idade completa pede 179. Empilhado, o valor fica com a largura
    // inteira e tanto a data por extenso quanto a idade cabem numa linha.
    //
    // **Sem `maxLines`, e isso é decisão.** Forçar linha única trocaria a
    // quebra por reticências, e num telefone bem estreito um nome de
    // hospital sairia cortado. Espremer um dado em duas linhas é feio;
    // escondê-lo atrás de "..." é perder a informação que a pessoa veio ler.
    return Column(
      children: <Widget>[
        Text(label, style: text.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: Space.x4),
        Text(value, style: text.titleSmall, textAlign: TextAlign.center),
      ],
    );
  }
}
