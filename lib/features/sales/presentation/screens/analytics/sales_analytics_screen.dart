import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesAnalyticsScreen extends ConsumerStatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  ConsumerState<SalesAnalyticsScreen> createState() =>
      _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends ConsumerState<SalesAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Sales Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'By Product'),
            Tab(text: 'By Customer'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildByProductTab(),
          _buildByCustomerTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    // TODO: Replace with real data
    final totalSales = 125000.0;
    final totalOrders = 320;
    final avgOrderValue = 390.0;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricCard(
                  'Total Sales',
                  'ر.س${totalSales.toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green),
              _buildMetricCard('Orders', totalOrders.toString(),
                  Icons.shopping_cart, Colors.blue),
              _buildMetricCard(
                  'Avg Order',
                  'ر.س${avgOrderValue.toStringAsFixed(0)}',
                  Icons.bar_chart,
                  Colors.orange),
            ],
          ),
          const SizedBox(height: 32),
          Text('Recent Sales Trend',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildSalesTrendChart(
              [10000, 12000, 15000, 18000, 20000, 22000, 25000]),
        ],
      ),
    );
  }

  Widget _buildByProductTab() {
    // TODO: Replace with real data
    final products = [
      {'name': 'Milk', 'sales': 40000.0},
      {'name': 'Cheese', 'sales': 30000.0},
      {'name': 'Yogurt', 'sales': 20000.0},
    ];
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Sales by Product',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ...products.map((p) => ListTile(
              leading: const Icon(Icons.local_offer),
              title: Text(p['name'] as String),
              trailing: Text('ر.س${(p['sales'] as double).toStringAsFixed(0)}'),
            )),
      ],
    );
  }

  Widget _buildByCustomerTab() {
    // TODO: Replace with real data
    final customers = [
      {'name': 'Acme Corp', 'sales': 25000.0},
      {'name': 'DairyMart', 'sales': 18000.0},
      {'name': 'FreshFoods', 'sales': 15000.0},
    ];
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Sales by Customer',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ...customers.map((c) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(c['name'] as String),
              trailing: Text('ر.س${(c['sales'] as double).toStringAsFixed(0)}'),
            )),
      ],
    );
  }

  Widget _buildTrendsTab() {
    // TODO: Replace with real data
    final salesTrend = [10000, 12000, 15000, 18000, 20000, 22000, 25000];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales Trends', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildSalesTrendChart(salesTrend),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTrendChart(List<int> sales) {
    return Card(
      elevation: 2,
      child: SizedBox(
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sales
                .map((value) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: value / 300,
                        color: Colors.blueAccent,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
