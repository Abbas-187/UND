import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/recipe_ingredient_model.dart';
import '../../data/models/recipe_model.dart';
import '../../data/models/recipe_step_model.dart';
import '../../../sales/data/models/product_catalog_model.dart';
import '../../../sales/data/repositories/product_catalog_repository.dart';

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

    // Load ingredient models from recipe if needed
    if (widget.initialValue != null &&
        widget.initialValue!.ingredients.isNotEmpty) {
      _ingredientModels = widget.initialValue!.ingredients.entries.map((entry) {
        return RecipeIngredientModel(
          id: entry.key,
          name: '', // Name/unit not stored in map, could be fetched if needed
          quantity: entry.value,
          unit: '',
        );
      }).toList();
    } else {
      _ingredientModels = [];
    }
    _steps = widget.initialValue?.steps ?? [];
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

  void _selectProduct() async {
    final productId = await showDialog<String>(
      context: context,
      builder: (context) => _ProductSelectionDialog(),
    );
    if (productId != null) {
      setState(() {
        _productIdController.text = productId;
      });
    }
  }

  void _addIngredient() async {
    final ingredient = await showDialog<RecipeIngredientModel>(
      context: context,
      builder: (context) => _IngredientDialog(),
    );
    if (ingredient != null) {
      setState(() {
        _ingredientModels.add(ingredient);
        _ingredients[ingredient.id] = ingredient.quantity;
      });
    }
  }

  void _editIngredient(int index) async {
    final ingredient = _ingredientModels[index];
    final updated = await showDialog<RecipeIngredientModel>(
      context: context,
      builder: (context) => _IngredientDialog(ingredient: ingredient),
    );
    if (updated != null) {
      setState(() {
        _ingredientModels[index] = updated;
        _ingredients[updated.id] = updated.quantity;
      });
    }
  }

  void _addStep() async {
    final step = await showDialog<RecipeStepModel>(
      context: context,
      builder: (context) => _StepDialog(order: _steps.length + 1),
    );
    if (step != null) {
      setState(() {
        _steps.add(step);
      });
    }
  }

  void _editStep(int index) async {
    final step = _steps[index];
    final updated = await showDialog<RecipeStepModel>(
      context: context,
      builder: (context) => _StepDialog(step: step),
    );
    if (updated != null) {
      setState(() {
        _steps[index] = updated;
      });
    }
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
        steps: _steps,
      );

      widget.onSubmit(recipe);
    }
  }
}

class _IngredientDialog extends StatefulWidget {
  final RecipeIngredientModel? ingredient;
  const _IngredientDialog({this.ingredient});

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.ingredient?.name ?? '');
    _quantityController = TextEditingController(
        text: widget.ingredient?.quantity.toString() ?? '');
    _unitController =
        TextEditingController(text: widget.ingredient?.unit ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final unit = _unitController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (unit.isEmpty) {
      setState(() => _error = 'Unit is required');
      return;
    }
    if (quantity <= 0) {
      setState(() => _error = 'Quantity must be greater than 0');
      return;
    }
    Navigator.pop(
      context,
      RecipeIngredientModel(
        id: widget.ingredient?.id ??
            'ingredient-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        quantity: quantity,
        unit: unit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.ingredient == null ? 'Add Ingredient' : 'Edit Ingredient'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _unitController,
            decoration: const InputDecoration(labelText: 'Unit'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _validateAndSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _StepDialog extends StatefulWidget {
  final RecipeStepModel? step;
  final int? order;
  const _StepDialog({this.step, this.order});

  @override
  State<_StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends State<_StepDialog> {
  late TextEditingController _instructionController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _instructionController =
        TextEditingController(text: widget.step?.instruction ?? '');
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    final instruction = _instructionController.text.trim();
    if (instruction.isEmpty) {
      setState(() => _error = 'Instruction is required');
      return;
    }
    Navigator.pop(
      context,
      RecipeStepModel(
        id: widget.step?.id ?? 'step-${DateTime.now().millisecondsSinceEpoch}',
        instruction: instruction,
        order: widget.order ?? widget.step?.order ?? 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.step == null ? 'Add Step' : 'Edit Step'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          TextField(
            controller: _instructionController,
            decoration: const InputDecoration(labelText: 'Instruction'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _validateAndSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ProductSelectionDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState
    extends ConsumerState<_ProductSelectionDialog> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(productCatalogRepositoryProvider);
    return FutureBuilder<List<ProductCatalogModel>>(
      future: _search.isEmpty
          ? repo.getProducts(isActive: true)
          : repo.searchProducts(_search),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            title: Text('Select Product'),
            content: SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator())),
          );
        }
        if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Select Product'),
            content: Text('Error: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        }
        final products = snapshot.data ?? [];
        return AlertDialog(
          title: const Text('Select Product'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
                const SizedBox(height: 8),
                if (products.isEmpty) const Text('No products found'),
                if (products.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(product.code),
                          onTap: () => Navigator.pop(context, product.id),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
