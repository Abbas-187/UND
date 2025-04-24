import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';
import 'order_creation_edit_screen.dart';
import '../models/user_role.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/order_filter_bar.dart';

// Provider for the list of orders - this would typically be in the providers directory
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  // This is a placeholder - actual implementation would fetch orders
  // return ref.read(orderRepositoryProvider).getOrders();
  return [];
});

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  String _searchQuery = '';
  OrderStatus? _statusFilter;
  String? _locationFilter;
  bool _isLoading = false;
  Order? _selectedOrder;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Simulated user role & location - in a real app this would come from auth
  final RoleType _userRole = RoleType.manager;
  final String _userLocation = 'Nairobi';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Only managers or admins can see all locations
      final String? locationFilter =
          _userRole.canViewAllOrders ? _locationFilter : _userLocation;

      await ref.read(orderProviderProvider.notifier).fetchOrders(
            location: locationFilter,
            role: _userRole,
          );
    } catch (e) {
      // Error handling would go here
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = null;
      _locationFilter = null;
      _searchController.clear();
    });
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter orders',
            semanticLabel: 'Filter orders',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh orders',
            semanticLabel: 'Refresh orders',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const Divider(height: 1),
          Expanded(
            child: _buildOrderList(),
          ),
        ],
      ),
      floatingActionButton: _userRole.canCreateOrders
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateOrder(),
              tooltip: 'Create Order',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter orders',
            semanticLabel: 'Filter orders',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh orders',
            semanticLabel: 'Refresh orders',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildSearchBar()),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filters'),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          _buildFilterChips(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildOrderList(),
                ),
                if (_selectedOrder != null) ...[
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 4,
                    child: OrderDetailScreen(orderId: _selectedOrder!.id),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _userRole.canCreateOrders
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateOrder(),
              tooltip: 'Create Order',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh orders',
            semanticLabel: 'Refresh orders',
          ),
        ],
      ),
      body: Row(
        children: [
          // Side panel for filters
          SizedBox(
            width: 300,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    const Text('Status',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildStatusFilterDropdown(),
                    const SizedBox(height: 16),
                    if (_userRole.canViewAllOrders) ...[
                      const Text('Location',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildLocationFilterField(),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _loadOrders,
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    if (_userRole.canCreateOrders) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Order'),
                          onPressed: () => _navigateToCreateOrder(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildOrderList(),
                      ),
                      if (_selectedOrder != null) ...[
                        const VerticalDivider(width: 1),
                        Expanded(
                          flex: 4,
                          child: OrderDetailScreen(orderId: _selectedOrder!.id),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterDropdown() {
    return DropdownButtonFormField<OrderStatus>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _statusFilter,
      isExpanded: true,
      hint: const Text('Select status'),
      items: OrderStatus.values.map((status) {
        return DropdownMenuItem<OrderStatus>(
          value: status,
          child: Text(_getStatusDisplayName(status)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _statusFilter = value;
        });
      },
    );
  }

  Widget _buildLocationFilterField() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Enter location',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        setState(() {
          _locationFilter = value.isEmpty ? null : value;
        });
      },
      controller: TextEditingController(text: _locationFilter ?? ''),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search orders...',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                  _loadOrders();
                },
                tooltip: 'Clear search',
                semanticLabel: 'Clear search',
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      onSubmitted: (_) => _loadOrders(),
      semanticsLabel: 'Search orders',
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          if (_statusFilter != null)
            Chip(
              label: Text('Status: ${_getStatusDisplayName(_statusFilter!)}'),
              onDeleted: () {
                setState(() {
                  _statusFilter = null;
                });
                _loadOrders();
              },
              deleteButtonTooltipMessage: 'Remove status filter',
            ),
          if (_locationFilter != null)
            Chip(
              label: Text('Location: $_locationFilter'),
              onDeleted: () {
                setState(() {
                  _locationFilter = null;
                });
                _loadOrders();
              },
              deleteButtonTooltipMessage: 'Remove location filter',
            ),
          if (_statusFilter != null || _locationFilter != null)
            TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear All'),
              onPressed: _clearFilters,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Consumer(
      builder: (context, ref, child) {
        final ordersAsync = ref.watch(orderProviderProvider);

        return ordersAsync.when(
          data: (orders) {
            // Apply client-side filtering based on search query
            final filteredOrders = _filterOrders(orders);

            if (filteredOrders.isEmpty) {
              return const Center(
                child: Text(
                  'No orders found matching your criteria',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadOrders,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredOrders.length,
                  // Use a more optimized approach for large data sets
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Column(
                      children: [
                        _buildOrderListItem(order),
                        if (index < filteredOrders.length - 1)
                          const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  onPressed: _loadOrders,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_searchQuery.isEmpty &&
        _statusFilter == null &&
        _locationFilter == null) {
      return orders;
    }

    return orders.where((order) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!order.id.toLowerCase().contains(query) &&
            !order.customer.toLowerCase().contains(query)) {
          return false;
        }
      }

      if (_statusFilter != null && order.status != _statusFilter) {
        return false;
      }

      if (_locationFilter != null && order.location != _locationFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildOrderListItem(Order order) {
    final isSelected = _selectedOrder?.id == order.id;

    return Material(
      color: isSelected ? Theme.of(context).highlightColor : null,
      child: InkWell(
        onTap: () {
          // For mobile, navigate to detail screen
          if (MediaQuery.of(context).size.width < 600) {
            _navigateToOrderDetail(order.id);
          } else {
            // For tablet/desktop, show in split view
            setState(() {
              _selectedOrder = order;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(
              'Order #${order.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              semanticsLabel: 'Order number ${order.id}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order.customer}',
                    semanticsLabel: 'Customer ${order.customer}'),
                Text('Location: ${order.location}',
                    semanticsLabel: 'Location ${order.location}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Semantics(
                      label: 'Status ${_getStatusDisplayName(order.status)}',
                      child: _buildStatusBadge(order.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${_formatDate(order.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      semanticsLabel:
                          'Created on ${_formatDate(order.createdAt)}',
                    ),
                  ],
                ),
              ],
            ),
            trailing: FittedBox(
              fit: BoxFit.fill,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _navigateToOrderDetail(order.id),
                    tooltip: 'View details',
                    semanticLabel: 'View order details',
                  ),
                  if (_userRole.canCreateOrders)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _navigateToEditOrder(order.id),
                      tooltip: 'Edit order',
                      semanticLabel: 'Edit order',
                    ),
                  if (_userRole.canCancelOrders &&
                      order.status != OrderStatus.cancelled)
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _showCancelOrderDialog(order),
                      tooltip: 'Cancel order',
                      semanticLabel: 'Cancel order',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOrderDetail(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: orderId),
      ),
    );
  }

  void _navigateToCreateOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderCreationEditScreen(),
      ),
    ).then((_) => _loadOrders());
  }

  void _navigateToEditOrder(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderCreationEditScreen(orderId: orderId),
      ),
    ).then((_) => _loadOrders());
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Orders'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<OrderStatus>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: _statusFilter,
                    items: OrderStatus.values.map((status) {
                      return DropdownMenuItem<OrderStatus>(
                        value: status,
                        child: Text(_getStatusDisplayName(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _statusFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_userRole.canViewAllOrders)
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _locationFilter = value.isEmpty ? null : value;
                        });
                      },
                      controller:
                          TextEditingController(text: _locationFilter ?? ''),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadOrders();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCancelOrderDialog(Order order) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to cancel order #${order.id}?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Cancellation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No, Keep It'),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please provide a reason for cancellation')),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  setState(() {
                    _isLoading = true;
                  });

                  await ref.read(orderProviderProvider.notifier).cancelOrder(
                        order.id,
                        reasonController.text.trim(),
                        'currentUserId', // In a real app, this would be the actual user ID
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Order cancelled successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error cancelling order: $e')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.awaitingProcurement:
        return 'Awaiting Procurement';
      case OrderStatus.readyForProduction:
        return 'Ready for Production';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;

    switch (status) {
      case OrderStatus.draft:
        color = Colors.grey;
        break;
      case OrderStatus.pending:
        color = Colors.purple;
        break;
      case OrderStatus.approved:
        color = Colors.teal;
        break;
      case OrderStatus.awaitingProcurement:
        color = Colors.blue;
        break;
      case OrderStatus.readyForProduction:
        color = Colors.amber;
        break;
      case OrderStatus.inProduction:
        color = Colors.orange;
        break;
      case OrderStatus.ready:
        color = Colors.lightGreen;
        break;
      case OrderStatus.completed:
        color = Colors.green;
        break;
      case OrderStatus.delivered:
        color = Colors.green.shade800;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
      case OrderStatus.rejected:
        color = Colors.deepOrange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
