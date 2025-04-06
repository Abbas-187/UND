import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/custom_search_bar.dart';
import '../../../../../common/widgets/date_range_picker.dart';
import '../../../../../common/widgets/order_status_chip.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/providers/order_provider.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Set default date range to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate?.subtract(const Duration(days: 30));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Draft'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipped'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(filteredOrdersProvider(
              status: _getCurrentTabStatus(),
              startDate: _startDate,
              endDate: _endDate,
            )),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    hint: 'Search orders...',
                    onSearch: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DateRangePicker(
                  startDate: _startDate,
                  endDate: _endDate,
                  onDateRangeSelected: (start, end) {
                    setState(() {
                      _startDate = start;
                      _endDate = end;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(null),
                _buildOrdersList('draft'),
                _buildOrdersList('processing'),
                _buildOrdersList('shipped'),
                _buildOrdersList('completed'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/sales/orders/create'),
      ),
    );
  }

  Widget _buildOrdersList(String? statusStr) {
    // Convert string to enum if not null
    OrderStatus? status;
    if (statusStr != null) {
      try {
        status = OrderStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => OrderStatus.draft,
        );
      } catch (_) {
        // Fallback if conversion fails
        status = OrderStatus.draft;
      }
    }

    final orders = ref.watch(filteredOrdersProvider(
      status: status,
      startDate: _startDate,
      endDate: _endDate,
    ));

    return orders.when(
      data: (ordersList) {
        // Filter by search query if provided
        final filteredOrders = _searchQuery.isEmpty
            ? ordersList
            : ordersList.where((order) {
                // Safe access to properties
                final orderNumber = order.toString().contains('orderNumber:')
                    ? order
                        .toString()
                        .split('orderNumber:')[1]
                        .split(',')[0]
                        .trim()
                    : '';
                final customerName = order.toString().contains('customerName:')
                    ? order
                        .toString()
                        .split('customerName:')[1]
                        .split(',')[0]
                        .trim()
                    : '';

                return orderNumber
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    customerName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
              }).toList();

        if (filteredOrders.isEmpty) {
          return const Center(
            child: Text('No orders found', style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.builder(
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            // Safe extraction for display
            final orderNumber = order.toString().contains('orderNumber:')
                ? order.toString().split('orderNumber:')[1].split(',')[0].trim()
                : '';
            final customerName = order.toString().contains('customerName:')
                ? order
                    .toString()
                    .split('customerName:')[1]
                    .split(',')[0]
                    .trim()
                : '';
            final totalAmount = order.toString().contains('totalAmount:')
                ? double.tryParse(order
                        .toString()
                        .split('totalAmount:')[1]
                        .split(',')[0]
                        .trim()) ??
                    0.0
                : 0.0;
            final status = order.toString().contains('status:')
                ? order.toString().split('status:')[1].split(',')[0].trim()
                : 'draft';
            final id = order.toString().contains('id:')
                ? order.toString().split('id:')[1].split(',')[0].trim()
                : '';

            // Convert string status to OrderStatus enum
            OrderStatus orderStatus = OrderStatus.draft;
            try {
              orderStatus = OrderStatus.values.firstWhere(
                  (e) => e.toString().contains(status),
                  orElse: () => OrderStatus.draft);
            } catch (_) {
              // Fallback to draft if conversion fails
              orderStatus = OrderStatus.draft;
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName),
                    const Text(
                      'Order Date: ',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        OrderStatusChip(status: orderStatus),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/sales/orders/details',
                  arguments: id,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  OrderStatus? _getCurrentTabStatus() {
    switch (_tabController.index) {
      case 1:
        return OrderStatus.draft;
      case 2:
        return OrderStatus.processing;
      case 3:
        return OrderStatus.shipped;
      case 4:
        return OrderStatus.completed;
      default:
        return null;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Filter options would go here
            // For example, customer selector, date range picker, etc.
            OverflowBar(
              children: [
                TextButton(
                  child: const Text('CLEAR FILTERS'),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _startDate =
                          DateTime.now().subtract(const Duration(days: 30));
                      _endDate = DateTime.now();
                    });
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: const Text('APPLY'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
