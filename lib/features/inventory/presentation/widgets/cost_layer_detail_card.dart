import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cost_layer.dart';

/// A card widget displaying details for a single cost layer
class CostLayerDetailCard extends StatelessWidget {
  const CostLayerDetailCard({
    super.key,
    required this.layer,
    required this.index,
    required this.uom,
  });
  final CostLayer layer;
  final int index;
  final String uom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,##0.00');
    final quantityFormat = NumberFormat('#,##0.###');
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Determine the age of the layer in days using movementDate
    final age = DateTime.now().difference(layer.movementDate).inDays;

    // Get appropriate color for the age indicator
    final ageColor = _getAgeIndicatorColor(age, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Received: ${dateFormat.format(layer.movementDate)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ageColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ageColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$age days',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ageColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (layer.movementId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Source: ${layer.movementId}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailColumn(
                  theme,
                  'Quantity',
                  '${quantityFormat.format(layer.remainingQuantity)} $uom',
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  theme,
                  'Unit Cost',
                  '\$${numberFormat.format(layer.costAtTransaction)}',
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  theme,
                  'Value',
                  '\$${numberFormat.format(layer.remainingQuantity * layer.costAtTransaction)}',
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(ThemeData theme, String label, String value,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
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
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getAgeIndicatorColor(int days, ThemeData theme) {
    if (days <= 30) {
      return Colors.green;
    } else if (days <= 60) {
      return Colors.orange;
    } else if (days <= 90) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
