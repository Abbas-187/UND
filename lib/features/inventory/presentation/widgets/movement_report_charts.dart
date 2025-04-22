import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/models/inventory_movement_type.dart';

/// Line chart: Movements over time (by day)
Widget movementLineChart(List<InventoryMovementModel> movements) {
  if (movements.isEmpty) {
    return const Center(child: Text('No data for line chart'));
  }
  // Group by day
  final Map<DateTime, int> counts = {};
  for (final m in movements) {
    final day = DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
    counts[day] = (counts[day] ?? 0) + 1;
  }
  final sortedDays = counts.keys.toList()..sort();
  final spots = <FlSpot>[];
  for (int i = 0; i < sortedDays.length; i++) {
    spots.add(FlSpot(i.toDouble(), counts[sortedDays[i]]!.toDouble()));
  }
  return Column(
    children: [
      LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData:
                  BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
            ),
          ],
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < sortedDays.length) {
                    final d = sortedDays[idx];
                    return Text('${d.month}/${d.day}',
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true, border: Border.all(color: Colors.grey.shade300)),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.blue, 'Movements'),
        ],
      ),
    ],
  );
}

/// Bar chart: Movements by type
Widget movementBarChartByType(List<InventoryMovementModel> movements) {
  if (movements.isEmpty) {
    return const Center(child: Text('No data for bar chart'));
  }
  final typeCounts = <InventoryMovementType, int>{};
  for (final m in movements) {
    typeCounts[m.movementType] = (typeCounts[m.movementType] ?? 0) + 1;
  }
  final types = typeCounts.keys.toList();
  final barGroups = <BarChartGroupData>[];
  for (int i = 0; i < types.length; i++) {
    barGroups.add(
      BarChartGroupData(x: i, barRods: [
        BarChartRodData(
            toY: typeCounts[types[i]]!.toDouble(),
            color: Colors.green,
            width: 18),
      ]),
    );
  }
  return Column(
    children: [
      BarChart(
        BarChartData(
          barGroups: barGroups,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < types.length) {
                    return Text(types[idx].toString().split('.').last,
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true, border: Border.all(color: Colors.grey.shade300)),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        children: [
          for (int i = 0; i < types.length; i++)
            _legendItem(Colors.green, types[i].toString().split('.').last),
        ],
      ),
    ],
  );
}

/// Pie chart: Movements by status
Widget movementPieChartByStatus(List<InventoryMovementModel> movements) {
  if (movements.isEmpty) {
    return const Center(child: Text('No data for pie chart'));
  }
  final statusCounts = <String, int>{};
  for (final m in movements) {
    final status = m.approvalStatus.toString().split('.').last;
    statusCounts[status] = (statusCounts[status] ?? 0) + 1;
  }
  final statuses = statusCounts.keys.toList();
  final total = statusCounts.values.fold(0, (a, b) => a + b);
  final colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal
  ];
  return Column(
    children: [
      PieChart(
        PieChartData(
          sections: List.generate(statuses.length, (i) {
            final percent =
                total == 0 ? 0.0 : (statusCounts[statuses[i]]! / total) * 100;
            return PieChartSectionData(
              color: colors[i % colors.length],
              value: statusCounts[statuses[i]]!.toDouble(),
              title: '${statuses[i]}\n${percent.toStringAsFixed(1)}%',
              radius: 50,
              titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            );
          }),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        children: [
          for (int i = 0; i < statuses.length; i++)
            _legendItem(colors[i % colors.length], statuses[i]),
        ],
      ),
    ],
  );
}

/// Grouped bar chart: Movements by location & type
Widget movementGroupedBarChartByLocationType(
    List<InventoryMovementModel> movements) {
  if (movements.isEmpty) {
    return const Center(child: Text('No data for grouped bar chart'));
  }
  // Group by location and type
  final Map<String, Map<InventoryMovementType, int>> data = {};
  for (final m in movements) {
    final loc = m.sourceLocationName.isNotEmpty
        ? m.sourceLocationName
        : m.destinationLocationName;
    data[loc] ??= {};
    data[loc]![m.movementType] = (data[loc]![m.movementType] ?? 0) + 1;
  }
  final locations = data.keys.toList();
  final types = InventoryMovementType.values;
  final barGroups = <BarChartGroupData>[];
  for (int i = 0; i < locations.length; i++) {
    final rods = <BarChartRodData>[];
    for (int j = 0; j < types.length; j++) {
      final count = data[locations[i]]![types[j]] ?? 0;
      rods.add(BarChartRodData(
        toY: count.toDouble(),
        color: Colors.primaries[j % Colors.primaries.length],
        width: 10,
      ));
    }
    barGroups.add(BarChartGroupData(x: i, barRods: rods));
  }
  return Column(
    children: [
      BarChart(
        BarChartData(
          barGroups: barGroups,
          groupsSpace: 16,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < locations.length) {
                    return Text(locations[idx],
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true, border: Border.all(color: Colors.grey.shade300)),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        children: [
          for (int j = 0; j < types.length; j++)
            _legendItem(Colors.primaries[j % Colors.primaries.length],
                types[j].toString().split('.').last),
        ],
      ),
    ],
  );
}

Widget _legendItem(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 16,
          height: 16,
          color: color,
          margin: const EdgeInsets.only(right: 6)),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
