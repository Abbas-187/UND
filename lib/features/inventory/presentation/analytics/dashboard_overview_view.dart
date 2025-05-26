import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/services/inventory_analytics_service.dart';
import '../../domain/usecases/analytics/excess_obsolete_analysis_usecase.dart';
import '../../domain/usecases/analytics/inventory_turnover_usecase.dart';
import '../../domain/usecases/analytics/stockout_analysis_usecase.dart';
import '../../providers/inventory_analytics_provider.dart';
import 'kpi_card.dart';

class DashboardOverviewView extends ConsumerStatefulWidget {
  const DashboardOverviewView({super.key});

  @override
  ConsumerState<DashboardOverviewView> createState() =>
      _DashboardOverviewViewState();
}

class _DashboardOverviewViewState extends ConsumerState<DashboardOverviewView> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(inventoryAnalyticsDashboardProvider(
      DashboardParams(
        periodStart: _startDate,
        periodEnd: _endDate,
        categoryFilter: _categoryFilter,
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(inventoryAnalyticsDashboardProvider(
              DashboardParams(
                periodStart: _startDate,
                periodEnd: _endDate,
                categoryFilter: _categoryFilter,
              ),
            )),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => _buildDashboard(dashboard),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error loading dashboard: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(inventoryAnalyticsDashboardProvider(
                  DashboardParams(
                    periodStart: _startDate,
                    periodEnd: _endDate,
                    categoryFilter: _categoryFilter,
                  ),
                )),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(InventoryAnalyticsDashboard dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 24),
          _buildOverviewMetrics(dashboard.overviewMetrics),
          const SizedBox(height: 24),
          _buildCriticalAlerts(dashboard.criticalAlerts),
          const SizedBox(height: 24),
          _buildPerformanceIndicators(dashboard.performanceIndicators),
          const SizedBox(height: 24),
          _buildAnalyticsGrid(dashboard),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    final formatter = DateFormat('MMM dd, yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 8),
            Text(
              'Period: ${formatter.format(_startDate!)} - ${formatter.format(_endDate!)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_categoryFilter != null) ...[
              const SizedBox(width: 16),
              Chip(
                label: Text('Category: $_categoryFilter'),
                onDeleted: () => setState(() => _categoryFilter = null),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics(InventoryOverviewMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview Metrics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            KPICard(
              title: 'Total Inventory Value',
              value: '\$${_formatCurrency(metrics.totalInventoryValue)}',
              icon: Icons.inventory,
              color: Colors.blue,
            ),
            KPICard(
              title: 'Total Items',
              value: '${metrics.totalItems}',
              icon: Icons.category,
              color: Colors.green,
            ),
            KPICard(
              title: 'Low Stock Items',
              value: '${metrics.lowStockItems}',
              icon: Icons.warning,
              color: Colors.orange,
            ),
            KPICard(
              title: 'Critical Stock Items',
              value: '${metrics.criticalStockItems}',
              icon: Icons.error,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCriticalAlerts(List<CriticalAlert> alerts) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Critical Alerts (${alerts.length})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: alerts.take(10).length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  color: _getAlertColor(alert.severity),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getAlertIcon(alert.type),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                alert.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          alert.description,
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          'Value: \$${_formatCurrency(alert.value)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicators(PerformanceIndicators indicators) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Indicators',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            KPICard(
              title: 'Inventory Accuracy',
              value: '${indicators.inventoryAccuracy.toStringAsFixed(1)}%',
              icon: Icons.check_circle,
              color: _getPerformanceColor(indicators.inventoryAccuracy),
            ),
            KPICard(
              title: 'Fill Rate',
              value: '${indicators.fillRate.toStringAsFixed(1)}%',
              icon: Icons.local_shipping,
              color: _getPerformanceColor(indicators.fillRate),
            ),
            KPICard(
              title: 'Cycle Count Accuracy',
              value: '${indicators.cycleCountAccuracy.toStringAsFixed(1)}%',
              icon: Icons.fact_check,
              color: _getPerformanceColor(indicators.cycleCountAccuracy),
            ),
            KPICard(
              title: 'Warehouse Utilization',
              value: '${indicators.warehouseUtilization.toStringAsFixed(1)}%',
              icon: Icons.warehouse,
              color: _getPerformanceColor(indicators.warehouseUtilization),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsGrid(InventoryAnalyticsDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Analytics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildTurnoverAnalysisCard(dashboard.turnoverAnalysis),
            _buildStockoutAnalysisCard(dashboard.stockoutAnalysis),
            _buildEOAnalysisCard(dashboard.excessObsoleteAnalysis),
            _buildTrendsCard(dashboard.trends),
          ],
        ),
      ],
    );
  }

  Widget _buildTurnoverAnalysisCard(TurnoverAnalysisResult analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Turnover Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
                'Overall Rate: ${analysis.overallTurnoverRate.toStringAsFixed(2)}'),
            Text('Total COGS: \$${_formatCurrency(analysis.totalCOGS)}'),
            Text('Top Performers: ${analysis.topPerformers.length}'),
            Text('Bottom Performers: ${analysis.bottomPerformers.length}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _navigateToTurnoverDetails(analysis),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockoutAnalysisCard(StockoutAnalysisResult analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Stockout Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Total Events: ${analysis.totalStockoutEvents}'),
            Text(
                'Stockout Rate: ${analysis.overallStockoutRate.toStringAsFixed(1)}%'),
            Text(
                'Lost Sales: \$${_formatCurrency(analysis.totalEstimatedLostSales)}'),
            Text('Ongoing: ${analysis.ongoingStockouts.length}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _navigateToStockoutDetails(analysis),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEOAnalysisCard(ExcessObsoleteAnalysisResult analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.red),
                const SizedBox(width: 8),
                const Text('E&O Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
                'E&O Percentage: ${analysis.eoPercentage.toStringAsFixed(1)}%'),
            Text(
                'Total E&O Value: \$${_formatCurrency(analysis.totalEOValue)}'),
            Text('Critical Items: ${analysis.criticalItems.length}'),
            Text('Near Expiry: ${analysis.nearExpiryItems.length}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _navigateToEODetails(analysis),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsCard(AnalyticsTrends trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Trends',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Turnover Trends: ${trends.turnoverTrends.length} points'),
            Text('Stockout Trends: ${trends.stockoutTrends.length} points'),
            Text('Value Trends: ${trends.inventoryValueTrends.length} points'),
            Text('E&O Trends: ${trends.excessObsoleteTrends.length} points'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _navigateToTrendsDetails(trends),
              child: const Text('View Charts'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red[700]!;
      case AlertSeverity.high:
        return Colors.orange[700]!;
      case AlertSeverity.medium:
        return Colors.yellow[700]!;
      case AlertSeverity.low:
        return Colors.blue[700]!;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.stockout:
        return Icons.remove_shopping_cart;
      case AlertType.lowStock:
        return Icons.warning;
      case AlertType.excessStock:
        return Icons.inventory_2;
      case AlertType.obsoleteStock:
        return Icons.delete;
      case AlertType.expiredStock:
        return Icons.schedule;
      case AlertType.qualityIssue:
        return Icons.bug_report;
      case AlertType.costVariance:
        return Icons.attach_money;
      case AlertType.turnoverIssue:
        return Icons.trending_down;
    }
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 95) return Colors.green;
    if (percentage >= 85) return Colors.orange;
    return Colors.red;
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Dashboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text(
                  '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'),
              trailing: const Icon(Icons.date_range),
              onTap: _selectDateRange,
            ),
            ListTile(
              title: const Text('Category Filter'),
              subtitle: Text(_categoryFilter ?? 'All Categories'),
              trailing: const Icon(Icons.category),
              onTap: _selectCategory,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate!, end: _endDate!),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _selectCategory() {
    // TODO: Implement category selection dialog
    // This would show a list of available categories to filter by
  }

  void _navigateToTurnoverDetails(TurnoverAnalysisResult analysis) {
    // TODO: Navigate to detailed turnover analysis screen
  }

  void _navigateToStockoutDetails(StockoutAnalysisResult analysis) {
    // TODO: Navigate to detailed stockout analysis screen
  }

  void _navigateToEODetails(ExcessObsoleteAnalysisResult analysis) {
    // TODO: Navigate to detailed E&O analysis screen
  }

  void _navigateToTrendsDetails(AnalyticsTrends trends) {
    // TODO: Navigate to detailed trends/charts screen
  }
}

// Dashboard parameters for provider
class DashboardParams {
  const DashboardParams({
    this.periodStart,
    this.periodEnd,
    this.categoryFilter,
  });

  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String? categoryFilter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardParams &&
          runtimeType == other.runtimeType &&
          periodStart == other.periodStart &&
          periodEnd == other.periodEnd &&
          categoryFilter == other.categoryFilter;

  @override
  int get hashCode =>
      periodStart.hashCode ^ periodEnd.hashCode ^ categoryFilter.hashCode;
}
