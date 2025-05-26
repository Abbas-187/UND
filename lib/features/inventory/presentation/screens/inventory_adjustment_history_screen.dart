import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/inventory_adjustment.dart';
import '../providers/inventory_adjustment_provider.dart';
import '../widgets/adjustment_details_dialog.dart';
import '../widgets/adjustment_filter_dialog.dart';
import '../widgets/adjustment_statistics_chart.dart';

class InventoryAdjustmentHistoryScreen extends ConsumerStatefulWidget {
  const InventoryAdjustmentHistoryScreen({super.key});

  @override
  ConsumerState<InventoryAdjustmentHistoryScreen> createState() =>
      _InventoryAdjustmentHistoryScreenState();
}

class _InventoryAdjustmentHistoryScreenState
    extends ConsumerState<InventoryAdjustmentHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref
        .read(adjustmentFilterProvider.notifier)
        .update((state) => state.copyWith(searchQuery: _searchController.text));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AdjustmentFilterDialog(
        initialFilter: ref.read(adjustmentFilterProvider),
        onFilterChanged: (newFilter) {
          ref.read(adjustmentFilterProvider.notifier).state = newFilter;
        },
      ),
    );
  }

  void _clearFilters() {
    ref.read(adjustmentFilterProvider.notifier).state =
        const AdjustmentFilterState();
    _searchController.clear();
  }

  void _showAdjustmentDetails(InventoryAdjustment adjustment) {
    showDialog(
      context: context,
      builder: (context) => AdjustmentDetailsDialog(adjustment: adjustment),
    );
  }

  void _approveAdjustment(InventoryAdjustment adjustment) async {
    try {
      final repository = ref.read(inventoryAdjustmentRepositoryProvider);
      await repository.updateAdjustmentStatus(
        adjustment.id,
        AdjustmentApprovalStatus.approved,
        'Current User', // In a real app, this would be the current user
      );

      // Invalidate providers to refresh the data
      ref.invalidate(filteredAdjustmentsProvider);
      ref.invalidate(adjustmentProvider(adjustment.id));
      ref.invalidate(pendingAdjustmentsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adjustment approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectAdjustment(InventoryAdjustment adjustment) async {
    try {
      final repository = ref.read(inventoryAdjustmentRepositoryProvider);
      await repository.updateAdjustmentStatus(
        adjustment.id,
        AdjustmentApprovalStatus.rejected,
        'Current User', // In a real app, this would be the current user
      );

      // Invalidate providers to refresh the data
      ref.invalidate(filteredAdjustmentsProvider);
      ref.invalidate(adjustmentProvider(adjustment.id));
      ref.invalidate(pendingAdjustmentsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adjustment rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final adjustmentsAsync = ref.watch(filteredAdjustmentsProvider);
    final filterState = ref.watch(adjustmentFilterProvider);

    // Check if filters are active
    final bool hasActiveFilters = filterState.startDate != null ||
        filterState.endDate != null ||
        filterState.type != null ||
        filterState.itemId != null ||
        filterState.categoryId != null ||
        filterState.status != null ||
        filterState.searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            l10n?.inventoryAdjustmentHistory ?? 'Inventory Adjustment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(filteredAdjustmentsProvider);
              ref.invalidate(adjustmentStatisticsProvider);
              ref.invalidate(quantityByTypeProvider);
              ref.invalidate(pendingAdjustmentsProvider);
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n?.searchAdjustments ?? 'Search adjustments',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (hasActiveFilters)
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: Text('Clear Filters'),
                    onPressed: _clearFilters,
                  ),
              ],
            ),
          ),

          // Statistics Overview (if no filters applied)
          if (!hasActiveFilters)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 200,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AdjustmentStatisticsChart(),
                  ),
                ),
              ),
            ),

          // Applied filters chips
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (filterState.startDate != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                              'From: ${_dateFormat.format(filterState.startDate!)}'),
                          onDeleted: () {
                            ref.read(adjustmentFilterProvider.notifier).update(
                                  (state) =>
                                      state.copyWith(clearStartDate: true),
                                );
                          },
                        ),
                      ),
                    if (filterState.endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                              'To: ${_dateFormat.format(filterState.endDate!)}'),
                          onDeleted: () {
                            ref.read(adjustmentFilterProvider.notifier).update(
                                  (state) => state.copyWith(clearEndDate: true),
                                );
                          },
                        ),
                      ),
                    if (filterState.type != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                              'Type: ${filterState.type.toString().split('.').last}'),
                          onDeleted: () {
                            ref.read(adjustmentFilterProvider.notifier).update(
                                  (state) => state.copyWith(clearType: true),
                                );
                          },
                        ),
                      ),
                    if (filterState.status != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                              'Status: ${filterState.status.toString().split('.').last}'),
                          onDeleted: () {
                            ref.read(adjustmentFilterProvider.notifier).update(
                                  (state) => state.copyWith(clearStatus: true),
                                );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Adjustment list
          Expanded(
            child: adjustmentsAsync.when(
              data: (adjustments) {
                if (adjustments.isEmpty) {
                  return Center(
                    child: Text(
                        l10n?.noAdjustmentsFound ?? 'No adjustments found'),
                  );
                }

                return ListView.builder(
                  itemCount: adjustments.length,
                  itemBuilder: (context, index) {
                    final adjustment = adjustments[index];
                    final isPositive = adjustment.quantity >= 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getAdjustmentTypeColor(
                              adjustment.adjustmentType),
                          child: Icon(
                            _getAdjustmentTypeIcon(adjustment.adjustmentType),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(adjustment.itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reason: ${adjustment.reason}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Date: ${_dateFormat.format(adjustment.performedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Quantity indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: isPositive
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                '${isPositive ? '+' : ''}${adjustment.quantity.toStringAsFixed(1)} ${adjustment.quantity.abs() == 1.0 ? 'unit' : 'units'}',
                                style: TextStyle(
                                  color: isPositive
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                        adjustment.approvalStatus ??
                                            AdjustmentApprovalStatus.pending)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                adjustment.approvalStatus
                                    .toString()
                                    .split('.')
                                    .last,
                                style: TextStyle(
                                  color: _getStatusColor(
                                      adjustment.approvalStatus ??
                                          AdjustmentApprovalStatus.pending),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showAdjustmentDetails(adjustment),
                        // Approval action buttons
                        isThreeLine: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),

          // Pending approvals card (at bottom)
          Consumer(
            builder: (context, ref, child) {
              final pendingAsync = ref.watch(pendingAdjustmentsProvider);

              return pendingAsync.when(
                data: (pendingAdjustments) {
                  if (pendingAdjustments.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${l10n?.pendingApprovals ?? 'Pending Approvals'} (${pendingAdjustments.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                child: Text(l10n?.viewAll ?? 'View All'),
                                onPressed: () {
                                  // Set filter to show only pending
                                  ref
                                      .read(adjustmentFilterProvider.notifier)
                                      .state = AdjustmentFilterState(
                                    status: AdjustmentApprovalStatus.pending,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: pendingAdjustments.length > 3
                                ? 3 // Show max 3 items in this row
                                : pendingAdjustments.length,
                            itemBuilder: (context, index) {
                              final adjustment = pendingAdjustments[index];

                              return SizedBox(
                                width: 280,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          adjustment.itemName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${adjustment.quantity >= 0 ? '+' : ''}${adjustment.quantity.toStringAsFixed(1)} ${l10n?.units ?? 'units'}',
                                          style: TextStyle(
                                            color: adjustment.quantity >= 0
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              child: Text(
                                                  l10n?.approve ?? 'Approve'),
                                              onPressed: () =>
                                                  _approveAdjustment(
                                                      adjustment),
                                            ),
                                            TextButton(
                                              child: Text(
                                                l10n?.reject ?? 'Reject',
                                                style: TextStyle(
                                                    color: Colors.red[700]),
                                              ),
                                              onPressed: () =>
                                                  _rejectAdjustment(adjustment),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // context.go('/inventory/adjustments/create');
        },
        tooltip: l10n?.createAdjustment ?? 'Create Adjustment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getAdjustmentTypeColor(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.manual:
        return Colors.blue;
      case AdjustmentType.stockCount:
        return Colors.green;
      case AdjustmentType.expiry:
        return Colors.red;
      case AdjustmentType.damage:
        return Colors.orange;
      case AdjustmentType.loss:
        return Colors.deepOrange;
      case AdjustmentType.return_to_supplier:
        return Colors.purple;
      case AdjustmentType.system_correction:
        return Colors.teal;
      case AdjustmentType.transfer:
        return Colors.indigo;
    }
  }

  IconData _getAdjustmentTypeIcon(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.manual:
        return Icons.edit;
      case AdjustmentType.stockCount:
        return Icons.inventory;
      case AdjustmentType.expiry:
        return Icons.timer_off;
      case AdjustmentType.damage:
        return Icons.warning;
      case AdjustmentType.loss:
        return Icons.clear;
      case AdjustmentType.return_to_supplier:
        return Icons.assignment_return;
      case AdjustmentType.system_correction:
        return Icons.settings;
      case AdjustmentType.transfer:
        return Icons.swap_horiz;
    }
  }

  Color _getStatusColor(AdjustmentApprovalStatus status) {
    switch (status) {
      case AdjustmentApprovalStatus.pending:
        return Colors.amber[700]!;
      case AdjustmentApprovalStatus.approved:
        return Colors.green[700]!;
      case AdjustmentApprovalStatus.rejected:
        return Colors.red[700]!;
    }
  }
}
