import 'package:riverpod/riverpod.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  Future<List<RecipeModel>> getRecipes() async {
    // Return mock recipes
    return [
      RecipeModel(
        id: 'recipe-001',
        name: 'Yogurt Production',
        productId: 'yogurt-001',
        ingredients: {
          'milk': 100.0,
          'yogurt-culture': 5.0,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        approvedByUserId: 'user-002',
        approvedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RecipeModel(
        id: 'recipe-002',
        name: 'Flavored Yogurt Production',
        productId: 'yogurt-002',
        ingredients: {
          'milk': 100.0,
          'yogurt-culture': 5.0,
          'sugar': 10.0,
          'fruit-puree': 15.0,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        approvedByUserId: 'user-002',
        approvedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      RecipeModel(
        id: 'recipe-003',
        name: 'Cheese Production',
        productId: 'cheese-001',
        ingredients: {
          'milk': 100.0,
          'rennet': 2.0,
          'salt': 1.5,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<RecipeModel> getRecipeById(String id) async {
    // Return a mock recipe based on ID
    final recipes = await getRecipes();
    final recipe = recipes.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Recipe not found'),
    );
    return recipe;
  }

  Future<List<RecipeModel>> getRecipesByProductId(String productId) async {
    // Return mock recipes filtered by product ID
    final recipes = await getRecipes();
    return recipes.where((r) => r.productId == productId).toList();
  }

  Future<void> createRecipe(RecipeModel recipe) async {
    // Simulate creation - in a real app this would save to a database
    print('Creating recipe: ${recipe.name}');
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    // Simulate update - in a real app this would update the database
    print('Updating recipe: ${recipe.name}');
  }

  Future<void> deleteRecipe(String id) async {
    // Simulate deletion - in a real app this would delete from the database
    print('Deleting recipe with ID: $id');
  }

  Future<void> approveRecipe(String id, String approvedByUserId) async {
    // Simulate approval - in a real app this would update approval status
    print('Approving recipe with ID: $id by user: $approvedByUserId');
  }
}

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});
