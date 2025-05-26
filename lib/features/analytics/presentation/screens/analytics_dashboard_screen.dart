import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/eo_stock_usecase.dart';
import '../../domain/inventory_aging_usecase.dart';
import '../../domain/stockout_rate_usecase.dart';
import '../../domain/supplier_performance_usecase.dart';
import '../../domain/traceability_report_usecase.dart';
import '../../domain/turnover_rate_usecase.dart';
import '../analytics_providers.dart';
import '../widgets/inventory_distribution_chart.dart';
import '../widgets/inventory_value_chart.dart';
import '../widgets/kpi_card.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/top_products_chart.dart';
import '../widgets/traceability_report_widget.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter state
  DateTimeRange? _dateRange;
  String? _selectedSupplier;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sales'),
            Tab(text: 'Inventory'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSalesTab(),
                _buildInventoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Date range filter
          TextButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(_dateRange == null
                ? 'Select Date Range'
                : '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}'),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() {
                  _dateRange = picked;
                });
              }
            },
          ),
          const SizedBox(width: 12),
          // Supplier filter (stub dropdown)
          DropdownButton<String>(
            value: _selectedSupplier,
            hint: const Text('Supplier'),
            items: [null, 'SUPPLIER_001', 'SUPPLIER_002']
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s ?? 'All'),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedSupplier = val;
              });
            },
          ),
          const SizedBox(width: 12),
          // Category filter (stub dropdown)
          DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('Category'),
            items: [null, 'Electronics', 'Clothing', 'Groceries']
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c ?? 'All'),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedCategory = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 20),
          _buildSupplierPerformanceKpi(),
          const SizedBox(height: 20),
          _buildTraceabilityReportButton(context),
          const SizedBox(height: 20),
          const Text(
            'Key Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: InventoryDistributionChart(),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SalesTrendChart(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TopProductsChart(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Supplier Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildSupplierPerformanceKpi(),
        ],
      ),
    );
  }

  Widget _buildTraceabilityReportButton(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Batch/Lot Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Traceability Report'),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Traceability Report'),
                    content: SizedBox(
                      width: 600,
                      child: _TraceabilityReportDialog(
                          batchOrLotNumber: controller.text),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SalesTrendChart(isDetailed: true),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sales by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SalesByCategoryChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Value Over Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InventoryValueChart(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Stock Levels by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: StockLevelsByCategoryChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final start =
        _dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = _dateRange?.end ?? DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final turnover = ref.watch(turnoverRateProvider(
                  TurnoverRateParams(
                      startDate: start,
                      endDate: end,
                      categoryId: _selectedCategory)));
              return turnover.when(
                data: (value) => KpiCard(
                  title: 'Turnover Rate',
                  value: value.toStringAsFixed(2),
                  icon: Icons.loop,
                  trendValue: '',
                  trendUp: value > 1,
                  onTap: () => _showDrilldown(context, 'Turnover Rate'),
                ),
                loading: () => const KpiCard(
                    title: 'Turnover Rate',
                    value: '...',
                    icon: Icons.loop,
                    trendValue: '',
                    trendUp: true),
                error: (e, _) => KpiCard(
                    title: 'Turnover Rate',
                    value: 'Err',
                    icon: Icons.loop,
                    trendValue: '',
                    trendUp: false),
              );
            },
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final stockout = ref.watch(stockoutRateProvider(
                  StockoutRateParams(
                      startDate: start,
                      endDate: end,
                      categoryId: _selectedCategory)));
              return stockout.when(
                data: (value) => KpiCard(
                  title: 'Stockout Rate',
                  value: '${(value * 100).toStringAsFixed(1)}%',
                  icon: Icons.warning,
                  trendValue: '',
                  trendUp: value < 0.05,
                  onTap: () => _showDrilldown(context, 'Stockout Rate'),
                ),
                loading: () => const KpiCard(
                    title: 'Stockout Rate',
                    value: '...',
                    icon: Icons.warning,
                    trendValue: '',
                    trendUp: true),
                error: (e, _) => KpiCard(
                    title: 'Stockout Rate',
                    value: 'Err',
                    icon: Icons.warning,
                    trendValue: '',
                    trendUp: false),
              );
            },
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final eo = ref.watch(eoStockProvider(EOStockParams(
                  agingThresholdDays: 90, categoryId: _selectedCategory)));
              return eo.when(
                data: (value) => KpiCard(
                  title: 'E&O Stock',
                  value: '\$${value.toStringAsFixed(0)}',
                  icon: Icons.delete,
                  trendValue: '',
                  trendUp: value < 1000,
                  onTap: () => _showDrilldown(context, 'E&O Stock'),
                ),
                loading: () => const KpiCard(
                    title: 'E&O Stock',
                    value: '...',
                    icon: Icons.delete,
                    trendValue: '',
                    trendUp: true),
                error: (e, _) => KpiCard(
                    title: 'E&O Stock',
                    value: 'Err',
                    icon: Icons.delete,
                    trendValue: '',
                    trendUp: false),
              );
            },
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final aging = ref.watch(inventoryAgingProvider(
                  InventoryAgingParams(
                      agingBuckets: [30, 60, 90],
                      categoryId: _selectedCategory)));
              return aging.when(
                data: (value) => KpiCard(
                  title: 'Aged >30d',
                  value: value[30]?.toStringAsFixed(0) ?? '0',
                  icon: Icons.timelapse,
                  trendValue: '',
                  trendUp: (value[30] ?? 0) < 100,
                  onTap: () => _showDrilldown(context, 'Inventory Aging'),
                ),
                loading: () => const KpiCard(
                    title: 'Aged >30d',
                    value: '...',
                    icon: Icons.timelapse,
                    trendValue: '',
                    trendUp: true),
                error: (e, _) => KpiCard(
                    title: 'Aged >30d',
                    value: 'Err',
                    icon: Icons.timelapse,
                    trendValue: '',
                    trendUp: false),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDrilldown(BuildContext context, String kpi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Drilldown: $kpi'),
        content: Text('Detailed analytics for $kpi will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierPerformanceKpi() {
    final start =
        _dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = _dateRange?.end ?? DateTime.now();
    final supplierId = _selectedSupplier ?? 'SUPPLIER_001';
    return Consumer(
      builder: (context, ref, _) {
        final perf =
            ref.watch(supplierPerformanceProvider(SupplierPerformanceParams(
          supplierId: supplierId,
          startDate: start,
          endDate: end,
        )));
        return perf.when(
          data: (result) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KpiCard(
                title: 'OTIF',
                value: '${(result.otif * 100).toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                trendValue: '',
                trendUp: result.otif > 0.9,
                onTap: () => _showDrilldown(context, 'Supplier OTIF'),
              ),
              KpiCard(
                title: 'Lead Time Var.',
                value: '${result.leadTimeVariance.toStringAsFixed(1)}d',
                icon: Icons.timer,
                trendValue: '',
                trendUp: result.leadTimeVariance < 3,
                onTap: () => _showDrilldown(context, 'Supplier Lead Time'),
              ),
              KpiCard(
                title: 'Rejection Rate',
                value:
                    '${(result.qualityRejectionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.cancel,
                trendValue: '',
                trendUp: result.qualityRejectionRate < 0.05,
                onTap: () => _showDrilldown(context, 'Supplier Rejection Rate'),
              ),
            ],
          ),
          loading: () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              KpiCard(
                  title: 'OTIF',
                  value: '...',
                  icon: Icons.check_circle,
                  trendValue: '',
                  trendUp: true),
              KpiCard(
                  title: 'Lead Time Var.',
                  value: '...',
                  icon: Icons.timer,
                  trendValue: '',
                  trendUp: true),
              KpiCard(
                  title: 'Rejection Rate',
                  value: '...',
                  icon: Icons.cancel,
                  trendValue: '',
                  trendUp: true),
            ],
          ),
          error: (e, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              KpiCard(
                  title: 'OTIF',
                  value: 'Err',
                  icon: Icons.check_circle,
                  trendValue: '',
                  trendUp: false),
              KpiCard(
                  title: 'Lead Time Var.',
                  value: 'Err',
                  icon: Icons.timer,
                  trendValue: '',
                  trendUp: false),
              KpiCard(
                  title: 'Rejection Rate',
                  value: 'Err',
                  icon: Icons.cancel,
                  trendValue: '',
                  trendUp: false),
            ],
          ),
        );
      },
    );
  }
}

