import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../factory/data/models/recipe_ingredient_model.dart';
import '../models/inventory_item_model.dart';

// Provider for DairyInventoryProvider
final dairyInventoryProvider = Provider<DairyInventoryProvider>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return DairyInventoryProvider(sharedPreferences: sharedPrefs);
});

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

/// Provider for dairy inventory data
class DairyInventoryProvider {
  // Constructor (placed before other class members)
  DairyInventoryProvider({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  final Uuid _uuid = const Uuid();

  // Empty list for Firebase data
  final List<InventoryItemModel> _mockDairyItems = [];

  // Get all dairy inventory items
  List<InventoryItemModel> getAllItems() => _mockDairyItems;

  // Get item by ID
  InventoryItemModel? getItemById(String id) {
    try {
      return _mockDairyItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new item
  void addItem(InventoryItemModel item) {
    final newItem =
        item.id?.isEmpty ?? true ? item.copyWith(id: _uuid.v4()) : item;
    _mockDairyItems.add(newItem);
    // Firebase data is used instead of storage
  }

  // Update item
  void updateItem(InventoryItemModel updatedItem) {
    final index =
        _mockDairyItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _mockDairyItems[index] = updatedItem;
      // Firebase data is used instead of storage
    }
  }

  // Delete item
  void deleteItem(String id) {
    _mockDairyItems.removeWhere((item) => item.id == id);
    // Firebase data is used instead of storage
  }

  // Get items by category
  List<InventoryItemModel> getItemsByCategory(String category) {
    return _mockDairyItems.where((item) => item.category == category).toList();
  }

  // Get low stock items
  List<InventoryItemModel> getLowStockItems() {
    return _mockDairyItems
        .where((item) => item.quantity <= item.minimumQuantity)
        .toList();
  }

  // Get expiring items
  List<InventoryItemModel> getExpiringItems({int days = 7}) {
    final threshold = DateTime.now().add(Duration(days: days));
    return _mockDairyItems
        .where((item) =>
            item.expiryDate != null && item.expiryDate!.isBefore(threshold))
        .toList();
  }

  // Get items by location
  List<InventoryItemModel> getItemsByLocation(String location) {
    return _mockDairyItems.where((item) => item.location == location).toList();
  }

  // Adjust item quantity
  void adjustQuantity(String itemId, double adjustment, String reason) {
    final item = getItemById(itemId);
    if (item != null) {
      final updatedItem = item.copyWith(
        quantity: item.quantity + adjustment,
        lastUpdated: DateTime.now(),
      );
      updateItem(updatedItem);
    }
  }

  // Get inventory value by category
  Map<String, double> getInventoryValueByCategory() {
    final Map<String, double> values = {};
    for (final item in _mockDairyItems) {
      final category = item.category;
      final cost = item.cost ?? 0.0;
      final value = item.quantity * cost;

      if (values.containsKey(category)) {
        values[category] = (values[category] ?? 0) + value;
      } else {
        values[category] = value;
      }
    }
    return values;
  }

  // Search items by name or category
  List<InventoryItemModel> searchItems(String query) {
    final lowerQuery = query.toLowerCase();
    return _mockDairyItems.where((item) {
      final lowerName = item.name.toLowerCase();
      final lowerCategory = item.category.toLowerCase();
      return lowerName.contains(lowerQuery) ||
          lowerCategory.contains(lowerQuery);
    }).toList();
  }

  // Get items needing reorder
  List<InventoryItemModel> getItemsNeedingReorder() {
    return _mockDairyItems
        .where((item) => item.quantity <= item.reorderPoint)
        .toList();
  }

  // Reset inventory to default state (mock implementation)
  Future<void> resetInventory() async {
    _mockDairyItems.clear();
    // Optionally, re-add default/mock items here if needed
  }

  // Reset to original inventory data - disabled for Firebase usage
  void resetToOriginal() {
    // Functionality removed for Firebase integration
  }

  /// Get recipe ingredients by recipe ID
  List<RecipeIngredientModel>? getRecipeIngredients(String recipeId) {
    // Mock implementation: Replace with actual logic to fetch recipe ingredients
    return [
      RecipeIngredientModel(
          id: 'item1', name: 'Milk', quantity: 2.0, unit: 'liters'),
      RecipeIngredientModel(
          id: 'item2', name: 'Sugar', quantity: 1.5, unit: 'kg'),
    ];
  }
}
