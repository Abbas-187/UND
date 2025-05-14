import 'package:flutter/material.dart';
import '../models/crm_report.dart';

class CrmReportScreen extends StatelessWidget {

  const CrmReportScreen({super.key, required this.report});
  final CrmReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRM Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Customers: ${report.totalCustomers}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Total Interactions: ${report.totalInteractions}'),
            SizedBox(height: 8),
            Text('Total Orders: ${report.totalOrders}'),
          ],
        ),
      ),
    );
  }
}
