import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/routes/app_router.dart';
import '../../widgets/procurement_metrics_card.dart';
import '../../widgets/purchase_order_list.dart';
import '../../../../suppliers/presentation/widgets/supplier_performance_chart.dart';
import '../../../../suppliers/presentation/providers/supplier_provider.dart';

class ProcurementDashboardScreen extends ConsumerWidget {
  const ProcurementDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createPurchaseOrder);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildMetricsSection(context),
                const SizedBox(height: 24),
                _buildPurchaseOrdersSection(context),
                const SizedBox(height: 24),
                _buildSupplierPerformanceSection(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Procurement Overview',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor and manage your procurement activities',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            'Create PO',
            Icons.add,
            Colors.blue,
            () {
              Navigator.pushNamed(context, AppRoutes.createPurchaseOrder);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            'Suppliers',
            Icons.people,
            Colors.green,
            () {
              Navigator.pushNamed(context, AppRoutes.suppliers);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    // Simulate async loading and error states for demonstration
    // In a real app, replace with provider/future/stream
    final bool isLoading = false; // set to true to simulate loading
    final String? errorMessage = null; // set to a string to simulate error

    final List<_MetricData> metrics = [
      _MetricData(
        title: 'Open POs',
        value: '12',
        icon: Icons.shopping_cart,
        color: Colors.blue,
        subtitle: 'Orders not yet fulfilled',
        tooltip: 'Number of purchase orders that are still open',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Open POs tapped')),
          );
        },
        isLoading: isLoading,
        errorMessage: errorMessage,
      ),
      _MetricData(
        title: 'Pending Approvals',
        value: '5',
        icon: Icons.pending_actions,
        color: Colors.orange,
        subtitle: 'Awaiting manager review',
        tooltip: 'Purchase orders waiting for approval',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pending Approvals tapped')),
          );
        },
        isLoading: isLoading,
        errorMessage: errorMessage,
      ),
      _MetricData(
        title: 'Total Suppliers',
        value: '24',
        icon: Icons.people,
        color: Colors.green,
        subtitle: 'Active suppliers',
        tooltip: 'Number of suppliers currently active',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Total Suppliers tapped')),
          );
        },
        isLoading: isLoading,
        errorMessage: errorMessage,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: metrics
              .map((metric) => Expanded(
                    child: ProcurementMetricsCard(
                      title: metric.title,
                      value: metric.value,
                      icon: metric.icon,
                      color: metric.color,
                      subtitle: metric.subtitle,
                      tooltip: metric.tooltip,
                      onTap: metric.onTap,
                      isLoading: metric.isLoading,
                      errorMessage: metric.errorMessage,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPurchaseOrdersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Purchase Orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.purchaseOrders);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const PurchaseOrderList(limit: 5),
      ],
    );
  }

  Widget _buildSupplierPerformanceSection(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(allSuppliersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supplier Performance',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: suppliersAsync.when(
            data: (suppliers) {
              final data = suppliers
                  .map((s) => SupplierPerformance(
                        name: s.name,
                        score: (s.metrics.qualityScore ?? s.rating ?? 0.0)
                            .toDouble(),
                      ))
                  .toList();
              return SupplierPerformanceChart(
                data: data,
                title: 'Supplier Performance',
                barColor: Colors.blue,
                backgroundColor: Colors.white,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading suppliers: $error')),
          ),
        ),
      ],
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? errorMessage;
  const _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.tooltip,
    this.onTap,
    this.isLoading = false,
    this.errorMessage,
  });
}
