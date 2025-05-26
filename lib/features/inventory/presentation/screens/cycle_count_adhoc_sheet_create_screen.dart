import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cycle_count_item.dart';
import '../../domain/entities/cycle_count_sheet.dart';
import '../providers/cycle_count_providers.dart';

class CycleCountAdHocSheetCreateScreen extends ConsumerStatefulWidget {
  const CycleCountAdHocSheetCreateScreen({super.key});
  @override
  ConsumerState<CycleCountAdHocSheetCreateScreen> createState() =>
      _CycleCountAdHocSheetCreateScreenState();
}

class _CycleCountAdHocSheetCreateScreenState
    extends ConsumerState<CycleCountAdHocSheetCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assignedUserController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _criteriaController = TextEditingController();
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ad-hoc Cycle Count Sheet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _assignedUserController,
                decoration:
                    const InputDecoration(labelText: 'Assigned User ID'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _warehouseController,
                decoration: const InputDecoration(labelText: 'Warehouse ID'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _dueDateController,
                decoration:
                    const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _criteriaController,
                decoration: const InputDecoration(
                    labelText: 'Selection Criteria (JSON)'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: _creating
                    ? const Text('Creating...')
                    : const Text('Create Sheet'),
                onPressed: _creating
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _creating = true);
                        try {
                          final dueDate = DateTime.parse(_dueDateController
                              .text); // Parse criteria from text field to include in notes
                          final criteriaText =
                              _criteriaController.text.isNotEmpty
                                  ? _criteriaController.text
                                  : '{}';

                          // Create CycleCountSheet object from the form data
                          final sheetData = CycleCountSheet(
                            sheetId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(), // Generate a unique ID
                            creationDate: DateTime.now(),
                            assignedUserId: _assignedUserController.text,
                            dueDate: dueDate,
                            status: 'Pending',
                            warehouseId: _warehouseController.text,
                            notes:
                                'Ad-hoc cycle count created on ${DateTime.now().toIso8601String()} with criteria: $criteriaText',
                          );

                          // Create an empty list of CycleCountItem objects
                          // In a real implementation, this would contain actual inventory items
                          final itemsList = <CycleCountItem>[];

                          await ref
                              .read(processCycleCountResultsUseCaseProvider)
                              .sheetRepository
                              .createSheet(sheetData, itemsList);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sheet Created')));
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          if (mounted) Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        } finally {
                          setState(() => _creating = false);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
