import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/gendered.dart';
import '../../core/router/app_router.dart';
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
        title: Text(G.of(profile?.gender).babyInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label, style: text.bodySmall)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(value, style: text.titleSmall, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
