import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/order_provider.dart';
import '../widgets/order_filter_bar.dart';
import '../../../../core/auth/services/auth_service.dart';
import '../../../sales/domain/providers/customer_provider.dart';
import '../../data/models/order_model.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  String _searchQuery = '';
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final ordersAsync = ref.watch(orderProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Not authenticated'));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Orders')),
          body: Column(
            children: [
              OrderFilterBar(
                onSearchChanged: (query) {
                  setState(() => _searchQuery = query);
                },
                onStatusChanged: (status) {
                  setState(() => _statusFilter = status);
                },
              ),
              Expanded(
                child: ordersAsync.when(
                  data: (orders) {
                    var filtered = orders;
                    // Role-based filtering
                    if (user.role.name == 'salesSupervisor') {
                      filtered = filtered
                          .where((o) => o.createdByUserId == user.id)
                          .toList();
                    }
                    if (user.role.name == 'branchManager') {
                      filtered = filtered.where((o) {
                        final customerAsync =
                            ref.watch(customerDetailsProvider(o.customerId));
                        return customerAsync.maybeWhen(
                          data: (customer) =>
                              customer.branches.any((b) => b.id == o.branchId),
                          orElse: () => false,
                        );
                      }).toList();
                      // TODO: Optimize to avoid N+1 fetches if needed
                    }
                    if (_searchQuery.isNotEmpty) {
                      filtered = filtered
                          .where((o) =>
                              o.customerName
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              o.orderNumber
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                          .toList();
                    }
                    if (_statusFilter != null && _statusFilter != 'All') {
                      filtered = filtered
                          .where((o) => (o.status is OrderStatus
                                  ? (o.status as OrderStatus).name
                                  : o.status.toString().toLowerCase())
                              .contains(_statusFilter!.toLowerCase()))
                          .toList();
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return ListTile(
                          title: Text(order.customerName),
                          subtitle: Text(order.orderDate.toLocal().toString()),
                          onTap: () {
                            context
                                .go('/order-management/detail?id=${order.id}');
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading user: $e')),
    );
  }
}
