import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Use case to get stock levels filtered by quality status
class GetItemStockLevelByQualityStatusUseCase {
  GetItemStockLevelByQualityStatusUseCase(this.repository);
  final InventoryRepository repository;

  /// Returns a map of qualityStatus -> total quantity for the item
  Future<Map<String, double>> execute(String itemId) async {
    final item = await repository.getItem(itemId);
    if (item == null) return {};
    final attrs = item.additionalAttributes ?? {};
    final batchStatuses = attrs['batchQualityStatus'] as Map<String, dynamic>?;
    final Map<String, double> result = {};
    if (batchStatuses != null) {
      // If batch-tracked, sum quantities by quality status
      for (final entry in batchStatuses.entries) {
        final batch = entry.key;
        final status = entry.value;
        // For demo, assume batch quantity is stored in additionalAttributes['batchQuantities']
        final batchQuantities =
            attrs['batchQuantities'] as Map<String, dynamic>?;
        final qty = batchQuantities != null && batchQuantities[batch] != null
            ? (batchQuantities[batch] as num).toDouble()
            : 0.0;
        result[status] = (result[status] ?? 0) + qty;
      }
    } else {
      // Not batch-tracked, use item-level qualityStatus
      final status = attrs['qualityStatus'] ?? 'unknown';
      result[status] = item.quantity;
    }
    return result;
  }
}
