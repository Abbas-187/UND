import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // In a real app, navigate to edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Edit functionality not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: recipeAsync.when(
        data: (recipe) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Product ID: ${recipe.productId}'),
                        const SizedBox(height: 16),
                        Text(
                          'Status: ${recipe.approvedByUserId != null ? "Approved" : "Not Approved"}',
                          style: TextStyle(
                            color: recipe.approvedByUserId != null
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (recipe.approvedByUserId != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Approved by: ${recipe.approvedByUserId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Approved on: ${recipe.approvedAt?.toString().substring(0, 10) ?? "Unknown"}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingredients',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        if (recipe.ingredients.isEmpty)
                          const Text('No ingredients added')
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipe.ingredients.length,
                            itemBuilder: (context, index) {
                              final entry =
                                  recipe.ingredients.entries.elementAt(index);
                              return ListTile(
                                title: Text('Item ID: ${entry.key}'),
                                subtitle: Text('Quantity: ${entry.value}'),
                                leading: const Icon(Icons.inventory_2),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Production Steps',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Steps not available in this version. Use the full recipe documentation.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Metadata',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          title: const Text('Created'),
                          subtitle: Text(
                              recipe.createdAt.toString().substring(0, 10)),
                          leading: const Icon(Icons.calendar_today),
                        ),
                        ListTile(
                          title: const Text('Last Updated'),
                          subtitle: Text(
                              recipe.updatedAt.toString().substring(0, 10)),
                          leading: const Icon(Icons.update),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading recipe: $error'),
        ),
      ),
    );
  }
}
