import 'package:flutter/material.dart';

/// Bottom action bar for bulk BOM operations
class BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onBulkUpdate;
  final VoidCallback onBulkDelete;
  final VoidCallback onBulkCopy;
  final VoidCallback onBulkStatusChange;
  final VoidCallback onBulkCostRecalculation;
  final VoidCallback onClearSelection;

  const BulkActionBar({
    Key? key,
    required this.selectedCount,
    required this.onBulkUpdate,
    required this.onBulkDelete,
    required this.onBulkCopy,
    required this.onBulkStatusChange,
    required this.onBulkCostRecalculation,
    required this.onClearSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection info
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '$selectedCount BOMs selected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearSelection,
                  child: const Text('Clear'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.edit,
                    label: 'Update',
                    onPressed: onBulkUpdate,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.copy,
                    label: 'Copy',
                    onPressed: onBulkCopy,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.swap_horiz,
                    label: 'Status',
                    onPressed: onBulkStatusChange,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.calculate,
                    label: 'Costs',
                    onPressed: onBulkCostRecalculation,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.delete,
                    label: 'Delete',
                    onPressed: onBulkDelete,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
