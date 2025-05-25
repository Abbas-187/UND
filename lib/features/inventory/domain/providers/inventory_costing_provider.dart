import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/cost_layer.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import '../usecases/calculate_outbound_movement_cost_usecase.dart';
import '../usecases/generate_inventory_valuation_report_usecase.dart';
import '../usecases/generate_picking_suggestions_usecase.dart'
    as picking_usecase;
import '../usecases/process_inventory_movement_usecase.dart';

// Repository provider
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  throw UnimplementedError(
      'Provider must be overridden with a real implementation');
});

// UseCase providers
final calculateOutboundMovementCostUseCaseProvider =
    Provider<CalculateOutboundMovementCostUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return CalculateOutboundMovementCostUseCase(repository);
});

final generateInventoryValuationReportUseCaseProvider =
    Provider<GenerateInventoryValuationReportUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GenerateInventoryValuationReportUseCase(repository);
});

final generatePickingSuggestionsUseCaseProvider =
    Provider<picking_usecase.GeneratePickingSuggestionsUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return picking_usecase.GeneratePickingSuggestionsUseCase(repository);
});

final processInventoryMovementUseCaseProvider =
    Provider<ProcessInventoryMovementUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return ProcessInventoryMovementUseCase(repository);
});

// State notifier for costing method selection
class CostingMethodState {
  CostingMethodState({
    required this.selectedCostingMethod,
    this.isLoading = false,
    this.error,
  });

  final CostingMethod selectedCostingMethod;
  final bool isLoading;
  final String? error;

  CostingMethodState copyWith({
    CostingMethod? selectedCostingMethod,
    bool? isLoading,
    String? error,
  }) {
    return CostingMethodState(
      selectedCostingMethod:
          selectedCostingMethod ?? this.selectedCostingMethod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CostingMethodNotifier extends StateNotifier<CostingMethodState> {
  CostingMethodNotifier(this._repository)
      : super(CostingMethodState(selectedCostingMethod: CostingMethod.fifo));

  final InventoryRepository _repository;

  Future<void> changeCostingMethod(CostingMethod method) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      // In the future, you may want to update all inventory items with this method
      // For now, we just update the state
      state = state.copyWith(
        selectedCostingMethod: method,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to change costing method: $e',
      );
    }
  }

  Future<void> updateItemCostingMethod(
      InventoryItem item, CostingMethod method) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final updatedItem = item.copyWith();
      await _repository.updateInventoryItem(updatedItem);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update item costing method: $e',
      );
    }
  }
}

final costingMethodProvider =
    StateNotifierProvider<CostingMethodNotifier, CostingMethodState>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return CostingMethodNotifier(repository);
});

// Provider for inventory valuation report
final inventoryValuationReportProvider =
    FutureProvider.family((ref, CostingMethod costingMethod) async {
  final useCase = ref.watch(generateInventoryValuationReportUseCaseProvider);
  return useCase.execute(
      costingMethod: costingMethod, includeLayerBreakdown: true);
});

// Provider for picking suggestions
final pickingSuggestionsProvider =
    FutureProvider.family((ref, Map<String, dynamic> params) async {
  final useCase = ref.watch(generatePickingSuggestionsUseCaseProvider);
  return useCase.execute(
    itemId: params['itemId'],
    warehouseId: params['warehouseId'],
    quantityNeeded: params['quantityNeeded'],
    strategy: params['strategy'] ?? picking_usecase.PickingStrategy.fefo,
    includeExpiringSoon: params['includeExpiringSoon'] ?? false,
  );
});
