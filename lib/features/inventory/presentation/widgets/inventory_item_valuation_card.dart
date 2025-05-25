import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cost_layer.dart' as inventory;
import '../../domain/usecases/generate_inventory_valuation_report_usecase.dart';
import 'cost_layer_detail_card.dart';

/// A card widget displaying valuation information for a single inventory item
class InventoryItemValuationCard extends StatelessWidget {
  const InventoryItemValuationCard({
    super.key,
    required this.entry,
    this.showCostLayers = true,
  });
  final InventoryValuationEntry entry;
  final bool showCostLayers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,##0.00');
    final quantityFormat = NumberFormat('#,##0.###');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemHeader(theme, numberFormat),
          const Divider(height: 1),
          _buildItemDetails(theme, numberFormat, quantityFormat),
          if (showCostLayers &&
              (entry.costLayerBreakdown?.isNotEmpty ?? false)) ...[
            const Divider(height: 1),
            _buildCostLayerSection(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildItemHeader(ThemeData theme, NumberFormat numberFormat) {
    return Container(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.itemName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Item Code: ${entry.itemCode}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${numberFormat.format(entry.totalValue)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total Value',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails(
      ThemeData theme, NumberFormat numberFormat, NumberFormat quantityFormat) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDetailColumn(theme, 'Quantity',
                  quantityFormat.format(entry.totalQuantity)),
              _buildDetailColumn(
                theme,
                'Average Cost',
                '\$${numberFormat.format(entry.averageCost)}',
              ),
              _buildDetailColumn(
                theme,
                'Valuation Method',
                _getMethodName(entry.costingMethod),
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(ThemeData theme, String label, String value,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostLayerSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
          child: Text(
            'Cost Layers',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: entry.costLayerBreakdown?.length ?? 0,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final layer = entry.costLayerBreakdown![index];
            return CostLayerDetailCard(
              layer: inventory.CostLayer(
                id: layer.id,
                itemId: layer.itemId,
                warehouseId: '', // Not available
                batchLotNumber: layer.batchLotNumber,
                initialQuantity: layer.quantity,
                remainingQuantity: layer.quantity,
                costAtTransaction: layer.costPerUnit,
                movementId: null,
                movementDate: layer.movementDate,
                expirationDate: layer.expirationDate,
                productionDate: layer.productionDate,
                createdAt: layer.movementDate,
              ),
              index: index,
              uom: '', // UOM not available
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _getMethodName(inventory.CostingMethod? method) {
    switch (method) {
      case inventory.CostingMethod.fifo:
        return 'FIFO';
      case inventory.CostingMethod.lifo:
        return 'LIFO';
      case inventory.CostingMethod.wac:
        return 'WAC';
      default:
        return 'Unknown';
    }
  }
}
