import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Peso e altura ao longo do tempo, em dois gráficos empilhados.
class GrowthChartScreen extends ConsumerWidget {
  const GrowthChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    // Do mais antigo para o mais novo: um gráfico lê da esquerda para a direita.
    final List<Entry> records = ref
        .watch(growthRecordsProvider)
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.growthChart),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.growth),
        ),
      ),
      body: records.length < 2 || profile == null
          ? const EmptyState(
              icon: Icons.show_chart,
              title: 'Poucos registros',
              message:
                  'A partir de dois registros o gráfico começa a contar a '
                  'história.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: <Widget>[
                _ChartCard(
                  title: S.weightField,
                  unit: 'kg',
                  color: AppColors.growth,
                  profile: profile,
                  records: records,
                  valueOf: (Entry e) => e.growth!.weightGrams / 1000,
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: S.heightField,
                  unit: 'cm',
                  color: AppColors.document,
                  profile: profile,
                  records: records,
                  valueOf: (Entry e) => e.growth!.heightCm,
                ),
              ],
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.unit,
    required this.color,
    required this.profile,
    required this.records,
    required this.valueOf,
  });

  final String title;
  final String unit;
  final Color color;
  final BabyProfile profile;
  final List<Entry> records;
  final double Function(Entry) valueOf;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    // O eixo X é a idade em dias — assim os pontos ficam espaçados no tempo
    // real, e não em intervalos iguais.
    final List<FlSpot> spots = <FlSpot>[
      for (final Entry entry in records)
        FlSpot(profile.ageAt(entry.date).totalDays.toDouble(), valueOf(entry)),
    ];

    final double minY = spots
        .map((FlSpot s) => s.y)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxY = spots
        .map((FlSpot s) => s.y)
        .reduce((double a, double b) => a > b ? a : b);
    final double pad = ((maxY - minY) * 0.15).clamp(0.5, double.infinity);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('$title ($unit)', style: text.titleSmall),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY - pad,
                maxY: maxY + pad,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (double _) =>
                      const FlLine(color: AppColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) => Text(
                        value.toStringAsFixed(unit == 'kg' ? 1 : 0),
                        style: text.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: _bottomInterval(spots),
                      getTitlesWidget: (double value, TitleMeta meta) =>
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _ageLabel(value.round()),
                              style: text.labelSmall,
                            ),
                          ),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touched) =>
                        touched.map((LineBarSpot spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(unit == 'kg' ? 3 : 1)} '
                            '$unit\n${_ageLabel(spot.x.round())}',
                            text.labelSmall!.copyWith(color: Colors.white),
                          );
                        }).toList(),
                  ),
                ),
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: color,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Do nascimento até ${Fmt.date(records.last.date)}',
            style: text.labelSmall,
          ),
        ],
      ),
    );
  }

  /// Cerca de cinco marcações no eixo, independentemente do intervalo.
  static double _bottomInterval(List<FlSpot> spots) {
    final double span = spots.last.x - spots.first.x;
    return span <= 0 ? 1 : (span / 4).ceilToDouble();
  }

  /// Rótulo curto do eixo: `0d`, `3s`, `8m`, `2a`.
  static String _ageLabel(int days) {
    if (days < 14) return '${days}d';
    if (days < 90) return '${days ~/ 7}s';
    if (days < 730) return '${(days / 30.44).round()}m';
    return '${(days / 365.25).round()}a';
  }
}
