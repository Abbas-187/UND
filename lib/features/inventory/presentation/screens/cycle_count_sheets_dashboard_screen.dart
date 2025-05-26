import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cycle_count_sheet.dart';
import '../providers/cycle_count_sheet_repository_provider.dart';
import 'cycle_count_reporting_screen.dart';

class CycleCountSheetsDashboardScreen extends ConsumerStatefulWidget {
  const CycleCountSheetsDashboardScreen({super.key, this.userId});
  final String? userId;

  @override
  ConsumerState<CycleCountSheetsDashboardScreen> createState() =>
      _CycleCountSheetsDashboardScreenState();
}

class _CycleCountSheetsDashboardScreenState
    extends ConsumerState<CycleCountSheetsDashboardScreen> {
  String? _statusFilter;
  String? _warehouseFilter;
  @override
  Widget build(BuildContext context) {
    final sheetRepo = ref.watch(cycleCountSheetRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count Sheets')),
      body: FutureBuilder<List<CycleCountSheet>>(
        future: sheetRepo.getSheets(assignedUserId: widget.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var sheets = snapshot.data!;
          // Filtering
          if (_statusFilter != null && _statusFilter!.isNotEmpty) {
            sheets = sheets.where((s) => s.status == _statusFilter).toList();
          }
          if (_warehouseFilter != null && _warehouseFilter!.isNotEmpty) {
            sheets =
                sheets.where((s) => s.warehouseId == _warehouseFilter).toList();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        hint: const Text('Filter by Status'),
                        isExpanded: true,
                        items: [
                          null,
                          'Pending',
                          'In Progress',
                          'Completed',
                          'Adjusted',
                          'Requires Review',
                          'Cancelled'
                        ]
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status ?? 'All'),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _statusFilter = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration:
                            const InputDecoration(labelText: 'Warehouse'),
                        onChanged: (val) =>
                            setState(() => _warehouseFilter = val),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      tooltip: 'Reporting',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const CycleCountReportingScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sheets.length,
                  itemBuilder: (context, idx) {
                    final sheet = sheets[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('Sheet: ${sheet.sheetId}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${sheet.status}'),
                            Text('Due: ${sheet.dueDate.toLocal()}'),
                            Text('Warehouse: ${sheet.warehouseId}'),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/cycle-count-sheet-detail',
                            arguments: sheet.sheetId,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Sheet'),
        onPressed: () {
          Navigator.of(context).pushNamed('/cycle-count-sheet-create');
        },
      ),
    );
  }
}
