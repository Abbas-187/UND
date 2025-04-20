import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../inventory/data/providers/mock_inventory_provider.dart';
import '../models/recipe_model.dart';
import '../models/recipe_ingredient_model.dart';

/// Provides mock recipe data that integrates with inventory
class MockRecipeProvider {
  MockRecipeProvider({
    required this.mockDataService,
    required this.mockInventoryProvider,
  });

  final MockDataService mockDataService;
  final MockInventoryProvider mockInventoryProvider;

  // Get recipe ingredients from inventory
  List<RecipeIngredientModel> getRecipeIngredients(String recipeId) {
    final ingredients = mockDataService.getRecipeIngredients(recipeId);
    final List<RecipeIngredientModel> result = [];

    for (final ingredient in ingredients) {
      result.add(
        RecipeIngredientModel(
          id: ingredient['ingredientId'] as String,
          name: ingredient['name'] as String,
          quantity: ingredient['quantity'] as double,
          unit: ingredient['unit'] as String,
        ),
      );
    }

    return result;
  }

  // Check if there's enough inventory for a recipe
  bool checkInventoryForRecipe(String recipeId, double batchSize) {
    return mockDataService.checkInventoryForRecipe(recipeId, batchSize);
  }

  // Get mock recipes
  List<RecipeModel> getAllRecipes() {
    // Create mock recipes based on recipe ingredients in mock data service
    final Map<String, List<Map<String, dynamic>>> recipeIngredients =
        mockDataService.recipeIngredients;
    final List<RecipeModel> recipes = [];

    // Convert each recipe in mock data to RecipeModel
    recipeIngredients.forEach((recipeId, ingredients) {
      String recipeName = 'Unknown Recipe';
      String productId = '';

      // Determine the recipe name based on the recipe ID
      switch (recipeId) {
        case 'recipe-001':
          recipeName = 'Yogurt Production';
          productId = 'yogurt-001';
          break;
        case 'recipe-002':
          recipeName = 'Flavored Yogurt Production';
          productId = 'yogurt-002';
          break;
        case 'recipe-003':
          recipeName = 'Cheese Production';
          productId = 'cheese-001';
          break;
        default:
          recipeName = 'Recipe $recipeId';
      }

      // Convert ingredients to RecipeIngredientModel
      final recipeIngredients = ingredients.map((ingredient) {
        return RecipeIngredientModel(
          id: ingredient['ingredientId'] as String,
          name: ingredient['name'] as String,
          quantity: ingredient['quantity'] as double,
          unit: ingredient['unit'] as String,
        );
      }).toList();

      // Create the recipe model
      recipes.add(
        RecipeModel(
          id: recipeId,
          name: recipeName,
          productId: productId,
          ingredients: Map.fromEntries(recipeIngredients.map(
            (i) => MapEntry(i.id, i.quantity),
          )),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
          approvedByUserId: 'user-002',
          approvedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      );
    });

    return recipes;
  }

  // Helper to generate mock instructions for a recipe
  String _generateInstructions(
      String recipeName, List<RecipeIngredientModel> ingredients) {
    StringBuffer instructions = StringBuffer();

    // Add header
    instructions.writeln('# Production Instructions for $recipeName\n');

    // Add ingredients list
    instructions.writeln('## Ingredients\n');
    for (final ingredient in ingredients) {
      instructions.writeln(
          '- ${ingredient.quantity} ${ingredient.unit} of ${ingredient.name}');
    }
    instructions.writeln('');

    // Add preparation steps
    instructions.writeln('## Preparation Steps\n');

    if (recipeName.contains('Yogurt')) {
      instructions.writeln('1. Heat the milk to 85°C for 30 minutes.');
      instructions.writeln('2. Cool down to 45°C.');
      instructions.writeln('3. Add yogurt culture and mix well.');
      instructions.writeln('4. Incubate at 45°C for 4-6 hours until set.');
      if (recipeName.contains('Flavored')) {
        instructions.writeln('5. Mix in fruit puree and sugar.');
        instructions
            .writeln('6. Package in containers and refrigerate at 4°C.');
      } else {
        instructions
            .writeln('5. Package in containers and refrigerate at 4°C.');
      }
    } else if (recipeName.contains('Cheese')) {
      instructions.writeln('1. Heat the milk to 32°C.');
      instructions.writeln('2. Add starter culture and mix well.');
      instructions.writeln('3. Add rennet and stir for 1 minute.');
      instructions.writeln('4. Let set for 30-45 minutes until curd forms.');
      instructions.writeln('5. Cut the curd into 1/2 inch cubes.');
      instructions.writeln('6. Heat slowly to 38°C while stirring gently.');
      instructions.writeln('7. Drain the whey and transfer curds to molds.');
      instructions.writeln('8. Press the cheese for 12 hours.');
      instructions.writeln('9. Salt the cheese and age for 60 days at 10°C.');
    }

    return instructions.toString();
  }
}

/// Provider for mock recipes
final mockRecipeProvider = Provider<MockRecipeProvider>((ref) {
  final mockDataService = ref.read(mockDataServiceProvider);
  final inventoryProvider = ref.read(mockInventoryProvider);

  return MockRecipeProvider(
    mockDataService: mockDataService,
    mockInventoryProvider: inventoryProvider,
  );
});
