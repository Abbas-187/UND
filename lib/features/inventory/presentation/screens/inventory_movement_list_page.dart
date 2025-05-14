import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../presentation/providers/inventory_movement_providers.dart';
import '../widgets/movements/movement_filter_bottom_sheet.dart';
import '../widgets/movements/movement_list_item.dart';

class InventoryMovementListPage extends ConsumerStatefulWidget {
  const InventoryMovementListPage({super.key});

  @override
  ConsumerState<InventoryMovementListPage> createState() =>
      _InventoryMovementListPageState();
}

class _InventoryMovementListPageState
    extends ConsumerState<InventoryMovementListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtering state
  InventoryMovementType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _locationId;
  String? _productId;
  bool _sortAscending = false;

  // Initial loading of all movements
  AsyncValue<List<InventoryMovementModel>> get _movements {
    if (_selectedType != null) {
      return ref.watch(movementsByTypeProvider(_selectedType!));
    } else if (_startDate != null && _endDate != null) {
      return ref.watch(
          movementsByDateRangeProvider((start: _startDate!, end: _endDate!)));
    } else if (_locationId != null) {
      return ref.watch(movementsByLocationProvider(
          (locationId: _locationId!, isSource: true)));
    } else if (_productId != null) {
      return ref.watch(movementsByProductProvider(_productId!));
    } else {
      // Default: last 30 days of movements
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      return ref.watch(
          movementsByDateRangeProvider((start: thirtyDaysAgo, end: now)));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => MovementFilterBottomSheet(
        selectedType: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        locationId: _locationId,
        productId: _productId,
        onApplyFilters: (type, start, end, location, product) {
          setState(() {
            _selectedType = type;
            _startDate = start;
            _endDate = end;
            _locationId = location;
            _productId = product;
          });
          Navigator.pop(context);
        },
        onResetFilters: () {
          setState(() {
            _selectedType = null;
            _startDate = null;
            _endDate = null;
            _locationId = null;
            _productId = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _sortAscending = !_sortAscending;
    });
  }

  List<InventoryMovementModel> _getFilteredAndSortedMovements(
      List<InventoryMovementModel> movements) {
    // First apply search filter if any
    List<InventoryMovementModel> filteredMovements = movements;

    if (_searchQuery.isNotEmpty) {
      filteredMovements = movements.where((movement) {
        final movementId = movement.movementId.toLowerCase();
        final sourceLocation = movement.sourceLocationName?.toLowerCase() ?? '';
        final destinationLocation =
            movement.destinationLocationName?.toLowerCase() ?? '';
        final search = _searchQuery.toLowerCase();
        final itemMatch = movement.items.any((item) =>
            item.productName.toLowerCase().contains(search) ||
            (item.batchLotNumber?.toLowerCase().contains(search) ?? false));
        return movementId.contains(search) ||
            sourceLocation.contains(search) ||
            destinationLocation.contains(search) ||
            itemMatch;
      }).toList();
    }

    // Then sort
    filteredMovements.sort((a, b) {
      int result = a.timestamp.compareTo(b.timestamp);
      return _sortAscending ? result : -result;
    });

    return filteredMovements;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Check text direction
    final isRightToLeft = Directionality.of(context) == TextDirection.RTL;
    final hasFilterApplied = _selectedType != null ||
        _startDate != null ||
        _locationId != null ||
        _productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryMovements),
        actions: [
          IconButton(
            icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _sortAscending ? l10n.oldestFirst : l10n.newestFirst,
            onPressed: _toggleSortOrder,
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasFilterApplied,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: l10n.filter,
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchMovements,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Applied filters chips
          if (hasFilterApplied)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_selectedType != null)
                    Padding(
                      padding: EdgeInsets.only(
                          right: isRightToLeft ? 0 : 8,
                          left: isRightToLeft ? 8 : 0),
                      child: Chip(
                        label: Text(_selectedType.toString().split('.').last),
                        onDeleted: () {
                          setState(() {
                            _selectedType = null;
                          });
                        },
                      ),
                    ),
                  if (_startDate != null && _endDate != null)
                    Padding(
                      padding: EdgeInsets.only(
                          right: isRightToLeft ? 0 : 8,
                          left: isRightToLeft ? 8 : 0),
                      child: Chip(
                        label: Text(
                            '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}'),
                        onDeleted: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                      ),
                    ),
                  if (_locationId != null)
                    Padding(
                      padding: EdgeInsets.only(
                          right: isRightToLeft ? 0 : 8,
                          left: isRightToLeft ? 8 : 0),
                      child: Chip(
                        label: Text(l10n.location),
                        onDeleted: () {
                          setState(() {
                            _locationId = null;
                          });
                        },
                      ),
                    ),
                  if (_productId != null)
                    Padding(
                      padding: EdgeInsets.only(
                          right: isRightToLeft ? 0 : 8,
                          left: isRightToLeft ? 8 : 0),
                      child: Chip(
                        label: Text(l10n.product),
                        onDeleted: () {
                          setState(() {
                            _productId = null;
                          });
                        },
                      ),
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: Text(l10n.clearFilters),
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _startDate = null;
                        _endDate = null;
                        _locationId = null;
                        _productId = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Movements list
          Expanded(
            child: _movements.when(
              data: (movements) {
                final filteredMovements =
                    _getFilteredAndSortedMovements(movements);

                if (filteredMovements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasFilterApplied || _searchQuery.isNotEmpty
                              ? l10n.noMovementsMatchingFilters
                              : l10n.noMovementsRecorded,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(movementsByDateRangeProvider);
                    ref.invalidate(movementsByTypeProvider);
                    ref.invalidate(movementsByLocationProvider);
                    ref.invalidate(movementsByProductProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredMovements.length,
                    itemBuilder: (context, index) {
                      final movement = filteredMovements[index];
                      return MovementListItem(
                        movement: movement,
                        onTap: () {
                          context.go(
                              '/inventory/movement-details/${movement.movementId}');
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingMovements,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                      onPressed: () {
                        ref.invalidate(movementsByDateRangeProvider);
                        ref.invalidate(movementsByTypeProvider);
                        ref.invalidate(movementsByLocationProvider);
                        ref.invalidate(movementsByProductProvider);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/inventory/movement-create');
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newMovement),
      ),
    );
  }
}
