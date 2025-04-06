import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef DateRangeSelectedCallback = void Function(DateTime start, DateTime end);

class DateRangePicker extends StatelessWidget {

  const DateRangePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
  });
  final DateTime? startDate;
  final DateTime? endDate;
  final DateRangeSelectedCallback onDateRangeSelected;

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      firstDate: DateTime(2020), // Adjust as needed
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // Adjust as needed
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayStartDate =
        startDate != null ? DateFormat.yMd().format(startDate!) : 'Start';
    final String displayEndDate =
        endDate != null ? DateFormat.yMd().format(endDate!) : 'End';

    return TextButton.icon(
      icon: const Icon(Icons.calendar_today),
      label: Text('$displayStartDate - $displayEndDate'),
      onPressed: () => _selectDateRange(context),
    );
  }
}