class SalesByCategoryChart extends StatelessWidget {
  const SalesByCategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: 35,
        title: 'Electronics',
        color: Colors.blue,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 25,
        title: 'Clothing',
        color: Colors.orange,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 20,
        title: 'Groceries',
        color: Colors.green,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 20,
        title: 'Other',
        color: Colors.purple,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }
}

class StockLevelsByCategoryChart extends StatelessWidget {
  const StockLevelsByCategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: 80,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: 45,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: 65,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: 35,
            color: Colors.red,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: 90,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text = '';
                switch (value.toInt()) {
                  case 0:
                    text = 'Electronics';
                    break;
                  case 1:
                    text = 'Clothing';
                    break;
                  case 2:
                    text = 'Kitchen';
                    break;
                  case 3:
                    text = 'Food';
                    break;
                  case 4:
                    text = 'Office';
                    break;
                }
                return Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              },
              interval: 20,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withAlpha((0.3 * 255).toInt()),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _TraceabilityReportDialog extends ConsumerWidget {
  const _TraceabilityReportDialog({required this.batchOrLotNumber});
  final String batchOrLotNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(traceabilityReportProvider(
      TraceabilityReportParams(batchOrLotNumber: batchOrLotNumber),
    ));
    return reportAsync.when(
      data: (report) => SizedBox(
        height: 400,
        child: TraceabilityReportWidget(report: report),
      ),
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 200,
        child: Center(child: Text('Error: $e')),
      ),
    );
  }
}
