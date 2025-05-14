/*
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Class that provides mock data for analytics charts and metrics
class MockAnalyticsData {

  factory MockAnalyticsData() {
    return _instance;
  }

  MockAnalyticsData._internal();
  /// Singleton pattern
  static final MockAnalyticsData _instance = MockAnalyticsData._internal();

  /// Generate data for the inventory distribution pie chart
  List<PieChartSectionData> getInventoryDistributionData() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 45,
        title: 'Milk',
        radius: 50,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 25,
        title: 'Yogurt',
        radius: 50,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.amber,
        value: 15,
        title: 'Cheese',
        radius: 50,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.redAccent,
        value: 10,
        title: 'Butter',
        radius: 50,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 5,
        title: 'Cream',
        radius: 50,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }

  /// Generate data for sales trend line chart
  List<FlSpot> getSalesTrendData() {
    // Generate 12 months of sales data with seasonal pattern
    return List.generate(12, (i) {
      // Base value with seasonal pattern
      double value = 50000 + 15000 * math.sin(math.pi * i / 6);

      // Add trend
      value += i * 2000;

      // Add some randomness
      value += (math.Random().nextDouble() * 5000) - 2500;

      return FlSpot(i.toDouble(), value);
    });
  }

  /// Generate data for inventory value chart
  List<FlSpot> getInventoryValueData() {
    // Generate 12 months of inventory value data
    return List.generate(12, (i) {
      // Base value with mild fluctuation
      double value = 120000 + 10000 * math.sin(math.pi * i / 6);

      // Add slight upward trend
      value += i * 1000;

      // Add some randomness
      value += (math.Random().nextDouble() * 6000) - 3000;

      return FlSpot(i.toDouble(), value);
    });
  }

  /// Generate data for top products bar chart
  List<Map<String, dynamic>> getTopProductsData() {
    return [
      {'product': 'Whole Milk (1L)', 'sales': 35420, 'color': Colors.blue},
      {
        'product': 'Low-Fat Milk (1L)',
        'sales': 25840,
        'color': Colors.lightBlue
      },
      {
        'product': 'Strawberry Yogurt (500g)',
        'sales': 18650,
        'color': Colors.green
      },
      {'product': 'Cheese Curd (250g)', 'sales': 12480, 'color': Colors.amber},
      {'product': 'Butter (200g)', 'sales': 8950, 'color': Colors.redAccent},
    ];
  }

  /// Generate data for sales by category chart
  List<BarChartGroupData> getSalesByCategoryData() {
    final categories = ['Milk', 'Yogurt', 'Cheese', 'Butter', 'Cream'];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.redAccent,
      Colors.purple
    ];

    // Generate data for each month and category
    return List.generate(6, (monthIndex) {
      final bars = List.generate(categories.length, (categoryIndex) {
        // Base value with seasonality factor
        double value = 15000 + 5000 * math.sin(math.pi * monthIndex / 3);

        // Adjust for category popularity
        value = value * (1.0 - (categoryIndex * 0.15));

        // Add some randomness
        value += (math.Random().nextDouble() * 2000) - 1000;

        return BarChartRodData(
          toY: value,
          color: colors[categoryIndex],
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        );
      });

      return BarChartGroupData(
        x: monthIndex,
        barRods: bars,
      );
    });
  }

  /// Generate data for stock levels by category
  List<BarChartGroupData> getStockLevelsByCategoryData() {
    final categories = ['Milk', 'Yogurt', 'Cheese', 'Butter', 'Cream'];
    final currentStock = [8500, 5200, 3800, 2100, 1400];
    final safetyStock = [3000, 2000, 1500, 1000, 800];

    return List.generate(categories.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: currentStock[index].toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            rodStackItems: [
              BarChartRodStackItem(
                0,
                safetyStock[index].toDouble(),
                Colors.redAccent.withOpacity(0.3),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// Get summary metrics for the dashboard
  Map<String, dynamic> getSummaryMetrics() {
    return {
      'totalRevenue': 48590,
      'totalOrders': 342,
      'inventoryValue': 125430,
      'lowStockItems': 24,
      'revenueChange': 12.4,
      'ordersChange': 8.2,
      'inventoryChange': 3.1,
      'lowStockChange': -5.3,
    };
  }
}
*/
