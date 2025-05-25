import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cycle_count_sheet_repository_provider.dart';
import '../../domain/entities/cycle_count_sheet.dart';
import '../../domain/entities/cycle_count_item.dart';

class CycleCountActivityDashboardScreen extends ConsumerStatefulWidget {
  const CycleCountActivityDashboardScreen({super.key});
  @override
  ConsumerState<CycleCountActivityDashboardScreen> createState() =>
      _CycleCountActivityDashboardScreenState();
}

class _CycleCountActivityDashboardScreenState
    extends ConsumerState<CycleCountActivityDashboardScreen> {
  String? _userFilter;
  String? _warehouseFilter;
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final sheetRepo = ref.watch(cycleCountSheetRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count Activity Dashboard')),
      body: FutureBuilder<List<CycleCountSheet>>(
        future: sheetRepo.getSheets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var sheets = snapshot.data!;
          // Filtering
          if (_userFilter != null && _userFilter!.isNotEmpty) {
            sheets =
                sheets.where((s) => s.assignedUserId == _userFilter).toList();
          }
          if (_warehouseFilter != null && _warehouseFilter!.isNotEmpty) {
            sheets =
                sheets.where((s) => s.warehouseId == _warehouseFilter).toList();
          }
          if (_statusFilter != null && _statusFilter!.isNotEmpty) {
            sheets = sheets.where((s) => s.status == _statusFilter).toList();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Filter by User ID'),
                        onChanged: (v) => setState(() => _userFilter = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Filter by Warehouse'),
                        onChanged: (v) => setState(() => _warehouseFilter = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        hint: const Text('Status'),
                        isExpanded: true,
                        items: [
                          null,
                          'Pending',
                          'In Progress',
                          'Completed',
                          'Adjusted',
                          'Requires Review'
                        ]
                            .map((s) => DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s ?? 'All'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _statusFilter = v),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    for (final sheet in sheets)
                      Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: ExpansionTile(
                          title: Text(
                              'Sheet: ${sheet.sheetId} | Warehouse: ${sheet.warehouseId}'),
                          subtitle: Text(
                              'User: ${sheet.assignedUserId} | Status: ${sheet.status} | Due: ${sheet.dueDate.toLocal()}'),
                          children: [
                            FutureBuilder<List<CycleCountItem>>(
                              future: sheetRepo.getSheetItems(sheet.sheetId),
                              builder: (context, itemSnap) {
                                if (!itemSnap.hasData) {
                                  return const SizedBox.shrink();
                                }
                                final items = itemSnap.data!;
                                return DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Item ID')),
                                    DataColumn(label: Text('Expected')),
                                    DataColumn(label: Text('Counted')),
                                    DataColumn(label: Text('Discrepancy')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  rows: items
                                      .map((item) => DataRow(cells: [
                                            DataCell(
                                                Text(item.inventoryItemId)),
                                            DataCell(Text(item.expectedQuantity
                                                .toString())),
                                            DataCell(Text(item.countedQuantity
                                                    ?.toString() ??
                                                '-')),
                                            DataCell(Text(item
                                                    .discrepancyQuantity
                                                    ?.toString() ??
                                                '-')),
                                            DataCell(Text(item.status)),
                                          ]))
                                      .toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
