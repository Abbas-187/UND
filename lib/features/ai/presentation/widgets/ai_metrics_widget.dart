import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder for a provider that fetches AI system metrics
final aiSystemMetricsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  // Simulate network delay and fetching data
  await Future.delayed(Duration(seconds: 1));
  return {
    'total_queries': 12345,
    'avg_response_time_ms': 750.5,
    'accuracy_rate_percent': 96.8,
    'active_models': 3,
    'cost_last_24h_usd': 12.34,
  };
});

class AIMetricsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMetrics = ref.watch(aiSystemMetricsProvider);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI System Metrics',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            asyncMetrics.when(
              data: (metrics) => _buildMetricsGrid(context, metrics),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading metrics: $err',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, Map<String, dynamic> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5, // Adjust for better layout
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildMetricItem(context, 'Total Queries',
            metrics['total_queries']?.toString() ?? 'N/A'),
        _buildMetricItem(context, 'Avg. Response',
            '${metrics['avg_response_time_ms']?.toStringAsFixed(1) ?? 'N/A'} ms'),
        _buildMetricItem(context, 'Accuracy',
            '${metrics['accuracy_rate_percent']?.toStringAsFixed(1) ?? 'N/A'} %'),
        _buildMetricItem(context, 'Active Models',
            metrics['active_models']?.toString() ?? 'N/A'),
        _buildMetricItem(context, 'Cost (24h)',
            '\$${metrics['cost_last_24h_usd']?.toStringAsFixed(2) ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
