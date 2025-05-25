import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cycle_count_item.dart';
import '../../domain/entities/cycle_count_sheet.dart';
import '../providers/cycle_count_sheet_repository_provider.dart';

class CycleCountReportingScreen extends ConsumerWidget {
  const CycleCountReportingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetRepo = ref.watch(cycleCountSheetRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count Reporting')),
      body: FutureBuilder<List<CycleCountSheet>>(
        future: sheetRepo.getSheets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sheets = snapshot.data!;
          int totalSheets = sheets.length;
          int completedSheets = sheets
              .where((s) => s.status == 'Completed' || s.status == 'Adjusted')
              .length;
          int pendingSheets = sheets
              .where((s) => s.status == 'Pending' || s.status == 'In Progress')
              .length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.blue[50],
                child: ListTile(
                  title: const Text('Summary',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Sheets: $totalSheets'),
                      Text('Completed/Adjusted: $completedSheets'),
                      Text('Pending/In Progress: $pendingSheets'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Discrepancy Report',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ...sheets.map((sheet) => FutureBuilder<List<CycleCountItem>>(
                    future: sheetRepo.getSheetItems(sheet.sheetId),
                    builder: (context, itemSnap) {
                      if (!itemSnap.hasData) return const SizedBox.shrink();
                      final items = itemSnap.data!;
                      final discrepancies = items
                          .where((i) => (i.discrepancyQuantity ?? 0) != 0)
                          .toList();
                      if (discrepancies.isEmpty) return const SizedBox.shrink();
                      return ExpansionTile(
                        title: Text(
                            'Sheet: ${sheet.sheetId} | Warehouse: ${sheet.warehouseId}'),
                        subtitle: Text('Due: ${sheet.dueDate.toLocal()}'),
                        children: [
                          DataTable(
                            columns: const [
                              DataColumn(label: Text('Item ID')),
                              DataColumn(label: Text('Expected')),
                              DataColumn(label: Text('Counted')),
                              DataColumn(label: Text('Discrepancy')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: discrepancies
                                .map((item) => DataRow(cells: [
                                      DataCell(Text(item.inventoryItemId)),
                                      DataCell(Text(
                                          item.expectedQuantity.toString())),
                                      DataCell(Text(
                                          item.countedQuantity?.toString() ??
                                              '-')),
                                      DataCell(Text(item.discrepancyQuantity
                                              ?.toString() ??
                                          '-')),
                                      DataCell(Text(item.status)),
                                    ]))
                                .toList(),
                          ),
                        ],
                      );
                    },
                  )),
            ],
          );
        },
      ),
    );
  }
}
