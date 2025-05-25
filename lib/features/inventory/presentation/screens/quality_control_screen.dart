import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/quality_parameters_provider.dart';
import '../widgets/quality_status_chip.dart';

class QualityControlScreen extends ConsumerWidget {
  const QualityControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTestsAsync = ref.watch(pendingQualityTestsProvider);
    void showSnack(String msg, {Color? color}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: color,
            duration: const Duration(seconds: 2)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Quality Control'),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(pendingQualityTestsProvider),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: pendingTestsAsync.when(
          data: (tests) {
            if (tests.isEmpty) {
              return const Center(
                child: Text(
                  'No pending quality tests.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return AnimatedList(
              key: GlobalKey<AnimatedListState>(),
              initialItemCount: tests.length,
              itemBuilder: (context, index, animation) {
                final test = tests[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  test.parameterName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              QualityStatusChip(status: test.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('Value: ',
                                  style: TextStyle(color: Colors.grey[700])),
                              Text('${test.value}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          if (test.fatContent != null)
                            Row(
                              children: [
                                Text('Fat: ',
                                    style: TextStyle(color: Colors.grey[700])),
                                Text('${test.fatContent}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          if (test.proteinContent != null)
                            Row(
                              children: [
                                Text('Protein: ',
                                    style: TextStyle(color: Colors.grey[700])),
                                Text('${test.proteinContent}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          if (test.testDate != null)
                            Row(
                              children: [
                                const Icon(Icons.event,
                                    size: 16, color: Colors.blueGrey),
                                const SizedBox(width: 4),
                                Text('Tested: ${test.testDate}'),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final notifier = ref.read(
                                      itemQualityParametersProvider(test.id)
                                          .notifier);
                                  await notifier
                                      .approveQualityParameters(test.id);
                                  showSnack('Test approved',
                                      color: Colors.green[700]);
                                  ref.invalidate(pendingQualityTestsProvider);
                                },
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final reason =
                                      await _showRejectionDialog(context);
                                  if (reason != null && reason.isNotEmpty) {
                                    final notifier = ref.read(
                                        itemQualityParametersProvider(test.id)
                                            .notifier);
                                    await notifier.rejectQualityParameters(
                                        test.id, reason);
                                    showSnack('Test rejected',
                                        color: Colors.red[700]);
                                    ref.invalidate(pendingQualityTestsProvider);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Future<String?> _showRejectionDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Quality Test'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
