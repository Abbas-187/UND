import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/inventory_distribution_chart.dart';
import '../widgets/inventory_value_chart.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/top_products_chart.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sales'),
            Tab(text: 'Inventory'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalesTab(),
          _buildInventoryTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 20),
          const Text(
            'Key Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: InventoryDistributionChart(),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SalesTrendChart(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TopProductsChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SalesTrendChart(isDetailed: true),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sales by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SalesByCategoryChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Value Over Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InventoryValueChart(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Stock Levels by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: StockLevelsByCategoryChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          title: 'Total Revenue',
          value: '\$48,590',
          icon: Icons.attach_money,
          trendValue: '+12%',
          trendUp: true,
        ),
        _buildSummaryCard(
          title: 'Total Orders',
          value: '342',
          icon: Icons.shopping_cart,
          trendValue: '+8%',
          trendUp: true,
        ),
        _buildSummaryCard(
          title: 'Inventory Value',
          value: '\$125,430',
          icon: Icons.inventory_2,
          trendValue: '+3%',
          trendUp: true,
        ),
        _buildSummaryCard(
          title: 'Low Stock Items',
          value: '24',
          icon: Icons.warning_amber,
          trendValue: '-5%',
          trendUp: false,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required String trendValue,
    required bool trendUp,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Icon(
                  icon,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: trendUp ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  trendValue,
                  style: TextStyle(
                    color: trendUp ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SalesByCategoryChart extends StatelessWidget {
  const SalesByCategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: 35,
        title: 'Electronics',
        color: Colors.blue,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 25,
        title: 'Clothing',
        color: Colors.orange,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 20,
        title: 'Groceries',
        color: Colors.green,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 20,
        title: 'Other',
        color: Colors.purple,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }
}

class StockLevelsByCategoryChart extends StatelessWidget {
  const StockLevelsByCategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: 80,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: 45,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: 65,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: 35,
            color: Colors.red,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: 90,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text = '';
                switch (value.toInt()) {
                  case 0:
                    text = 'Electronics';
                    break;
                  case 1:
                    text = 'Clothing';
                    break;
                  case 2:
                    text = 'Kitchen';
                    break;
                  case 3:
                    text = 'Food';
                    break;
                  case 4:
                    text = 'Office';
                    break;
                }
                return Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              },
              interval: 20,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3 * 255),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
