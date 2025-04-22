import 'package:riverpod/riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository.dart';
import 'package:collection/collection.dart';

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
    // Add history entry for creation
    final user = 'system'; // Replace with actual user if available
    final historyEntry = RecipeHistoryEntry(
      timestamp: DateTime.now(),
      user: user,
      action: 'created',
      before: null,
      after: recipe.toJson(),
      note: 'Recipe created',
    );
    final recipeWithHistory = recipe.copyWith(
      history: [...recipe.history, historyEntry],
    );
    await recipeRepository.createRecipe(recipeWithHistory);
    await _loadRecipes();
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    // Find the old recipe for before/after diff
    final oldRecipe = state.value?.firstWhereOrNull((r) => r.id == recipe.id);
    final user = 'system'; // Replace with actual user if available
    final historyEntry = RecipeHistoryEntry(
      timestamp: DateTime.now(),
      user: user,
      action: 'edited',
      before: oldRecipe?.toJson(),
      after: recipe.toJson(),
      note: 'Recipe updated',
    );
    final recipeWithHistory = recipe.copyWith(
      history: [...recipe.history, historyEntry],
    );
    await recipeRepository.updateRecipe(recipeWithHistory);
    await _loadRecipes();
  }

  Future<void> deleteRecipe(String id) async {
    await recipeRepository.deleteRecipe(id);
    await _loadRecipes();
  }

  Future<void> approveRecipe(String id, String approvedByUserId) async {
    // Find the old recipe for before/after diff
    final oldRecipe = state.value?.firstWhereOrNull((r) => r.id == id);
    if (oldRecipe == null) return;
    final updatedRecipe = oldRecipe.copyWith(
      approvedByUserId: approvedByUserId,
      approvedAt: DateTime.now(),
    );
    final historyEntry = RecipeHistoryEntry(
      timestamp: DateTime.now(),
      user: approvedByUserId,
      action: 'approved',
      before: oldRecipe.toJson(),
      after: updatedRecipe.toJson(),
      note: 'Recipe approved',
    );
    final recipeWithHistory = updatedRecipe.copyWith(
      history: [...oldRecipe.history, historyEntry],
    );
    await recipeRepository.updateRecipe(recipeWithHistory);
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
