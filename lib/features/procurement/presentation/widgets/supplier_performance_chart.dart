import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SupplierPerformanceChart extends StatelessWidget {
  const SupplierPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual supplier performance data
    final mockData = [
      _SupplierData(name: 'Supplier A', score: 95),
      _SupplierData(name: 'Supplier B', score: 88),
      _SupplierData(name: 'Supplier C', score: 92),
      _SupplierData(name: 'Supplier D', score: 85),
      _SupplierData(name: 'Supplier E', score: 90),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barGroups: mockData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.score.toDouble(),
                    color: _getColorForScore(data.score),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        mockData[value.toInt()].name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red;
  }
}

class _SupplierData {
  const _SupplierData({
    required this.name,
    required this.score,
  });

  final String name;
  final int score;
}
