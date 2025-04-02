import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef DateRangeSelectedCallback = void Function(DateTime start, DateTime end);

class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateRangeSelectedCallback onDateRangeSelected;
  final String? label;
  final bool compact;

  const DateRangePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
    this.label,
    this.compact = false,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = startDate != null && endDate != null
        ? DateTimeRange(start: startDate!, end: endDate!)
        : DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat =
        compact ? DateFormat.MMMd() : DateFormat.yMMMd();

    final String displayStartDate =
        startDate != null ? dateFormat.format(startDate!) : 'Start';
    final String displayEndDate =
        endDate != null ? dateFormat.format(endDate!) : 'End';

    if (compact) {
      return IconButton(
        icon: const Icon(Icons.calendar_today),
        tooltip: '$displayStartDate - $displayEndDate',
        onPressed: () => _selectDateRange(context),
      );
    }

    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            if (label != null) ...[
              Text(label!, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
            ],
            Text('$displayStartDate - $displayEndDate'),
          ],
        ),
      ),
    );
  }
}
