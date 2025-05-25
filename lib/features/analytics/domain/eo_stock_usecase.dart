// UseCase: Calculates Excess & Obsolete (E&O) stock value for a given period and filter.
import '../../inventory/domain/repositories/inventory_repository.dart';

abstract class AnalyticsUseCase<T, P> {
  Future<T> execute(P params);
}

class EOStockParams {
  EOStockParams({
    required this.agingThresholdDays,
    this.itemId,
    this.categoryId,
  });
  final int agingThresholdDays;
  final String? itemId;
  final String? categoryId;
}

class EOStockUseCase extends AnalyticsUseCase<double, EOStockParams> {
  EOStockUseCase(this.inventoryRepository);
  final InventoryRepository inventoryRepository;

  @override
  Future<double> execute(EOStockParams params) async {
    final items = await inventoryRepository.getItems();
    final now = DateTime.now();
    double eoValue = 0;
    for (final item in items) {
      if ((params.itemId != null && item.id != params.itemId) ||
          (params.categoryId != null && item.category != params.categoryId)) {
        continue;
      }
      // Check for obsolete (no update for X days) or expired
      final isObsolete =
          now.difference(item.lastUpdated).inDays > params.agingThresholdDays;
      final isExpired = item.isExpired;
      if (isObsolete || isExpired) {
        eoValue += item.quantity * (item.cost ?? 0);
      }
    }
    return eoValue;
  }
}
