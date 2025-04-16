import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/inventory_category.dart';

class AttributeDefinitionForm extends StatefulWidget {
  const AttributeDefinitionForm({
    super.key,
    required this.category,
    required this.onSave,
  });

  final InventoryCategory category;
  final Function(Map<String, AttributeDefinition>) onSave;

  @override
  State<AttributeDefinitionForm> createState() =>
      _AttributeDefinitionFormState();
}

class _AttributeDefinitionFormState extends State<AttributeDefinitionForm> {
  late Map<String, AttributeDefinition> _attributes;
  late Map<String, TextEditingController> _nameControllers;
  late Map<String, TextEditingController> _descriptionControllers;
  late Map<String, TextEditingController> _optionsControllers;
  String? _attributeToRemove;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAttributes();
  }

  @override
  void didUpdateWidget(AttributeDefinitionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _loadAttributes();
    }
  }

  void _loadAttributes() {
    // Copy attributes to allow editing
    _attributes = Map.from(widget.category.attributeDefinitions);

    // Initialize controllers
    _nameControllers = {};
    _descriptionControllers = {};
    _optionsControllers = {};

    // Set up controllers for existing attributes
    for (final entry in _attributes.entries) {
      final key = entry.key;
      final attr = entry.value;

      _nameControllers[key] = TextEditingController(text: attr.name);
      _descriptionControllers[key] =
          TextEditingController(text: attr.description);
      _optionsControllers[key] = TextEditingController(
        text: attr.options.join(', '),
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }
    for (final controller in _optionsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addAttribute() {
    final key = 'attr_${DateTime.now().millisecondsSinceEpoch}';
    final newAttr = AttributeDefinition(
      name: 'New Attribute',
      type: AttributeType.text,
      description: '',
      required: false,
    );

    setState(() {
      _attributes[key] = newAttr;
      _nameControllers[key] = TextEditingController(text: newAttr.name);
      _descriptionControllers[key] =
          TextEditingController(text: newAttr.description);
      _optionsControllers[key] = TextEditingController();
    });
  }

  void _confirmRemoveAttribute(String key) {
    setState(() {
      _attributeToRemove = key;
    });

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Attribute'),
        content: Text(
          'Are you sure you want to remove "${_attributes[key]?.name}" attribute?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _attributeToRemove = null;
              });
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeAttribute(key);
            },
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }

  void _removeAttribute(String key) {
    setState(() {
      _attributes.remove(key);
      _nameControllers[key]?.dispose();
      _nameControllers.remove(key);
      _descriptionControllers[key]?.dispose();
      _descriptionControllers.remove(key);
      _optionsControllers[key]?.dispose();
      _optionsControllers.remove(key);
      _attributeToRemove = null;
    });
  }

  void _updateAttributeType(String key, AttributeType type) {
    setState(() {
      final attr = _attributes[key];
      if (attr != null) {
        _attributes[key] = attr.copyWith(type: type);
      }
    });
  }

  void _updateAttributeRequired(String key, bool required) {
    setState(() {
      final attr = _attributes[key];
      if (attr != null) {
        _attributes[key] = attr.copyWith(required: required);
      }
    });
  }

  void _saveAttributes() {
    // Update attributes with current values from controllers
    for (final entry in _attributes.entries) {
      final key = entry.key;
      final attr = entry.value;

      final nameController = _nameControllers[key];
      final descController = _descriptionControllers[key];
      final optionsController = _optionsControllers[key];

      if (nameController != null && descController != null) {
        List<String> options = [];

        if (attr.type == AttributeType.selection && optionsController != null) {
          options = optionsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        _attributes[key] = attr.copyWith(
          name: nameController.text,
          description: descController.text,
          options: options,
        );
      }
    }

    setState(() {
      _isSaving = true;
    });

    widget.onSave(_attributes).then((_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_attributes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No attributes defined for this category.'),
          )
        else
          ...buildAttributeWidgets(),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Attribute'),
              onPressed: _addAttribute,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveAttributes,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Attributes'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> buildAttributeWidgets() {
    final List<Widget> widgets = [];

    for (final entry in _attributes.entries) {
      final key = entry.key;
      final attr = entry.value;
      final isRemoving = _attributeToRemove == key;

      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameControllers[key],
                        decoration: const InputDecoration(
                          labelText: 'Attribute Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: isRemoving
                          ? null
                          : () => _confirmRemoveAttribute(key),
                      tooltip: 'Remove Attribute',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AttributeType>(
                        value: attr.type,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: AttributeType.values.map((type) {
                          return DropdownMenuItem<AttributeType>(
                            value: type,
                            child: Text(type.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateAttributeType(key, value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Required'),
                        value: attr.required,
                        onChanged: (value) {
                          if (value != null) {
                            _updateAttributeRequired(key, value);
                          }
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionControllers[key],
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),

                // Options field for selection type
                if (attr.type == AttributeType.selection) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _optionsControllers[key],
                    decoration: const InputDecoration(
                      labelText: 'Options (comma separated)',
                      border: OutlineInputBorder(),
                      hintText: 'Option1, Option2, Option3',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
