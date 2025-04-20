import '../entities/inventory_category.dart';

abstract class InventoryCategoryRepository {
  Future<List<InventoryCategory>> getCategories();
  Future<InventoryCategory?> getCategory(String id);
  Future<InventoryCategory> addCategory(InventoryCategory category);
  Future<void> updateCategory(InventoryCategory category);
  Future<void> deleteCategory(String id);
  Future<List<InventoryCategory>> getChildCategories(String parentId);
  Future<Map<String, int>> getCategoryItemCounts();
  Future<void> updateCategoryAttributes(
      String categoryId, Map<String, AttributeDefinition> attributeDefinitions);
}
