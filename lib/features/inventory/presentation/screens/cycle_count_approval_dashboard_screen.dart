import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cycle_count_providers.dart';
import '../providers/cycle_count_sheet_repository_provider.dart';
import '../../domain/entities/cycle_count_item.dart';
import '../../domain/entities/cycle_count_sheet.dart';

class CycleCountApprovalDashboardScreen extends ConsumerWidget {
  const CycleCountApprovalDashboardScreen(
      {super.key, required this.approverUserId});
  final String approverUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetRepo = ref.watch(cycleCountSheetRepositoryProvider);
    return FutureBuilder<List<CycleCountSheet>>(
      future: sheetRepo.getSheets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final sheets = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Cycle Count Approvals')),
          body: ListView(
            children: [
              for (final sheet in sheets)
                FutureBuilder<List<CycleCountItem>>(
                  future: sheetRepo.getSheetItems(sheet.sheetId),
                  builder: (context, itemSnap) {
                    if (!itemSnap.hasData) return const SizedBox.shrink();
                    final reviewItems = itemSnap.data!
                        .where((i) => i.status == 'Requires Review')
                        .toList();
                    if (reviewItems.isEmpty) return const SizedBox.shrink();
                    return ExpansionTile(
                      title: Text(
                          'Sheet: ${sheet.sheetId} | Warehouse: ${sheet.warehouseId}'),
                      subtitle: Text('Due: ${sheet.dueDate.toLocal()}'),
                      children: [
                        for (final item in reviewItems)
                          Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text('Item: ${item.inventoryItemId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Expected: ${item.expectedQuantity}'),
                                  Text(
                                      'Counted: ${item.countedQuantity ?? '-'}'),
                                  Text(
                                      'Discrepancy: ${item.discrepancyQuantity ?? '-'}'),
                                  if (item.batchLotNumber != null)
                                    Text('Batch: ${item.batchLotNumber}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    tooltip: 'Approve',
                                    onPressed: () async {
                                      await ref
                                          .read(
                                              approveCycleCountAdjustmentUseCaseProvider)
                                          .call(
                                            sheetId: sheet.sheetId,
                                            countItemId: item.countItemId,
                                            approverUserId: approverUserId,
                                            approved: true,
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Adjustment Approved')));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    tooltip: 'Reject',
                                    onPressed: () async {
                                      await ref
                                          .read(
                                              approveCycleCountAdjustmentUseCaseProvider)
                                          .call(
                                            sheetId: sheet.sheetId,
                                            countItemId: item.countItemId,
                                            approverUserId: approverUserId,
                                            approved: false,
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Adjustment Rejected')));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
