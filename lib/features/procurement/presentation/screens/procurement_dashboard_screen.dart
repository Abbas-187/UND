import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/procurement_routes.dart';

/// Dashboard screen for the procurement feature.
class ProcurementDashboardScreen extends StatelessWidget {
  const ProcurementDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Procurement Module',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Purchase Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPurchaseOrderCard(
              context,
              'PO-20250420-ABCD',
              'ABC Supplies Inc.',
              'Pending Approval',
              2800.0,
              'po-123',
            ),
            const SizedBox(height: 16),
            _buildPurchaseOrderCard(
              context,
              'PO-20250419-EFGH',
              'XYZ Manufacturing',
              'Draft',
              4500.0,
              'po-124',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOrderCard(
    BuildContext context,
    String poNumber,
    String supplier,
    String status,
    double amount,
    String poId,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  poNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Supplier: $supplier'),
            Text('Status: $status'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/procurement/po-approval',
                      arguments: {'purchaseOrderId': poId},
                    );
                  },
                  child: const Text('View & Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
