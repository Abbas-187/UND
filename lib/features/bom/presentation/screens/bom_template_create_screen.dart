import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bom_template.dart';

class BomTemplateCreateScreen extends ConsumerStatefulWidget {
  final BomTemplate? template;

  const BomTemplateCreateScreen({super.key, this.template});

  @override
  ConsumerState<BomTemplateCreateScreen> createState() =>
      _BomTemplateCreateScreenState();
}

class _BomTemplateCreateScreenState
    extends ConsumerState<BomTemplateCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0');

  TemplateCategory _selectedCategory = TemplateCategory.dairy;
  TemplateComplexity _selectedComplexity = TemplateComplexity.simple;
  bool _isPublic = false;
  bool _isActive = true;
  List<String> _tags = [];
  List<BomTemplateItem> _items = [];
  List<String> _validationRules = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _loadTemplate(widget.template!);
    }
  }

  void _loadTemplate(BomTemplate template) {
    _nameController.text = template.name;
    _descriptionController.text = template.description;
    _versionController.text = template.version;
    _selectedCategory = template.category;
    _selectedComplexity = template.complexity;
    _isPublic = template.isPublic;
    _isActive = template.isActive;
    _tags = List.from(template.tags);
    _items = List.from(template.items);
    _validationRules = List.from(template.validationRules);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.template == null ? 'Create Template' : 'Edit Template'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTemplate,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildSettingsSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildItemsSection(),
              const SizedBox(height: 24),
              _buildValidationRulesSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name *',
                border: OutlineInputBorder(),
                helperText: 'Enter a descriptive name for this template',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Template name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                helperText: 'Describe what this template is used for',
              ),
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _versionController,
              decoration: const InputDecoration(
                labelText: 'Version',
                border: OutlineInputBorder(),
                helperText: 'Template version (e.g., 1.0, 2.1)',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Version is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category & Complexity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TemplateCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: TemplateCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_formatCategoryName(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<TemplateComplexity>(
                    value: _selectedComplexity,
                    decoration: const InputDecoration(
                      labelText: 'Complexity',
                      border: OutlineInputBorder(),
                    ),
                    items: TemplateComplexity.values.map((complexity) {
                      return DropdownMenuItem(
                        value: complexity,
                        child: Text(_formatComplexityName(complexity)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedComplexity = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Template is available for use'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Public'),
              subtitle: const Text('Template is visible to all users'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tags',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tag'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tags.isEmpty)
              const Text('No tags added yet')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Template Items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No items added yet'),
                      Text('Add items to define the template structure'),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(item.itemName),
                    subtitle: Text(
                        '${item.itemCode} • ${item.quantity} ${item.unit}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isOptional)
                          const Chip(
                            label: Text('Optional'),
                            backgroundColor: Colors.orange,
                          ),
                        if (item.isVariable)
                          const Chip(
                            label: Text('Variable'),
                            backgroundColor: Colors.blue,
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationRulesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Validation Rules',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addValidationRule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Rule'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_validationRules.isEmpty)
              const Text('No validation rules defined')
            else
              Column(
                children: _validationRules.map((rule) {
                  return ListTile(
                    leading: const Icon(Icons.rule),
                    title: Text(_getValidationRuleDescription(rule)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _validationRules.remove(rule);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatCategoryName(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.dairy:
        return 'Dairy';
      case TemplateCategory.packaging:
        return 'Packaging';
      case TemplateCategory.processing:
        return 'Processing';
      case TemplateCategory.quality:
        return 'Quality';
      case TemplateCategory.maintenance:
        return 'Maintenance';
      case TemplateCategory.custom:
        return 'Custom';
    }
  }

  String _formatComplexityName(TemplateComplexity complexity) {
    switch (complexity) {
      case TemplateComplexity.simple:
        return 'Simple';
      case TemplateComplexity.intermediate:
        return 'Intermediate';
      case TemplateComplexity.advanced:
        return 'Advanced';
      case TemplateComplexity.expert:
        return 'Expert';
    }
  }

  String _getValidationRuleDescription(String rule) {
    switch (rule) {
      case 'require_dairy_items':
        return 'Require at least one dairy item';
      case 'max_items_50':
        return 'Maximum 50 items allowed';
      case 'require_packaging':
        return 'Require packaging items';
      default:
        return rule;
    }
  }

  // Action methods
  void _addTag() {
    showDialog(
      context: context,
      builder: (context) => _AddTagDialog(
        onAdd: (tag) {
          setState(() {
            if (!_tags.contains(tag)) {
              _tags.add(tag);
            }
          });
        },
      ),
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        item: _items[index],
        onAdd: (item) {
          setState(() {
            _items[index] = item;
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _addValidationRule() {
    showDialog(
      context: context,
      builder: (context) => _AddValidationRuleDialog(
        onAdd: (rule) {
          setState(() {
            if (!_validationRules.contains(rule)) {
              _validationRules.add(rule);
            }
          });
        },
      ),
    );
  }

  void _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final template = BomTemplate(
        id: widget.template?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        complexity: _selectedComplexity,
        version: _versionController.text,
        isActive: _isActive,
        isPublic: _isPublic,
        createdBy: 'current_user', // This would come from auth
        createdAt: widget.template?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        items: _items,
        tags: _tags,
        validationRules: _validationRules,
      );

      // TODO: Save template using template use case

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.template == null
              ? 'Template created successfully'
              : 'Template updated successfully'),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving template: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Supporting dialog widgets
class _AddTagDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _AddTagDialog({required this.onAdd});

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Tag name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAdd(_controller.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final BomTemplateItem? item;
  final Function(BomTemplateItem) onAdd;

  const _AddItemDialog({this.item, required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _maxQuantityController = TextEditingController();

  bool _isOptional = false;
  bool _isVariable = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _loadItem(widget.item!);
    }
  }

  void _loadItem(BomTemplateItem item) {
    _codeController.text = item.itemCode;
    _nameController.text = item.itemName;
    _typeController.text = item.itemType;
    _quantityController.text = item.quantity.toString();
    _unitController.text = item.unit;
    _descriptionController.text = item.description ?? '';
    _minQuantityController.text = item.minQuantity.toString();
    _maxQuantityController.text = item.maxQuantity.toString();
    _isOptional = item.isOptional;
    _isVariable = item.isVariable;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Item Code *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Item Type *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (double.tryParse(value!) == null)
                            return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Optional'),
                  subtitle: const Text('Item is optional in the BOM'),
                  value: _isOptional,
                  onChanged: (value) =>
                      setState(() => _isOptional = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Variable'),
                  subtitle: const Text('Quantity can vary within limits'),
                  value: _isVariable,
                  onChanged: (value) =>
                      setState(() => _isVariable = value ?? false),
                ),
                if (_isVariable) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Min Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Max Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = BomTemplateItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        itemCode: _codeController.text,
        itemName: _nameController.text,
        itemType: _typeController.text,
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text,
        isOptional: _isOptional,
        isVariable: _isVariable,
        minQuantity: _isVariable
            ? double.tryParse(_minQuantityController.text) ?? 0.0
            : 0.0,
        maxQuantity: _isVariable
            ? double.tryParse(_maxQuantityController.text) ?? double.infinity
            : double.infinity,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      widget.onAdd(item);
      Navigator.of(context).pop();
    }
  }
}

class _AddValidationRuleDialog extends StatelessWidget {
  final Function(String) onAdd;

  const _AddValidationRuleDialog({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final rules = [
      'require_dairy_items',
      'max_items_50',
      'require_packaging',
    ];

    return AlertDialog(
      title: const Text('Add Validation Rule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: rules.map((rule) {
          return ListTile(
            title: Text(_getValidationRuleDescription(rule)),
            onTap: () {
              onAdd(rule);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _getValidationRuleDescription(String rule) {
    switch (rule) {
      case 'require_dairy_items':
        return 'Require at least one dairy item';
      case 'max_items_50':
        return 'Maximum 50 items allowed';
      case 'require_packaging':
        return 'Require packaging items';
      default:
        return rule;
    }
  }
}
