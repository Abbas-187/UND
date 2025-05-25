// UseCase: Calculates inventory aging for a given period and filter.
import '../../inventory/domain/repositories/inventory_repository.dart';

abstract class AnalyticsUseCase<T, P> {
  Future<T> execute(P params);
}

class InventoryAgingParams {
  InventoryAgingParams({
    required this.agingBuckets,
    this.itemId,
    this.categoryId,
  });
  final List<int> agingBuckets;
  final String? itemId;
  final String? categoryId;
}

class InventoryAgingUseCase
    extends AnalyticsUseCase<Map<int, double>, InventoryAgingParams> {
  InventoryAgingUseCase(this.inventoryRepository);
  final InventoryRepository inventoryRepository;

  @override
  Future<Map<int, double>> execute(InventoryAgingParams params) async {
    final items = await inventoryRepository.getItems();
    final now = DateTime.now();
    final Map<int, double> agingBuckets = {
      for (var b in params.agingBuckets) b: 0
    };
    for (final item in items) {
      if ((params.itemId != null && item.id != params.itemId) ||
          (params.categoryId != null && item.category != params.categoryId)) {
        continue;
      }
      final age = now.difference(item.lastUpdated).inDays;
      for (final bucket in params.agingBuckets) {
        if (age <= bucket) {
          agingBuckets[bucket] = agingBuckets[bucket]! + item.quantity;
          break;
        }
      }
    }
    return agingBuckets;
  }
}
