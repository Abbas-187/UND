import 'package:flutter/material.dart';

/// Widget for dashboard filter controls (date range, category, etc.)
class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({
    super.key,
    this.dateRange,
    this.onDateRangeChanged,
    this.selectedCategory,
    this.onCategoryChanged,
    this.categories = const [],
  });
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final String? selectedCategory;
  final ValueChanged<String?>? onCategoryChanged;
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Date range picker
        TextButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(dateRange == null
              ? 'Select Date Range'
              : '${dateRange!.start.toLocal()} - ${dateRange!.end.toLocal()}'),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (onDateRangeChanged != null) {
              onDateRangeChanged!(picked);
            }
          },
        ),
        const SizedBox(width: 16),
        // Category dropdown
        if (categories.isNotEmpty)
          DropdownButton<String>(
            value: selectedCategory,
            hint: const Text('Category'),
            items: categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ))
                .toList(),
            onChanged: onCategoryChanged,
          ),
      ],
    );
  }
}
