import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reason_code.dart';
import '../providers/reason_code_providers.dart';

class ReasonCodeManagementScreen extends ConsumerStatefulWidget {
  const ReasonCodeManagementScreen({super.key});
  @override
  ConsumerState<ReasonCodeManagementScreen> createState() =>
      _ReasonCodeManagementScreenState();
}

class _ReasonCodeManagementScreenState
    extends ConsumerState<ReasonCodeManagementScreen> {
  void _showReasonCodeDialog({ReasonCode? code}) {
    final codeController = TextEditingController(text: code?.reasonCode ?? '');
    final descController = TextEditingController(text: code?.description ?? '');
    final appliesToController =
        TextEditingController(text: code?.appliesTo ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(code == null ? 'Add Reason Code' : 'Edit Reason Code'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Reason Code'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: appliesToController,
                decoration: const InputDecoration(
                    labelText:
                        'Applies To (e.g. CycleCount, ManualAdjustment)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(createReasonCodeUseCaseProvider);
              final updateRepo = ref.read(updateReasonCodeUseCaseProvider);
              final newCode = ReasonCode(
                reasonCodeId: code?.reasonCodeId ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                reasonCode: codeController.text,
                description: descController.text,
                appliesTo: appliesToController.text,
              );
              if (code == null) {
                await repo(newCode);
              } else {
                await updateRepo(newCode);
              }
              if (mounted) setState(() {});
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final getCodes = ref.watch(getReasonCodesUseCaseProvider);
    final deleteCode = ref.read(deleteReasonCodeUseCaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reason Codes Management')),
      body: FutureBuilder<List<ReasonCode>>(
        future: getCodes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final codes = snapshot.data!;
          return ListView(
            children: [
              for (final code in codes)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(code.reasonCode),
                    subtitle: Text(
                        'Applies To: ${code.appliesTo}\n${code.description ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showReasonCodeDialog(code: code),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await deleteCode(code.reasonCodeId);
                            setState(() {});
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Reason Code'),
        onPressed: () => _showReasonCodeDialog(),
      ),
    );
  }
}
