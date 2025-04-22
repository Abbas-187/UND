import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/report_aggregators.dart';

// 1. Stock Table Widget
class StockTableWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  const StockTableWidget({super.key, required this.aggregators});

  @override
  Widget build(BuildContext context) {
    final data = aggregators.stockByItem();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Unit')),
        ],
        rows: data
            .map((row) => DataRow(cells: [
                  DataCell(Text(row['name'].toString())),
                  DataCell(Text(row['category'].toString())),
                  DataCell(Text(row['quantity'].toString())),
                  DataCell(Text(row['unit'].toString())),
                ]))
            .toList(),
      ),
    );
  }
}

// 1. Stock Bar Chart Widget (by category)
class StockBarChartWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  const StockBarChartWidget({super.key, required this.aggregators});

  @override
  Widget build(BuildContext context) {
    final data = aggregators.stockByCategory();
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: (data[i]['quantity'] as num).toDouble(),
                  color: Colors.blue,
                ),
              ]),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Text(data[idx]['category'].toString()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. Expiry Table Widget
class ExpiryTableWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  const ExpiryTableWidget({super.key, required this.aggregators});

  @override
  Widget build(BuildContext context) {
    final data = aggregators.expiryStatus();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Expiry Date')),
          DataColumn(label: Text('Status')),
        ],
        rows: data
            .map((row) => DataRow(cells: [
                  DataCell(Text(row['name'].toString())),
                  DataCell(Text(row['expiryDate']?.toString() ?? '-')),
                  DataCell(Text(row['status'].toString())),
                ]))
            .toList(),
      ),
    );
  }
}

// 2. Expiry Pie Chart Widget
class ExpiryPieChartWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  const ExpiryPieChartWidget({super.key, required this.aggregators});

  @override
  Widget build(BuildContext context) {
    final counts = aggregators.expiryStatusCounts();
    final colors = [Colors.red, Colors.orange, Colors.green, Colors.grey];
    final statusLabels = ['expired', 'expiring_soon', 'safe', 'no_expiry'];
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: [
            for (int i = 0; i < statusLabels.length; i++)
              PieChartSectionData(
                color: colors[i],
                value: (counts[statusLabels[i]] ?? 0).toDouble(),
                title: statusLabels[i],
              ),
          ],
        ),
      ),
    );
  }
}

// 3. Valuation Table Widget
class ValuationTableWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  const ValuationTableWidget({super.key, required this.aggregators});

  @override
  Widget build(BuildContext context) {
    final data = aggregators.valuationByItem();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Unit')),
          DataColumn(label: Text('Unit Cost (﷼)')),
          DataColumn(label: Text('Total Value (﷼)')),
        ],
        rows: data
            .map((row) => DataRow(cells: [
                  DataCell(Text(row['name'].toString())),
                  DataCell(Text(row['category'].toString())),
                  DataCell(Text(row['quantity'].toString())),
                  DataCell(Text(row['unit'].toString())),
                  DataCell(Text(row['unitCost'].toString())),
                  DataCell(Text(row['totalValue'].toString())),
                ]))
            .toList(),
      ),
    );
  }
}

// 3. Valuation Bar Chart Widget (by category)
class ValuationBarChartWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  const ValuationBarChartWidget({super.key, required this.aggregators});

  @override
  Widget build(BuildContext context) {
    final data = aggregators.valuationByCategory();
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: (data[i]['totalValue'] as num).toDouble(),
                  color: Colors.teal,
                ),
              ]),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Text(data[idx]['category'].toString()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 4. Movement Table Widget
class MovementTableWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  const MovementTableWidget({super.key, required this.aggregators});

  @override
  Widget build(BuildContext context) {
    final data = aggregators.movementTable();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Movement ID')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Unit')),
          DataColumn(label: Text('Source')),
          DataColumn(label: Text('Destination')),
        ],
        rows: data
            .map((row) => DataRow(cells: [
                  DataCell(Text(row['movementId'].toString())),
                  DataCell(Text(row['timestamp'].toString().substring(0, 16))),
                  DataCell(Text(row['type'].toString())),
                  DataCell(Text(row['status'].toString())),
                  DataCell(Text(row['item'].toString())),
                  DataCell(Text(row['quantity'].toString())),
                  DataCell(Text(row['unit'].toString())),
                  DataCell(Text(row['source'].toString())),
                  DataCell(Text(row['destination'].toString())),
                ]))
            .toList(),
      ),
    );
  }
}

// 4. Movement Bar Chart Widget (by type/status/date)
class MovementBarChartWidget extends StatelessWidget {
  final ReportAggregators aggregators;
  final String breakdown; // 'type', 'status', or 'date'
  const MovementBarChartWidget(
      {super.key, required this.aggregators, this.breakdown = 'type'});

  @override
  Widget build(BuildContext context) {
    Map<String, int> data;
    Color color = Colors.deepPurple;
    if (breakdown == 'type') {
      data = aggregators.movementCountByType();
      color = Colors.deepPurple;
    } else if (breakdown == 'status') {
      data = aggregators.movementCountByStatus();
      color = Colors.orange;
    } else {
      data = aggregators.movementCountByDate();
      color = Colors.blueGrey;
    }
    final keys = data.keys.toList();
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (int i = 0; i < keys.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: (data[keys[i]] ?? 0).toDouble(),
                  color: color,
                ),
              ]),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= keys.length) return const SizedBox();
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Text(keys[idx]),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
