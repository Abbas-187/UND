import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/entities/inventory_item.dart';
import '../../domain/entities/location_optimization_criteria.dart';
import '../../domain/usecases/optimize_item_locations_usecase.dart';

/// State for location optimization
class LocationOptimizationState {
  LocationOptimizationState({
    this.isLoading = false,
    this.optimizedItemCount = 0,
    this.totalItemCount = 0,
    this.errorMessage,
    this.lastOptimizationDate,
    this.selectedCriteria,
    this.selectedCategoryFilter,
    this.selectedWarehouseId,
    this.previewItems = const [],
  });

  final bool isLoading;
  final int optimizedItemCount;
  final int totalItemCount;
  final String? errorMessage;
  final DateTime? lastOptimizationDate;
  final LocationOptimizationCriteria? selectedCriteria;
  final String? selectedCategoryFilter;
  final String? selectedWarehouseId;
  final List<OptimizationPreviewItem> previewItems;

  LocationOptimizationState copyWith({
    bool? isLoading,
    int? optimizedItemCount,
    int? totalItemCount,
    String? errorMessage,
    DateTime? lastOptimizationDate,
    LocationOptimizationCriteria? selectedCriteria,
    String? selectedCategoryFilter,
    String? selectedWarehouseId,
    List<OptimizationPreviewItem>? previewItems,
    bool clearError = false,
  }) {
    return LocationOptimizationState(
      isLoading: isLoading ?? this.isLoading,
      optimizedItemCount: optimizedItemCount ?? this.optimizedItemCount,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastOptimizationDate: lastOptimizationDate ?? this.lastOptimizationDate,
      selectedCriteria: selectedCriteria ?? this.selectedCriteria,
      selectedCategoryFilter:
          selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedWarehouseId: selectedWarehouseId ?? this.selectedWarehouseId,
      previewItems: previewItems ?? this.previewItems,
    );
  }
}

/// Preview item for location optimization
class OptimizationPreviewItem {
  OptimizationPreviewItem({
    required this.item,
    required this.currentLocation,
    required this.suggestedLocation,
    this.currentLocationName = '',
    this.suggestedLocationName = '',
    this.improvementScore = 0.0,
  });

  final InventoryItem item;
  final String currentLocation;
  final String suggestedLocation;
  final String currentLocationName;
  final String suggestedLocationName;
  final double improvementScore; // 0-100% improvement

  OptimizationPreviewItem copyWith({
    InventoryItem? item,
    String? currentLocation,
    String? suggestedLocation,
    String? currentLocationName,
    String? suggestedLocationName,
    double? improvementScore,
  }) {
    return OptimizationPreviewItem(
      item: item ?? this.item,
      currentLocation: currentLocation ?? this.currentLocation,
      suggestedLocation: suggestedLocation ?? this.suggestedLocation,
      currentLocationName: currentLocationName ?? this.currentLocationName,
      suggestedLocationName:
          suggestedLocationName ?? this.suggestedLocationName,
      improvementScore: improvementScore ?? this.improvementScore,
    );
  }
}

/// Notifier for location optimization
class LocationOptimizationNotifier
    extends StateNotifier<LocationOptimizationState> {
  LocationOptimizationNotifier(this._optimizeLocations)
      : super(LocationOptimizationState());

  final OptimizeItemLocationsUseCase _optimizeLocations;

  /// Set the selected optimization criteria
  void setCriteria(LocationOptimizationCriteria criteria) {
    state = state.copyWith(
      selectedCriteria: criteria,
      clearError: true,
    );
  }

  /// Set the category filter
  void setCategoryFilter(String? category) {
    state = state.copyWith(
      selectedCategoryFilter: category,
      clearError: true,
    );
  }

  /// Set the warehouse ID
  void setWarehouse(String warehouseId) {
    state = state.copyWith(
      selectedWarehouseId: warehouseId,
      clearError: true,
    );
  }

  /// Preview location optimization without applying changes
  Future<void> previewOptimization() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Run optimization without applying changes
      final count = await _optimizeLocations.execute(
        categoryFilter: state.selectedCategoryFilter,
        warehouseId: state.selectedWarehouseId,
        criteria: state.selectedCriteria ?? LocationOptimizationCriteria(),
        applyChanges: false,
      );

      // Update state with preview results
      state = state.copyWith(
        isLoading: false,
        optimizedItemCount: count,
        // Preview items would be populated in a real implementation
        // This would require changes to the use case to return item details
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error previewing optimization: $e',
      );
    }
  }

  /// Apply location optimization
  Future<void> applyOptimization() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Run optimization with changes applied
      final count = await _optimizeLocations.execute(
        categoryFilter: state.selectedCategoryFilter,
        warehouseId: state.selectedWarehouseId,
        criteria: state.selectedCriteria ?? LocationOptimizationCriteria(),
        applyChanges: true,
      );

      // Update state with results
      state = state.copyWith(
        isLoading: false,
        optimizedItemCount: count,
        lastOptimizationDate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error applying optimization: $e',
      );
    }
  }
}

/// Provider for location optimization
final locationOptimizationProvider = StateNotifierProvider<
    LocationOptimizationNotifier, LocationOptimizationState>((ref) {
  final optimizeLocations = ref.watch(optimizeItemLocationsUseCaseProvider);
  return LocationOptimizationNotifier(optimizeLocations);
});
