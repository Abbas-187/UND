import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

// Example data structure for chart
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

// Placeholder for a provider that fetches chart data
final chartDataProvider = FutureProvider<List<ChartData>>((ref) async {
  // Simulate network delay
  await Future.delayed(Duration(seconds: 1));
  // Generate some random data for demonstration
  final random = Random();
  return List.generate(7, (index) {
    return ChartData('Day ${index + 1}', random.nextDouble() * 100);
  });
});

class InteractiveChartsWidget extends ConsumerStatefulWidget {
  @override
  _InteractiveChartsWidgetState createState() =>
      _InteractiveChartsWidgetState();
}

class _InteractiveChartsWidgetState
    extends ConsumerState<InteractiveChartsWidget> {
  String _selectedChartType = 'Line'; // Default chart type
  TooltipBehavior? _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final asyncChartData = ref.watch(chartDataProvider);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Interactive AI Analytics',
                    style: Theme.of(context).textTheme.titleLarge),
                DropdownButton<String>(
                  value: _selectedChartType,
                  items: <String>['Line', 'Bar', 'Pie']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedChartType = newValue!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            asyncChartData.when(
              data: (data) {
                if (data.isEmpty) {
                  return Center(child: Text('No data available for chart.'));
                }
                return SizedBox(
                  height: 300,
                  child: _buildChart(data),
                );
              },
              loading: () => SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SizedBox(
                  height: 300,
                  child: Center(
                      child: Text('Error loading chart data: $err',
                          style: TextStyle(color: Colors.red)))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<ChartData> data) {
    if (_selectedChartType == 'Line') {
      return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        tooltipBehavior: _tooltipBehavior,
        series: <ChartSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
              dataSource: data,
              xValueMapper: (ChartData sales, _) => sales.x,
              yValueMapper: (ChartData sales, _) => sales.y)
        ],
      );
    } else if (_selectedChartType == 'Bar') {
      // Implement Bar chart similarly
      return Center(child: Text('Bar Chart (To be implemented)'));
    }
    // Implement Pie chart similarly
    return Center(child: Text('Pie Chart (To be implemented)'));
  }
}
