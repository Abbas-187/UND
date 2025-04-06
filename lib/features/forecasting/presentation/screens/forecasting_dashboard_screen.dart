import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common/widgets/app_loading_indicator.dart';
import '../../../../common/widgets/error_view.dart';
import '../../../../core/routes/app_router.dart';
import '../../../inventory/data/models/inventory_item_model.dart';
import '../../../inventory/domain/providers/inventory_provider.dart';

class ForecastingDashboardScreen extends ConsumerWidget {
  const ForecastingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryItems = ref.watch(inventoryProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forecasting Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(inventoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderStats(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildInventoryForecastSection(context, ref, inventoryItems),
                const SizedBox(height: 24),
                _buildRecentForecastsSection(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.forecastingCreate);
        },
        label: const Text('New Forecast'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales & Inventory Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  context,
                  'Monthly Sales',
                  '\$34,567',
                  Icons.trending_up,
                  Colors.green,
                  '+12.3%',
                ),
                _buildStatCard(
                  context,
                  'Stock Value',
                  '\$128,950',
                  Icons.inventory_2,
                  Colors.blue,
                  '87 items',
                ),
                _buildStatCard(
                  context,
                  'Stock Turnover',
                  '4.2',
                  Icons.loop,
                  Colors.orange,
                  'Last 30 days',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              'Forecasts',
              Icons.insights,
              Colors.blue,
              () {
                Navigator.of(context).pushNamed(AppRoutes.forecasting);
              },
            ),
            _buildActionButton(
              context,
              'Inventory',
              Icons.inventory_2,
              Colors.green,
              () {
                Navigator.of(context).pushNamed(AppRoutes.inventory);
              },
            ),
            _buildActionButton(
              context,
              'Optimize',
              Icons.auto_graph,
              Colors.orange,
              () {
                // Navigate to inventory optimization
              },
            ),
            _buildActionButton(
              context,
              'Reports',
              Icons.assessment,
              Colors.purple,
              () {
                // Navigate to reports
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryForecastSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<InventoryItemModel>> inventoryItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Inventory Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        inventoryItems.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No inventory items found'),
                ),
              );
            }
            // Show top 5 items that need forecasting
            final topItems = items.take(5).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topItems.length,
              itemBuilder: (context, index) {
                final item = topItems[index];
                return _buildInventoryForecastItem(context, item);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: AppLoadingIndicator(),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: ErrorView(
              message: 'Error loading inventory: $error',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryForecastItem(
    BuildContext context,
    InventoryItemModel item,
  ) {
    // Simulate forecast data
    final currentStock = item.quantity;
    final reorderPoint = item.reorderPoint;
    final daysToReorder = (currentStock > reorderPoint)
        ? ((currentStock - reorderPoint) / (currentStock * 0.05)).round()
        : 0;
    final needsAttention = daysToReorder <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 50,
              decoration: BoxDecoration(
                color: needsAttention ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${item.quantity} ${item.unit} • Reorder: ${item.reorderPoint} ${item.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  needsAttention
                      ? 'Reorder Soon'
                      : '$daysToReorder days to reorder',
                  style: TextStyle(
                    color: needsAttention ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: () {
                    // Create forecast for this item
                    Navigator.of(context).pushNamed(
                      AppRoutes.forecastingCreate,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Forecast'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentForecastsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Forecasts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.forecasting);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 4 / 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(
            6,
            (index) => _buildForecastCard(
              context,
              'Product ${index + 1}',
              DateFormat('MMM dd, yyyy').format(
                DateTime.now().subtract(Duration(days: index * 3)),
              ),
              index % 3 == 0
                  ? 'Linear'
                  : index % 3 == 1
                      ? 'Moving Avg'
                      : 'Seasonal',
              index % 3 == 0
                  ? Colors.blue
                  : index % 3 == 1
                      ? Colors.green
                      : Colors.purple,
              index % 2 == 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(
    BuildContext context,
    String productName,
    String date,
    String method,
    Color methodColor,
    bool isPositive,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.forecastingDetail,
              arguments: ForecastingDetailArgs(forecastId: 'dummy-id'));
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: methodColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      method,
                      style: TextStyle(
                        fontSize: 10,
                        color: methodColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPositive ? '+12.5%' : '-8.3%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
