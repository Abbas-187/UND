import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../../../shared/widgets/quick_action_button.dart';
import '../providers/bom_providers.dart';

class BomMainScreen extends ConsumerWidget {
  const BomMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bomStatsAsync = ref.watch(bomStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill of Materials (BOM)'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/bom/create'),
            tooltip: 'Create New BOM',
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => context.push('/bom/dashboard'),
            tooltip: 'BOM Dashboard',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bomStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, theme),
              const SizedBox(height: 24),

              // Statistics Overview
              bomStatsAsync.when(
                data: (stats) => _buildStatsOverview(stats, theme),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    _buildErrorCard('Failed to load statistics'),
              ),
              const SizedBox(height: 24),

              // Main Actions Grid
              _buildMainActionsGrid(context, theme),
              const SizedBox(height: 24),

              // Quick Access Section
              _buildQuickAccessSection(context, theme),
              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivitySection(context, ref),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bom/create'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create BOM'),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.withOpacity(0.8),
            Colors.deepOrange.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOM Management',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your Bills of Materials efficiently',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Create, manage, and analyze your product Bills of Materials. Track components, costs, and ensure accurate production planning.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, dynamic> stats, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Total BOMs',
                value: stats['totalBoms']?.toString() ?? '0',
                icon: Icons.list_alt,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardCard(
                title: 'Active',
                value: stats['activeBoms']?.toString() ?? '0',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardCard(
                title: 'Draft',
                value: stats['draftBoms']?.toString() ?? '0',
                icon: Icons.edit,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainActionsGrid(BuildContext context, ThemeData theme) {
    final actions = [
      {
        'title': 'View All BOMs',
        'subtitle': 'Browse and manage existing BOMs',
        'icon': Icons.list,
        'color': Colors.blue,
        'route': '/bom/list',
      },
      {
        'title': 'Create New BOM',
        'subtitle': 'Add a new Bill of Materials',
        'icon': Icons.add_box,
        'color': Colors.green,
        'route': '/bom/create',
      },
      {
        'title': 'BOM Analytics',
        'subtitle': 'View detailed analytics and reports',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'route': '/bom/analytics',
      },
      {
        'title': 'Cost Analysis',
        'subtitle': 'Analyze BOM costs and pricing',
        'icon': Icons.attach_money,
        'color': Colors.teal,
        'route': '/bom/cost-analysis',
      },
      {
        'title': 'Import/Export',
        'subtitle': 'Import or export BOM data',
        'icon': Icons.import_export,
        'color': Colors.indigo,
        'route': '/bom/import-export',
      },
      {
        'title': 'Settings',
        'subtitle': 'Configure BOM preferences',
        'icon': Icons.settings,
        'color': Colors.grey,
        'route': '/bom/settings',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              context,
              action['title'] as String,
              action['subtitle'] as String,
              action['icon'] as IconData,
              action['color'] as Color,
              action['route'] as String,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                QuickActionButton(
                  icon: Icons.copy,
                  label: 'Copy BOM',
                  onPressed: () => context.push('/bom/copy'),
                ),
                QuickActionButton(
                  icon: Icons.upload_file,
                  label: 'Import',
                  onPressed: () => context.push('/bom/import'),
                ),
                QuickActionButton(
                  icon: Icons.download,
                  label: 'Export',
                  onPressed: () => context.push('/bom/export'),
                ),
                QuickActionButton(
                  icon: Icons.inventory,
                  label: 'Check Stock',
                  onPressed: () => context.push('/bom/inventory-check'),
                ),
                QuickActionButton(
                  icon: Icons.shopping_cart,
                  label: 'Generate PO',
                  onPressed: () => context.push('/bom/generate-po'),
                ),
                QuickActionButton(
                  icon: Icons.production_quantity_limits,
                  label: 'Production',
                  onPressed: () => context.push('/bom/create-production'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
            ),
            TextButton(
              onPressed: () => context.push('/bom/list'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildActivityItem(
                context,
                'BOM-001 - Chocolate Cake',
                'Created 2 hours ago',
                Icons.add_circle,
                Colors.green,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                context,
                'BOM-002 - Vanilla Ice Cream',
                'Updated 4 hours ago',
                Icons.edit,
                Colors.orange,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                context,
                'BOM-003 - Strawberry Yogurt',
                'Approved 1 day ago',
                Icons.check_circle,
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/bom/detail'),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
