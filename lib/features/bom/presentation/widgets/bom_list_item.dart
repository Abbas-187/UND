import 'package:flutter/material.dart';

import '../../domain/entities/bill_of_materials.dart';
import '../../../shared/widgets/status_indicator.dart';

class BomListItem extends StatelessWidget {
  const BomListItem({
    super.key,
    required this.bom,
    required this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  final BillOfMaterials bom;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bom.bomCode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bom.bomName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      StatusIndicator(
                        isActive: bom.status == BomStatus.active,
                        size: 10,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bom.status.name.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(bom.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Information
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bom.productCode} - ${bom.productName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // BOM Details Row
              Row(
                children: [
                  _buildDetailChip(
                    icon: Icons.category,
                    label: bom.bomType.name.toUpperCase(),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    icon: Icons.numbers,
                    label: 'v${bom.version}',
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    icon: Icons.list,
                    label: '${bom.items.length} items',
                    theme: theme,
                  ),
                  const Spacer(),
                  Text(
                    '\$${bom.totalCost.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Actions Row
              Row(
                children: [
                  Text(
                    'Updated: ${_formatDate(bom.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit BOM',
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onDuplicate != null)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: onDuplicate,
                      tooltip: 'Duplicate BOM',
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon:
                          Icon(Icons.delete, size: 20, color: Colors.red[400]),
                      onPressed: onDelete,
                      tooltip: 'Delete BOM',
                      visualDensity: VisualDensity.compact,
                    ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BomStatus status) {
    switch (status) {
      case BomStatus.active:
        return Colors.green;
      case BomStatus.approved:
        return Colors.blue;
      case BomStatus.draft:
        return Colors.orange;
      case BomStatus.inactive:
        return Colors.grey;
      case BomStatus.obsolete:
        return Colors.red;
      case BomStatus.underReview:
        return Colors.purple;
      case BomStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
