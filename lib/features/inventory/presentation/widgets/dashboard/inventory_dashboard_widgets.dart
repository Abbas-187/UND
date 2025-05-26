import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/inventory_movement_model.dart';
import '../../providers/inventory_movement_providers.dart';
import '../../screens/inventory_movement_list_page.dart';
import '../../screens/movement_details_page.dart';

/// Widget that displays a summary of recent movements
class RecentMovementsSummaryWidget extends ConsumerWidget {
  const RecentMovementsSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
                  l10n?.recentMovements ?? 'Recent Movements',
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
                  child: Text(l10n?.viewAll ?? 'View All'),
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: recentMovementsAsync.when(
                data: (movements) {
                  if (movements.isEmpty) {
                    return Center(
                      child: Text(
                          l10n?.noRecentMovements ?? 'No recent movements'),
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
                  child: Text(l10n?.errorWithMessage(error.toString()) ??
                      'Error: ${error.toString()}'),
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
      case InventoryMovementType.poReceipt:
        iconData = Icons.input;
        iconColor = Colors.blue;
        break;
      case InventoryMovementType.transferIn:
        iconData = Icons.swap_horiz;
        iconColor = Colors.green;
        break;
      case InventoryMovementType.productionIssue:
        iconData = Icons.remove;
        iconColor = Colors.orange;
        break;
      case InventoryMovementType.salesReturn:
        iconData = Icons.replay;
        iconColor = Colors.teal;
        break;
      case InventoryMovementType.adjustmentOther:
        iconData = Icons.tune;
        iconColor = Colors.purple;
        break;
      case InventoryMovementType.productionOutput:
        iconData = Icons.add;
        iconColor = Colors.indigo;
        break;
      case InventoryMovementType.transferOut:
        iconData = Icons.logout;
        iconColor = Colors.redAccent;
        break;
      case InventoryMovementType.saleShipment:
        iconData = Icons.local_shipping;
        iconColor = Colors.deepOrange;
        break;
      case InventoryMovementType.adjustmentDamage:
        iconData = Icons.report_problem;
        iconColor = Colors.brown;
        break;
      case InventoryMovementType.adjustmentCycleCountGain:
        iconData = Icons.add_circle_outline;
        iconColor = Colors.lightGreen;
        break;
      case InventoryMovementType.adjustmentCycleCountLoss:
        iconData = Icons.remove_circle_outline;
        iconColor = Colors.red;
        break;
      case InventoryMovementType.qualityStatusUpdate:
        iconData = Icons.verified;
        iconColor = Colors.blueGrey;
        break;
      default:
        iconData = Icons.inventory_2_outlined;
        iconColor = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ApprovalStatus status) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String text;

    switch (status) {
      case ApprovalStatus.pending:
        color = Colors.orange;
        text = l10n?.pending ?? 'Pending';
        break;
      case ApprovalStatus.approved:
        color = Colors.green;
        text = l10n?.approved ?? 'Approved';
        break;
      case ApprovalStatus.rejected:
        color = Colors.red;
        text = l10n?.rejected ?? 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = l10n?.unknown ?? 'Unknown';
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
    final l10n = AppLocalizations.of(context);

    // Use the movementsByTypeProvider for transfers since they often need approval
    final pendingMovementsAsync =
        ref.watch(movementsByTypeProvider(InventoryMovementType.transferIn));

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
                  l10n?.pendingApprovals ?? 'Pending Approvals',
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
                  child: Text(l10n?.viewAll ?? 'View All'),
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
                      .where((m) => m.approvalStatus == ApprovalStatus.pending)
                      .toList();

                  if (pendingMovements.isEmpty) {
                    return Center(
                      child: Text(
                          l10n?.noRecentMovements ?? 'No recent movements'),
                    );
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingMovements.length.clamp(0, 3),
                    itemBuilder: (context, index) {
                      final movement = pendingMovements[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(movement.movementId),
                        subtitle: Text(
                          DateFormat.yMd().format(movement.timestamp),
                        ),
                        trailing: OutlinedButton(
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
                          child: Text(l10n?.reviewItems ?? 'Review Items'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text(l10n?.errorWithMessage(error.toString()) ??
                      'Error: ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays critical movements alerts
class CriticalMovementsAlertWidget extends ConsumerWidget {
  const CriticalMovementsAlertWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Get movements with critical status (using SALES_RETURN as proxy for critical movements)
    final pendingMovementsAsync =
        ref.watch(movementsByTypeProvider(InventoryMovementType.salesReturn));

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.criticalMovements ?? 'Critical Movements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            pendingMovementsAsync.when(
              data: (criticalMovements) {
                if (criticalMovements.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text('No movements match the filters'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: criticalMovements.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final movement = criticalMovements[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        movement.movementId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${movement.movementType.toString().split('.').last} - ${DateFormat.yMd().format(movement.timestamp)}',
                      ),
                      trailing: ElevatedButton(
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
                        child: Text(l10n?.review ?? 'Review'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(l10n?.errorWithMessage(error.toString()) ??
                    'Error: ${error.toString()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays movement trends chart
class MovementTrendsChartWidget extends ConsumerWidget {
  const MovementTrendsChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // This would normally use chart data from backend
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.movementTrends ?? 'Movement Trends',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(l10n?.notAvailable ?? 'Not available'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
