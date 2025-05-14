import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/inventory_movement_model.dart';

class MovementListItem extends StatelessWidget {
  const MovementListItem({
    super.key,
    required this.movement,
    required this.onTap,
  });
  final InventoryMovementModel movement;
  final VoidCallback onTap;

  Color _getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.PENDING:
        return Colors.orange;
      case ApprovalStatus.APPROVED:
        return Colors.green;
      case ApprovalStatus.REJECTED:
        return Colors.red;
      case ApprovalStatus.CANCELLED:
        return Colors.grey;
    }
  }

  IconData _getMovementTypeIcon(InventoryMovementType type) {
    switch (type) {
      case InventoryMovementType.PO_RECEIPT:
        return Icons.input;
      case InventoryMovementType.TRANSFER_IN:
        return Icons.swap_horiz;
      case InventoryMovementType.PRODUCTION_ISSUE:
        return Icons.remove;
      case InventoryMovementType.SALES_RETURN:
        return Icons.replay;
      case InventoryMovementType.ADJUSTMENT_OTHER:
        return Icons.tune;
      // Explicitly handle all other enum values
      case InventoryMovementType.receipt:
      case InventoryMovementType.issue:
      case InventoryMovementType.return_:
      case InventoryMovementType.transfer:
      case InventoryMovementType.adjustment:
      case InventoryMovementType.production:
      case InventoryMovementType.consumption:
      case InventoryMovementType.waste:
      case InventoryMovementType.expiry:
      case InventoryMovementType.qualityStatusChange:
      case InventoryMovementType.repack:
      case InventoryMovementType.sample:
      case InventoryMovementType.salesIssue:
      case InventoryMovementType.purchaseReceipt:
      case InventoryMovementType.productionConsumption:
      case InventoryMovementType.productionOutput:
      case InventoryMovementType.interWarehouseTransfer:
      case InventoryMovementType.intraWarehouseTransfer:
      case InventoryMovementType.scrapDisposal:
      case InventoryMovementType.qualityHold:
      case InventoryMovementType.initialBalanceAdjustment:
      case InventoryMovementType.reservationAdjustment:
      case InventoryMovementType.TRANSFER_OUT:
      case InventoryMovementType.SALE_SHIPMENT:
      case InventoryMovementType.ADJUSTMENT_DAMAGE:
      case InventoryMovementType.ADJUSTMENT_CYCLE_COUNT_GAIN:
      case InventoryMovementType.ADJUSTMENT_CYCLE_COUNT_LOSS:
      case InventoryMovementType.QUALITY_STATUS_UPDATE:
        return Icons.inventory_2;
    }
  }

  String _getTotalItems() {
    return '${movement.items.length} ${movement.items.length == 1 ? 'item' : 'items'}';
  }

  String _formatTimestamp() {
    final formatter = DateFormat('MMM d, yyyy h:mm a');
    return formatter.format(movement.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with type and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getMovementTypeIcon(movement.movementType),
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            movement.movementType.toString().split('.').last,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      movement.approvalStatus.toString().split('.').last,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getStatusColor(movement.approvalStatus),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),

              const Divider(),

              // Movement details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          movement.sourceLocationName != null &&
                                  movement.sourceLocationName!.isNotEmpty
                              ? movement.sourceLocationName!
                              : 'N/A',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'To:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          movement.destinationLocationName != null &&
                                  movement.destinationLocationName!.isNotEmpty
                              ? movement.destinationLocationName!
                              : 'N/A',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          _formatTimestamp(),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Items:',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          _getTotalItems(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // First item preview (if available)
              if (movement.items.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          movement.items.first.productName,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${movement.items.first.quantity} ${movement.items.first.unitOfMeasurement}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Show "more items" indication if there are multiple items
              if (movement.items.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${movement.items.length - 1} more items',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
