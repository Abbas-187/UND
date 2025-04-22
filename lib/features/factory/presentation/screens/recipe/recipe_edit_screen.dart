import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/recipe_provider.dart';
import '../../../data/models/recipe_model.dart';
import '../../widgets/recipe_form.dart';

class RecipeEditScreen extends ConsumerWidget {
  final String recipeId;
  const RecipeEditScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
      ),
      body: recipeAsync.when(
        data: (recipe) => RecipeForm(
          initialValue: recipe,
          isEditing: true,
          onSubmit: (updatedRecipe) async {
            try {
              final recipesNotifier = ref.read(recipesStateProvider.notifier);
              await recipesNotifier.updateRecipe(updatedRecipe);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe updated successfully')),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update recipe: $e')),
                );
              }
            }
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
