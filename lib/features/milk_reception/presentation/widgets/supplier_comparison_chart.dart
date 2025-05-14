import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A chart for comparing multiple suppliers' milk quality and quantity metrics
class SupplierComparisonChart extends StatelessWidget {
  /// Create a supplier comparison chart
  const SupplierComparisonChart({
    super.key,
    required this.supplierData,
    required this.metric,
    this.title,
    this.height = 300,
    this.barWidth = 18,
    this.animate = true,
    this.showAverage = true,
    this.gradientColors,
    this.sortDescending = true,
    this.maxSuppliersToShow = 10,
  });

  /// The supplier data to visualize
  final List<SupplierMetricData> supplierData;

  /// The metric being compared
  final SupplierMetric metric;

  /// Optional title for the chart
  final String? title;

  /// Height of the chart
  final double height;

  /// Width of each bar
  final double barWidth;

  /// Whether to animate the chart
  final bool animate;

  /// Whether to show the average line
  final bool showAverage;

  /// Optional gradient colors for the bars
  final List<Color>? gradientColors;

  /// Whether to sort suppliers in descending order by the metric
  final bool sortDescending;

  /// Maximum number of suppliers to show
  final int maxSuppliersToShow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default colors
    final defaultGradientColors = [
      theme.colorScheme.primary,
      theme.colorScheme.primary.withValues(alpha: 0.6 * 255),
    ];

    // Sort and limit suppliers
    final sortedData = _getSortedData();

    if (sortedData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No data available for comparison'),
        ),
      );
    }

    // Calculate average for reference line
    final average = sortedData.isEmpty
        ? 0.0
        : sortedData.map((e) => e.value).reduce((a, b) => a + b) /
            sortedData.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              title!,
              style: theme.textTheme.titleMedium,
            ),
          ),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: _calculateMaxY(sortedData),
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, response) {},
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${sortedData[groupIndex].supplierName}\n',
                      theme.textTheme.bodyMedium!,
                      children: [
                        TextSpan(
                          text:
                              '${_formatValue(sortedData[groupIndex].value)} ${_getMetricUnit()}',
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < sortedData.length) {
                        // Show label with supplier initials
                        final initials = _getInitials(
                            sortedData[value.toInt()].supplierName);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            initials,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox();

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          _formatAxisValue(value),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: _calculateInterval(sortedData),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                  left: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              barGroups: sortedData.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.value,
                      gradient: LinearGradient(
                        colors: gradientColors ?? defaultGradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      width: barWidth,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              extraLinesData: showAverage
                  ? ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: average,
                          color: theme.colorScheme.secondary,
                          strokeWidth: 1.5,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 8, bottom: 4),
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                            labelResolver: (line) =>
                                'Avg: ${_formatValue(average)} ${_getMetricUnit()}',
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            swapAnimationDuration:
                animate ? const Duration(milliseconds: 500) : Duration.zero,
          ),
        ),
      ],
    );
  }

  /// Get the sorted and limited data for display
  List<SupplierMetricData> _getSortedData() {
    if (supplierData.isEmpty) return [];

    // Filter out suppliers with no data
    final validData = supplierData.where((data) => data.value >= 0).toList();

    // Sort the data
    if (sortDescending) {
      validData.sort((a, b) => b.value.compareTo(a.value));
    } else {
      validData.sort((a, b) => a.value.compareTo(b.value));
    }

    // Limit to max suppliers
    return validData.take(maxSuppliersToShow).toList();
  }

  /// Calculate the maximum Y value for the chart
  double _calculateMaxY(List<SupplierMetricData> data) {
    if (data.isEmpty) return 100;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    // Add 10% padding to the top
    return maxValue * 1.1;
  }

  /// Calculate the interval for horizontal grid lines
  double _calculateInterval(List<SupplierMetricData> data) {
    final maxY = _calculateMaxY(data);

    if (maxY <= 10) return 1;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    return 500;
  }

  /// Get initials from a supplier name
  String _getInitials(String supplierName) {
    if (supplierName.isEmpty) return '';

    final words = supplierName.trim().split(' ');
    if (words.length == 1) {
      return words[0].length > 2
          ? words[0].substring(0, 2).toUpperCase()
          : words[0].toUpperCase();
    }

    return words.length >= 2
        ? (words[0][0] + words[1][0]).toUpperCase()
        : words[0].substring(0, min(2, words[0].length)).toUpperCase();
  }

  /// Format value based on metric type
  String _formatValue(double value) {
    switch (metric) {
      case SupplierMetric.volume:
      case SupplierMetric.averageVolume:
        return value.toStringAsFixed(0);
      case SupplierMetric.fatContent:
      case SupplierMetric.proteinContent:
      case SupplierMetric.qualityScore:
        return value.toStringAsFixed(1);
      case SupplierMetric.rejectionRate:
        return value.toStringAsFixed(1);
    }
  }

  /// Format axis values
  String _formatAxisValue(double value) {
    switch (metric) {
      case SupplierMetric.rejectionRate:
        return '${value.toInt()}%';
      case SupplierMetric.fatContent:
      case SupplierMetric.proteinContent:
        return value.toStringAsFixed(1);
      case SupplierMetric.volume:
      case SupplierMetric.averageVolume:
      case SupplierMetric.qualityScore:
        return value.toInt().toString();
    }
  }

  /// Get the unit for the metric
  String _getMetricUnit() {
    switch (metric) {
      case SupplierMetric.volume:
      case SupplierMetric.averageVolume:
        return 'L';
      case SupplierMetric.fatContent:
      case SupplierMetric.proteinContent:
        return '%';
      case SupplierMetric.rejectionRate:
        return '%';
      case SupplierMetric.qualityScore:
        return 'pts';
    }
  }

  /// Get minimum between two values
  int min(int a, int b) => a < b ? a : b;
}

/// Enum representing different supplier metrics
enum SupplierMetric {
  volume,
  averageVolume,
  fatContent,
  proteinContent,
  qualityScore,
  rejectionRate,
}

/// Data class for supplier metrics
class SupplierMetricData {
  const SupplierMetricData({
    required this.supplierId,
    required this.supplierName,
    required this.value,
  });
  final String supplierId;
  final String supplierName;
  final double value;
}
