import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/dashboard/inventory_dashboard_widgets.dart';
import '../../presentation/providers/inventory_provider.dart';
import '../providers/inventory_provider.dart'
    show filteredInventoryItemsProvider;

class InventoryDashboardPage extends ConsumerWidget {
  const InventoryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.inventoryDashboard ?? 'Inventory Dashboard'),
        actions: [
          IconButton(
            tooltip: l10n?.inventoryReports ?? 'Inventory Reports',
            icon: const Icon(Icons.summarize),
            onPressed: () => context.go('/inventory/reports'),
          ),
          IconButton(
            tooltip: l10n?.inventorySettings ?? 'Inventory Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/inventory/settings'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics summary row (real data)
                _MetricsSummaryRow(),
                const SizedBox(height: 16),
                // Header with welcome and quick actions
                _DashboardHeader(l10n: l10n!, theme: theme),
                const SizedBox(height: 16),
                // Chart section (real data)
                _TrendsChartSection(),
                const SizedBox(height: 16),
                // Main dashboard widgets
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(
                              flex: 2, child: RecentMovementsSummaryWidget()),
                          SizedBox(width: 16),
                          Expanded(flex: 1, child: PendingApprovalsWidget()),
                        ],
                      )
                    : Column(
                        children: const [
                          RecentMovementsSummaryWidget(),
                          SizedBox(height: 16),
                          PendingApprovalsWidget(),
                        ],
                      ),
                const SizedBox(height: 16),
                const CriticalMovementsAlertWidget(),
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.list),
                    label: Text(l10n?.viewAllMovements ?? 'View All Movements'),
                    onPressed: () => context.go('/inventory/movements'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Metrics summary row at the top of the dashboard (real data)
class _MetricsSummaryRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(filteredInventoryItemsProvider);
    return inventoryAsync.when(
      data: (items) {
        final totalStock =
            items.fold<double>(0, (sum, item) => sum + item.quantity);
        final lowStock = items.where((item) => item.isLowStock).length;
        final inventoryValue = items.fold<double>(
            0, (sum, item) => sum + ((item.cost ?? 0) * item.quantity));
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MetricCard(
              icon: Icons.inventory,
              label: 'Total Stock',
              value: totalStock.toStringAsFixed(0),
              semanticLabel: 'Total Stock: $totalStock',
            ),
            _MetricCard(
              icon: Icons.warning,
              label: 'Low Stock',
              value: lowStock.toString(),
              semanticLabel: 'Low Stock Items: $lowStock',
            ),
            _MetricCard(
              icon: Icons.attach_money,
              label: 'Inventory Value',
              value: '\u20B9 ${_formatValue(inventoryValue)}',
              semanticLabel: 'Inventory Value: $inventoryValue',
            ),
          ],
        );
      },
      loading: () => const _MetricsShimmer(),
      error: (e, _) => _MetricsError(error: e.toString()),
    );
  }

  String _formatValue(double value) {
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)}M';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String semanticLabel;
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticLabel,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricsShimmer extends StatelessWidget {
  const _MetricsShimmer();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) => _ShimmerCard()),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 32, height: 32, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Container(width: 40, height: 18, color: Colors.grey.shade300),
            const SizedBox(height: 4),
            Container(width: 60, height: 14, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }
}

class _MetricsError extends StatelessWidget {
  final String error;
  const _MetricsError({required this.error});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red),
        const SizedBox(width: 8),
        Text('Error: $error'),
      ],
    );
  }
}

/// Chart section with a real chart and call to action (real data)
class _TrendsChartSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trendsAsync = ref.watch(inventoryTrendsProvider);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Inventory Trends',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: trendsAsync.when(
                data: (trends) {
                  if (trends.isEmpty) {
                    return const Center(
                        child: Text('No trend data available.'));
                  }
                  // Group by month, sum value
                  final points = <FlSpot>[];
                  final sorted = List<Map<String, dynamic>>.from(trends)
                    ..sort((a, b) => (a['date'] as DateTime)
                        .compareTo(b['date'] as DateTime));
                  for (int i = 0; i < sorted.length; i++) {
                    points.add(FlSpot(
                        i.toDouble(), (sorted[i]['value'] as num).toDouble()));
                  }
                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error loading trends: $e')),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text('View Analytics'),
                onPressed: () => context.go('/inventory/analytics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  const _DashboardHeader({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.85),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
            Wrap(
              spacing: 12,
              children: [
                Tooltip(
                  message: 'New Movement',
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text('New Movement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () => context.go('/inventory/movement-create'),
                  ),
                ),
                Tooltip(
                  message: 'Scan',
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text('Scan'),
                    onPressed: () => context.go('/inventory/batch-scan'),
                  ),
                ),
                Tooltip(
                  message: 'Add Item',
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_box),
                    label: const Text('Add Item'),
                    onPressed: () => context.go('/inventory/item-edit'),
                  ),
                ),
                Tooltip(
                  message: 'Export',
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Export'),
                    onPressed: () {
                      // TODO: Implement export logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Export not implemented (dummy).')),
                      );
                    },
                  ),
                ),
                Tooltip(
                  message: 'Import',
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_download),
                    label: const Text('Import'),
                    onPressed: () {
                      // TODO: Implement import logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Import not implemented (dummy).')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
