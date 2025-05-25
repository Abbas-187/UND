import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/report_aggregators.dart';

// 1. Stock Table Widget
class StockTableWidget extends StatelessWidget {
  const StockTableWidget(
      {super.key, required this.aggregators, this.categoryFilter});
  final ReportAggregators aggregators;
  final String? categoryFilter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: aggregators.stockByItem(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!;
        if (categoryFilter != null) {
          data =
              data.where((row) => row['category'] == categoryFilter).toList();
        }
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
      },
    );
  }
}

// 1. Stock Bar Chart Widget (by category)
class StockBarChartWidget extends StatelessWidget {
  const StockBarChartWidget({super.key, required this.aggregators});
  final ReportAggregators aggregators;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: aggregators.stockByCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
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
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.length) {
                        return const SizedBox();
                      }
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
      },
    );
  }
}

// 2. Expiry Table Widget
class ExpiryTableWidget extends StatelessWidget {
  const ExpiryTableWidget(
      {super.key, required this.aggregators, this.statusFilter});
  final ReportAggregators aggregators;
  final String? statusFilter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: aggregators.expiryStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!;
        if (statusFilter != null) {
          data = data.where((row) => row['status'] == statusFilter).toList();
        }
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
      },
    );
  }
}

// 2. Expiry Pie Chart Widget
class ExpiryPieChartWidget extends StatelessWidget {
  const ExpiryPieChartWidget({super.key, required this.aggregators});
  final ReportAggregators aggregators;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: aggregators.expiryStatusCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final counts = snapshot.data!;
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
      },
    );
  }
}

// 3. Valuation Table Widget
class ValuationTableWidget extends StatelessWidget {
  const ValuationTableWidget(
      {super.key, required this.aggregators, this.categoryFilter});
  final ReportAggregators aggregators;
  final String? categoryFilter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: aggregators.valuationByItem(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!;
        if (categoryFilter != null) {
          data =
              data.where((row) => row['category'] == categoryFilter).toList();
        }
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
      },
    );
  }
}

// 3. Valuation Bar Chart Widget (by category)
class ValuationBarChartWidget extends StatelessWidget {
  const ValuationBarChartWidget({super.key, required this.aggregators});
  final ReportAggregators aggregators;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: aggregators.valuationByCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
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
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.length) {
                        return const SizedBox();
                      }
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
      },
    );
  }
}

// 4. Movement Table Widget
class MovementTableWidget extends StatelessWidget {
  const MovementTableWidget(
      {super.key, required this.aggregators, this.dateRange});
  final ReportAggregators aggregators;
  final DateTimeRange? dateRange;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: aggregators.movementTable(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!;
        if (dateRange != null) {
          data = data.where((row) {
            final date = DateTime.tryParse(row['timestamp'].toString());
            if (date == null) return false;
            return date.isAfter(
                    dateRange!.start.subtract(const Duration(days: 1))) &&
                date.isBefore(dateRange!.end.add(const Duration(days: 1)));
          }).toList();
        }
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
                      DataCell(
                          Text(row['timestamp'].toString().substring(0, 16))),
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
      },
    );
  }
}

// 4. Movement Bar Chart Widget (by type/status/date)
class MovementBarChartWidget extends StatelessWidget {
  // 'type', 'status', or 'date'
  const MovementBarChartWidget(
      {super.key, required this.aggregators, this.breakdown = 'type'});
  final ReportAggregators aggregators;
  final String breakdown;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: () {
        if (breakdown == 'type') {
          return aggregators.movementCountByType();
        } else if (breakdown == 'status') {
          return aggregators.movementCountByStatus();
        } else {
          return aggregators.movementCountByDate();
        }
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final keys = data.keys.toList();
        Color color = Colors.deepPurple;
        if (breakdown == 'status') {
          color = Colors.orange;
        } else if (breakdown == 'date') {
          color = Colors.blueGrey;
        }
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
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= keys.length) {
                        return const SizedBox();
                      }
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
      },
    );
  }
}
