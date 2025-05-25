import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/inventory_repository_provider.dart' as repo_provider;
import '../repositories/inventory_repository.dart';

/// State notifier for stock level management
class StockLevelNotifier extends StateNotifier<AsyncValue<void>> {
  StockLevelNotifier(this._repository) : super(const AsyncValue.data(null));

  final InventoryRepository _repository;

  /// Gets items below reorder level
  Future<List<Map<String, dynamic>>> getItemsBelowReorderLevel() async {
    try {
      final items = await _repository.getItemsBelowReorderLevel();
      return items.map((item) {
        return {
          'materialId': item.id,
          'materialName': item.name,
          'currentLevel': item.quantity,
          'minLevel': item.minimumQuantity,
          'maxLevel': item.reorderPoint,
          'leadTimeDays': 7, // Default lead time
          'criticalLevel': item.minimumQuantity * 0.5,
          'unit': item.unit,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get items below reorder level: $e');
    }
  }

  /// Gets items at critical level
  Future<List<Map<String, dynamic>>> getItemsAtCriticalLevel() async {
    try {
      final items = await _repository.getItemsAtCriticalLevel();
      return items.map((item) {
        return {
          'materialId': item.id,
          'materialName': item.name,
          'currentLevel': item.quantity,
          'criticalLevel': item.minimumQuantity * 0.5,
          'unit': item.unit,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get items at critical level: $e');
    }
  }
}

/// Provider for stock level state
final stockLevelProvider =
    StateNotifierProvider<StockLevelNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(repo_provider.inventoryRepositoryProvider);
  return StockLevelNotifier(repository);
});
