import 'package:flutter/material.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';

/// Mobile-optimized floating action button with label
class MobileFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const MobileFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      elevation: 4,
    );
  }
}

/// Mobile-optimized BOM card with swipe actions
class MobileBomCard extends StatelessWidget {
  final BillOfMaterials bom;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const MobileBomCard({
    super.key,
    required this.bom,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(bom.id),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bom.bomCode,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bom.bomName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context, bom.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bom.productName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '\$${bom.totalCost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      _formatBomType(bom.bomType),
                      Icons.category,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      'v${bom.version}',
                      Icons.tag,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showActionMenu(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BomStatus status) {
    Color color;
    switch (status) {
      case BomStatus.active:
        color = Colors.green;
        break;
      case BomStatus.draft:
        color = Colors.orange;
        break;
      case BomStatus.inactive:
        color = Colors.grey;
        break;
      case BomStatus.obsolete:
        color = Colors.red;
        break;
      case BomStatus.underReview:
        color = Colors.blue;
        break;
      case BomStatus.approved:
        color = Colors.green;
        break;
      case BomStatus.rejected:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _formatBomStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                onDuplicate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete BOM'),
            content: Text('Are you sure you want to delete ${bom.bomCode}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatBomType(BomType type) {
    switch (type) {
      case BomType.production:
        return 'Production';
      case BomType.engineering:
        return 'Engineering';
      case BomType.sales:
        return 'Sales';
      case BomType.costing:
        return 'Costing';
      case BomType.planning:
        return 'Planning';
    }
  }

  String _formatBomStatus(BomStatus status) {
    switch (status) {
      case BomStatus.draft:
        return 'Draft';
      case BomStatus.active:
        return 'Active';
      case BomStatus.inactive:
        return 'Inactive';
      case BomStatus.obsolete:
        return 'Obsolete';
      case BomStatus.underReview:
        return 'Under Review';
      case BomStatus.approved:
        return 'Approved';
      case BomStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Mobile-optimized BOM item card
class MobileBomItemCard extends StatelessWidget {
  final BomItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobileBomItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getItemTypeColor(item.itemType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getItemTypeIcon(item.itemType),
                      color: _getItemTypeColor(item.itemType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemCode,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          item.itemDescription,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, size: 16),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading:
                              Icon(Icons.delete, size: 16, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDetailChip(
                    context,
                    '${item.quantity} ${item.unit}',
                    Icons.straighten,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    context,
                    '\$${item.costPerUnit.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                  const Spacer(),
                  Text(
                    '\$${item.totalCost.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getItemTypeColor(BomItemType type) {
    switch (type) {
      case BomItemType.rawMaterial:
        return Colors.green;
      case BomItemType.semiFinished:
        return Colors.orange;
      case BomItemType.finishedGood:
        return Colors.blue;
      case BomItemType.packaging:
        return Colors.purple;
      case BomItemType.consumable:
        return Colors.grey;
      case BomItemType.byProduct:
        return Colors.brown;
      case BomItemType.coProduct:
        return Colors.teal;
    }
  }

  IconData _getItemTypeIcon(BomItemType type) {
    switch (type) {
      case BomItemType.rawMaterial:
        return Icons.grass;
      case BomItemType.semiFinished:
        return Icons.build_circle;
      case BomItemType.finishedGood:
        return Icons.check_circle;
      case BomItemType.packaging:
        return Icons.inventory_2;
      case BomItemType.consumable:
        return Icons.local_fire_department;
      case BomItemType.byProduct:
        return Icons.recycling;
      case BomItemType.coProduct:
        return Icons.merge_type;
    }
  }
}

/// Mobile-optimized expandable card
class MobileExpandableCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isExpanded;
  final VoidCallback onToggle;

  const MobileExpandableCard({
    super.key,
    required this.title,
    required this.child,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// Mobile item detail bottom sheet
class MobileItemDetailSheet extends StatelessWidget {
  final BomItem item;

  const MobileItemDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Item Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Basic Information', [
                        _buildDetailRow('Item Code', item.itemCode),
                        _buildDetailRow('Item Name', item.itemName),
                        _buildDetailRow('Description', item.itemDescription),
                        _buildDetailRow('Type', _formatItemType(item.itemType)),
                        _buildDetailRow(
                            'Status', _formatItemStatus(item.status)),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Quantity & Cost', [
                        _buildDetailRow(
                            'Quantity', '${item.quantity} ${item.unit}'),
                        _buildDetailRow('Unit Cost',
                            '\$${item.costPerUnit.toStringAsFixed(2)}'),
                        _buildDetailRow('Total Cost',
                            '\$${item.totalCost.toStringAsFixed(2)}'),
                        _buildDetailRow('Consumption Type',
                            _formatConsumptionType(item.consumptionType)),
                        _buildDetailRow('Sequence', '${item.sequenceNumber}'),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Additional Information', [
                        _buildDetailRow(
                            'Wastage %', '${item.wastagePercentage}%'),
                        _buildDetailRow('Yield %', '${item.yieldPercentage}%'),
                        if (item.supplierCode != null)
                          _buildDetailRow('Supplier', item.supplierCode!),
                        if (item.batchNumber != null)
                          _buildDetailRow('Batch Number', item.batchNumber!),
                        if (item.qualityGrade != null)
                          _buildDetailRow('Quality Grade', item.qualityGrade!),
                        if (item.storageLocation != null)
                          _buildDetailRow(
                              'Storage Location', item.storageLocation!),
                      ]),
                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('Notes', [
                          Text(
                            item.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatItemType(BomItemType type) {
    switch (type) {
      case BomItemType.rawMaterial:
        return 'Raw Material';
      case BomItemType.semiFinished:
        return 'Semi-Finished';
      case BomItemType.finishedGood:
        return 'Finished Good';
      case BomItemType.packaging:
        return 'Packaging';
      case BomItemType.consumable:
        return 'Consumable';
      case BomItemType.byProduct:
        return 'By-Product';
      case BomItemType.coProduct:
        return 'Co-Product';
    }
  }

  String _formatItemStatus(BomItemStatus status) {
    switch (status) {
      case BomItemStatus.active:
        return 'Active';
      case BomItemStatus.inactive:
        return 'Inactive';
      case BomItemStatus.obsolete:
        return 'Obsolete';
      case BomItemStatus.pending:
        return 'Pending';
      case BomItemStatus.approved:
        return 'Approved';
      case BomItemStatus.rejected:
        return 'Rejected';
    }
  }

  String _formatConsumptionType(ConsumptionType type) {
    switch (type) {
      case ConsumptionType.fixed:
        return 'Fixed';
      case ConsumptionType.variable:
        return 'Variable';
      case ConsumptionType.optional:
        return 'Optional';
      case ConsumptionType.alternative:
        return 'Alternative';
    }
  }
}
