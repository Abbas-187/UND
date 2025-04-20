import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../data/models/inventory_movement_model.dart';
import '../../../data/models/inventory_movement_type.dart';
import '../../../providers/inventory_movement_providers.dart';
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
                  l10n.recentMovements,
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
                  child: Text(l10n.viewAll),
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
                      child: Text(l10n.noRecentMovements),
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
                  child: Text(l10n.errorWithMessage(error.toString())),
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
      case InventoryMovementType.ISSUE:
        iconData = Icons.remove;
        iconColor = Colors.orange;
        break;
      case InventoryMovementType.RETURN:
        iconData = Icons.replay;
        iconColor = Colors.teal;
        break;
      case InventoryMovementType.ADJUSTMENT:
        iconData = Icons.tune;
        iconColor = Colors.purple;
        break;
      case InventoryMovementType.DISPOSAL:
        iconData = Icons.delete;
        iconColor = Colors.red;
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
    final l10n = AppLocalizations.of(context);
    Color color;
    String text;

    switch (status) {
      case ApprovalStatus.PENDING:
        color = Colors.orange;
        text = l10n.pending;
        break;
      case ApprovalStatus.APPROVED:
        color = Colors.green;
        text = l10n.approved;
        break;
      case ApprovalStatus.REJECTED:
        color = Colors.red;
        text = l10n.rejected;
        break;
      default:
        color = Colors.grey;
        text = l10n.unknown;
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
                  l10n.pendingApprovals,
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
                  child: Text(l10n.viewAll),
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
                      child: Text(l10n.noRecentMovements),
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
                          child: Text(l10n.reviewItems),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text(l10n.errorWithMessage(error.toString())),
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

    // Get movements with critical status (using RETURN as proxy for critical movements)
    final pendingMovementsAsync =
        ref.watch(movementsByTypeProvider(InventoryMovementType.RETURN));

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.criticalMovements,
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
                      child: Text(l10n.noMovementsMatchingFilters),
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
                        child: Text(l10n.review),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(l10n.errorWithMessage(error.toString())),
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
              l10n.movementTrends,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(l10n.notAvailable),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
