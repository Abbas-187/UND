import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/inventory_movement_model.dart';
import '../../../models/inventory_movement_type.dart';
import '../../../providers/inventory_movement_providers.dart';
import '../../screens/inventory_movement_list_page.dart';
import '../../screens/movement_details_page.dart';

/// Widget that displays a summary of recent movements
class RecentMovementsSummaryWidget extends ConsumerWidget {
  const RecentMovementsSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentMovementsAsync =
        ref.watch(movementsByDateRangeProvider((start: weekAgo, end: now)));

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Movements',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryMovementListPage(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: recentMovementsAsync.when(
                data: (movements) {
                  if (movements.isEmpty) {
                    return const Center(
                      child: Text('No recent movements'),
                    );
                  }

                  // Sort by date, newest first
                  final sortedMovements =
                      List<InventoryMovementModel>.from(movements)
                        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  // Take at most 5 recent movements
                  final recentMovements = sortedMovements.take(5).toList();

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentMovements.length,
                    itemBuilder: (context, index) {
                      final movement = recentMovements[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: _buildMovementTypeIcon(movement.movementType),
                        title: Text(
                            movement.movementType.toString().split('.').last),
                        subtitle: Text(DateFormat.yMd()
                            .add_jm()
                            .format(movement.timestamp)),
                        trailing:
                            _buildStatusBadge(context, movement.approvalStatus),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovementDetailsPage(
                                movementId: movement.movementId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementTypeIcon(InventoryMovementType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case InventoryMovementType.RECEIPT:
        iconData = Icons.input;
        iconColor = Colors.blue;
        break;
      case InventoryMovementType.TRANSFER:
        iconData = Icons.swap_horiz;
        iconColor = Colors.green;
        break;
      case InventoryMovementType.PRODUCTION_CONSUMPTION:
        iconData = Icons.remove;
        iconColor = Colors.orange;
        break;
      case InventoryMovementType.PRODUCTION_OUTPUT:
        iconData = Icons.add;
        iconColor = Colors.teal;
        break;
      case InventoryMovementType.QUALITY_HOLD:
        iconData = Icons.pause_circle;
        iconColor = Colors.amber;
        break;
      case InventoryMovementType.QUALITY_RELEASE:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case InventoryMovementType.ADJUSTMENT:
        iconData = Icons.tune;
        iconColor = Colors.purple;
        break;
      case InventoryMovementType.DISPOSAL:
        iconData = Icons.delete;
        iconColor = Colors.red;
        break;
      case InventoryMovementType.SHIPPING:
        iconData = Icons.local_shipping;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.inventory_2;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ApprovalStatus status) {
    Color color;
    String text;

    switch (status) {
      case ApprovalStatus.PENDING:
        color = Colors.orange;
        text = 'Pending';
        break;
      case ApprovalStatus.APPROVED:
        color = Colors.green;
        text = 'Approved';
        break;
      case ApprovalStatus.REJECTED:
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

/// Widget that displays pending approvals
class PendingApprovalsWidget extends ConsumerWidget {
  const PendingApprovalsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Get any movements with PENDING status
    final pendingMovementsAsync =
        ref.watch(movementsByTypeProvider(InventoryMovementType.TRANSFER));

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Approvals',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to filtered movements list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryMovementListPage(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: pendingMovementsAsync.when(
                data: (movements) {
                  // Filter for pending approvals
                  final pendingMovements = movements
                      .where((m) => m.approvalStatus == ApprovalStatus.PENDING)
                      .toList();

                  if (pendingMovements.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No pending approvals',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  // Take at most 5 pending movements
                  final recentPending = pendingMovements.take(5).toList();

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentPending.length,
                    itemBuilder: (context, index) {
                      final movement = recentPending[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.orange.shade50,
                        child: ListTile(
                          title: Text(
                            movement.movementType.toString().split('.').last,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Initiated by: ${movement.initiatingEmployeeName}\n'
                            'Date: ${DateFormat.yMd().format(movement.timestamp)}',
                          ),
                          trailing: FilledButton.tonal(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovementDetailsPage(
                                    movementId: movement.movementId,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Review'),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays critical movements that require attention
class CriticalMovementsAlertWidget extends ConsumerWidget {
  const CriticalMovementsAlertWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Critical Movement Alerts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.red),
            const Text(
              '2 items in Quality Hold require review',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Items have been in quality hold for more than 48 hours',
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () {
                // Navigate to quality hold items list
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
              ),
              child: const Text('Review Items'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that shows movement volume trends chart
class MovementTrendsChartWidget extends ConsumerWidget {
  const MovementTrendsChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // This would normally use chart data from backend
    // For now we'll just use a placeholder

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movement Volume Trends',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Movement Volume Chart',
                      style: theme.textTheme.titleSmall,
                    ),
                    const Text(
                      'Integration with chart library would display here',
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, 'Receipts', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem(context, 'Transfers', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem(context, 'Disposals', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
