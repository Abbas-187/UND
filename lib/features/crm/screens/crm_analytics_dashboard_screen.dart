import 'package:flutter/material.dart';

class CrmAnalyticsDashboardScreen extends StatelessWidget {

  const CrmAnalyticsDashboardScreen({
    super.key,
    required this.totalCustomers,
    required this.newCustomersThisMonth,
    required this.totalInteractions,
    required this.interactionsThisMonth,
    required this.totalOrders,
    required this.ordersThisMonth,
  });
  final int totalCustomers;
  final int newCustomersThisMonth;
  final int totalInteractions;
  final int interactionsThisMonth;
  final int totalOrders;
  final int ordersThisMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRM Analytics Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Customers: $totalCustomers',
                style: TextStyle(fontSize: 18)),
            Text('New Customers This Month: $newCustomersThisMonth'),
            SizedBox(height: 16),
            Text('Total Interactions: $totalInteractions',
                style: TextStyle(fontSize: 18)),
            Text('Interactions This Month: $interactionsThisMonth'),
            SizedBox(height: 16),
            Text('Total Orders: $totalOrders', style: TextStyle(fontSize: 18)),
            Text('Orders This Month: $ordersThisMonth'),
            // Add more analytics widgets/graphs as needed
          ],
        ),
      ),
    );
  }
}
