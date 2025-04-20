import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_order_providers.dart';
import '../screens/purchase_order/purchase_order_detail_screen.dart';

class PurchaseOrderList extends ConsumerStatefulWidget {
  final int? limit;
  const PurchaseOrderList({Key? key, this.limit}) : super(key: key);

  @override
  ConsumerState<PurchaseOrderList> createState() => _PurchaseOrderListState();
}

class _PurchaseOrderListState extends ConsumerState<PurchaseOrderList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingMore = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    ref.read(purchaseOrdersNotifierProvider.notifier).fetchPurchaseOrders(
          searchQuery: _searchQuery,
          refresh: true,
        );
  }

  void _onSortChanged(SortOption? option) {
    if (option != null) {
      ref
          .read(purchaseOrdersNotifierProvider.notifier)
          .updateSortOption(option);
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(purchaseOrdersNotifierProvider.notifier)
        .fetchPurchaseOrders(refresh: true);
  }

  void _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await ref.read(purchaseOrdersNotifierProvider.notifier).loadMore();
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseOrdersNotifierProvider);
    final orders =
        widget.limit != null && state.purchaseOrders.length > widget.limit!
            ? state.purchaseOrders.take(widget.limit!).toList()
            : state.purchaseOrders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by order number or supplier',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<SortOption>(
                value: state.sortBy,
                onChanged: _onSortChanged,
                items: SortOption.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.label),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Builder(
              builder: (context) {
                if (state.isLoading && orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.hasError) {
                  return Center(
                    child: Text(
                        state.errorMessage ?? 'Error loading purchase orders'),
                  );
                }
                if (orders.isEmpty) {
                  return const Center(child: Text('No purchase orders found.'));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!state.isLoading &&
                        state.hasMore &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 100) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    itemCount: orders.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= orders.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final order = orders[index];
                      return ListTile(
                        title: Text('PO# ${order.poNumber}'),
                        subtitle: Text(order.supplierName),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'view') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PurchaseOrderDetailScreen(
                                      orderId: order.id),
                                ),
                              );
                            } else if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Purchase Order'),
                                  content: const Text(
                                      'Are you sure you want to delete this order?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                final deletePurchaseOrderUseCase = ref
                                    .read(deletePurchaseOrderUseCaseProvider);
                                await deletePurchaseOrderUseCase
                                    .execute(order.id);
                                await ref
                                    .read(
                                        purchaseOrdersNotifierProvider.notifier)
                                    .fetchPurchaseOrders(refresh: true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Order deleted')));
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'view', child: Text('View')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PurchaseOrderDetailScreen(orderId: order.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
