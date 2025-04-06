import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesTrendChart extends StatelessWidget {

  const SalesTrendChart({super.key, this.isDetailed = false});
  final bool isDetailed;

  @override
  Widget build(BuildContext context) {
    // Sample data - in a real app, this would come from a provider
    final salesData = [
      FlSpot(0, 3000),
      FlSpot(1, 4200),
      FlSpot(2, 3800),
      FlSpot(3, 5000),
      FlSpot(4, 4500),
      FlSpot(5, 5200),
      FlSpot(6, 6000),
    ];

    return Column(
      children: [
        Text(
          'Sales Trend',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: salesData,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: isDetailed),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
              gridData: FlGridData(
                show: isDetailed,
                horizontalInterval: 1000,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul'
                      ];
                      if (value >= 0 && value < months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[value.toInt()],
                            style: TextStyle(fontSize: isDetailed ? 12 : 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: isDetailed,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final formatter = NumberFormat.compact();
                      return Text(formatter.format(value));
                    },
                    interval: 1000,
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  left: isDetailed
                      ? BorderSide(color: Colors.grey.withOpacity(0.3))
                      : BorderSide.none,
                ),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 7000,
            ),
          ),
        ),
      ],
    );
  }
}
