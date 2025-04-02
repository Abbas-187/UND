import 'package:flutter/material.dart';

import '../../data/models/recipe_ingredient_model.dart';
import '../../data/models/recipe_model.dart';
import '../../data/models/recipe_step_model.dart';

class RecipeForm extends StatefulWidget {
  const RecipeForm({
    super.key,
    this.initialValue,
    required this.onSubmit,
    this.isEditing = false,
  });
  final RecipeModel? initialValue;
  final Function(RecipeModel) onSubmit;
  final bool isEditing;

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _productIdController;
  Map<String, double> _ingredients = {};
  late List<RecipeIngredientModel> _ingredientModels;
  late List<RecipeStepModel> _steps;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values or defaults
    _nameController = TextEditingController(
      text: widget.initialValue?.name ?? '',
    );
    _productIdController = TextEditingController(
      text: widget.initialValue?.productId ?? '',
    );

    // Initialize ingredients map
    _ingredients = widget.initialValue?.ingredients ?? {};

    // These are not part of the RecipeModel, but for UI handling
    _ingredientModels = [];
    _steps = [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                hintText: 'Enter recipe title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter recipe title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productIdController,
                    decoration: const InputDecoration(
                      labelText: 'Product ID',
                      hintText: 'Enter product ID',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product ID';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _selectProduct,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildIngredientsList(),
            OutlinedButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Steps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildStepsList(),
            OutlinedButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(widget.isEditing ? 'Update Recipe' : 'Create Recipe'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientsList() {
    return _ingredientModels.asMap().entries.map((entry) {
      final index = entry.key;
      final ingredient = entry.value;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${ingredient.quantity} ${ingredient.unit}'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editIngredient(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _ingredients.remove(ingredient.id);
                  });
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildStepsList() {
    return _steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(step.order.toString()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.instruction,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editStep(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _steps.removeAt(index);
                        // Renumber steps
                        for (var i = 0; i < _steps.length; i++) {
                          _steps[i] = _steps[i].copyWith(order: i + 1);
                        }
                      });
                    },
                  ),
                ],
              ),
              Text('Order: ${step.order}'),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _selectProduct() {
    // TODO: Implement product selection
    // This would typically open a dialog or navigate to a product selection screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product selection not implemented yet')),
    );
  }

  void _addIngredient() {
    // TODO: Implement ingredient dialog
    // For now, just add a dummy ingredient
    setState(() {
      final ingredient = RecipeIngredientModel(
        id: 'ingredient-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Sample Ingredient',
        quantity: 1.0,
        unit: 'kg',
      );
      _ingredients[ingredient.id] = ingredient.quantity;
    });
  }

  void _editIngredient(int index) {
    // TODO: Implement ingredient edit dialog
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit ingredient dialog not implemented yet')),
    );
  }

  void _addStep() {
    // TODO: Implement step dialog
    // For now, just add a dummy step
    setState(() {
      _steps.add(
        RecipeStepModel(
          id: 'step-${DateTime.now().millisecondsSinceEpoch}',
          instruction: 'Sample step instruction',
          order: _steps.length + 1,
        ),
      );
    });
  }

  void _editStep(int index) {
    // TODO: Implement step edit dialog
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit step dialog not implemented yet')),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final recipe = RecipeModel(
        id: widget.initialValue?.id ?? '',
        name: _nameController.text,
        productId: _productIdController.text,
        ingredients: _ingredients,
        createdAt: widget.initialValue?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(recipe);
    }
  }
}
