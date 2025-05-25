import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';

class SalesTrendChart extends ConsumerWidget {
  const SalesTrendChart({super.key, this.isDetailed = false});

  final bool isDetailed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.read(firestoreServiceProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: firestore.getCollection('salesTrendData'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final salesData = snapshot.data!
            .map((doc) => FlSpot((doc['monthIndex'] as num).toDouble(),
                (doc['value'] as num).toDouble()))
            .toList();
        return Column(
          children: [
            Text(
              isDetailed ? 'Monthly Sales Trend' : 'Sales Trend',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                    drawVerticalLine: isDetailed,
                    horizontalInterval: 10000,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: isDetailed,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final text = '${(value / 1000).toStringAsFixed(0)}K';
                          return Text(
                            text,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        interval: 20000,
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
                          if (value.toInt() >= 0 &&
                              value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        interval: isDetailed ? 1 : 2,
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
                    show: isDetailed,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SalesByCategoryChart extends ConsumerWidget {
  const SalesByCategoryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.read(firestoreServiceProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: firestore.getCollection('salesByCategoryData'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final barGroups = snapshot.data!.map((doc) {
          final index = (doc['categoryIndex'] as num).toInt();
          final toY = (doc['value'] as num).toDouble();
          final color = Color(doc['color'] as int);
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(toY: toY, color: color, width: 12),
          ]);
        }).toList();
        return Column(
          children: [
            const Text(
              'Sales by Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 5000,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final text = '${(value / 1000).toStringAsFixed(0)}K';
                          return Text(
                            text,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        interval: 5000,
                        reservedSize: 40,
                      ),
                    ),
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
                            'Jun'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 22,
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
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Milk', Colors.blue.withOpacity(0.2)),
                const SizedBox(width: 16),
                _buildLegendItem('Yogurt', Colors.green.withOpacity(0.2)),
                const SizedBox(width: 16),
                _buildLegendItem('Cheese', Colors.amber),
                const SizedBox(width: 16),
                _buildLegendItem('Butter', Colors.redAccent.withOpacity(0.3)),
                const SizedBox(width: 16),
                _buildLegendItem('Cream', Colors.purple),
              ],
            ),
          ],
        );
      },
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
            shape: BoxShape.circle,
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
