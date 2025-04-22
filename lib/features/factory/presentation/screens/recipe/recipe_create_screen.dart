import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/recipe_model.dart';
import '../../../domain/providers/recipe_provider.dart';
import '../../widgets/recipe_form.dart';

class RecipeCreateScreen extends ConsumerWidget {
  const RecipeCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
      ),
      body: RecipeForm(
        onSubmit: (recipe) async {
          try {
            final recipesNotifier = ref.read(recipesStateProvider.notifier);
            await recipesNotifier.createRecipe(recipe);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recipe created successfully')),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create recipe: $e')),
              );
            }
          }
        },
        isEditing: false,
      ),
    );
  }
}
