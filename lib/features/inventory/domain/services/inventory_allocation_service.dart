import '../../data/models/quality_status.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Service for inventory allocation and picking that respects quality status.
class InventoryAllocationService {
  InventoryAllocationService(this.repository);
  final InventoryRepository repository;

  /// Returns only items/batches with qualityStatus == 'AVAILABLE' for allocation/picking.
  Future<List<InventoryItem>> getAllocatableItems({
    String? category,
    String? warehouseId,
  }) async {
    final items = await repository.getItems();
    // Only include items with qualityStatus == 'AVAILABLE'
    return items.where((item) {
      final attrs = item.additionalAttributes ?? {};
      final status = attrs['qualityStatus'] ??
          (attrs['batchQualityStatus'] != null &&
                  attrs['batchQualityStatus'] is Map
              ? (attrs['batchQualityStatus'] as Map).values.first
              : null);
      return status == QualityStatus.available.name;
    }).toList();
  }
}
