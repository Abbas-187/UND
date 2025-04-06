import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_provider.dart';

class LowStockAlertsBanner extends ConsumerWidget {
  const LowStockAlertsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockItems = ref.watch(filteredInventoryItemsProvider.select(
      (items) => items.whenData(
        (items) => items
            .where((item) => item.quantity <= item.minimumQuantity)
            .toList(),
      ),
    ));

    return lowStockItems.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.red.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Low Stock Alert',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${items.length} ${items.length == 1 ? 'item needs' : 'items need'} restocking:',
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: items.map((item) {
                  return Chip(
                    backgroundColor: Colors.red.shade100,
                    label: Text(
                      '${item.name} (${item.quantity} ${item.unit})',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
