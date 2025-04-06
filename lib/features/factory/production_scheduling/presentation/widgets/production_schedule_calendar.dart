import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/production_schedule_model.dart';

class ProductionScheduleCalendar extends StatefulWidget {
  const ProductionScheduleCalendar({
    super.key,
    required this.schedules,
    required this.onScheduleTap,
    required this.onDayTap,
  });

  final List<ProductionScheduleModel> schedules;
  final Function(ProductionScheduleModel) onScheduleTap;
  final Function(DateTime) onDayTap;

  @override
  State<ProductionScheduleCalendar> createState() =>
      _ProductionScheduleCalendarState();
}

class _ProductionScheduleCalendarState
    extends State<ProductionScheduleCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late Map<DateTime, List<ProductionScheduleModel>> _schedulesByDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;
    _updateSchedulesByDay();
  }

  @override
  void didUpdateWidget(ProductionScheduleCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.schedules != oldWidget.schedules) {
      _updateSchedulesByDay();
    }
  }

  void _updateSchedulesByDay() {
    _schedulesByDay = {};

    for (final schedule in widget.schedules) {
      final day = DateTime(
        schedule.scheduleDate.year,
        schedule.scheduleDate.month,
        schedule.scheduleDate.day,
      );

      if (_schedulesByDay[day] == null) {
        _schedulesByDay[day] = [];
      }

      _schedulesByDay[day]!.add(schedule);
    }
  }

  List<ProductionScheduleModel> _getSchedulesForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _schedulesByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<ProductionScheduleModel>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getSchedulesForDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDayTap(selectedDay);
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            markerDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: true,
            formatButtonShowsNext: false,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildScheduleList(),
        ),
      ],
    );
  }

  Widget _buildScheduleList() {
    final schedules = _getSchedulesForDay(_selectedDay);

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules for ${DateFormat.yMMMd().format(_selectedDay)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Schedule'),
              onPressed: () {
                // TODO: Navigate to create schedule screen
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () => widget.onScheduleTap(schedule),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          schedule.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusChip(schedule.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${DateFormat.yMMMd().format(schedule.scheduleDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created by: ${schedule.createdBy}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lines: ${schedule.lineAllocations.length} | Slots: ${schedule.slots.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ScheduleStatus status) {
    final Color backgroundColor;
    final Color textColor = Colors.white;
    final String label;

    switch (status) {
      case ScheduleStatus.draft:
        backgroundColor = Colors.grey;
        label = 'Draft';
        break;
      case ScheduleStatus.published:
        backgroundColor = Colors.blue;
        label = 'Published';
        break;
      case ScheduleStatus.inProgress:
        backgroundColor = Colors.green;
        label = 'In Progress';
        break;
      case ScheduleStatus.completed:
        backgroundColor = Colors.purple;
        label = 'Completed';
        break;
      case ScheduleStatus.cancelled:
        backgroundColor = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
