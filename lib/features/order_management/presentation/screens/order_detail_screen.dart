import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/order_model.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/providers/order_usecase_providers.dart';
import '../widgets/backorder_management_widget.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late Future<OrderEntity> _orderFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = GoRouterState.of(context).uri.queryParameters['id'] ?? '';
    final usecase = ref.read(getOrderByIdUseCaseProvider);
    _orderFuture = usecase.execute(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder<OrderEntity>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final order = snapshot.data!;
          final orderModel = OrderModel.fromEntity(order);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: \\${order.id}'),
                Text('Customer: \\${order.customerName}'),
                Text('Date: \\${order.orderDate.toLocal()}'),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      ...order.items.map((item) => Text(item.toString())),
                      const SizedBox(height: 16),
                      BackorderManagementWidget(order: orderModel),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.push(
                        '/order-management/create',
                        extra: order,
                      ),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        final cancelUsecase =
                            ref.read(cancelOrderUseCaseProvider);
                        await cancelUsecase.execute(order.id);
                        context.go('/order-management');
                      },
                      child: const Text('Cancel Order'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: () {
                        context.push(
                          '/order-management/discussion?id=${order.id}',
                        );
                      },
                      child: const Text('Discussion'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      onPressed: () {
                        context.push(
                          '/order-management/audit-trail?id=${order.id}',
                        );
                      },
                      child: const Text('Audit Trail'),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
