import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

/// Provider for the inventory items picker
final inventoryItemsProvider = FutureProvider<List<InventoryItem>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getItems();
});

/// Provider for filtered inventory items based on search query
final filteredInventoryItemsProvider =
    FutureProvider.family<List<InventoryItem>, String>((ref, query) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final items = await repository.getItems();

  if (query.isEmpty) {
    return items;
  }

  final lowercaseQuery = query.toLowerCase();
  return items.where((item) {
    return item.itemCode.toLowerCase().contains(lowercaseQuery) ||
        item.name.toLowerCase().contains(lowercaseQuery);
  }).toList();
});

/// Provider for inventory item by ID
final inventoryItemByIdProvider =
    FutureProvider.family<InventoryItem?, String>((ref, itemId) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getInventoryItem(itemId);
});

/// Provider for inventory items in a specific warehouse
final inventoryItemsByWarehouseProvider =
    FutureProvider.family<List<InventoryItem>, String>(
        (ref, warehouseId) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getInventoryItems(warehouseId);
});

/// Provider for perishable inventory items (items with batch tracking required)
final perishableInventoryItemsProvider =
    FutureProvider<List<InventoryItem>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final items = await repository.getItems();
  return items
      .where((item) =>
          item.customAttributes != null &&
          item.customAttributes!['isPerishable'] == true)
      .toList();
});
