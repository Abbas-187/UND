import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/dashboard/inventory_dashboard_widgets.dart';

class InventoryDashboardPage extends ConsumerWidget {
  const InventoryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryDashboard),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with welcome and quick actions
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.7),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.inventoryManagement,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.monitorAndManageInventory,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.newMovement),
                      onPressed: () {
                        context.go('/inventory/create-movement');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dashboard Widgets
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: RecentMovementsSummaryWidget(),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: PendingApprovalsWidget(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const CriticalMovementsAlertWidget(),

            const SizedBox(height: 16),

            const MovementTrendsChartWidget(),

            const SizedBox(height: 24),

            // View all movements button
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.list),
                label: Text(l10n.viewAllMovements),
                onPressed: () {
                  context.go('/inventory/movements');
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
