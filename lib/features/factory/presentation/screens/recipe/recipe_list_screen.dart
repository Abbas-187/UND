import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/recipe_provider.dart';

class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, '/factory/recipe/create'),
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(
              child: Text('No recipes found'),
            );
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(recipe.name),
                  subtitle: Text('Product ID: ${recipe.productId}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ingredients: ${recipe.ingredients.length}'),
                      const SizedBox(width: 8),
                      Text(
                          'Created: ${recipe.createdAt.toString().substring(0, 10)}'),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/factory/recipe/detail',
                    arguments: {'recipeId': recipe.id},
                  ),
                  onLongPress: () => Navigator.pushNamed(
                    context,
                    '/factory/recipe/edit',
                    arguments: {'recipeId': recipe.id},
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading recipes: $error'),
        ),
      ),
    );
  }
}
