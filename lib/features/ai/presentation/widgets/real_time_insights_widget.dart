import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder for a provider that streams or fetches real-time insights
final realTimeInsightProvider = StreamProvider<String>((ref) {
  // In a real app, this would connect to a WebSocket, listen to a stream from a service,
  // or periodically fetch new insights.
  return Stream.periodic(Duration(seconds: 5), (count) {
    final insights = [
      "Milk production is up 5% this week.",
      "High somatic cell count detected in Tank 3.",
      "Feed consumption in Barn A is lower than average.",
      "Weather forecast: High temperatures expected, ensure adequate water for herds.",
      "New order received from Customer XYZ for 1000L of pasteurized milk."
    ];
    return "Insight ${count % insights.length}: ${insights[count % insights.length]}";
  });
});

class RealTimeInsightsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInsight = ref.watch(realTimeInsightProvider);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Real-time AI Insights',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            asyncInsight.when(
              data: (insight) =>
                  Text(insight, style: Theme.of(context).textTheme.bodyMedium),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading insights: $err',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
