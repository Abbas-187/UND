import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/providers/inventory_provider.dart';
import '../providers/inventory_provider.dart';

class InventoryItemDetailsScreen extends ConsumerWidget {
  const InventoryItemDetailsScreen({
    super.key,
    required this.itemId,
  });
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(inventoryRepositoryProvider);
    final itemStream = repository.watchItem(itemId);
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<InventoryItem>(
      stream: itemStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item Details')),
            body: Center(
                child: Text(l10n.errorWithMessage(snapshot.error.toString()))),
          );
        }

        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item Details')),
            body: const Center(child: Text('Item not found')),
          );
        }

        final isLowStock = item.quantity <= item.minimumQuantity;
        final needsReorder = item.quantity <= item.reorderPoint;

        final daysUntilExpiry =
            item.expiryDate?.difference(DateTime.now()).inDays;

        final isExpiringSoon = daysUntilExpiry != null && daysUntilExpiry <= 30;

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.go('/inventory/edit', extra: itemId);
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.confirmDeletion),
                        content: Text(l10n.confirmDeleteItem(item.name)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancelButton),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(l10n.deleteButton),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await repository.deleteItem(itemId);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.deleteItem),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main info card
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Category: ${item.category}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isLowStock
                                    ? Colors.red.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${item.quantity} ${item.unit}',
                                style: TextStyle(
                                  color: isLowStock
                                      ? Colors.red.shade900
                                      : Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _infoRow('Location', item.location),
                        _infoRow('Minimum Quantity',
                            '${item.minimumQuantity} ${item.unit}'),
                        _infoRow('Reorder Point',
                            '${item.reorderPoint} ${item.unit}'),
                        if (item.batchNumber != null)
                          _infoRow('Batch Number', item.batchNumber!),
                        if (item.expiryDate != null)
                          _infoRow(
                            'Expiry Date',
                            _formatDate(item.expiryDate!),
                            isExpiringSoon ? Colors.red : null,
                          ),
                        _infoRow(
                            'Last Updated', _formatDateTime(item.lastUpdated)),
                      ],
                    ),
                  ),
                ),

                // Status flags
                if (isLowStock || needsReorder || isExpiringSoon)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Alerts',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.amber.shade900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (isLowStock)
                            _alertItem(
                              'Low Stock',
                              'Current quantity is below minimum level',
                              Colors.red,
                            ),
                          if (needsReorder)
                            _alertItem(
                              'Reorder Needed',
                              'Current quantity is below reorder point',
                              Colors.orange,
                            ),
                          if (isExpiringSoon)
                            _alertItem(
                              'Expiring Soon',
                              'Item will expire in $daysUntilExpiry days',
                              Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),

                // Additional attributes
                if (item.additionalAttributes != null &&
                    item.additionalAttributes!.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Attributes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ...item.additionalAttributes!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(entry.value.toString()),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                // Action buttons
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _actionButton(
                              context,
                              icon: Icons.add,
                              label: 'Add Stock',
                              onPressed: () => _showAdjustQuantityDialog(
                                  context, ref, item, true),
                            ),
                            _actionButton(
                              context,
                              icon: Icons.remove,
                              label: 'Remove Stock',
                              onPressed: () => _showAdjustQuantityDialog(
                                  context, ref, item, false),
                            ),
                            _actionButton(
                              context,
                              icon: Icons.swap_horiz,
                              label: 'Transfer',
                              onPressed: () {
                                context.go('/inventory/transfer',
                                    extra: itemId);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Movement history
                FutureBuilder<List<dynamic>>(
                  future: repository.getItemMovementHistory(itemId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final movements = snapshot.data ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Movement History',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.go('/inventory/movement-history',
                                        extra: itemId);
                                  },
                                  child: const Text('See All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (movements.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No movement history available'),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    movements.length > 5 ? 5 : movements.length,
                                itemBuilder: (context, index) {
                                  final movement = movements[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      movement['quantity'] > 0
                                          ? Icons.add_circle
                                          : Icons.remove_circle,
                                      color: movement['quantity'] > 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    title: Text(movement['reason'] ??
                                        'Quantity adjustment'),
                                    subtitle: Text(
                                        _formatDateTime(movement['timestamp'])),
                                    trailing: Text(
                                      '${movement['quantity'] > 0 ? '+' : ''}${movement['quantity']} ${item.unit}',
                                      style: TextStyle(
                                        color: movement['quantity'] > 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _alertItem(String title, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Text(message, style: TextStyle(color: color.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdjustQuantityDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
    bool isAddition,
  ) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isAddition ? 'Add to' : 'Remove from'} Inventory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (${item.unit})',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              final reason = reasonController.text;

              if (quantity != null && quantity > 0 && reason.isNotEmpty) {
                final adjustQuantity = ref.read(adjustQuantityUseCaseProvider);

                try {
                  await adjustQuantity.execute(
                    item.id,
                    isAddition ? quantity : -quantity,
                    reason,
                    'SYSTEM', // Replace with actual employee ID from auth if available
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.errorWithMessage(e.toString()))),
                  );
                }
              }
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
