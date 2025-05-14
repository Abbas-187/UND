import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/order.dart';

class CustomerProfileScreen extends StatelessWidget {

  const CustomerProfileScreen(
      {super.key, required this.customer, required this.orders});
  final Customer customer;
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: \t${customer.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: \t${customer.email}'),
            SizedBox(height: 8),
            Text('Phone: \t${customer.phone}'),
            SizedBox(height: 8),
            Text('Address: \t${customer.address}'),
            SizedBox(height: 8),
            Text('Created: \t${customer.createdAt.toLocal()}'),
            if (customer.updatedAt != null)
              Text('Updated: \t${customer.updatedAt!.toLocal()}'),
            SizedBox(height: 16),
            Text('Order History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Expanded(
              child: orders.isEmpty
                  ? Text('No orders found.')
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return ListTile(
                          title: Text('Order #${order.id}'),
                          subtitle: Text(
                              'Date: ${order.date.toLocal()} | Total: ${order.totalAmount} | Status: ${order.status}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
