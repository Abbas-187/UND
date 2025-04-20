import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/inventory_adjustment.dart';
import '../providers/inventory_adjustment_provider.dart';
import '../../../../l10n/app_localizations.dart';

class AdjustmentFilterDialog extends StatefulWidget {
  final AdjustmentFilterState initialFilter;
  final Function(AdjustmentFilterState) onFilterChanged;

  const AdjustmentFilterDialog({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
  });

  @override
  State<AdjustmentFilterDialog> createState() => _AdjustmentFilterDialogState();
}

class _AdjustmentFilterDialogState extends State<AdjustmentFilterDialog> {
  late AdjustmentFilterState _filter;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final TextEditingController _itemIdController = TextEditingController();
  final TextEditingController _categoryIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _itemIdController.text = _filter.itemId ?? '';
    _categoryIdController.text = _filter.categoryId ?? '';
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    _categoryIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  Text(
                    l10n.filterAdjustments,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Filter options
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    _buildSectionTitle(context, l10n.dateRange),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            label: l10n.startDate,
                            value: _filter.startDate != null
                                ? _dateFormat.format(_filter.startDate!)
                                : l10n.any,
                            onTap: () =>
                                _selectDate(context, isStartDate: true),
                            onClear: _filter.startDate != null
                                ? () {
                                    setState(() {
                                      _filter = _filter.copyWith(
                                          clearStartDate: true);
                                    });
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateSelector(
                            label: l10n.endDate,
                            value: _filter.endDate != null
                                ? _dateFormat.format(_filter.endDate!)
                                : l10n.any,
                            onTap: () =>
                                _selectDate(context, isStartDate: false),
                            onClear: _filter.endDate != null
                                ? () {
                                    setState(() {
                                      _filter =
                                          _filter.copyWith(clearEndDate: true);
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Adjustment Type
                    _buildSectionTitle(context, l10n.adjustmentTypeLabel),
                    const SizedBox(height: 8),
                    _buildDropdown<AdjustmentType>(
                      value: _filter.type,
                      items: AdjustmentType.values,
                      itemBuilder: (type) => _formatAdjustmentType(type),
                      onChanged: (value) {
                        setState(() {
                          if (value == null) {
                            _filter = _filter.copyWith(clearType: true);
                          } else {
                            _filter = _filter.copyWith(type: value);
                          }
                        });
                      },
                      hint: l10n.allTypes,
                    ),
                    const SizedBox(height: 16),

                    // Status
                    _buildSectionTitle(context, l10n.statusLabel),
                    const SizedBox(height: 8),
                    _buildDropdown<AdjustmentApprovalStatus>(
                      value: _filter.status,
                      items: AdjustmentApprovalStatus.values,
                      itemBuilder: (status) => _formatStatus(status),
                      onChanged: (value) {
                        setState(() {
                          if (value == null) {
                            _filter = _filter.copyWith(clearStatus: true);
                          } else {
                            _filter = _filter.copyWith(status: value);
                          }
                        });
                      },
                      hint: l10n.allStatuses,
                    ),
                    const SizedBox(height: 16),

                    // Item & Category IDs
                    _buildSectionTitle(context, l10n.itemAndCategory),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _itemIdController,
                      decoration: InputDecoration(
                        labelText: l10n.itemId,
                        border: const OutlineInputBorder(),
                        suffixIcon: _itemIdController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _itemIdController.clear();
                                    _filter =
                                        _filter.copyWith(clearItemId: true);
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            itemId: value.isEmpty ? null : value,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryIdController,
                      decoration: InputDecoration(
                        labelText: l10n.categoryId,
                        border: const OutlineInputBorder(),
                        suffixIcon: _categoryIdController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _categoryIdController.clear();
                                    _filter =
                                        _filter.copyWith(clearCategoryId: true);
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            categoryId: value.isEmpty ? null : value,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filter = const AdjustmentFilterState();
                        _itemIdController.clear();
                        _categoryIdController.clear();
                      });
                    },
                    child: Text(l10n.clearAll),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      widget.onFilterChanged(_filter);
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.applyFilters),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(value),
                const Spacer(),
                if (onClear != null)
                  InkWell(
                    onTap: onClear,
                    child: const Icon(Icons.clear, size: 16),
                  )
                else
                  const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        hint: Text(hint),
        underline: const SizedBox(),
        items: [
          DropdownMenuItem<T>(
            value: null,
            child: Text(hint),
          ),
          ...items.map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemBuilder(item)),
              )),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _filter.startDate ?? DateTime.now()
          : _filter.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _filter = _filter.copyWith(startDate: pickedDate);
        } else {
          _filter = _filter.copyWith(endDate: pickedDate);
        }
      });
    }
  }

  String _formatAdjustmentType(AdjustmentType type) {
    final typeString = type.toString().split('.').last;
    final words = typeString.split('_');
    return words
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatStatus(AdjustmentApprovalStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case AdjustmentApprovalStatus.pending:
        return l10n.pendingApproval;
      case AdjustmentApprovalStatus.approved:
        return l10n.approved;
      case AdjustmentApprovalStatus.rejected:
        return l10n.rejected;
    }
  }
}
