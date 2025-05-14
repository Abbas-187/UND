import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/logging_service.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/providers/inventory_repository_provider.dart';
import '../../domain/repositories/inventory_repository.dart';

// Provider for the inventory database controller
final inventoryDatabaseControllerProvider =
    StateNotifierProvider<InventoryDatabaseController, AsyncValue<void>>((ref) {
  final inventoryRepository = ref.watch(inventoryRepositoryProvider);
  final loggingService = ref.watch(loggingServiceProvider);
  return InventoryDatabaseController(
    inventoryRepository: inventoryRepository,
    loggingService: loggingService,
  );
});

// Provider for fetching inventory items
final inventoryItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final inventoryRepository = ref.watch(inventoryRepositoryProvider);
  return inventoryRepository.watchAllItems();
});

// Provider for categories
final inventoryCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final inventoryRepository = ref.watch(inventoryRepositoryProvider);
  final items = await inventoryRepository.getItems();
  // Extract unique categories from items
  return items.map((e) => e.category).toSet().toList();
});

// Provider for locations
final inventoryLocationsProvider = FutureProvider<List<String>>((ref) async {
  final inventoryRepository = ref.watch(inventoryRepositoryProvider);
  final items = await inventoryRepository.getItems();
  // Extract unique locations from items
  return items.map((e) => e.location).toSet().toList();
});

String generateAppItemId({
  required String locationCode, // e.g., 'MAN', 'FRZ'
  required String categoryCode, // e.g., '01'
  required String subCategoryCode, // e.g., '01'
  required int sequence, // e.g., 1
}) {
  final seqStr = sequence.toString().padLeft(5, '0'); // 5 digits, e.g., 00001
  return '$locationCode$categoryCode$subCategoryCode$seqStr';
}

// Example mapping helpers (should be replaced with your actual mappings)
String getLocationCode(String location) {
  switch (location.toLowerCase()) {
    case 'main warehouse':
      return 'MAN';
    case 'freezer warehouse':
      return 'FRZ';
    case 'chilled warehouse':
      return 'CHL';
    default:
      return 'OTH';
  }
}

String getCategoryCode(String category) {
  // Example: Packaging=01, Dairy=02, etc.
  switch (category.toLowerCase()) {
    case 'packaging':
      return '01';
    case 'dairy':
      return '02';
    default:
      return '99';
  }
}

String getSubCategoryCode(String subCategory) {
  // Example: Bottle=01, Cups=02, etc.
  switch (subCategory.toLowerCase()) {
    case 'bottle':
      return '01';
    case 'cups':
      return '02';
    default:
      return '99';
  }
}

Future<int> getNextSequenceNumber(
    String location, String category, String subCategory) async {
  // TODO: Implement a robust way to get the next sequence number (e.g., from Firestore or a counter collection)
  // For now, return a random number for demonstration
  return DateTime.now().millisecondsSinceEpoch % 100000; // Not for production!
}

class InventoryDatabaseController extends StateNotifier<AsyncValue<void>> {
  InventoryDatabaseController({
    required InventoryRepository inventoryRepository,
    required LoggingService loggingService,
  })  : _inventoryRepository = inventoryRepository,
        _loggingService = loggingService,
        super(const AsyncValue.data(null)) {
    // Ensure any items without appItemId get one dynamically on startup
    _ensureAppItemIds();
  }

  final InventoryRepository _inventoryRepository;
  final LoggingService _loggingService;

  // Generate missing appItemIds for existing items in the database
  Future<void> _ensureAppItemIds() async {
    try {
      final items = await _inventoryRepository.getItems();
      for (final item in items) {
        if (item.appItemId.isEmpty) {
          final locationCode = getLocationCode(item.location);
          final categoryCode = getCategoryCode(item.category);
          final subCategoryCode = getSubCategoryCode(
              item.additionalAttributes?['subCategory'] ?? '');
          final sequence = await getNextSequenceNumber(item.location,
              item.category, item.additionalAttributes?['subCategory'] ?? '');
          final generatedId = generateAppItemId(
            locationCode: locationCode,
            categoryCode: categoryCode,
            subCategoryCode: subCategoryCode,
            sequence: sequence,
          );
          final updated = item.copyWith(appItemId: generatedId);
          await _inventoryRepository.updateItem(updated);
        }
      }
    } catch (e, st) {
      _loggingService.error('Failed to ensure appItemIds', e, st);
    }
  }

  Future<void> createInventoryItem(InventoryItem item) async {
    try {
      state = const AsyncValue.loading();
      // Generate appItemId if not provided
      final locationCode = getLocationCode(item.location);
      final categoryCode = getCategoryCode(item.category);
      final subCategoryCode =
          getSubCategoryCode(item.additionalAttributes?['subCategory'] ?? '');
      final sequence = await getNextSequenceNumber(item.location, item.category,
          item.additionalAttributes?['subCategory'] ?? '');
      final appItemId = generateAppItemId(
        locationCode: locationCode,
        categoryCode: categoryCode,
        subCategoryCode: subCategoryCode,
        sequence: sequence,
      );
      final itemWithId = item.copyWith(appItemId: appItemId);
      await _inventoryRepository.addItem(itemWithId);
      _loggingService.info(
          'Inventory item created: ${itemWithId.name} (${itemWithId.appItemId})');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _loggingService.error('Failed to create inventory item', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    try {
      state = const AsyncValue.loading();
      await _inventoryRepository.updateItem(item);
      _loggingService.info('Inventory item updated: ${item.name} (${item.id})');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _loggingService.error('Failed to update inventory item', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      state = const AsyncValue.loading();
      await _inventoryRepository.deleteItem(id);
      _loggingService.info('Inventory item deleted: $id');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _loggingService.error('Failed to delete inventory item', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> importInventoryItems(List<InventoryItem> items) async {
    try {
      state = const AsyncValue.loading();
      await _inventoryRepository.batchUpdateItems(items);
      _loggingService.info('Imported ${items.length} inventory items');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _loggingService.error('Failed to import inventory items', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<List<InventoryItem>> exportInventoryItems() async {
    try {
      final items = await _inventoryRepository.getItems();
      _loggingService.info('Exported ${items.length} inventory items');
      return items;
    } catch (e, stackTrace) {
      _loggingService.error('Failed to export inventory items', e, stackTrace);
      rethrow;
    }
  }

  /// Filter items using multidimensional criteria
  Future<List<InventoryItem>> filterItems({
    String? category,
    String? subCategory,
    String? location,
    String? supplier,
    bool? lowStock,
    bool? needsReorder,
    bool? expired,
  }) async {
    return _inventoryRepository.filterItems(
      category: category,
      subCategory: subCategory,
      location: location,
      supplier: supplier,
      lowStock: lowStock,
      needsReorder: needsReorder,
      expired: expired,
    );
  }

  /// Get top N most expensive items
  Future<List<InventoryItem>> getMostExpensiveItems(int limit) async {
    return _inventoryRepository.getMostExpensiveItems(limit);
  }

  /// Count number of items by supplier
  Future<int> countItemsBySupplier(String supplier) async {
    return _inventoryRepository.countItemsBySupplier(supplier);
  }

  /// Count number of recipes using item
  Future<int> countRecipesUsingItem(String itemId) async {
    return _inventoryRepository.countRecipesUsingItem(itemId);
  }
}
