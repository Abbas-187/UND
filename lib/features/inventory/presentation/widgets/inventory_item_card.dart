import 'package:flutter/material.dart';
import '../../domain/entities/inventory_item.dart';
import 'quality_status_chip.dart';

class InventoryItemCard extends StatelessWidget {
  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final InventoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLowStock = item.quantity <= item.lowStockThreshold;
    final bool needsReorder = item.quantity <= item.reorderPoint;
    final bool isExpired = item.isExpired;
    final String? qualityStatus =
        item.additionalAttributes?['qualityStatus'] as String?;
    // Restrict actions if quality is not acceptable
    bool isQualityAcceptable = qualityStatus == null ||
        qualityStatus == 'excellent' ||
        qualityStatus == 'good' ||
        qualityStatus == 'acceptable';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      child: InkWell(
        onTap: isQualityAcceptable ? onTap : null,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${item.sapCode}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.category} > ${item.subCategory}',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (qualityStatus != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: QualityStatusChip(status: qualityStatus),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                              isLowStock, needsReorder, isExpired),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(isLowStock, needsReorder, isExpired),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quantity.toStringAsFixed(2)} ${item.unit}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getQuantityColor(
                              isLowStock, needsReorder, isExpired),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Supplier info
                  if (item.supplier != null && item.supplier!.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.business, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.supplier!,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Location info
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Batch and expiry info if available
              if (item.batchNumber != null || item.expiryDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      if (item.batchNumber != null)
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Batch: ${item.batchNumber}',
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (item.expiryDate != null)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: isExpired ? Colors.red : null,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Exp: ${_formatDate(item.expiryDate!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isExpired ? Colors.red : null,
                                    fontWeight:
                                        isExpired ? FontWeight.bold : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(bool isLowStock, bool needsReorder, bool isExpired) {
    if (isExpired) return 'EXPIRED';
    if (isLowStock) return 'LOW STOCK';
    if (needsReorder) return 'REORDER';
    return 'IN STOCK';
  }

  Color _getStatusColor(bool isLowStock, bool needsReorder, bool isExpired) {
    if (isExpired) return Colors.red;
    if (isLowStock) return Colors.red.shade700;
    if (needsReorder) return Colors.orange;
    return Colors.green;
  }

  Color _getQuantityColor(bool isLowStock, bool needsReorder, bool isExpired) {
    if (isExpired) return Colors.red;
    if (isLowStock) return Colors.red.shade700;
    if (needsReorder) return Colors.orange;
    return Colors.black87;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
