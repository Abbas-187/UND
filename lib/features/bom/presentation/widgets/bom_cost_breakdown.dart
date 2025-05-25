import 'package:flutter/material.dart';

import '../../domain/entities/bill_of_materials.dart';

class BomCostBreakdown extends StatelessWidget {
  const BomCostBreakdown({
    super.key,
    required this.bom,
  });

  final BillOfMaterials bom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materialCost = bom.calculateMaterialCost(bom.baseQuantity);
    final totalCost = bom.calculateTotalBomCost(bom.baseQuantity);

    return Column(
      children: [
        _buildCostRow(
          'Material Cost',
          materialCost,
          totalCost,
          theme,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildCostRow(
          'Labor Cost',
          bom.laborCost,
          totalCost,
          theme,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildCostRow(
          'Overhead Cost',
          bom.overheadCost,
          totalCost,
          theme,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildCostRow(
          'Setup Cost',
          bom.setupCost,
          totalCost,
          theme,
          Colors.purple,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Total Cost',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '\$${totalCost.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Cost per Unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Text(
              '\$${(totalCost / bom.baseQuantity).toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostRow(
    String label,
    double cost,
    double totalCost,
    ThemeData theme,
    Color color,
  ) {
    final percentage = totalCost > 0 ? (cost / totalCost) * 100 : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '\$${cost.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
