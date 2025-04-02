import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InventoryDistributionChart extends StatelessWidget {
  const InventoryDistributionChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data - in a real app, this would come from a provider
    final pieData = [
      PieChartSectionData(
        value: 40,
        title: '40%',
        color: Colors.blue,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: 25,
        title: '25%',
        color: Colors.orange,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: 20,
        title: '20%',
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: 15,
        title: '15%',
        color: Colors.purple,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];

    return Column(
      children: [
        Text(
          'Inventory by Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: pieData,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Electronics', Colors.blue),
            const SizedBox(width: 10),
            _buildLegendItem('Clothing', Colors.orange),
            const SizedBox(width: 10),
            _buildLegendItem('Kitchen', Colors.green),
            const SizedBox(width: 10),
            _buildLegendItem('Office', Colors.purple),
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
