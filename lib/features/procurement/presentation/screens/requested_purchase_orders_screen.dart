import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/in_memory_purchase_requests.dart';
import 'purchase_order/purchase_order_create_screen.dart';

class RequestedPurchaseOrdersScreen extends StatefulWidget {
  const RequestedPurchaseOrdersScreen({super.key});

  @override
  State<RequestedPurchaseOrdersScreen> createState() =>
      _RequestedPurchaseOrdersScreenState();
}

class _RequestedPurchaseOrdersScreenState
    extends State<RequestedPurchaseOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final requests = InMemoryPurchaseRequests.requests.reversed.where((req) {
      final item = req['item'];
      final supplier = (req['supplier'] ?? '').toString().trim().toLowerCase();
      // Check if any PO exists with the same item and supplier
      return !InMemoryPurchaseOrders.orders.any((po) {
        final poItems = po['items'] ?? [];
        final poSupplier = ((po['supplierId'] ?? po['supplier']) ?? '')
            .toString()
            .trim()
            .toLowerCase();
        return poSupplier == supplier &&
            poItems.any((poItem) {
              // Try to match by itemId, fallback to name if missing
              final poItemId = poItem['itemId'] ?? poItem['id'];
              if (item.id != null && poItemId != null) {
                return poItemId.toString() == item.id.toString();
              } else if (item.name != null && poItem['itemName'] != null) {
                return poItem['itemName'].toString().trim().toLowerCase() ==
                    item.name.toString().trim().toLowerCase();
              }
              return false;
            });
      });
    }).toList();
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop && !Navigator.of(context).canPop()) {
          context.go('/procurement/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requested Purchase Orders'),
          backgroundColor: Colors.blue.shade700,
          elevation: 2,
        ),
        body: requests.isEmpty
            ? Center(
                child: Text(
                  'No purchase requests yet.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final item = req['item'];
                  final supplier = req['supplier'] ?? '-';
                  final date = req['timestamp'] as DateTime;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory_2,
                                  color: Colors.blue.shade400),
                              const SizedBox(width: 8),
                              Text(
                                item?.name ?? '-',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Chip(
                                label: Text(supplier.toString()),
                                backgroundColor: Colors.purple.shade50,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _infoChip(
                                  Icons.numbers, 'Qty: ${req['quantity']}'),
                              const SizedBox(width: 12),
                              _infoChip(Icons.security,
                                  'Safety: ${req['safetyStock']}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Justification: ${req['justification']?.toString().isNotEmpty == true ? req['justification'] : '-'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_box),
                              label: const Text('Create PO'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                // Open PO creation screen prefilled with request data
                                final po = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PurchaseOrderCreateScreen(
                                      initialItem: item,
                                      initialQuantity: req['quantity'],
                                      initialSupplier: supplier,
                                    ),
                                  ),
                                );
                                if (po != null) {
                                  setState(() {
                                    InMemoryPurchaseOrders.orders.add(po);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.blueGrey.shade700),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      backgroundColor: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      elevation: 1,
    );
  }
}
