import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/providers/production_scheduling_provider.dart';
import '../../data/models/production_schedule_model.dart';
import '../widgets/production_line_timeline.dart';
import '../widgets/production_schedule_calendar.dart';

class ProductionSchedulingScreen extends ConsumerWidget {
  const ProductionSchedulingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekSchedulesAsync = ref.watch(weekProductionSchedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Scheduling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Get current user status
              final userAsync = ref.read(currentUserProvider);
              userAsync.when(
                data: (user) {
                  if (user != null) {
                    context.go('/factory/production-scheduling/create');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('You must be logged in to create schedules'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                loading: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loading user information...'),
                    ),
                  );
                },
                error: (error, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: weekSchedulesAsync.when(
        data: (schedules) => _buildScheduleContent(context, ref, schedules),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading schedules: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final userAsync = ref.read(currentUserProvider);
          userAsync.when(
            data: (user) {
              if (user != null) {
                context.go('/factory/production-scheduling/create');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must be logged in to create schedules'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            loading: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loading user information...'),
                ),
              );
            },
            error: (error, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScheduleContent(
    BuildContext context,
    WidgetRef ref,
    List<ProductionScheduleModel> schedules,
  ) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No production schedules for this week',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Schedule'),
              onPressed: () {
                context.go('/factory/production-scheduling/create');
              },
            ),
          ],
        ),
      );
    }

    final firstSchedule = schedules.first;
    final firstLineAllocation = firstSchedule.lineAllocations.isNotEmpty
        ? firstSchedule.lineAllocations.first
        : null;

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ProductionScheduleCalendar(
            schedules: schedules,
            onScheduleTap: (schedule) {
              final slots = schedule.slots;
              if (slots.isNotEmpty) {
                context
                    .go('/factory/production-scheduling/slot-detail', extra: {
                  'slot': slots.first,
                  'scheduleId': schedule.id,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No production slots in this schedule'),
                  ),
                );
              }
            },
            onDayTap: (day) {
              // Show schedules for specific day using the provider
              final now = DateTime.now();
              final dateRange = CustomDateTimeRange(
                start: day,
                end: DateTime(day.year, day.month, day.day, 23, 59, 59),
              );

              // Load schedules for this day
              final daySchedules =
                  ref.read(filteredSchedulesProvider(dateRange));

              if (daySchedules.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Found ${daySchedules.length} schedules for ${day.toString().split(' ')[0]}'),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: firstLineAllocation != null
              ? ProductionLineTimeline(
                  lineAllocation: firstLineAllocation,
                  onTimeBlockSelected: (startTime, endTime) {
                    // Handle time block selection
                  },
                )
              : const Center(child: Text('No line allocations available')),
        ),
      ],
    );
  }
}
