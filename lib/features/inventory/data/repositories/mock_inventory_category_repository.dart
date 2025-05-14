/*
import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../domain/entities/inventory_category.dart';
import '../../domain/repositories/inventory_category_repository.dart';

class MockInventoryCategoryRepository implements InventoryCategoryRepository {
  final List<InventoryCategory> _categories = [
    InventoryCategory(
      id: '1',
      name: 'Dairy Products',
      description: 'All dairy products',
      colorCode: '#4caf50',
      itemCount: 28,
      attributeDefinitions: {
        'fatContent': AttributeDefinition(
          name: 'Fat Content',
          type: AttributeType.number,
          description: 'Fat content percentage',
          required: true,
        ),
        'pasteurization': AttributeDefinition(
          name: 'Pasteurization',
          type: AttributeType.selection,
          options: ['Raw', 'HTST', 'UHT'],
          required: true,
        ),
      },
    ),
    InventoryCategory(
      id: '2',
      name: 'Milk',
      description: 'All milk products',
      parentCategoryId: '1',
      colorCode: '#8bc34a',
      itemCount: 15,
      attributeDefinitions: {
        'milkType': AttributeDefinition(
          name: 'Milk Type',
          type: AttributeType.selection,
          options: ['Whole', 'Skimmed', 'Semi-skimmed'],
          required: true,
        ),
      },
    ),
    InventoryCategory(
      id: '3',
      name: 'Cheese',
      description: 'All cheese products',
      parentCategoryId: '1',
      colorCode: '#cddc39',
      itemCount: 8,
      attributeDefinitions: {
        'ageingPeriod': AttributeDefinition(
          name: 'Ageing Period',
          type: AttributeType.number,
          description: 'Ageing period in days',
          required: false,
        ),
        'cheeseType': AttributeDefinition(
          name: 'Cheese Type',
          type: AttributeType.selection,
          options: ['Soft', 'Semi-soft', 'Hard', 'Blue'],
          required: true,
        ),
      },
    ),
    InventoryCategory(
      id: '4',
      name: 'Yogurt',
      description: 'All yogurt products',
      parentCategoryId: '1',
      colorCode: '#ffeb3b',
      itemCount: 5,
      attributeDefinitions: {
        'cultures': AttributeDefinition(
          name: 'Bacterial Cultures',
          type: AttributeType.text,
          required: false,
        ),
      },
    ),
    InventoryCategory(
      id: '5',
      name: 'Packaging Materials',
      description: 'All packaging materials',
      colorCode: '#795548',
      itemCount: 18,
      attributeDefinitions: {
        'material': AttributeDefinition(
          name: 'Material',
          type: AttributeType.selection,
          options: ['Plastic', 'Glass', 'Paper', 'Metal', 'Composite'],
          required: true,
        ),
        'recyclable': AttributeDefinition(
          name: 'Recyclable',
          type: AttributeType.boolean,
          required: true,
          defaultValue: true,
        ),
      },
    ),
    InventoryCategory(
      id: '6',
      name: 'Ingredients',
      description: 'Raw ingredients',
      colorCode: '#ff9800',
      itemCount: 32,
      attributeDefinitions: {
        'allergen': AttributeDefinition(
          name: 'Allergen',
          type: AttributeType.boolean,
          required: true,
          defaultValue: false,
        ),
        'organiCertified': AttributeDefinition(
          name: 'Organic Certified',
          type: AttributeType.boolean,
          required: false,
        ),
      },
    ),
    InventoryCategory(
      id: '7',
      name: 'Equipment',
      description: 'Processing and manufacturing equipment',
      colorCode: '#607d8b',
      itemCount: 12,
      attributeDefinitions: {
        'maintenanceInterval': AttributeDefinition(
          name: 'Maintenance Interval',
          type: AttributeType.number,
          description: 'Maintenance interval in days',
          required: true,
        ),
      },
    ),
  ];

  final Map<String, int> _itemCounts = {
    '1': 28,
    '2': 15,
    '3': 8,
    '4': 5,
    '5': 18,
    '6': 32,
    '7': 12,
  };

  @override
  Future<List<InventoryCategory>> getCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_categories);
  }

  @override
  Future<InventoryCategory?> getCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<InventoryCategory> addCategory(InventoryCategory category) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final newId = category.id.isEmpty ? const Uuid().v4() : category.id;
    final newCategory = category.copyWith(id: newId);

    _categories.add(newCategory);
    _itemCounts[newId] = newCategory.itemCount;

    return newCategory;
  }

  @override
  Future<void> updateCategory(InventoryCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      _itemCounts[category.id] = category.itemCount;
    } else {
      throw Exception('Category not found: ${category.id}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final categoryToDelete = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Category not found: $id'),
    );

    // Check if there are any child categories
    if (_categories.any((c) => c.parentCategoryId == id)) {
      throw Exception('Cannot delete category with child categories');
    }

    _categories.removeWhere((c) => c.id == id);
    _itemCounts.remove(id);
  }

  @override
  Future<List<InventoryCategory>> getChildCategories(String parentId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _categories
        .where((category) => category.parentCategoryId == parentId)
        .toList();
  }

  @override
  Future<void> updateCategoryAttributes(
      String categoryId, Map<String, AttributeDefinition> attributes) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        attributeDefinitions: attributes,
      );
    } else {
      throw Exception('Category not found: $categoryId');
    }
  }

  @override
  Future<Map<String, int>> getCategoryItemCounts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Map.from(_itemCounts);
  }
}
*/
