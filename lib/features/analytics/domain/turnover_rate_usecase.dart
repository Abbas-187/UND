import '../../inventory/domain/entities/cost_layer.dart';
import '../../inventory/domain/repositories/inventory_repository.dart';

// UseCase: Calculates inventory turnover rate for a given period and filter.
abstract class AnalyticsUseCase<T, P> {
  Future<T> execute(P params);
}

class TurnoverRateParams {
  TurnoverRateParams({
    required this.startDate,
    required this.endDate,
    this.itemId,
    this.categoryId,
  });
  final DateTime startDate;
  final DateTime endDate;
  final String? itemId;
  final String? categoryId;
}

class TurnoverRateUseCase extends AnalyticsUseCase<double, TurnoverRateParams> {
  TurnoverRateUseCase(this.inventoryRepository);
  final InventoryRepository inventoryRepository;

  @override
  Future<double> execute(TurnoverRateParams params) async {
    // 1. Calculate COGS (Cost of Goods Sold) for the period
    final cogs = await _calculateCogs(params);
    // 2. Calculate average inventory value for the period
    final avgInventory = await _calculateAverageInventory(params);
    if (avgInventory == 0) return 0;
    return cogs / avgInventory;
  }

  Future<double> _calculateCogs(TurnoverRateParams params) async {
    // Fetch all outbound movements (issues, sales, consumption) for the period
    final movements = await inventoryRepository.getItemMovementHistory(
      params.itemId ?? '',
    );
    double cogs = 0;
    for (final mov in movements) {
      // Only consider outbound movements within the period
      if (mov.timestamp.isAfter(params.startDate) &&
          mov.timestamp.isBefore(params.endDate) &&
          mov.isOutbound) {
        cogs += mov.quantity.abs() * (mov.costAtTransaction ?? 0);
      }
    }
    return cogs;
  }

  Future<double> _calculateAverageInventory(TurnoverRateParams params) async {
    // Get inventory valuation at start and end of period
    final startVal = await _getInventoryValueAt(params.startDate, params);
    final endVal = await _getInventoryValueAt(params.endDate, params);
    return (startVal + endVal) / 2;
  }

  Future<double> _getInventoryValueAt(
      DateTime date, TurnoverRateParams params) async {
    // Fetch all items or filter by item/category
    final items = await inventoryRepository.getItems();
    double total = 0;
    for (final item in items) {
      if ((params.itemId != null && item.id != params.itemId) ||
          (params.categoryId != null && item.category != params.categoryId)) {
        continue;
      }
      // Use cost layers to get value as of the date
      final costLayers = await inventoryRepository.getAvailableCostLayers(
        item.id,
        item.location ?? '',
        CostingMethod.fifo, // Use FIFO for valuation snapshot
      );
      for (final layer in costLayers) {
        if (layer.movementDate.isBefore(date)) {
          total += layer.remainingQuantity * layer.costAtTransaction;
        }
      }
    }
    return total;
  }
}
