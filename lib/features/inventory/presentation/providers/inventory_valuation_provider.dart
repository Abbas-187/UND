import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cost_layer.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/generate_inventory_valuation_report_usecase.dart';

/// Provider for inventory categories
final inventoryCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final items = await repository.getItems();
  final categories = items.map((item) => item.category).toSet().toList();
  categories.sort(); // Sort alphabetically
  return categories;
});

/// Provider for the inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  throw UnimplementedError(
      'Repository must be overridden with a real implementation');
});

/// Provider for the valuation report generation use case
final inventoryValuationReportUseCaseProvider =
    Provider<GenerateInventoryValuationReportUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GenerateInventoryValuationReportUseCase(repository);
});

/// Provider for the inventory valuation state notifier
final inventoryValuationProvider =
    StateNotifierProvider<InventoryValuationNotifier, InventoryValuationState>(
        (ref) {
  final useCase = ref.watch(inventoryValuationReportUseCaseProvider);
  return InventoryValuationNotifier(useCase);
});

/// State class for inventory valuation
class InventoryValuationState {

  InventoryValuationState({
    this.isLoading = false,
    this.report,
    this.selectedWarehouse,
    this.selectedCategory,
    this.searchQuery = '',
    this.costingMethod = CostingMethod.fifo,
    this.includeLayerBreakdown = true,
    this.errorMessage,
  });
  final bool isLoading;
  final InventoryValuationReport? report;
  final String? selectedWarehouse;
  final String? selectedCategory;
  final String searchQuery;
  final CostingMethod costingMethod;
  final bool includeLayerBreakdown;
  final String? errorMessage;

  InventoryValuationState copyWith({
    bool? isLoading,
    InventoryValuationReport? report,
    String? selectedWarehouse,
    String? selectedCategory,
    String? searchQuery,
    CostingMethod? costingMethod,
    bool? includeLayerBreakdown,
    String? errorMessage,
  }) {
    return InventoryValuationState(
      isLoading: isLoading ?? this.isLoading,
      report: report ?? this.report,
      selectedWarehouse: selectedWarehouse ?? this.selectedWarehouse,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      costingMethod: costingMethod ?? this.costingMethod,
      includeLayerBreakdown:
          includeLayerBreakdown ?? this.includeLayerBreakdown,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier class for inventory valuation
class InventoryValuationNotifier
    extends StateNotifier<InventoryValuationState> {
  InventoryValuationNotifier(this._useCase) : super(InventoryValuationState()) {
    // Initialize the valuation report
    generateValuationReport();
  }

  final GenerateInventoryValuationReportUseCase _useCase;

  /// Update the costing method and regenerate the report
  void updateCostingMethod(CostingMethod method) {
    state = state.copyWith(costingMethod: method);
    generateValuationReport();
  }

  /// Update the warehouse filter and regenerate the report
  void updateWarehouseFilter(String? warehouseId) {
    state = state.copyWith(selectedWarehouse: warehouseId);
    generateValuationReport();
  }

  /// Update the category filter
  void updateCategoryFilter(String? category) {
    state = state.copyWith(selectedCategory: category);
    _applyFiltersToReport();
  }

  /// Update the search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersToReport();
  }

  /// Toggle layer breakdown visibility
  void toggleLayerBreakdown() {
    state = state.copyWith(includeLayerBreakdown: !state.includeLayerBreakdown);
    generateValuationReport();
  }

  /// Refresh the valuation data
  void refreshValuation() {
    generateValuationReport();
  }

  /// Generate or regenerate the valuation report
  Future<void> generateValuationReport() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final report = await _useCase.execute(
        warehouseId: state.selectedWarehouse,
        costingMethod: state.costingMethod,
        includeLayerBreakdown: state.includeLayerBreakdown,
      );

      state = state.copyWith(
        isLoading: false,
        report: report,
      );

      // Apply any existing filters
      _applyFiltersToReport();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate valuation report: ${e.toString()}',
      );
    }
  }

  /// Apply category and search filters to the existing report
  void _applyFiltersToReport() {
    if (state.report == null) return;

    final category = state.selectedCategory;
    final query = state.searchQuery.toLowerCase();

    // If no filters, use the original report
    if ((category == null || category.isEmpty) && query.isEmpty) {
      // No need to create a new filtered report
      return;
    }

    final originalEntries = state.report!.entries;
    var filteredEntries = originalEntries;

    // Apply category filter
    if (category != null && category.isNotEmpty) {
      filteredEntries =
          filteredEntries.where((entry) => entry.category == category).toList();
    }

    // Apply search filter
    if (query.isNotEmpty) {
      filteredEntries = filteredEntries
          .where((entry) =>
              entry.itemName.toLowerCase().contains(query) ||
              entry.itemCode.toLowerCase().contains(query))
          .toList();
    }

    // Create a new report with filtered entries but keep other properties the same
    final filteredReport = InventoryValuationReport(
      reportDate: state.report!.reportDate,
      entries: filteredEntries,
      totalValue:
          filteredEntries.fold(0.0, (sum, entry) => sum + entry.totalValue),
      costingMethod: state.report!.costingMethod,
      warehouseId: state.report!.warehouseId,
      warehouseName: state.report!.warehouseName,
    );

    state = state.copyWith(report: filteredReport);
  }
}
