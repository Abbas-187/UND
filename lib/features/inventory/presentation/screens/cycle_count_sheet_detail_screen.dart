import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cycle_count_item.dart';
import '../../domain/entities/cycle_count_sheet.dart';
import '../providers/cycle_count_sheet_repository_provider.dart';

class CycleCountSheetDetailScreen extends ConsumerStatefulWidget {
  const CycleCountSheetDetailScreen({super.key, required this.sheetId});
  final String sheetId;

  @override
  ConsumerState<CycleCountSheetDetailScreen> createState() =>
      _CycleCountSheetDetailScreenState();
}

class _CycleCountSheetDetailScreenState
    extends ConsumerState<CycleCountSheetDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;
  bool _completed = false;
  CycleCountSheet? _sheet;

  Future<void> _loadSheet() async {
    final sheetRepo = ref.read(cycleCountSheetRepositoryProvider);
    _sheet = await sheetRepo.getSheet(widget.sheetId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadSheet();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetRepo = ref.watch(cycleCountSheetRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count Sheet')),
      body: FutureBuilder<List<CycleCountItem>>(
        future: sheetRepo.getSheetItems(widget.sheetId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final item in items)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('Item: ${item.inventoryItemId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expected: ${item.expectedQuantity}'),
                        if (item.batchLotNumber != null)
                          Text('Batch: ${item.batchLotNumber}'),
                        Text('Status: ${item.status}'),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _controllers[item.countItemId] ??=
                            TextEditingController(
                          text: item.countedQuantity?.toString() ?? '',
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Counted'),
                        enabled: !_completed && item.status == 'Pending Count',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (!_completed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Progress'),
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              final items =
                                  await sheetRepo.getSheetItems(widget.sheetId);
                              for (final item in items) {
                                final ctrl = _controllers[item.countItemId];
                                if (ctrl != null && ctrl.text.isNotEmpty) {
                                  final counted = double.tryParse(ctrl.text);
                                  if (counted != null) {
                                    await sheetRepo.updateSheetItem(
                                      item.copyWith(
                                          countedQuantity: counted,
                                          countTimestamp: DateTime.now(),
                                          status: 'Counted'),
                                    );
                                  }
                                }
                              }
                              setState(() => _saving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Progress Saved')));
                            },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark Completed'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              final items =
                                  await sheetRepo.getSheetItems(widget.sheetId);
                              for (final item in items) {
                                final ctrl = _controllers[item.countItemId];
                                if (ctrl != null && ctrl.text.isNotEmpty) {
                                  final counted = double.tryParse(ctrl.text);
                                  if (counted != null) {
                                    await sheetRepo.updateSheetItem(
                                      item.copyWith(
                                          countedQuantity: counted,
                                          countTimestamp: DateTime.now(),
                                          status: 'Counted'),
                                    );
                                  }
                                }
                              }
                              // Update sheet status to Completed
                              if (_sheet != null) {
                                await sheetRepo.updateSheet(
                                    _sheet!.copyWith(status: 'Completed'));
                              }
                              setState(() {
                                _saving = false;
                                _completed = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Sheet Marked Completed')));
                            },
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
