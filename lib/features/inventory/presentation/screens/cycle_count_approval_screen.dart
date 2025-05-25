import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cycle_count_providers.dart';

class CycleCountApprovalScreen extends ConsumerWidget {
  const CycleCountApprovalScreen({
    super.key,
    required this.sheetId,
    required this.countItemId,
    required this.approverUserId,
  });
  final String sheetId;
  final String countItemId;
  final String approverUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count Approval')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await ref.read(approveCycleCountAdjustmentUseCaseProvider).call(
                      sheetId: sheetId,
                      countItemId: countItemId,
                      approverUserId: approverUserId,
                      approved: true,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adjustment Approved')));
              },
              child: const Text('Approve Adjustment'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(approveCycleCountAdjustmentUseCaseProvider).call(
                      sheetId: sheetId,
                      countItemId: countItemId,
                      approverUserId: approverUserId,
                      approved: false,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adjustment Rejected')));
              },
              child: const Text('Reject Adjustment'),
            ),
          ],
        ),
      ),
    );
  }
}
