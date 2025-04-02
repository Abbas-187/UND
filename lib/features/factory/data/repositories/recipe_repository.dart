import 'package:riverpod/riverpod.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  Future<List<RecipeModel>> getRecipes() async {
    // TODO: Implement actual API call
    return [];
  }

  Future<RecipeModel> getRecipeById(String id) async {
    // TODO: Implement actual API call
    throw UnimplementedError();
  }

  Future<List<RecipeModel>> getRecipesByProductId(String productId) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<void> createRecipe(RecipeModel recipe) async {
    // TODO: Implement actual API call
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    // TODO: Implement actual API call
  }

  Future<void> deleteRecipe(String id) async {
    // TODO: Implement actual API call
  }

  Future<void> approveRecipe(String id, String approvedByUserId) async {
    // TODO: Implement actual API call
  }
}

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});
