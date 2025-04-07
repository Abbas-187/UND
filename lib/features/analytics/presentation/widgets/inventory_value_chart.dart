import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../analytics/data/mock_analytics_data.dart';

class InventoryValueChart extends StatelessWidget {
  InventoryValueChart({super.key});

  final MockAnalyticsData _mockData = MockAnalyticsData();

  @override
  Widget build(BuildContext context) {
    final valueData = _mockData.getInventoryValueData();

    return Column(
      children: [
        const Text(
          'Inventory Value Over Time',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: valueData,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.2),
                  ),
                ),
              ],
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20000,
                verticalInterval: 1,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final text = (value / 1000).toStringAsFixed(0) + 'K';
                      return Text(
                        text,
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    interval: 30000,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                        return Text(
                          months[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                    interval: 1,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              minX: 0,
              maxX: 11,
              minY: 0,
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

class StockLevelsByCategoryChart extends StatelessWidget {
  StockLevelsByCategoryChart({super.key});

  final MockAnalyticsData _mockData = MockAnalyticsData();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Stock Levels by Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: _mockData.getStockLevelsByCategoryData(),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 2000,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final text = (value / 1000).toStringAsFixed(1) + 'K';
                      return Text(
                        text,
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    interval: 2000,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final categories = [
                        'Milk',
                        'Yogurt',
                        'Cheese',
                        'Butter',
                        'Cream'
                      ];
                      if (value.toInt() >= 0 &&
                          value.toInt() < categories.length) {
                        return Text(
                          categories[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Current Stock', Colors.blue),
            const SizedBox(width: 16),
            _buildLegendItem('Safety Stock', Colors.redAccent.withOpacity(0.3)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
