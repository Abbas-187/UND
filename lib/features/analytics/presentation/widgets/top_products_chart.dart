import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TopProductsChart extends StatelessWidget {
  const TopProductsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('sales')
          .orderBy('sales', descending: true)
          .limit(5)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
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
                  maxY: docs.isNotEmpty
                      ? (docs.first['sales'] as num).toDouble() * 1.1
                      : 40000,
                  barGroups: List.generate(
                    docs.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (docs[index]['sales'] as num).toDouble(),
                          color:
                              Colors.primaries[index % Colors.primaries.length],
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
                          final formattedValue =
                              (value / 1000).toStringAsFixed(0);
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
                          if (value < 0 || value >= docs.length) {
                            return const SizedBox.shrink();
                          }
                          final name =
                              docs[value.toInt()]['product'] as String? ?? '';
                          final truncatedName = name.length > 12
                              ? '${name.substring(0, 10)}...'
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
      },
    );
  }
}
