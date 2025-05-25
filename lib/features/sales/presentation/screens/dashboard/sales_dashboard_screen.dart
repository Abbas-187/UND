import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesDashboardScreen extends ConsumerWidget {
  const SalesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with real providers
    final totalSales = 125000.0;
    final totalOrders = 320;
    final topProducts = [
      {'name': 'Milk', 'sales': 40000.0},
      {'name': 'Cheese', 'sales': 30000.0},
      {'name': 'Yogurt', 'sales': 20000.0},
    ];
    final topCustomers = [
      {'name': 'Acme Corp', 'sales': 25000.0},
      {'name': 'DairyMart', 'sales': 18000.0},
      {'name': 'FreshFoods', 'sales': 15000.0},
    ];
    final salesTrend = [10000, 12000, 15000, 18000, 20000, 22000, 25000];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Analytics',
            onPressed: () => Navigator.pushNamed(context, '/sales/analytics'),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              ],
            ),
            const SizedBox(height: 24),
            Text('Sales Trend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildSalesTrendChart(salesTrend),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTopList('Top Products', topProducts)),
                const SizedBox(width: 16),
                Expanded(child: _buildTopList('Top Customers', topCustomers)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Create Order'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/sales/orders/create'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('View Orders'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/sales/orders'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analytics'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/sales/analytics'),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildTopList(String title, List<Map<String, dynamic>> items) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['name']),
                  trailing: Text('ر.س${item['sales'].toStringAsFixed(0)}'),
                )),
          ],
        ),
      ),
    );
  }
}
