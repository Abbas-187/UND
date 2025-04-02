import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/providers/production_provider.dart';

class ProductionListScreen extends ConsumerWidget {
  const ProductionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productionOrdersAsync = ref.watch(productionOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, '/factory/production/create'),
          ),
        ],
      ),
      body: productionOrdersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text('No production orders found'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('# ${order.orderNumber} - ${order.productName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${order.quantity} ${order.unit}'),
                      Text(
                          'Due: ${DateFormat('yyyy-MM-dd').format(order.dueDate)}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(order.status),
                    backgroundColor: _getStatusColor(order.status),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/factory/production/detail',
                    arguments: order.id,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading production orders: $error'),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'on_hold':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
