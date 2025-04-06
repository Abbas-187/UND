import 'package:flutter/material.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryItemCard extends StatelessWidget {

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onTap,
  });
  final InventoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = item.quantity <= item.minimumQuantity;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.quantity} ${item.unit}',
                      style: TextStyle(
                        color: isLowStock
                            ? Colors.red.shade900
                            : Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${item.category}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Location: ${item.location}',
                style: theme.textTheme.bodyMedium,
              ),
              if (item.expiryDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Expires: ${_formatDate(item.expiryDate!)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _isNearExpiry(item.expiryDate!) ? Colors.red : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isNearExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    return daysUntilExpiry <= 30;
  }
}
