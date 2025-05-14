import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InventoryDistributionChart extends StatelessWidget {
  const InventoryDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('inventory_items').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        final Map<String, double> categoryTotals = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] as String? ?? 'Unknown';
          final quantity = (data['quantity'] as num?)?.toDouble() ?? 0.0;
          categoryTotals[category] = (categoryTotals[category] ?? 0) + quantity;
        }
        final sections = categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            color: Colors.primaries[
                categoryTotals.keys.toList().indexOf(entry.key) %
                    Colors.primaries.length],
            value: entry.value,
            title: entry.key,
            radius: 50,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          );
        }).toList();
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
                  sections: sections,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                  centerSpaceColor: Colors.transparent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
