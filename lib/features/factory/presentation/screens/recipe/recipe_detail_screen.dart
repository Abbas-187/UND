import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/recipe_model.dart';
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
          Builder(
            builder: (context) {
              final recipe = ref.watch(recipeByIdProvider(recipeId)).maybeWhen(
                    data: (r) => r,
                    orElse: () => null,
                  );
              if (recipe == null) {
                return Container();
              }
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/factory/recipe/edit',
                        arguments: recipeId,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Recipe'),
                          content: const Text(
                              'Are you sure you want to delete this recipe?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(recipesStateProvider.notifier)
                            .deleteRecipe(recipeId);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.verified),
                    onPressed: recipe.approvedByUserId == null
                        ? () async {
                            // Replace with actual user ID
                            const userId = 'currentUserId';
                            await ref
                                .read(recipesStateProvider.notifier)
                                .approveRecipe(recipeId, userId);
                          }
                        : null,
                  ),
                ],
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
                        if (recipe.steps.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipe.steps.length,
                            itemBuilder: (context, index) {
                              final step = recipe.steps[index];
                              return ListTile(
                                leading:
                                    CircleAvatar(child: Text('${step.order}')),
                                title: Text(step.instruction),
                              );
                            },
                          )
                        else
                          const Text('No steps added'),
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
                const SizedBox(height: 16),
                // History Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'History',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/factory/recipe/history',
                                  arguments: {
                                    'recipeId': recipe.id,
                                    'history': recipe.history
                                  },
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (recipe.history.isEmpty)
                          const Text('No history available'),
                        if (recipe.history.isNotEmpty)
                          ...List.generate(
                            recipe.history.length > 3
                                ? 3
                                : recipe.history.length,
                            (i) => _HistoryEntryTile(entry: recipe.history[i]),
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

class _HistoryEntryTile extends StatefulWidget {
  const _HistoryEntryTile({required this.entry});
  final RecipeHistoryEntry entry;

  @override
  State<_HistoryEntryTile> createState() => _HistoryEntryTileState();
}

class _HistoryEntryTileState extends State<_HistoryEntryTile> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Card(
      child: ExpansionTile(
        title: Text('${entry.action} by ${entry.user}'),
        subtitle: Text(DateFormat.yMd().add_jm().format(entry.timestamp)),
        initiallyExpanded: expanded,
        onExpansionChanged: (val) => setState(() => expanded = val),
        children: [
          if (entry.note != null && entry.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Note: ${entry.note}'),
            ),
          if (entry.before != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Before: ${entry.before}'),
            ),
          if (entry.after != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('After: ${entry.after}'),
            ),
        ],
      ),
    );
  }
}
