import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_utils.dart';
import '../../domain/models/milk_reception_model.dart';

/// A chart for visualizing milk reception volumes over time
class ReceptionVolumeChart extends StatelessWidget {
  /// Create a reception volume chart
  const ReceptionVolumeChart({
    super.key,
    required this.receptions,
    required this.dateRange,
    this.groupBy = GroupBy.day,
    this.barColor,
    this.gradientColors,
    this.showGrid = true,
    this.animate = true,
    this.height = 250,
    this.enableTooltip = true,
    this.title,
  });

  /// The list of receptions to visualize
  final List<MilkReceptionModel> receptions;

  /// The date range for the chart
  final DateRange dateRange;

  /// How to group the data (day, week, month)
  final GroupBy groupBy;

  /// Optional override for the bar color
  final Color? barColor;

  /// Optional gradient colors for the bars
  final List<Color>? gradientColors;

  /// Whether to show grid lines
  final bool showGrid;

  /// Whether to animate the chart
  final bool animate;

  /// Height of the chart
  final double height;

  /// Whether to enable tooltips when tapping bars
  final bool enableTooltip;

  /// Optional title for the chart
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default colors if not provided
    final defaultColor = theme.colorScheme.primary;
    final defaultGradientColors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary.withValues(alpha: 0.7 * 255),
    ];

    // Prepare data
    final chartData = _prepareChartData();

    if (chartData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No data available for the selected time period'),
        ),
      );
    }

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
              alignment: BarChartAlignment.spaceAround,
              maxY: _calculateMaxY(chartData),
              minY: 0,
              barTouchData: BarTouchData(
                enabled: enableTooltip,
                handleBuiltInTouches: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${chartData[groupIndex].label}\n',
                      theme.textTheme.bodyMedium!,
                      children: [
                        TextSpan(
                          text:
                              '${chartData[groupIndex].value.toStringAsFixed(0)} L',
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: rod.color ?? defaultColor,
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
                      if (value >= 0 && value < chartData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getShortLabel(chartData[value.toInt()].label),
                            style: theme.textTheme.bodySmall,
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
                          value.toInt().toString(),
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
                show: showGrid,
                horizontalInterval: _calculateInterval(chartData),
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
              barGroups: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.value,
                      color: barColor ?? defaultColor,
                      gradient: gradientColors != null
                          ? LinearGradient(
                              colors: gradientColors!,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : LinearGradient(
                              colors: defaultGradientColors,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      width: _calculateBarWidth(chartData.length),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            duration:
                animate ? const Duration(milliseconds: 500) : Duration.zero,
          ),
        ),
      ],
    );
  }

  /// Prepare the data for the chart
  List<ChartDataPoint> _prepareChartData() {
    if (receptions.isEmpty) return [];

    // Filter receptions by date range
    final filteredReceptions = receptions
        .where((reception) =>
            reception.timestamp.isAfter(dateRange.start) &&
            reception.timestamp.isBefore(dateRange.end))
        .toList();

    if (filteredReceptions.isEmpty) return [];

    // Group by time period
    switch (groupBy) {
      case GroupBy.day:
        return _groupByDay(filteredReceptions);
      case GroupBy.week:
        return _groupByWeek(filteredReceptions);
      case GroupBy.month:
        return _groupByMonth(filteredReceptions);
    }
  }

  /// Group receptions by day
  List<ChartDataPoint> _groupByDay(List<MilkReceptionModel> receptions) {
    final groupedData = <String, double>{};

    // Initialize all days in range with zero
    for (final date
        in DateTimeUtils.getDateRange(dateRange.start, dateRange.end)) {
      final key = DateTimeUtils.formatDate(date);
      groupedData[key] = 0;
    }

    // Add reception volumes
    for (final reception in receptions) {
      final key = DateTimeUtils.formatDate(reception.timestamp);
      groupedData[key] = (groupedData[key] ?? 0) + reception.quantityLiters;
    }

    // Convert to list and sort by date
    return groupedData.entries
        .map((entry) => ChartDataPoint(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  /// Group receptions by week
  List<ChartDataPoint> _groupByWeek(List<MilkReceptionModel> receptions) {
    final groupedData = <String, double>{};

    // Process all receptions
    for (final reception in receptions) {
      final weekStart = DateTimeUtils.startOfWeek(reception.timestamp);
      final key = DateTimeUtils.formatDate(weekStart);
      groupedData[key] = (groupedData[key] ?? 0) + reception.quantityLiters;
    }

    // Convert to list and sort by date
    return groupedData.entries
        .map((entry) => ChartDataPoint(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  /// Group receptions by month
  List<ChartDataPoint> _groupByMonth(List<MilkReceptionModel> receptions) {
    final groupedData = <String, double>{};

    // Process all receptions
    for (final reception in receptions) {
      final key =
          '${reception.timestamp.year}-${reception.timestamp.month.toString().padLeft(2, '0')}';
      groupedData[key] = (groupedData[key] ?? 0) + reception.quantityLiters;
    }

    // Convert to list and sort by date
    return groupedData.entries
        .map((entry) => ChartDataPoint(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  /// Calculate the maximum Y value for the chart
  double _calculateMaxY(List<ChartDataPoint> data) {
    final maxValue = data
        .map((e) => e.value)
        .fold<double>(0, (prev, value) => value > prev ? value : prev);
    // Add 10% padding to the top
    return maxValue * 1.1;
  }

  /// Calculate the interval for horizontal grid lines
  double _calculateInterval(List<ChartDataPoint> data) {
    final maxY = _calculateMaxY(data);
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    return 2000;
  }

  /// Calculate the width of bars based on the number of data points
  double _calculateBarWidth(int dataPointCount) {
    if (dataPointCount <= 5) return 25;
    if (dataPointCount <= 10) return 20;
    if (dataPointCount <= 20) return 15;
    if (dataPointCount <= 31) return 10;
    return 8;
  }

  /// Get a shortened label for the x-axis
  String _getShortLabel(String label) {
    switch (groupBy) {
      case GroupBy.day:
        // For day, return only the day part (e.g., 01, 15)
        return label.substring(8, 10);
      case GroupBy.week:
        // For week, return the first 5 chars (e.g., 2023-01)
        return label.substring(5, 10);
      case GroupBy.month:
        // For month, return only the month part (e.g., 01, 12)
        return label.substring(5);
    }
  }
}

/// Data point for chart display
class ChartDataPoint {
  ChartDataPoint(this.label, this.value);
  final String label;
  final double value;
}

/// Enum for grouping chart data
enum GroupBy {
  day,
  week,
  month,
}

/// Class for representing a date range
class DateRange {
  const DateRange({required this.start, required this.end});

  /// Creates a date range for the current month
  factory DateRange.currentMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 1)
          .subtract(const Duration(milliseconds: 1)),
    );
  }

  /// Creates a date range for the last 7 days
  factory DateRange.lastWeek() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
  }

  /// Creates a date range for the last 30 days
  factory DateRange.lastMonth() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }
  final DateTime start;
  final DateTime end;
}
