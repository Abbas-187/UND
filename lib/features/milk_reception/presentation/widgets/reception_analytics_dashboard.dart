import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_utils.dart';
import '../../../../services/reception_analytics_service.dart' as analytics;
import '../../domain/models/milk_reception_model.dart';
import 'reception_volume_chart.dart';
import 'rejection_reasons_chart.dart';
import 'supplier_comparison_chart.dart';

/// A dashboard widget for displaying milk reception analytics
class ReceptionAnalyticsDashboard extends StatefulWidget {
  /// Create a reception analytics dashboard
  const ReceptionAnalyticsDashboard({
    super.key,
    required this.analyticsService,
    this.initialDateRange,
  });

  /// Service for analytics operations
  final analytics.ReceptionAnalyticsService analyticsService;

  /// Initial date range for analytics
  final analytics.DateRange? initialDateRange;

  @override
  State<ReceptionAnalyticsDashboard> createState() =>
      _ReceptionAnalyticsDashboardState();
}

class _ReceptionAnalyticsDashboardState
    extends State<ReceptionAnalyticsDashboard> {
  late analytics.DateRange _selectedDateRange;
  bool _isLoading = true;
  String? _errorMessage;

  // Analytics data
  Map<String, dynamic>? _volumeData;
  Map<String, dynamic>? _rejectionData;
  Map<String, dynamic>? _supplierRankings;
  Map<String, dynamic>? _qualityTrends;
  Map<String, dynamic>? _forecast;

  // UI settings
  bool _showDailyVolumes = true;

  @override
  void initState() {
    super.initState();
    _selectedDateRange =
        widget.initialDateRange ?? analytics.DateRange.lastDays(30);
    _loadData();
  }

  /// Load all dashboard data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadVolumeData(),
        _loadRejectionData(),
        _loadSupplierRankings(),
        _loadQualityTrends(),
        _loadForecast(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading analytics data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load volume analytics data
  Future<void> _loadVolumeData() async {
    try {
      final result = await widget.analyticsService.analyzeReceptionVolumes(
        _selectedDateRange,
        _showDailyVolumes ? analytics.GroupBy.day : analytics.GroupBy.week,
      );
      setState(() {
        _volumeData = result;
      });
    } catch (e) {
      debugPrint('Error loading volume data: $e');
      rethrow;
    }
  }

  /// Load rejection analytics data
  Future<void> _loadRejectionData() async {
    try {
      final result = await widget.analyticsService.calculateRejectionStatistics(
        _selectedDateRange,
      );
      setState(() {
        _rejectionData = result;
      });
    } catch (e) {
      debugPrint('Error loading rejection data: $e');
      rethrow;
    }
  }

  /// Load supplier rankings data
  Future<void> _loadSupplierRankings() async {
    try {
      // This would typically come from a service method
      // For now, we'll just set placeholder data
      setState(() {
        _supplierRankings = {
          'topSuppliers': [
            {
              'supplierId': 'S001',
              'supplierName': 'ABC Farms',
              'value': 5423.0
            },
            {
              'supplierId': 'S002',
              'supplierName': 'XYZ Cooperative',
              'value': 4210.0
            },
            {
              'supplierId': 'S003',
              'supplierName': 'Lakeside Dairy',
              'value': 3875.0
            },
            {
              'supplierId': 'S004',
              'supplierName': 'Highland Farms',
              'value': 3690.0
            },
            {
              'supplierId': 'S005',
              'supplierName': 'Valley Milk Co',
              'value': 2950.0
            },
          ],
        };
      });
    } catch (e) {
      debugPrint('Error loading supplier rankings: $e');
      rethrow;
    }
  }

  /// Load quality trend data
  Future<void> _loadQualityTrends() async {
    try {
      final result =
          await widget.analyticsService.analyzeQualityParametersTrend(
        ['fatContent', 'proteinContent', 'somaticCellCount'],
        _selectedDateRange,
      );
      setState(() {
        _qualityTrends = result;
      });
    } catch (e) {
      debugPrint('Error loading quality trends: $e');
      rethrow;
    }
  }

  /// Load forecast data
  Future<void> _loadForecast() async {
    try {
      // Calculate the forecast period (next 30 days)
      final today = DateTime.now();
      final forecastPeriod = analytics.DateRange(
        start: today,
        end: today.add(const Duration(days: 30)),
      );

      final result = await widget.analyticsService.predictFutureVolumes(
        forecastPeriod,
      );
      setState(() {
        _forecast = result;
      });
    } catch (e) {
      debugPrint('Error loading forecast: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _buildErrorWidget()
            else
              _buildDashboardContent(),
          ],
        ),
      ),
    );
  }

  /// Build the date range selector
  Widget _buildDateRangeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reception Analytics Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Period: ${DateTimeUtils.formatDate(_selectedDateRange.start)} - ${DateTimeUtils.formatDate(_selectedDateRange.end)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: _showDateRangePicker,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Group by:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                ToggleButtons(
                  isSelected: [_showDailyVolumes, !_showDailyVolumes],
                  onPressed: (index) {
                    setState(() {
                      _showDailyVolumes = index == 0;
                      _loadVolumeData();
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Daily'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Weekly'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show date range picker dialog
  Future<void> _showDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: _selectedDateRange.start,
      end: _selectedDateRange.end,
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = analytics.DateRange(
          start: pickedRange.start,
          end: pickedRange.end,
        );
      });
      _loadData();
    }
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the main dashboard content
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milk Reception Summary',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildSummaryCards(),
        const SizedBox(height: 24),

        // Reception volume chart
        _buildVolumeChart(),
        const SizedBox(height: 24),

        // Rejection reasons chart
        _buildRejectionChart(),
        const SizedBox(height: 24),

        // Top suppliers
        _buildTopSuppliers(),
        const SizedBox(height: 24),

        // Forecast
        _buildForecast(),
      ],
    );
  }

  /// Build summary metric cards
  Widget _buildSummaryCards() {
    // Extract summary metrics from volume and rejection data
    final totalVolume = _volumeData?['statistics']?['totalVolume'] ?? 0.0;
    final avgVolume = _volumeData?['statistics']?['averageVolume'] ?? 0.0;
    final rejectionRate = _rejectionData?['rejectionRate'] ?? 0.0;
    final supplierCount = _supplierRankings?['topSuppliers']?.length ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          'Total Volume',
          '${totalVolume.toStringAsFixed(0)} L',
          Icons.water_drop,
          Colors.blue,
        ),
        _buildMetricCard(
          'Avg. Daily Volume',
          '${avgVolume.toStringAsFixed(0)} L',
          Icons.show_chart,
          Colors.green,
        ),
        _buildMetricCard(
          'Rejection Rate',
          '${rejectionRate.toStringAsFixed(1)}%',
          Icons.cancel,
          Colors.red,
        ),
        _buildMetricCard(
          'Active Suppliers',
          supplierCount.toString(),
          Icons.people,
          Colors.purple,
        ),
      ],
    );
  }

  /// Build a metric card
  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build volume chart card
  Widget _buildVolumeChart() {
    if (_volumeData == null || _volumeData!['volumeData'] == null) {
      return const SizedBox();
    }

    // Create mock data for demonstration
    // In a real implementation, we would use _volumeData to build the chart
    final mockReceptions = [
      MilkReceptionModel(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        supplierId: 'S1',
        supplierName: 'Supplier 1',
        vehiclePlate: 'ABC123',
        driverName: 'John Doe',
        quantityLiters: 1200,
        milkType: MilkType.rawCow,
        containerType: ContainerType.bulk,
        containerCount: 1,
        initialObservations: 'Good',
        receptionStatus: ReceptionStatus.accepted,
        receivingEmployeeId: 'E1',
        temperatureAtArrival: 4.5,
        smell: 'Normal',
        appearance: 'White',
        hasVisibleContamination: false,
      ),
      MilkReceptionModel(
        id: '2',
        timestamp: DateTime.now().subtract(const Duration(days: 9)),
        supplierId: 'S1',
        supplierName: 'Supplier 1',
        vehiclePlate: 'ABC123',
        driverName: 'John Doe',
        quantityLiters: 1350,
        milkType: MilkType.rawCow,
        containerType: ContainerType.bulk,
        containerCount: 1,
        initialObservations: 'Good',
        receptionStatus: ReceptionStatus.accepted,
        receivingEmployeeId: 'E1',
        temperatureAtArrival: 4.2,
        smell: 'Normal',
        appearance: 'White',
        hasVisibleContamination: false,
      ),
      MilkReceptionModel(
        id: '3',
        timestamp: DateTime.now().subtract(const Duration(days: 8)),
        supplierId: 'S2',
        supplierName: 'Supplier 2',
        vehiclePlate: 'XYZ789',
        driverName: 'Jane Smith',
        quantityLiters: 980,
        milkType: MilkType.rawCow,
        containerType: ContainerType.bulk,
        containerCount: 1,
        initialObservations: 'Good',
        receptionStatus: ReceptionStatus.accepted,
        receivingEmployeeId: 'E2',
        temperatureAtArrival: 4.8,
        smell: 'Normal',
        appearance: 'White',
        hasVisibleContamination: false,
      ),
    ];

    // Convert analytics date range to chart date range
    final chartDateRange = DateRange(
      start: _selectedDateRange.start,
      end: _selectedDateRange.end,
    );

    // Convert analytics group by to chart group by
    final chartGroupBy = _showDailyVolumes ? GroupBy.day : GroupBy.week;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Milk Reception Volumes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ReceptionVolumeChart(
              receptions: mockReceptions,
              dateRange: chartDateRange,
              groupBy: chartGroupBy,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }

  /// Build rejection chart card
  Widget _buildRejectionChart() {
    if (_rejectionData == null || _rejectionData!['rejectionReasons'] == null) {
      return const SizedBox();
    }

    // Create mock data for demonstration
    // In a real implementation, we would use _rejectionData to build the chart
    final rejectionReasons = [
      RejectionReasonData(reason: 'High Temperature', count: 15),
      RejectionReasonData(reason: 'Abnormal Smell', count: 8),
      RejectionReasonData(reason: 'Abnormal Appearance', count: 5),
      RejectionReasonData(reason: 'Visible Contamination', count: 3),
      RejectionReasonData(reason: 'pH Out of Range', count: 2),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rejection Reasons',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: RejectionReasonsChart(
                    rejectionData: rejectionReasons,
                    diameter: 180,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Rejections: ${_rejectionData?['rejectedReceptions'] ?? 0}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Most Common: High Temperature',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to detailed rejection analysis
                        },
                        child: const Text('View Detailed Analysis'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build top suppliers card
  Widget _buildTopSuppliers() {
    if (_supplierRankings == null ||
        _supplierRankings!['topSuppliers'] == null) {
      return const SizedBox();
    }

    // Create mock data for demonstration
    final mockSupplierData = (_supplierRankings!['topSuppliers'] as List)
        .map((supplier) => SupplierMetricData(
              supplierId: supplier['supplierId'] as String,
              supplierName: supplier['supplierName'] as String,
              value: supplier['value'] as double,
            ))
        .toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performing Suppliers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SupplierComparisonChart(
                supplierData: mockSupplierData,
                metric: SupplierMetric.volume,
                title: 'Total Volume (L)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build forecast card
  Widget _buildForecast() {
    if (_forecast == null || _forecast!['forecast'] == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume Forecast (Next 30 Days)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildForecastMetric(
                    'Forecasted Total',
                    '38,500 L',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildForecastMetric(
                    'Daily Average',
                    '1,283 L',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildForecastMetric(
                    'Trend',
                    '+5.2%',
                    Icons.show_chart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to detailed forecast view
                },
                child: const Text('View Detailed Forecast'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build forecast metric
  Widget _buildForecastMetric(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
