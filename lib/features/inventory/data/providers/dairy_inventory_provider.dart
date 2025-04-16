import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_item_model_extensions.dart';

class DairyInventoryProvider {
  DairyInventoryProvider({required this.sharedPreferences}) {
    _loadFromStorage();
  }

  final SharedPreferences sharedPreferences;
  static const _storageKey = 'dairy_inventory_data';
  static const _originalInventoryKey = 'original_dairy_inventory_data';
  final _uuid = const Uuid();

  // Mock data container
  List<InventoryItemModel> _mockDairyItems = [];

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
    final newItem = item.id.isEmpty ? item.copyWith(id: _uuid.v4()) : item;
    _mockDairyItems.add(newItem);
    _saveToStorage();
  }

  // Update item
  void updateItem(InventoryItemModel updatedItem) {
    final index =
        _mockDairyItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _mockDairyItems[index] = updatedItem;
      _saveToStorage();
    }
  }

  // Delete item
  void deleteItem(String id) {
    _mockDairyItems.removeWhere((item) => item.id == id);
    _saveToStorage();
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
      if (item.cost != null) {
        values[item.category] =
            (values[item.category] ?? 0) + (item.quantity * item.cost!);
      }
    }
    return values;
  }

  // Get items needing reorder
  List<InventoryItemModel> getItemsNeedingReorder() {
    return _mockDairyItems
        .where((item) => item.quantity <= item.reorderPoint)
        .toList();
  }

  // Search items
  List<InventoryItemModel> searchItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _mockDairyItems.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          item.category.toLowerCase().contains(lowercaseQuery) ||
          item.batchNumber?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  // Reset all inventory to default
  Future<void> resetInventory() async {
    final originalDataString =
        sharedPreferences.getString(_originalInventoryKey);
    if (originalDataString != null) {
      await sharedPreferences.setString(_storageKey, originalDataString);
      _loadFromStorage();
    } else {
      _initializeDefaultInventory();
    }
  }

  // Save inventory to persistent storage
  void _saveToStorage() {
    final List<Map<String, dynamic>> itemsJson =
        _mockDairyItems.map((item) => item.toSimpleJson()).toList();

    // Convert to string and store
    sharedPreferences.setString(_storageKey, jsonEncode(itemsJson));
  }

  // Load inventory from persistent storage
  void _loadFromStorage() {
    final dataString = sharedPreferences.getString(_storageKey);

    if (dataString != null && dataString.isNotEmpty) {
      try {
        final List<dynamic> parsed = jsonDecode(dataString) as List<dynamic>;
        _mockDairyItems = parsed
            .map((itemJson) => InventoryItemModelFactory.fromJson(
                itemJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _initializeDefaultInventory();
      }
    } else {
      _initializeDefaultInventory();
    }
  }

  // Initialize with default inventory if none exists
  void _initializeDefaultInventory() {
    _mockDairyItems = _createDefaultDairyInventory();
    _saveToStorage();

    // Also save as original data for reset functionality
    final List<Map<String, dynamic>> itemsJson =
        _mockDairyItems.map((item) => item.toSimpleJson()).toList();
    sharedPreferences.setString(_originalInventoryKey, jsonEncode(itemsJson));
  }

  // Create default dairy inventory items
  List<InventoryItemModel> _createDefaultDairyInventory() {
    final now = DateTime.now();

    return [
      // Milk products
      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Fresh Whole Milk',
        category: 'Milk',
        unit: 'Liters',
        quantity: 250.0,
        minimumQuantity: 50.0,
        reorderPoint: 75.0,
        location: 'Cold Storage A',
        lastUpdated: now,
        batchNumber:
            'MILK-WH-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 7)),
        cost: 1.20,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 3.5,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Hillside Dairy',
          'region': 'Central Valley',
          'milkingDate':
              now.subtract(const Duration(days: 1)).toIso8601String(),
        },
        processingDate: now.subtract(const Duration(hours: 8)),
        additionalAttributes: {
          'pH': 6.7,
          'somatic_cell_count': 185000,
          'bacteria_count': 15000,
        },
      ),

      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Low-Fat Milk (2%)',
        category: 'Milk',
        unit: 'Liters',
        quantity: 180.0,
        minimumQuantity: 40.0,
        reorderPoint: 60.0,
        location: 'Cold Storage A',
        lastUpdated: now,
        batchNumber:
            'MILK-LF-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 7)),
        cost: 1.15,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 2.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Greenfield Farms',
          'region': 'Central Valley',
          'milkingDate':
              now.subtract(const Duration(days: 1)).toIso8601String(),
        },
        processingDate: now.subtract(const Duration(hours: 10)),
        additionalAttributes: {
          'pH': 6.6,
          'somatic_cell_count': 165000,
          'bacteria_count': 14000,
        },
      ),

      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Skimmed Milk',
        category: 'Milk',
        unit: 'Liters',
        quantity: 120.0,
        minimumQuantity: 30.0,
        reorderPoint: 45.0,
        location: 'Cold Storage A',
        lastUpdated: now,
        batchNumber:
            'MILK-SK-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 7)),
        cost: 1.05,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 0.1,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Riverdale Dairy',
          'region': 'Northern Plains',
          'milkingDate':
              now.subtract(const Duration(days: 1)).toIso8601String(),
        },
        processingDate: now.subtract(const Duration(hours: 9)),
        additionalAttributes: {
          'pH': 6.7,
          'somatic_cell_count': 150000,
          'bacteria_count': 13000,
        },
      ),

      // Yogurt products
      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Plain Greek Yogurt',
        category: 'Yogurt',
        unit: 'Kg',
        quantity: 85.0,
        minimumQuantity: 20.0,
        reorderPoint: 30.0,
        location: 'Cold Storage B',
        lastUpdated: now,
        batchNumber:
            'YOG-GR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 21)),
        cost: 2.10,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 5.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Hillside Dairy',
          'region': 'Central Valley',
        },
        processingDate: now.subtract(const Duration(days: 1)),
        additionalAttributes: {
          'pH': 4.5,
          'protein_content': 9.0,
          'live_cultures': true,
        },
      ),

      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Strawberry Yogurt',
        category: 'Yogurt',
        unit: 'Kg',
        quantity: 65.0,
        minimumQuantity: 15.0,
        reorderPoint: 25.0,
        location: 'Cold Storage B',
        lastUpdated: now,
        batchNumber:
            'YOG-ST-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 18)),
        cost: 2.25,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 3.5,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Greenfield Farms',
          'region': 'Central Valley',
        },
        processingDate: now.subtract(const Duration(days: 2)),
        additionalAttributes: {
          'pH': 4.3,
          'protein_content': 7.5,
          'live_cultures': true,
          'sugar_content': 12.0,
          'fruit_content': '8%',
          'contains_allergens': ['milk'],
        },
      ),

      // Cheese products
      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Cheddar Cheese',
        category: 'Cheese',
        unit: 'Kg',
        quantity: 45.0,
        minimumQuantity: 10.0,
        reorderPoint: 15.0,
        location: 'Cold Storage C',
        lastUpdated: now,
        batchNumber:
            'CHS-CH-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 60)),
        cost: 5.50,
        currentTemperature: 5.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 34.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Mountain Cheese Farm',
          'region': 'Western Highlands',
        },
        processingDate: now.subtract(const Duration(days: 30)),
        additionalAttributes: {
          'pH': 5.2,
          'moisture_content': 37.0,
          'ripening_stage': 'Medium',
          'salt_content': 1.8,
          'aging_time': '30 days',
          'texture': 'Firm',
          'color': 'Yellow-Orange',
          'contains_allergens': ['milk'],
        },
      ),

      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Mozzarella Cheese',
        category: 'Cheese',
        unit: 'Kg',
        quantity: 38.0,
        minimumQuantity: 8.0,
        reorderPoint: 12.0,
        location: 'Cold Storage C',
        lastUpdated: now,
        batchNumber:
            'CHS-MZ-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 30)),
        cost: 4.80,
        currentTemperature: 4.5,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 22.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Valley Dairy Co-op',
          'region': 'Southern Plains',
        },
        processingDate: now.subtract(const Duration(days: 7)),
        additionalAttributes: {
          'pH': 5.5,
          'moisture_content': 52.0,
          'salt_content': 1.2,
          'texture': 'Soft',
          'type': 'Fresh',
          'contains_allergens': ['milk'],
        },
      ),

      // Butter products
      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Unsalted Butter',
        category: 'Butter',
        unit: 'Kg',
        quantity: 30.0,
        minimumQuantity: 7.0,
        reorderPoint: 10.0,
        location: 'Cold Storage D',
        lastUpdated: now,
        batchNumber:
            'BTR-US-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 45)),
        cost: 7.20,
        currentTemperature: 3.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 82.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Hillside Dairy',
          'region': 'Central Valley',
        },
        processingDate: now.subtract(const Duration(days: 5)),
        additionalAttributes: {
          'moisture_content': 16.0,
          'salt_content': 0.0,
          'contains_allergens': ['milk'],
        },
      ),

      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Salted Butter',
        category: 'Butter',
        unit: 'Kg',
        quantity: 25.0,
        minimumQuantity: 6.0,
        reorderPoint: 9.0,
        location: 'Cold Storage D',
        lastUpdated: now,
        batchNumber:
            'BTR-SL-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 60)),
        cost: 7.50,
        currentTemperature: 3.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 80.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Greenfield Farms',
          'region': 'Central Valley',
        },
        processingDate: now.subtract(const Duration(days: 5)),
        additionalAttributes: {
          'moisture_content': 16.0,
          'salt_content': 2.5,
          'contains_allergens': ['milk'],
        },
      ),

      // Cream products
      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Heavy Cream',
        category: 'Cream',
        unit: 'Liters',
        quantity: 40.0,
        minimumQuantity: 10.0,
        reorderPoint: 15.0,
        location: 'Cold Storage A',
        lastUpdated: now,
        batchNumber:
            'CRM-HV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 14)),
        cost: 3.60,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 36.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Riverdale Dairy',
          'region': 'Northern Plains',
        },
        processingDate: now.subtract(const Duration(days: 2)),
        additionalAttributes: {
          'pH': 6.7,
          'somatic_cell_count': 170000,
          'contains_allergens': ['milk'],
        },
      ),

      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Sour Cream',
        category: 'Cream',
        unit: 'Kg',
        quantity: 22.0,
        minimumQuantity: 5.0,
        reorderPoint: 8.0,
        location: 'Cold Storage B',
        lastUpdated: now,
        batchNumber:
            'CRM-SR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 21)),
        cost: 2.90,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 20.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Hillside Dairy',
          'region': 'Central Valley',
        },
        processingDate: now.subtract(const Duration(days: 3)),
        additionalAttributes: {
          'pH': 4.5,
          'live_cultures': true,
          'contains_allergens': ['milk'],
        },
      ),

      // Near expiry item for testing
      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Ricotta Cheese (Near Expiry)',
        category: 'Cheese',
        unit: 'Kg',
        quantity: 5.0,
        minimumQuantity: 3.0,
        reorderPoint: 5.0,
        location: 'Cold Storage C',
        lastUpdated: now,
        batchNumber:
            'CHS-RC-${now.year}${now.month.toString().padLeft(2, '0')}${(now.day - 10).toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 1)), // Near expiry
        cost: 3.10,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.good,
        fatContent: 13.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Valley Dairy Co-op',
          'region': 'Southern Plains',
        },
        processingDate: now.subtract(const Duration(days: 9)),
        additionalAttributes: {
          'pH': 5.7,
          'moisture_content': 70.0,
          'texture': 'Soft',
          'contains_allergens': ['milk'],
        },
      ),

      // Low stock item for testing
      InventoryItemModel(
        id: _uuid.v4(),
        name: 'Cottage Cheese (Low Stock)',
        category: 'Cheese',
        unit: 'Kg',
        quantity: 3.0, // Low stock
        minimumQuantity: 4.0,
        reorderPoint: 6.0,
        location: 'Cold Storage C',
        lastUpdated: now,
        batchNumber:
            'CHS-CT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        expiryDate: now.add(const Duration(days: 14)),
        cost: 2.75,
        currentTemperature: 4.0,
        storageCondition: 'Refrigerated',
        overallQualityStatus: QualityStatus.excellent,
        fatContent: 4.0,
        pasteurized: true,
        sourceInfo: {
          'farm': 'Mountain Cheese Farm',
          'region': 'Western Highlands',
        },
        processingDate: now.subtract(const Duration(days: 3)),
        additionalAttributes: {
          'pH': 5.0,
          'moisture_content': 80.0,
          'texture': 'Curds',
          'contains_allergens': ['milk'],
        },
      ),
    ];
  }
}

// Provider for the dairy inventory
final dairyInventoryProvider = Provider<DairyInventoryProvider>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return DairyInventoryProvider(sharedPreferences: sharedPrefs);
});

// Provider for shared preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});
