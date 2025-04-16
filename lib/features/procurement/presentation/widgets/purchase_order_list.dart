import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseOrderList extends ConsumerWidget {
  const PurchaseOrderList({
    super.key,
    this.limit,
  });

  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual purchase order data
    final mockOrders = List.generate(
      limit ?? 5,
      (index) => {
        'id': 'PO-${index + 1}',
        'supplier': 'Supplier ${index + 1}',
        'date': '2024-04-${index + 1}',
        'status': index % 3 == 0 ? 'Pending' : 'Approved',
        'amount': '\$${(index + 1) * 1000}',
      },
    );

    return Card(
      elevation: 2,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mockOrders.length,
        itemBuilder: (context, index) {
          final order = mockOrders[index];
          return ListTile(
            title: Text('${order['id']} - ${order['supplier']}'),
            subtitle: Text('${order['date']} - ${order['amount']}'),
            trailing: Chip(
              label: Text(
                order['status']!,
                style: TextStyle(
                  color: order['status'] == 'Pending'
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
              backgroundColor: order['status'] == 'Pending'
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
            ),
            onTap: () {
              // TODO: Navigate to purchase order details
            },
          );
        },
      ),
    );
  }
}
