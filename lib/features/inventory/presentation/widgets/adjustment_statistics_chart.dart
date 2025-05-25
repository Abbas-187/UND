import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/entities/inventory_adjustment.dart';
import '../providers/inventory_adjustment_provider.dart';

class AdjustmentStatisticsChart extends ConsumerWidget {
  const AdjustmentStatisticsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(adjustmentStatisticsProvider);
    final quantityByTypeAsync = ref.watch(quantityByTypeProvider);
    final l10n = AppLocalizations.of(context);

    return statisticsAsync.when(
      data: (statistics) {
        return quantityByTypeAsync.when(
          data: (quantityByType) {
            if (statistics.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildCharts(context, statistics, quantityByType);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, error),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n?.noAdjustmentsFound ?? 'No adjustments found',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, [Object? error]) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            l10n?.errorLoadingData(error?.toString() ?? 'Unknown error') ??
                'Unknown error',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(BuildContext context, Map<AdjustmentType, int> statistics,
      Map<AdjustmentType, double> quantityByType) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        // Count by type chart
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text(
                  l10n?.adjustmentsByType ?? 'Adjustments by type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildPieSections(statistics),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider
        const VerticalDivider(),
        // Quantity by type chart
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text(
                  l10n?.quantityByType ?? 'Quantity by type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _calculateMaxY(quantityByType),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value >= 0 &&
                                value < AdjustmentType.values.length) {
                              final type = AdjustmentType.values[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _getShortName(type),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 9,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: _buildBarGroups(quantityByType),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<AdjustmentType, int> statistics) {
    final List<PieChartSectionData> sections = [];
    statistics.forEach((type, count) {
      sections.add(
        PieChartSectionData(
          color: _getAdjustmentTypeColor(type),
          value: count.toDouble(),
          title: _getShortName(type),
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    return sections;
  }

  List<BarChartGroupData> _buildBarGroups(
      Map<AdjustmentType, double> quantityByType) {
    final List<BarChartGroupData> groups = [];

    AdjustmentType.values.asMap().forEach((index, type) {
      final quantity = quantityByType[type] ?? 0.0;

      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: quantity.abs(),
              color: _getAdjustmentTypeColor(type),
              width: 15,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    });

    return groups;
  }

  double _calculateMaxY(Map<AdjustmentType, double> quantityByType) {
    double maxValue = 0;
    for (final qty in quantityByType.values) {
      final absQty = qty.abs();
      if (absQty > maxValue) {
        maxValue = absQty;
      }
    }
    // Adding 20% to make the chart look nicer
    return maxValue * 1.2;
  }

  String _getShortName(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.manual:
        return 'Man';
      case AdjustmentType.stockCount:
        return 'Cnt';
      case AdjustmentType.expiry:
        return 'Exp';
      case AdjustmentType.damage:
        return 'Dam';
      case AdjustmentType.loss:
        return 'Los';
      case AdjustmentType.return_to_supplier:
        return 'Ret';
      case AdjustmentType.system_correction:
        return 'Sys';
      case AdjustmentType.transfer:
        return 'Trf';
    }
  }

  Color _getAdjustmentTypeColor(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.manual:
        return Colors.blue;
      case AdjustmentType.stockCount:
        return Colors.green;
      case AdjustmentType.expiry:
        return Colors.red;
      case AdjustmentType.damage:
        return Colors.orange;
      case AdjustmentType.loss:
        return Colors.deepOrange;
      case AdjustmentType.return_to_supplier:
        return Colors.purple;
      case AdjustmentType.system_correction:
        return Colors.teal;
      case AdjustmentType.transfer:
        return Colors.indigo;
    }
  }
}
