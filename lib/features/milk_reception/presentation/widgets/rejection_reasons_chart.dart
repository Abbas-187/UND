import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A pie chart for visualizing milk rejection reasons
class RejectionReasonsChart extends StatelessWidget {
  /// Create a rejection reasons chart
  const RejectionReasonsChart({
    super.key,
    required this.rejectionData,
    this.title,
    this.showLabels = true,
    this.showLegend = true,
    this.animate = true,
    this.diameter = 180,
    this.colorScheme,
  });

  /// The rejection data to visualize
  final List<RejectionReasonData> rejectionData;

  /// Optional title for the chart
  final String? title;

  /// Whether to show labels on the chart sections
  final bool showLabels;

  /// Whether to show the legend
  final bool showLegend;

  /// Whether to animate the chart
  final bool animate;

  /// Diameter of the pie chart
  final double diameter;

  /// Custom color scheme for the chart sections
  final List<Color>? colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default colors if no color scheme provided
    final defaultColors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
      theme.colorScheme.errorContainer,
      theme.colorScheme.surfaceContainerHighest,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    // Filter and sort data
    final filteredData = _prepareData();

    if (filteredData.isEmpty) {
      return SizedBox(
        width: diameter,
        height: diameter,
        child: const Center(
          child: Text('No rejection data available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              title!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(
          width: diameter,
          height: diameter,
          child: PieChart(
            PieChartData(
              sections: _createSections(filteredData, defaultColors),
              centerSpaceRadius: diameter * 0.2,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                enabled: true,
              ),
            ),
            swapAnimationDuration:
                animate ? const Duration(milliseconds: 500) : Duration.zero,
          ),
        ),
        if (showLegend)
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: _buildLegend(context, filteredData, defaultColors),
          ),
      ],
    );
  }

  /// Prepare the data for the chart
  List<RejectionReasonData> _prepareData() {
    // Filter out invalid data
    final validData = rejectionData.where((data) => data.count > 0).toList();

    // Sort by count descending
    validData.sort((a, b) => b.count.compareTo(a.count));

    // Calculate percentages
    final total = validData.fold(0, (sum, item) => sum + item.count);

    return validData.map((data) {
      final double percentage = total > 0 ? (data.count / total) * 100 : 0.0;
      return data.copyWith(percentage: percentage);
    }).toList();
  }

  /// Create pie chart sections
  List<PieChartSectionData> _createSections(
      List<RejectionReasonData> data, List<Color> colors) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      // Use a color from the provided scheme or default colors
      final color = index < (colorScheme?.length ?? 0)
          ? colorScheme![index]
          : colors[index % colors.length];

      final double sectionRadius = diameter * 0.4;

      return PieChartSectionData(
        value: item.count.toDouble(),
        title: showLabels ? '${item.percentage.toInt()}%' : '',
        color: color,
        radius: sectionRadius,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  /// Build the legend for the chart
  Widget _buildLegend(BuildContext context, List<RejectionReasonData> data,
      List<Color> colors) {
    final theme = Theme.of(context);

    // Create legend items for each rejection reason
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        // Use a color from the provided scheme or default colors
        final color = index < (colorScheme?.length ?? 0)
            ? colorScheme![index]
            : colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 2, right: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.reason,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${item.count} occurrences (${item.percentage.toStringAsFixed(1)}%)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Data class for rejection reasons
class RejectionReasonData {

  const RejectionReasonData({
    required this.reason,
    required this.count,
    this.percentage = 0,
  });
  final String reason;
  final int count;
  final double percentage;

  /// Create a copy with updated values
  RejectionReasonData copyWith({
    String? reason,
    int? count,
    double? percentage,
  }) {
    return RejectionReasonData(
      reason: reason ?? this.reason,
      count: count ?? this.count,
      percentage: percentage ?? this.percentage,
    );
  }
}
