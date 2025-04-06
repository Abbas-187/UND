import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';

class InventoryEditScreen extends ConsumerStatefulWidget { // Null for adding new item, non-null for editing

  const InventoryEditScreen({
    super.key,
    this.itemId,
  });
  final String? itemId;

  @override
  ConsumerState<InventoryEditScreen> createState() =>
      _InventoryEditScreenState();
}

class _InventoryEditScreenState extends ConsumerState<InventoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _unitController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minimumQuantityController;
  late final TextEditingController _reorderPointController;
  late final TextEditingController _locationController;
  late final TextEditingController _batchNumberController;
  DateTime? _expiryDate;
  final Map<String, dynamic> _additionalAttributes = {};
  bool _isLoading = false;
  InventoryItem? _originalItem;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _unitController = TextEditingController();
    _quantityController = TextEditingController();
    _minimumQuantityController = TextEditingController();
    _reorderPointController = TextEditingController();
    _locationController = TextEditingController();
    _batchNumberController = TextEditingController();

    // Load item data if editing
    if (widget.itemId != null) {
      _loadItemData();
    }
  }

  Future<void> _loadItemData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(inventoryRepositoryProvider);
      final item = await repository.getItem(widget.itemId!);

      _originalItem = item;

      if (item != null) {
        _nameController.text = item.name;
        _categoryController.text = item.category;
        _unitController.text = item.unit;
        _quantityController.text = item.quantity.toString();
        _minimumQuantityController.text = item.minimumQuantity.toString();
        _reorderPointController.text = item.reorderPoint.toString();
        _locationController.text = item.location;

        if (item.batchNumber != null) {
          _batchNumberController.text = item.batchNumber!;
        }

        _expiryDate = item.expiryDate;

        if (item.additionalAttributes != null) {
          _additionalAttributes
              .addAll(Map<String, dynamic>.from(item.additionalAttributes!));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _minimumQuantityController.dispose();
    _reorderPointController.dispose();
    _locationController.dispose();
    _batchNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add New Item'),
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a category';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., kg, liters, pieces',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a unit';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a location';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minimumQuantityController,
                            decoration: const InputDecoration(
                              labelText: 'Minimum Quantity',
                              border: OutlineInputBorder(),
                              hintText: 'For low stock alerts',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a minimum quantity';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _reorderPointController,
                            decoration: const InputDecoration(
                              labelText: 'Reorder Point',
                              border: OutlineInputBorder(),
                              hintText: 'When to reorder',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a reorder point';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _batchNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Batch Number (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectExpiryDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _expiryDate != null
                                  ? _formatDate(_expiryDate!)
                                  : 'Select Date',
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_expiryDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _expiryDate = null;
                                      });
                                    },
                                  ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Additional Attributes (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    // List existing attributes
                    ..._additionalAttributes.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(entry.key),
                            ),
                            Expanded(
                              child: Text(entry.value.toString()),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _additionalAttributes.remove(entry.key);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    // Add new attribute button
                    OutlinedButton.icon(
                      onPressed: _addAttribute,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Attribute'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)), // 5 years ahead
    );

    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  void _addAttribute() async {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Attribute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Attribute Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Attribute Value',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final key = keyController.text.trim();
              final value = valueController.text.trim();

              if (key.isNotEmpty && value.isNotEmpty) {
                Navigator.pop(context, {key: value});
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _additionalAttributes.addAll(result);
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(inventoryRepositoryProvider);

      final newItem = InventoryItem(
        id: widget.itemId ?? '',
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        unit: _unitController.text.trim(),
        quantity: double.parse(_quantityController.text),
        minimumQuantity: double.parse(_minimumQuantityController.text),
        reorderPoint: double.parse(_reorderPointController.text),
        location: _locationController.text.trim(),
        lastUpdated: DateTime.now(),
        batchNumber: _batchNumberController.text.isEmpty
            ? null
            : _batchNumberController.text,
        expiryDate: _expiryDate,
        additionalAttributes:
            _additionalAttributes.isEmpty ? null : _additionalAttributes,
      );

      if (widget.itemId != null) {
        // Update existing item
        await repository.updateItem(newItem);
      } else {
        // Add new item
        await repository.addItem(newItem);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
