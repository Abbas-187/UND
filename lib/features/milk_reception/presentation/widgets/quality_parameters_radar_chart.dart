import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/milk_quality_test_model.dart';

/// A radar chart for visualizing milk quality parameters
class QualityParametersRadarChart extends StatelessWidget {
  /// Create a quality parameters radar chart
  const QualityParametersRadarChart({
    super.key,
    required this.qualityTest,
    this.backgroundColor,
    this.lineColor,
    this.fillColor,
    this.idealColor,
    this.labelColor,
    this.height = 250,
    this.width = 250,
    this.showIdealValues = true,
    this.animate = true,
    this.title,
  });

  /// The quality test to visualize
  final MilkQualityTestModel qualityTest;

  /// Background color of the chart
  final Color? backgroundColor;

  /// Line color for the chart
  final Color? lineColor;

  /// Fill color for the chart
  final Color? fillColor;

  /// Color for the ideal values line
  final Color? idealColor;

  /// Color for the labels
  final Color? labelColor;

  /// Height of the chart
  final double height;

  /// Width of the chart
  final double width;

  /// Whether to show ideal value range
  final bool showIdealValues;

  /// Whether to animate the chart
  final bool animate;

  /// Optional title for the chart
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default colors
    final defaultLineColor = theme.colorScheme.primary;
    final defaultFillColor = theme.colorScheme.primary.withOpacity(0.3);
    final defaultIdealColor = theme.colorScheme.secondary.withOpacity(0.5);
    final defaultLabelColor = theme.colorScheme.onSurface;
    final defaultBackgroundColor = theme.colorScheme.surface;

    // Prepare radar chart data
    final radarData = _prepareRadarData();

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
          height: height,
          width: width,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                // Actual values
                RadarDataSet(
                  dataEntries: radarData
                      .map((point) => RadarEntry(value: point.normalizedValue))
                      .toList(),
                  borderColor: lineColor ?? defaultLineColor,
                  borderWidth: 2,
                  entryRadius: 3,
                  fillColor: fillColor ?? defaultFillColor,
                ),
                // Ideal values (if enabled)
                if (showIdealValues)
                  RadarDataSet(
                    dataEntries: radarData
                        .map((point) =>
                            RadarEntry(value: point.normalizedIdealValue))
                        .toList(),
                    borderColor: idealColor ?? defaultIdealColor,
                    borderWidth: 1.5,
                    entryRadius: 0,
                    fillColor: Colors.transparent,
                  ),
              ],
              ticksTextStyle: TextStyle(
                color: labelColor ?? defaultLabelColor,
                fontSize: 10,
              ),
              radarBackgroundColor: backgroundColor ?? defaultBackgroundColor,
              tickBorderData: BorderSide(
                color: theme.dividerColor,
                width: 0.5,
              ),
              gridBorderData: BorderSide(
                color: theme.dividerColor,
                width: 0.5,
              ),
              tickCount: 5,
              titleTextStyle: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 12,
              ),
              titlePositionPercentageOffset: 0.2,
              getTitle: (index, angle) {
                if (index < radarData.length) {
                  return RadarChartTitle(
                    text: radarData[index].name,
                    angle: angle,
                  );
                }
                return RadarChartTitle(text: '');
              },
            ),
            swapAnimationDuration:
                animate ? const Duration(milliseconds: 500) : Duration.zero,
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                  context, 'Actual Value', lineColor ?? defaultLineColor),
              const SizedBox(width: 24),
              if (showIdealValues)
                _buildLegendItem(
                    context, 'Ideal Range', idealColor ?? defaultIdealColor),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a legend item
  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Prepare data for the radar chart
  List<RadarDataPoint> _prepareRadarData() {
    // Define the parameters to display and their ideal ranges
    final parameters = [
      RadarParameter(
        name: 'Fat',
        value: qualityTest.fatContent,
        minIdeal: 3.5,
        maxIdeal: 4.5,
        maxScale: 6.0,
      ),
      RadarParameter(
        name: 'Protein',
        value: qualityTest.proteinContent,
        minIdeal: 3.0,
        maxIdeal: 3.5,
        maxScale: 4.0,
      ),
      RadarParameter(
        name: 'Lactose',
        value: qualityTest.lactoseContent,
        minIdeal: 4.2,
        maxIdeal: 5.0,
        maxScale: 5.2,
      ),
      RadarParameter(
        name: 'Solids',
        value: qualityTest.totalSolids,
        minIdeal: 12.0,
        maxIdeal: 13.0,
        maxScale: 14.0,
      ),
      RadarParameter(
        name: 'Acidity',
        value: qualityTest.acidity,
        minIdeal: 6.6,
        maxIdeal: 6.8,
        maxScale: 7.0,
        isInverse: true, // Lower is better for SCC
      ),
      RadarParameter(
        name: 'SCC',
        // Convert to thousands for better scale
        value: qualityTest.somaticCellCount / 1000,
        minIdeal: 0,
        maxIdeal: 200, // 200,000 cells/ml is ideal max
        maxScale: 400, // 400,000 cells/ml is max for chart
        isInverse: true, // Lower is better for SCC
      ),
    ];

    // Calculate normalized values (0.0-1.0) for the radar chart
    return parameters.map((param) {
      // For regular parameters, higher is better
      double normalizedValue;
      double normalizedIdealValue;

      if (param.isInverse) {
        // For inverse parameters, lower is better
        // Invert the scale so lower values appear larger on chart
        normalizedValue = 1.0 - (param.value / param.maxScale).clamp(0.0, 1.0);
        normalizedIdealValue = 1.0 -
            ((param.minIdeal + param.maxIdeal) / 2 / param.maxScale)
                .clamp(0.0, 1.0);
      } else {
        // Normal parameters, higher is better
        normalizedValue = (param.value / param.maxScale).clamp(0.0, 1.0);
        normalizedIdealValue =
            ((param.minIdeal + param.maxIdeal) / 2 / param.maxScale)
                .clamp(0.0, 1.0);
      }

      return RadarDataPoint(
        name: param.name,
        value: param.value,
        normalizedValue: normalizedValue,
        normalizedIdealValue: normalizedIdealValue,
      );
    }).toList();
  }
}

/// A parameter for the radar chart
class RadarParameter {

  const RadarParameter({
    required this.name,
    required this.value,
    required this.minIdeal,
    required this.maxIdeal,
    required this.maxScale,
    this.isInverse = false,
  });
  final String name;
  final double value;
  final double minIdeal;
  final double maxIdeal;
  final double maxScale;
  final bool isInverse;
}

/// A data point for the radar chart
class RadarDataPoint {

  const RadarDataPoint({
    required this.name,
    required this.value,
    required this.normalizedValue,
    required this.normalizedIdealValue,
  });
  final String name;
  final double value;
  final double normalizedValue;
  final double normalizedIdealValue;
}
