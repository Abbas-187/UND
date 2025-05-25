import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/usecases/analytics/customer_demand_analytics_usecase.dart';
import '../providers/inventory_analytics_provider.dart';

class DemandInsightsView extends ConsumerStatefulWidget {
  const DemandInsightsView({super.key});

  @override
  ConsumerState<DemandInsightsView> createState() => _DemandInsightsViewState();
}

class _DemandInsightsViewState extends ConsumerState<DemandInsightsView> {
  String? selectedItemId;
  DateTime periodStart = DateTime.now().subtract(const Duration(days: 90));
  DateTime periodEnd = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final demandInsights = ref.watch(demandInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Demand Insights'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(demandInsightsProvider),
          ),
        ],
      ),
      body: demandInsights.when(
        data: (insights) => _buildInsightsContent(insights),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text('Error loading demand insights: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(demandInsightsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsContent(Map<String, DemandInsights> insights) {
    if (insights.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No demand insights available'),
            SizedBox(height: 8),
            Text('Try adjusting the date range or check your data sources.'),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: Row(
            children: [
              // Left panel - Item list
              SizedBox(
                width: 300,
                child: _buildItemList(insights),
              ),
              const VerticalDivider(width: 1),
              // Right panel - Detailed insights
              Expanded(
                child: selectedItemId != null &&
                        insights.containsKey(selectedItemId)
                    ? _buildDetailedInsights(insights[selectedItemId]!)
                    : _buildOverviewInsights(insights),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Period: ${_formatDate(periodStart)} - ${_formatDate(periodEnd)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change'),
                  onPressed: _showDateRangePicker,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('Analyze'),
            onPressed: () => ref.refresh(demandInsightsProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(Map<String, DemandInsights> insights) {
    final sortedInsights = insights.entries.toList()
      ..sort(
          (a, b) => b.value.totalCustomers.compareTo(a.value.totalCustomers));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                Icon(Icons.inventory_2, size: 20),
                SizedBox(width: 8),
                Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sortedInsights.length,
              itemBuilder: (context, index) {
                final entry = sortedInsights[index];
                final insight = entry.value;
                final isSelected = selectedItemId == entry.key;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.blue.shade50,
                  leading: CircleAvatar(
                    backgroundColor: _getDemandTrendColor(
                        insight.demandTrendAnalysis.overallTrend),
                    child: Text(
                      insight.totalCustomers.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(
                    insight.itemName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insight.category),
                      Text(
                        '${insight.totalCustomers} customers',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDemandTrendColor(
                              insight.demandTrendAnalysis.overallTrend),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          insight.demandTrendAnalysis.overallTrend.label,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${insight.aggregatedDemandForecast.confidenceLevel.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      selectedItemId = entry.key;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewInsights(Map<String, DemandInsights> insights) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demand Analytics Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildOverviewCard(
                  'Total Items Analyzed',
                  insights.length.toString(),
                  Icons.inventory_2,
                  Colors.blue,
                ),
                _buildOverviewCard(
                  'Total Customers',
                  insights.values
                      .fold<int>(
                          0, (sum, insight) => sum + insight.totalCustomers)
                      .toString(),
                  Icons.people,
                  Colors.green,
                ),
                _buildOverviewCard(
                  'Average Confidence',
                  '${(insights.values.fold<double>(0.0, (sum, insight) => sum + insight.aggregatedDemandForecast.confidenceLevel) / insights.length).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
                _buildOverviewCard(
                  'High Risk Items',
                  insights.values
                      .where(
                          (insight) => insight.customerConcentrationRisk > 0.7)
                      .length
                      .toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInsights(DemandInsights insight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightHeader(insight),
          const SizedBox(height: 24),
          _buildMetricsGrid(insight),
          const SizedBox(height: 24),
          _buildDemandForecastChart(insight),
          const SizedBox(height: 24),
          _buildCustomerSegmentChart(insight),
          const SizedBox(height: 24),
          _buildRecommendations(insight),
        ],
      ),
    );
  }

  Widget _buildInsightHeader(DemandInsights insight) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insight.itemName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                insight.category,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                _getDemandTrendColor(insight.demandTrendAnalysis.overallTrend),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            insight.demandTrendAnalysis.overallTrend.label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(DemandInsights insight) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          'Total Customers',
          insight.totalCustomers.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildMetricCard(
          'Active Customers',
          insight.activeCustomers.toString(),
          Icons.person_outline,
          Colors.green,
        ),
        _buildMetricCard(
          'Forecast Confidence',
          '${insight.aggregatedDemandForecast.confidenceLevel.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildMetricCard(
          'Concentration Risk',
          '${(insight.customerConcentrationRisk * 100).toStringAsFixed(1)}%',
          Icons.warning,
          insight.customerConcentrationRisk > 0.7 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemandForecastChart(DemandInsights insight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demand Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          'Day ${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateForecastSpots(insight),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _generateUpperBoundSpots(insight),
                      isCurved: true,
                      color: Colors.blue.withOpacity(0.3),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _generateLowerBoundSpots(insight),
                      isCurved: true,
                      color: Colors.blue.withOpacity(0.3),
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSegmentChart(DemandInsights insight) {
    final segmentData = <CustomerSegment, int>{};
    for (final pattern in insight.customerDemandPatterns) {
      segmentData[pattern.customerSegment] =
          (segmentData[pattern.customerSegment] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Segments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: segmentData.entries.map((entry) {
                    final percentage =
                        (entry.value / insight.totalCustomers) * 100;
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: _getSegmentColor(entry.key),
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: segmentData.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getSegmentColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key.label} (${entry.value})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(DemandInsights insight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...insight.recommendedActions.map((recommendation) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRecommendationColor(recommendation.priority)
                      .withOpacity(0.1),
                  border: Border(
                    left: BorderSide(
                      width: 4,
                      color: _getRecommendationColor(recommendation.priority),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRecommendationColor(
                                recommendation.priority),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            recommendation.priority.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recommendation.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(recommendation.description),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.trending_up,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Impact: ${recommendation.expectedImpact}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.schedule,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Effort: ${recommendation.implementationEffort}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateForecastSpots(DemandInsights insight) {
    final spots = <FlSpot>[];
    final dailyDemand = insight.aggregatedDemandForecast.forecastedDemand /
        insight.forecastPeriod;

    for (int i = 0; i <= insight.forecastPeriod; i += 7) {
      spots.add(FlSpot(i.toDouble(), dailyDemand * i));
    }

    return spots;
  }

  List<FlSpot> _generateUpperBoundSpots(DemandInsights insight) {
    final spots = <FlSpot>[];
    final dailyUpperBound =
        insight.aggregatedDemandForecast.upperBound / insight.forecastPeriod;

    for (int i = 0; i <= insight.forecastPeriod; i += 7) {
      spots.add(FlSpot(i.toDouble(), dailyUpperBound * i));
    }

    return spots;
  }

  List<FlSpot> _generateLowerBoundSpots(DemandInsights insight) {
    final spots = <FlSpot>[];
    final dailyLowerBound =
        insight.aggregatedDemandForecast.lowerBound / insight.forecastPeriod;

    for (int i = 0; i <= insight.forecastPeriod; i += 7) {
      spots.add(FlSpot(i.toDouble(), dailyLowerBound * i));
    }

    return spots;
  }

  Color _getDemandTrendColor(DemandTrend trend) {
    switch (trend) {
      case DemandTrend.increasing:
        return Colors.green;
      case DemandTrend.stable:
        return Colors.blue;
      case DemandTrend.decreasing:
        return Colors.orange;
      case DemandTrend.volatile:
        return Colors.red;
      case DemandTrend.seasonal:
        return Colors.purple;
    }
  }

  Color _getSegmentColor(CustomerSegment segment) {
    switch (segment) {
      case CustomerSegment.vip:
        return Colors.purple;
      case CustomerSegment.regular:
        return Colors.blue;
      case CustomerSegment.occasional:
        return Colors.orange;
      case CustomerSegment.newCustomer:
        return Colors.green;
      case CustomerSegment.atRisk:
        return Colors.red;
    }
  }

  Color _getRecommendationColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return Colors.red;
      case RecommendationPriority.high:
        return Colors.orange;
      case RecommendationPriority.medium:
        return Colors.blue;
      case RecommendationPriority.low:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: periodStart, end: periodEnd),
    );

    if (picked != null) {
      setState(() {
        periodStart = picked.start;
        periodEnd = picked.end;
      });
      ref.refresh(demandInsightsProvider);
    }
  }
}
