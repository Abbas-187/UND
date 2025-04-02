import 'package:riverpod/riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository.dart';

/// Provider for recipes and related CRUD operations.
///
/// This implementation removes the dependency on code generation by manually
/// implementing providers using Riverpod's StateNotifier and FutureProvider.

/// StateNotifier that manages the list of recipes.
class RecipesState extends StateNotifier<AsyncValue<List<RecipeModel>>> {
  RecipesState({required this.recipeRepository})
      : super(const AsyncValue.loading()) {
    _loadRecipes();
  }
  final RecipeRepository recipeRepository;

  Future<void> _loadRecipes() async {
    try {
      final recipes = await recipeRepository.getRecipes();
      state = AsyncValue.data(recipes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<RecipeModel>> getRecipesByProductId(String productId) async {
    return await recipeRepository.getRecipesByProductId(productId);
  }

  Future<void> createRecipe(RecipeModel recipe) async {
    await recipeRepository.createRecipe(recipe);
    await _loadRecipes();
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    await recipeRepository.updateRecipe(recipe);
    await _loadRecipes();
  }

  Future<void> deleteRecipe(String id) async {
    await recipeRepository.deleteRecipe(id);
    await _loadRecipes();
  }

  Future<void> approveRecipe(String id, String approvedByUserId) async {
    await recipeRepository.approveRecipe(id, approvedByUserId);
    await _loadRecipes();
  }
}

/// Provider for the recipes state notifier
final recipesStateProvider = StateNotifierProvider.autoDispose<RecipesState,
    AsyncValue<List<RecipeModel>>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipesState(recipeRepository: repository);
});

/// Provider to get a single recipe by ID
final recipeByIdProvider =
    FutureProvider.autoDispose.family<RecipeModel, String>((ref, id) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getRecipeById(id);
});

/// Provider to get recipes by product ID
final recipesByProductIdProvider = FutureProvider.autoDispose
    .family<List<RecipeModel>, String>((ref, productId) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getRecipesByProductId(productId);
});
