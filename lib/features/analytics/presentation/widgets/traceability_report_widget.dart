import 'package:flutter/material.dart';
import '../../domain/traceability_report_usecase.dart';

class TraceabilityReportWidget extends StatelessWidget {
  const TraceabilityReportWidget({super.key, required this.report});
  final TraceabilityReportResult report;

  @override
  Widget build(BuildContext context) {
    if (report.events.isEmpty) {
      return const Center(child: Text('No traceability events found.'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Timestamp')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Doc ID')),
          DataColumn(label: Text('Employee')),
        ],
        rows: report.events
            .map((e) => DataRow(cells: [
                  DataCell(Text(e.timestamp.toString())),
                  DataCell(Text(e.movementType)),
                  DataCell(Text(e.quantity.toString())),
                  DataCell(Text(e.location)),
                  DataCell(Text(e.documentId ?? '-')),
                  DataCell(Text(e.employeeId ?? '-')),
                ]))
            .toList(),
      ),
    );
  }
}
