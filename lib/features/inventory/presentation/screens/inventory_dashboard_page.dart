import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/inventory_movement_providers.dart';
import '../widgets/dashboard/inventory_dashboard_widgets.dart';
import 'create_movement_page.dart';
import 'inventory_movement_list_page.dart';

class InventoryDashboardPage extends ConsumerWidget {
  const InventoryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              // Refresh providers
              ref.invalidate(movementsByDateRangeProvider);
            },
          ),
        ],
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
                            'Inventory Management',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Monitor and manage your inventory movements',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('New Movement'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateMovementPage(),
                          ),
                        );
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
                label: const Text('View All Movements'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryMovementListPage(),
                    ),
                  );
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
