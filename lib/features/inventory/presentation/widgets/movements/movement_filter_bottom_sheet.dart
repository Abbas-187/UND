import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/inventory_movement_model.dart';

class MovementFilterBottomSheet extends ConsumerStatefulWidget {
  const MovementFilterBottomSheet({
    super.key,
    this.selectedType,
    this.startDate,
    this.endDate,
    this.locationId,
    this.productId,
    required this.onApplyFilters,
    required this.onResetFilters,
  });
  final InventoryMovementType? selectedType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? locationId;
  final String? productId;
  final Function(InventoryMovementType?, DateTime?, DateTime?, String?, String?)
      onApplyFilters;
  final VoidCallback onResetFilters;

  @override
  ConsumerState<MovementFilterBottomSheet> createState() =>
      _MovementFilterBottomSheetState();
}

class _MovementFilterBottomSheetState
    extends ConsumerState<MovementFilterBottomSheet> {
  late InventoryMovementType? _selectedType;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _locationId;
  late String? _productId;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _locationId = widget.locationId;
    _productId = widget.productId;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate =
        isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, update end date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // If start date is after end date, update start date
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filter Movements',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Movement Type
                    Text(
                      'Movement Type',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: InventoryMovementType.values.map((type) {
                        return FilterChip(
                          label: Text(type.toString().split('.').last),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Date Range
                    Text(
                      'Date Range',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                _startDate != null
                                    ? DateFormat.yMd().format(_startDate!)
                                    : 'Select',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                _endDate != null
                                    ? DateFormat.yMd().format(_endDate!)
                                    : 'Select',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Preset Date Ranges
                    Text(
                      'Quick Selections',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('Today', () {
                          final now = DateTime.now();
                          setState(() {
                            _startDate = DateTime(now.year, now.month, now.day);
                            _endDate = now;
                          });
                        }),
                        _buildPresetChip('Yesterday', () {
                          final now = DateTime.now();
                          final yesterday =
                              now.subtract(const Duration(days: 1));
                          setState(() {
                            _startDate = DateTime(
                                yesterday.year, yesterday.month, yesterday.day);
                            _endDate = DateTime(now.year, now.month, now.day)
                                .subtract(const Duration(milliseconds: 1));
                          });
                        }),
                        _buildPresetChip('Last 7 days', () {
                          final now = DateTime.now();
                          setState(() {
                            _startDate = now.subtract(const Duration(days: 7));
                            _endDate = now;
                          });
                        }),
                        _buildPresetChip('Last 30 days', () {
                          final now = DateTime.now();
                          setState(() {
                            _startDate = now.subtract(const Duration(days: 30));
                            _endDate = now;
                          });
                        }),
                        _buildPresetChip('This Month', () {
                          final now = DateTime.now();
                          setState(() {
                            _startDate = DateTime(now.year, now.month, 1);
                            _endDate = now;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onResetFilters,
                    child: const Text('Reset Filters'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      widget.onApplyFilters(
                        _selectedType,
                        _startDate,
                        _endDate,
                        _locationId,
                        _productId,
                      );
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
