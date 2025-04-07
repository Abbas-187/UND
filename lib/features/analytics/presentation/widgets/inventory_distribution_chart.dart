import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../analytics/data/mock_analytics_data.dart';

class InventoryDistributionChart extends StatelessWidget {
  InventoryDistributionChart({super.key});

  final MockAnalyticsData _mockData = MockAnalyticsData();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Inventory by Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: _mockData.getInventoryDistributionData(),
              centerSpaceRadius: 30,
              sectionsSpace: 2,
              centerSpaceColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
