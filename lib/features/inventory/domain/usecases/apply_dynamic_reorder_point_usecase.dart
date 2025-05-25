import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../forecasting/domain/usecases/calculate_inventory_optimization_usecase.dart';
import '../providers/forecasting_provider.dart';
import '../providers/inventory_repository_provider.dart';
import '../repositories/inventory_repository.dart' as repo;

/// Use case to apply dynamic reorder point and safety stock to an inventory item
class ApplyDynamicReorderPointUseCase {
  ApplyDynamicReorderPointUseCase(
    this._ref,
    this._calcUseCase,
    this._inventoryRepo,
  );

  final Ref _ref;
  final CalculateInventoryOptimizationUseCase _calcUseCase;
  final repo.InventoryRepository _inventoryRepo;

  /// Execute optimization by fetching demand history from forecasting and update inventory item
  Future<void> execute({
    required String itemId,
    // ignore: unused_parameter
    required String warehouseId,
    required double leadTime,
    required double serviceLevel,
    required double orderingCost,
    required double holdingCostPercentage,
    required double unitCost,
    List<double>? demandHistoryOverride,
  }) async {
    List<double> demandHistory;
    if (demandHistoryOverride != null) {
      demandHistory = demandHistoryOverride;
    } else {
      // Fetch forecast data to derive demand history
      final forecastNotifier = _ref.read(forecastingProvider.notifier);
      final forecast = await forecastNotifier.getForecastForMaterial(
        materialId: itemId,
        periodDays: leadTime.ceil(),
      );
      final dailyDemand = (forecast['dailyDemand'] as double);
      demandHistory = List<double>.filled(leadTime.ceil(), dailyDemand);
    }

    // Calculate optimization without saving
    final result = await _calcUseCase.calculateOnly(
      demandHistory: demandHistory,
      leadTime: leadTime,
      serviceLevel: serviceLevel,
      orderingCost: orderingCost,
      holdingCostPercentage: holdingCostPercentage,
      unitCost: unitCost,
    );

    // Fetch the item
    final inventoryItem = await _inventoryRepo.getItem(itemId);
    if (inventoryItem == null) {
      throw Exception('Item not found: $itemId');
    }

    // Update item with new reorderPoint and safetyStock in additionalAttributes
    final updated = inventoryItem.copyWith(
      reorderPoint: result['reorderPoint'] as double,
      additionalAttributes: {
        ...?inventoryItem.additionalAttributes,
        'safetyStock': result['safetyStock'],
      },
    );

    // Persist update
    await _inventoryRepo.updateItem(updated);
  }
}

/// Provider for ApplyDynamicReorderPointUseCase
final applyDynamicReorderPointUseCaseProvider =
    Provider<ApplyDynamicReorderPointUseCase>((Ref ref) {
  final calcUseCase = ref.watch(calculateInventoryOptimizationUseCaseProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return ApplyDynamicReorderPointUseCase(ref, calcUseCase, inventoryRepo);
});
