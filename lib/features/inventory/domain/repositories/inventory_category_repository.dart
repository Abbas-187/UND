import '../entities/inventory_category.dart';

/// Repository interface for inventory category management
abstract class InventoryCategoryRepository {
  /// Gets all inventory categories
  Future<List<InventoryCategory>> getCategories();

  /// Gets an inventory category by ID
  Future<InventoryCategory?> getCategory(String id);

  /// Adds a new inventory category
  Future<InventoryCategory> addCategory(InventoryCategory category);

  /// Updates an existing inventory category
  Future<void> updateCategory(InventoryCategory category);

  /// Deletes an inventory category
  Future<void> deleteCategory(String id);

  /// Gets child categories of a parent category
  Future<List<InventoryCategory>> getChildCategories(String parentId);

  /// Updates attribute definitions for a category
  Future<void> updateCategoryAttributes(
      String categoryId, Map<String, AttributeDefinition> attributes);

  /// Gets item count for each category
  Future<Map<String, int>> getCategoryItemCounts();
}
