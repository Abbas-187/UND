import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/inventory_category_repository_impl.dart';
import '../../domain/entities/inventory_category.dart';
import '../../domain/repositories/inventory_category_repository.dart';

// Provider for the repository instance
final inventoryCategoryRepositoryProvider =
    Provider<InventoryCategoryRepository>((ref) {
  // Provide the Firebase-backed implementation
  return InventoryCategoryRepositoryImpl();
});

// Provider for all categories
final categoriesProvider = FutureProvider<List<InventoryCategory>>((ref) async {
  final repository = ref.watch(inventoryCategoryRepositoryProvider);
  return repository.getCategories();
});

// Provider for a specific category
final categoryProvider =
    FutureProvider.family<InventoryCategory?, String>((ref, id) async {
  final repository = ref.watch(inventoryCategoryRepositoryProvider);
  return repository.getCategory(id);
});

// Provider for child categories of a given parent category
final childCategoriesProvider =
    FutureProvider.family<List<InventoryCategory>, String>(
        (ref, parentId) async {
  final repository = ref.watch(inventoryCategoryRepositoryProvider);
  return repository.getChildCategories(parentId);
});

// Provider for category item counts
final categoryItemCountsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(inventoryCategoryRepositoryProvider);
  return repository.getCategoryItemCounts();
});

// Provider for selected category ID (for UI state)
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

// Provider for category editing mode
final categoryEditModeProvider = StateProvider<bool>((ref) => false);

// Provider for currently edited category
final editedCategoryProvider = StateProvider<InventoryCategory?>((ref) => null);

// Class for selected category with children
class CategoryWithChildren {
  CategoryWithChildren({
    this.category,
    required this.children,
  });
  final InventoryCategory? category;
  final List<InventoryCategory> children;
}

// Utility provider that combines selected category with its child categories
final selectedCategoryWithChildrenProvider =
    FutureProvider<CategoryWithChildren>((ref) async {
  final selectedId = ref.watch(selectedCategoryIdProvider);

  if (selectedId == null) {
    return CategoryWithChildren(category: null, children: const []);
  }

  final category = await ref.watch(categoryProvider(selectedId).future);
  final children = await ref.watch(childCategoriesProvider(selectedId).future);

  return CategoryWithChildren(category: category, children: children);
});
