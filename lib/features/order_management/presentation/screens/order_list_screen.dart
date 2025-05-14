import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_provider.dart';
import '../widgets/order_filter_bar.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          const OrderFilterBar(),
          Expanded(
            child: ordersAsync.when(
              data: (orders) => ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text(order.customerName),
                    subtitle: Text(order.date.toLocal().toString()),
                    onTap: () {
                      context.go('/order-management/detail?id=${order.id}');
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/order-management/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
