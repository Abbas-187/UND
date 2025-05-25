import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../../../shared/widgets/quick_action_button.dart';
import '../../../shared/widgets/status_indicator.dart';
import '../providers/bom_providers.dart';

class BomDashboardScreen extends ConsumerWidget {
  const BomDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bomsAsync = ref.watch(allBomsProvider);
    final bomStatsAsync = ref.watch(bomStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BOM Management Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/bom/create'),
            tooltip: 'Create New BOM',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/bom/settings'),
            tooltip: 'BOM Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allBomsProvider);
          ref.invalidate(bomStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Section
              _buildQuickActionsSection(context),
              const SizedBox(height: 24),

              // Statistics Cards
              bomStatsAsync.when(
                data: (stats) => _buildStatsSection(stats, theme),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    _buildErrorCard('Failed to load statistics'),
              ),
              const SizedBox(height: 24),

              // BOM Status Overview
              _buildBomStatusSection(context, ref),
              const SizedBox(height: 24),

              // Integration Status
              _buildIntegrationStatusSection(context, ref),
              const SizedBox(height: 24),

              // Recent BOMs
              _buildRecentBomsSection(context, ref, bomsAsync),
              const SizedBox(height: 24),

              // Analytics Charts
              _buildAnalyticsSection(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                QuickActionButton(
                  icon: Icons.add_circle,
                  label: 'Create BOM',
                  onPressed: () => context.push('/bom/create'),
                ),
                QuickActionButton(
                  icon: Icons.copy,
                  label: 'Copy BOM',
                  onPressed: () => context.push('/bom/copy'),
                ),
                QuickActionButton(
                  icon: Icons.upload_file,
                  label: 'Import BOM',
                  onPressed: () => context.push('/bom/import'),
                ),
                QuickActionButton(
                  icon: Icons.analytics,
                  label: 'BOM Analytics',
                  onPressed: () => context.push('/bom/analytics'),
                ),
                QuickActionButton(
                  icon: Icons.inventory,
                  label: 'Check Inventory',
                  onPressed: () => context.push('/bom/inventory-check'),
                ),
                QuickActionButton(
                  icon: Icons.shopping_cart,
                  label: 'Generate PO',
                  onPressed: () => context.push('/bom/generate-po'),
                ),
                QuickActionButton(
                  icon: Icons.production_quantity_limits,
                  label: 'Create Production',
                  onPressed: () => context.push('/bom/create-production'),
                ),
                QuickActionButton(
                  icon: Icons.calculate,
                  label: 'Cost Analysis',
                  onPressed: () => context.push('/bom/cost-analysis'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: DashboardCard(
            title: 'Total BOMs',
            value: stats['totalBoms']?.toString() ?? '0',
            icon: Icons.list_alt,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardCard(
            title: 'Active BOMs',
            value: stats['activeBoms']?.toString() ?? '0',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardCard(
            title: 'Draft BOMs',
            value: stats['draftBoms']?.toString() ?? '0',
            icon: Icons.edit,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardCard(
            title: 'Avg Cost',
            value: '\$${stats['averageCost']?.toStringAsFixed(2) ?? '0.00'}',
            icon: Icons.attach_money,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildBomStatusSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BOM Status Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/bom/list'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final bomStatusAsync = ref.watch(bomStatusDistributionProvider);
                return bomStatusAsync.when(
                  data: (statusData) => _buildStatusChart(statusData),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      _buildErrorCard('Failed to load status data'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationStatusSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Module Integration Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final integrationStatusAsync =
                    ref.watch(integrationStatusProvider);
                return integrationStatusAsync.when(
                  data: (integrationData) => Column(
                    children: [
                      _buildIntegrationStatusRow(
                        'Inventory Integration',
                        integrationData['inventory'] ?? false,
                        'Real-time inventory checking',
                      ),
                      _buildIntegrationStatusRow(
                        'Production Integration',
                        integrationData['production'] ?? false,
                        'Production order generation',
                      ),
                      _buildIntegrationStatusRow(
                        'Procurement Integration',
                        integrationData['procurement'] ?? false,
                        'Purchase order automation',
                      ),
                      _buildIntegrationStatusRow(
                        'Sales Integration',
                        integrationData['sales'] ?? false,
                        'Product pricing updates',
                      ),
                      _buildIntegrationStatusRow(
                        'Quality Integration',
                        integrationData['quality'] ?? false,
                        'Quality parameter validation',
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      _buildErrorCard('Failed to load integration status'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationStatusRow(
      String title, bool isActive, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          StatusIndicator(isActive: isActive),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.check_circle : Icons.warning,
            color: isActive ? Colors.green : Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBomsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> bomsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent BOMs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/bom/list'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            bomsAsync.when(
              data: (boms) {
                final recentBoms = boms.take(5).toList();
                if (recentBoms.isEmpty) {
                  return const Center(
                    child: Text('No BOMs found'),
                  );
                }
                return Column(
                  children: recentBoms
                      .map((bom) => _buildBomListTile(context, bom))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorCard('Failed to load recent BOMs'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBomListTile(BuildContext context, dynamic bom) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getBomStatusColor(bom.status?.name ?? 'unknown'),
        child: Text(
          bom.bomCode?.substring(0, 2) ?? 'BM',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(bom.bomName ?? 'Unknown BOM'),
      subtitle: Text('${bom.productCode} • ${bom.version}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            bom.status?.name ?? 'Unknown',
            style: TextStyle(
              color: _getBomStatusColor(bom.status?.name ?? 'unknown'),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '\$${bom.totalCost?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      onTap: () => context.push('/bom/detail/${bom.id}'),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BOM Analytics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/bom/analytics'),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final analyticsAsync = ref.watch(bomAnalyticsProvider);
                return analyticsAsync.when(
                  data: (analytics) => _buildAnalyticsChart(analytics),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      _buildErrorCard('Failed to load analytics'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart(Map<String, int> statusData) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: statusData.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title: '${entry.key}\n${entry.value}',
              color: _getBomStatusColor(entry.key),
              radius: 80,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAnalyticsChart(Map<String, dynamic> analytics) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: (analytics['costTrend'] as List<dynamic>?)
                      ?.asMap()
                      .entries
                      .map((entry) => FlSpot(
                            entry.key.toDouble(),
                            (entry.value as num).toDouble(),
                          ))
                      .toList() ??
                  [],
              isCurved: true,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
      ),
    );
  }

  Color _getBomStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      case 'obsolete':
        return Colors.red;
      case 'approved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
