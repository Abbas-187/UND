import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../analytics/data/mock_analytics_data.dart';

class TopProductsChart extends StatelessWidget {
  TopProductsChart({super.key});

  final MockAnalyticsData _mockData = MockAnalyticsData();

  @override
  Widget build(BuildContext context) {
    final topProducts = _mockData.getTopProductsData();

    return Column(
      children: [
        const Text(
          'Top Products by Sales',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 40000,
              barGroups: List.generate(
                topProducts.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: topProducts[index]['sales'].toDouble(),
                      color: topProducts[index]['color'],
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final formattedValue = (value / 1000).toStringAsFixed(0);
                      return Text(
                        '$formattedValue K',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    interval: 10000,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= topProducts.length) {
                        return const SizedBox.shrink();
                      }

                      // Get product name and truncate if needed
                      final name =
                          topProducts[value.toInt()]['product'] as String;
                      final truncatedName = name.length > 12
                          ? name.substring(0, 10) + '...'
                          : name;

                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          truncatedName,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 10000,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
