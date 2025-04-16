import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_inventory_adjustment_repository.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/repositories/inventory_adjustment_repository.dart';

// Filter state immutable class
class AdjustmentFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final AdjustmentType? type;
  final String? itemId;
  final String? categoryId;
  final AdjustmentApprovalStatus? status;
  final String searchQuery;

  const AdjustmentFilterState({
    this.startDate,
    this.endDate,
    this.type,
    this.itemId,
    this.categoryId,
    this.status,
    this.searchQuery = '',
  });

  AdjustmentFilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    AdjustmentType? type,
    String? itemId,
    String? categoryId,
    AdjustmentApprovalStatus? status,
    String? searchQuery,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearType = false,
    bool clearItemId = false,
    bool clearCategoryId = false,
    bool clearStatus = false,
  }) {
    return AdjustmentFilterState(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      type: clearType ? null : type ?? this.type,
      itemId: clearItemId ? null : itemId ?? this.itemId,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      status: clearStatus ? null : status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdjustmentFilterState &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          type == other.type &&
          itemId == other.itemId &&
          categoryId == other.categoryId &&
          status == other.status &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      startDate.hashCode ^
      endDate.hashCode ^
      type.hashCode ^
      itemId.hashCode ^
      categoryId.hashCode ^
      status.hashCode ^
      searchQuery.hashCode;
}

// Provider for the repository instance
final inventoryAdjustmentRepositoryProvider =
    Provider<InventoryAdjustmentRepository>((ref) {
  return MockInventoryAdjustmentRepository();
});

// Provider for the filter state
final adjustmentFilterProvider = StateProvider<AdjustmentFilterState>((ref) {
  return const AdjustmentFilterState();
});

// Provider for filtered adjustments
final filteredAdjustmentsProvider =
    FutureProvider<List<InventoryAdjustment>>((ref) async {
  final repository = ref.watch(inventoryAdjustmentRepositoryProvider);
  final filter = ref.watch(adjustmentFilterProvider);

  final adjustments = await repository.getAdjustments(
    startDate: filter.startDate,
    endDate: filter.endDate,
    type: filter.type,
    itemId: filter.itemId,
    categoryId: filter.categoryId,
    status: filter.status,
  );

  // Apply text search if specified
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    return adjustments.where((adjustment) {
      return adjustment.itemName.toLowerCase().contains(query) ||
          adjustment.reason.toLowerCase().contains(query) ||
          (adjustment.notes?.toLowerCase().contains(query) ?? false) ||
          adjustment.performedBy.toLowerCase().contains(query);
    }).toList();
  }

  return adjustments;
});

// Provider for a specific adjustment
final adjustmentProvider =
    FutureProvider.family<InventoryAdjustment?, String>((ref, id) async {
  final repository = ref.watch(inventoryAdjustmentRepositoryProvider);
  return repository.getAdjustment(id);
});

// Provider for adjustments by item
final itemAdjustmentsProvider =
    FutureProvider.family<List<InventoryAdjustment>, String>(
        (ref, itemId) async {
  final repository = ref.watch(inventoryAdjustmentRepositoryProvider);
  return repository.getAdjustmentsForItem(itemId);
});

// Provider for pending adjustments
final pendingAdjustmentsProvider =
    FutureProvider<List<InventoryAdjustment>>((ref) async {
  final repository = ref.watch(inventoryAdjustmentRepositoryProvider);
  return repository.getPendingAdjustments();
});

// Provider for adjustment statistics
final adjustmentStatisticsProvider =
    FutureProvider<Map<AdjustmentType, int>>((ref) async {
  final repository = ref.watch(inventoryAdjustmentRepositoryProvider);
  final filter = ref.watch(adjustmentFilterProvider);

  return repository.getAdjustmentStatistics(
    startDate: filter.startDate,
    endDate: filter.endDate,
  );
});

// Provider for total quantities by type
final quantityByTypeProvider =
    FutureProvider<Map<AdjustmentType, double>>((ref) async {
  final repository = ref.watch(inventoryAdjustmentRepositoryProvider);
  final filter = ref.watch(adjustmentFilterProvider);

  return repository.getTotalQuantityByType(
    startDate: filter.startDate,
    endDate: filter.endDate,
  );
});
