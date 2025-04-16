import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inventory_category.dart';
import '../providers/inventory_category_provider.dart';
import '../widgets/attribute_definition_form.dart';
import '../widgets/category_list_item.dart';

class InventoryCategoryManagementScreen extends ConsumerStatefulWidget {
  const InventoryCategoryManagementScreen({super.key});

  @override
  ConsumerState<InventoryCategoryManagementScreen> createState() =>
      _InventoryCategoryManagementScreenState();
}

class _InventoryCategoryManagementScreenState
    extends ConsumerState<InventoryCategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _colorCodeController;

  String? _selectedParentId;
  bool _isCreatingCategory = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _colorCodeController = TextEditingController(text: '#AAAAAA');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorCodeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _colorCodeController.text = '#AAAAAA';
    _selectedParentId = null;
    ref.read(categoryEditModeProvider.notifier).state = false;
    ref.read(editedCategoryProvider.notifier).state = null;
  }

  void _prepareForEditing(InventoryCategory category) {
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    _colorCodeController.text = category.colorCode ?? '#AAAAAA';
    _selectedParentId = category.parentCategoryId;

    ref.read(categoryEditModeProvider.notifier).state = true;
    ref.read(editedCategoryProvider.notifier).state = category;
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isCreatingCategory = true;
    });

    try {
      final repository = ref.read(inventoryCategoryRepositoryProvider);
      final isEditMode = ref.read(categoryEditModeProvider);

      if (isEditMode) {
        // Update existing category
        final editedCategory = ref.read(editedCategoryProvider);
        if (editedCategory != null) {
          final updatedCategory = editedCategory.copyWith(
            name: _nameController.text,
            description: _descriptionController.text,
            parentCategoryId: _selectedParentId,
            colorCode: _colorCodeController.text,
          );

          await repository.updateCategory(updatedCategory);
          ref.invalidate(categoriesProvider);
          ref.invalidate(categoryProvider(editedCategory.id));

          if (_selectedParentId != null) {
            ref.invalidate(childCategoriesProvider(_selectedParentId!));
          }

          if (editedCategory.parentCategoryId != null &&
              editedCategory.parentCategoryId != _selectedParentId) {
            ref.invalidate(
                childCategoriesProvider(editedCategory.parentCategoryId!));
          }
        }
      } else {
        // Create new category
        final newCategory = InventoryCategory(
          id: const Uuid().v4(),
          name: _nameController.text,
          description: _descriptionController.text,
          parentCategoryId: _selectedParentId,
          colorCode: _colorCodeController.text,
          itemCount: 0,
        );

        await repository.addCategory(newCategory);
        ref.invalidate(categoriesProvider);

        if (_selectedParentId != null) {
          ref.invalidate(childCategoriesProvider(_selectedParentId!));
        }
      }

      _resetForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Category updated successfully'
                : 'Category created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingCategory = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEditMode = ref.watch(categoryEditModeProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Category Management'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            onPressed: () {
              ref.invalidate(categoriesProvider);
              ref.invalidate(categoryItemCountsProvider);
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category List - Left side (1/3 width)
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            tooltip: 'Add new category',
                            onPressed: () {
                              _resetForm();
                              ref
                                  .read(selectedCategoryIdProvider.notifier)
                                  .state = null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: categoriesAsync.when(
                        data: (categories) {
                          // First, show all top-level categories (no parent)
                          final topLevelCategories = categories
                              .where((c) => c.parentCategoryId == null)
                              .toList();

                          if (topLevelCategories.isEmpty) {
                            return const Center(
                              child: Text('No categories found'),
                            );
                          }

                          return ListView.builder(
                            itemCount: topLevelCategories.length,
                            itemBuilder: (context, index) {
                              final category = topLevelCategories[index];
                              final isSelected =
                                  category.id == selectedCategoryId;

                              // Find child categories
                              final childCategories = categories
                                  .where(
                                      (c) => c.parentCategoryId == category.id)
                                  .toList();

                              return CategoryListItem(
                                category: category,
                                isSelected: isSelected,
                                children: childCategories,
                                onSelect: (id) {
                                  ref
                                      .read(selectedCategoryIdProvider.notifier)
                                      .state = id;
                                },
                                onEdit: (category) {
                                  _prepareForEditing(category);
                                },
                                onDelete: (id) async {
                                  try {
                                    await ref
                                        .read(
                                            inventoryCategoryRepositoryProvider)
                                        .deleteCategory(id);
                                    ref.invalidate(categoriesProvider);
                                    if (category.parentCategoryId != null) {
                                      ref.invalidate(childCategoriesProvider(
                                          category.parentCategoryId!));
                                    }

                                    if (selectedCategoryId == id) {
                                      ref
                                          .read(selectedCategoryIdProvider
                                              .notifier)
                                          .state = null;
                                    }

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Category deleted successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text('Error: ${error.toString()}'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category Form & Details - Right side (2/3 width)
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Title
                      Text(
                        isEditMode ? 'Edit Category' : 'Create New Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Parent Category dropdown
                      categoriesAsync.when(
                        data: (categories) {
                          // Filter out the current category if in edit mode
                          final editedCategory =
                              ref.read(editedCategoryProvider);
                          final availableParents = categories
                              .where((c) => c.id != editedCategory?.id)
                              .toList();

                          return DropdownButtonFormField<String?>(
                            value: _selectedParentId,
                            decoration: const InputDecoration(
                              labelText: 'Parent Category (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('None (Top Level)'),
                              ),
                              ...availableParents.map((category) {
                                return DropdownMenuItem<String?>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedParentId = value;
                              });
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, _) => Text('Error: ${error.toString()}'),
                      ),
                      const SizedBox(height: 16),

                      // Color code field
                      TextFormField(
                        controller: _colorCodeController,
                        decoration: InputDecoration(
                          labelText: 'Color Code',
                          border: const OutlineInputBorder(),
                          hintText: '#RRGGBB',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(
                                int.tryParse(
                                        '0xFF${_colorCodeController.text.replaceAll('#', '')}') ??
                                    0xFFAAAAAA,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Simple hex color validation
                            if (!RegExp(r'^#?[0-9A-Fa-f]{6}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid hex color code';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Attribute definitions section (would be shown when a category is selected)
                      if (selectedCategoryId != null)
                        ref.watch(categoryProvider(selectedCategoryId)).when(
                              data: (category) {
                                if (category == null) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Attribute Definitions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // This would be replaced with a real attribute definition editor
                                    AttributeDefinitionForm(
                                      category: category,
                                      onSave: (attributes) async {
                                        try {
                                          await ref
                                              .read(
                                                  inventoryCategoryRepositoryProvider)
                                              .updateCategoryAttributes(
                                                category.id,
                                                attributes,
                                              );

                                          ref.invalidate(
                                              categoryProvider(category.id));

                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Attributes updated successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, _) =>
                                  Text('Error: ${error.toString()}'),
                            ),

                      const Spacer(),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isCreatingCategory ? null : _resetForm,
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed:
                                _isCreatingCategory ? null : _saveCategory,
                            child: _isCreatingCategory
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(isEditMode
                                    ? 'Update Category'
                                    : 'Create Category'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
