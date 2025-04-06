import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InventoryValueChart extends StatelessWidget {
  const InventoryValueChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - in a real app, this would come from a provider
    final List<InventoryValueData> chartData = [
      InventoryValueData(DateTime(2023, 1, 1), 110000),
      InventoryValueData(DateTime(2023, 2, 1), 130000),
      InventoryValueData(DateTime(2023, 3, 1), 120000),
      InventoryValueData(DateTime(2023, 4, 1), 140000),
      InventoryValueData(DateTime(2023, 5, 1), 125000),
      InventoryValueData(DateTime(2023, 6, 1), 135000),
      InventoryValueData(DateTime(2023, 7, 1), 150000),
    ];

    return SfCartesianChart(
      title: ChartTitle(
        text: 'Inventory Value Over Time',
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      legend: Legend(isVisible: false),
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.MMM(),
        intervalType: DateTimeIntervalType.months,
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}',
        numberFormat: NumberFormat.compact(),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        AreaSeries<InventoryValueData, DateTime>(
          dataSource: chartData,
          xValueMapper: (InventoryValueData data, _) => data.date,
          yValueMapper: (InventoryValueData data, _) => data.value,
          name: 'Inventory Value',
          color: Colors.blue.withOpacity(0.6),
          borderColor: Colors.blue,
          borderWidth: 2,
        ),
        LineSeries<InventoryValueData, DateTime>(
          dataSource: chartData,
          xValueMapper: (InventoryValueData data, _) => data.date,
          yValueMapper: (InventoryValueData data, _) => data.value,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }
}

class InventoryValueData {

  InventoryValueData(this.date, this.value);
  final DateTime date;
  final double value;
}
