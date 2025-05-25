// UseCase: Calculates stockout rate for a given period and filter.
import '../../inventory/domain/repositories/inventory_repository.dart';

abstract class AnalyticsUseCase<T, P> {
  Future<T> execute(P params);
}

class StockoutRateParams {
  StockoutRateParams({
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

class StockoutRateUseCase extends AnalyticsUseCase<double, StockoutRateParams> {
  StockoutRateUseCase(this.inventoryRepository);
  final InventoryRepository inventoryRepository;

  @override
  Future<double> execute(StockoutRateParams params) async {
    // Fetch all movement history for the item/category
    final movements =
        await inventoryRepository.getItemMovementHistory(params.itemId ?? '');
    int stockoutEvents = 0;
    int totalPeriods = 0;
    DateTime current = params.startDate;
    // Check daily for stockouts in the period
    while (current.isBefore(params.endDate)) {
      final dayMovements = movements.where((m) =>
          m.timestamp.day == current.day &&
          m.timestamp.month == current.month &&
          m.timestamp.year == current.year);
      double qoh = 0;
      for (final mov in dayMovements) {
        qoh += mov.quantity;
      }
      if (qoh <= 0) stockoutEvents++;
      totalPeriods++;
      current = current.add(const Duration(days: 1));
    }
    if (totalPeriods == 0) return 0;
    return stockoutEvents / totalPeriods;
  }
}
