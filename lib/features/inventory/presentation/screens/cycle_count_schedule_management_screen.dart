import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cycle_count_schedule.dart';
import '../providers/cycle_count_schedule_repository_provider.dart';

class CycleCountScheduleManagementScreen extends ConsumerStatefulWidget {
  const CycleCountScheduleManagementScreen({super.key});
  @override
  ConsumerState<CycleCountScheduleManagementScreen> createState() =>
      _CycleCountScheduleManagementScreenState();
}

class _CycleCountScheduleManagementScreenState
    extends ConsumerState<CycleCountScheduleManagementScreen> {
  void _showScheduleDialog({CycleCountSchedule? schedule}) {
    final nameController =
        TextEditingController(text: schedule?.scheduleName ?? '');
    final freqController =
        TextEditingController(text: schedule?.frequency ?? '');
    final dueDateController = TextEditingController(
        text: schedule?.nextDueDate.toIso8601String().split('T').first ?? '');
    final statusController =
        TextEditingController(text: schedule?.status ?? 'Active');
    final itemCriteriaController = TextEditingController(
        text: schedule?.itemSelectionCriteria.toString() ?? '{}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(schedule == null ? 'Create Schedule' : 'Edit Schedule'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Schedule Name')),
              TextField(
                  controller: freqController,
                  decoration: const InputDecoration(labelText: 'Frequency')),
              TextField(
                  controller: dueDateController,
                  decoration: const InputDecoration(
                      labelText: 'Next Due Date (YYYY-MM-DD)')),
              TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: 'Status')),
              TextField(
                  controller: itemCriteriaController,
                  decoration: const InputDecoration(
                      labelText: 'Item Selection Criteria (JSON)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(cycleCountScheduleRepositoryProvider);
              final dueDate =
                  DateTime.tryParse(dueDateController.text) ?? DateTime.now();
              final criteria = itemCriteriaController.text.isNotEmpty
                  ? Map<String, dynamic>.from(
                      jsonDecode(itemCriteriaController.text))
                  : <String, dynamic>{};
              final sched = CycleCountSchedule(
                scheduleId: schedule?.scheduleId ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                scheduleName: nameController.text,
                creationDate: schedule?.creationDate ?? DateTime.now(),
                frequency: freqController.text,
                nextDueDate: dueDate,
                itemSelectionCriteria: criteria,
                status: statusController.text,
                lastGeneratedSheetId: schedule?.lastGeneratedSheetId,
              );
              if (schedule == null) {
                await repo.createSchedule(sched);
              } else {
                await repo.updateSchedule(sched);
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
    final scheduleRepo = ref.watch(cycleCountScheduleRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count Schedules')),
      body: FutureBuilder<List<CycleCountSchedule>>(
        future: scheduleRepo.getSchedules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final schedules = snapshot.data!;
          return ListView(
            children: [
              for (final schedule in schedules)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(schedule.scheduleName),
                    subtitle: Text(
                        'Next Due: ${schedule.nextDueDate.toLocal()} | Status: ${schedule.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showScheduleDialog(schedule: schedule),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await scheduleRepo
                                .deleteSchedule(schedule.scheduleId);
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
        label: const Text('New Schedule'),
        onPressed: () => _showScheduleDialog(),
      ),
    );
  }
}
