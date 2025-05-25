import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/inventory_item.dart';
import '../controllers/inventory_database_controller.dart';

class InventoryCreateForm extends ConsumerStatefulWidget {
  const InventoryCreateForm({
    super.key,
    required this.onCreateItem,
    this.initialItem,
    this.isEditing = false,
  });
  final Function(InventoryItem) onCreateItem;
  final InventoryItem? initialItem;
  final bool isEditing;

  @override
  ConsumerState<InventoryCreateForm> createState() =>
      _InventoryCreateFormState();
}

class _InventoryCreateFormState extends ConsumerState<InventoryCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _sapCodeController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _supplierController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumQuantityController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _locationController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _costController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 90));
  DateTime _processingDate = DateTime.now();
  bool _isPasteurized = true;
  double? _fatContent;

  String? _selectedCategory;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _initializeWithItem(widget.initialItem!);
    } else {
      _lowStockThresholdController.text = '5';
    }
  }

  void _initializeWithItem(InventoryItem item) {
    _sapCodeController.text = item.sapCode;
    _subCategoryController.text = item.subCategory;
    if (item.supplier != null) {
      _supplierController.text = item.supplier!;
    }
    _nameController.text = item.name;
    _categoryController.text = item.category;
    _selectedCategory = item.category;
    _unitController.text = item.unit;
    _quantityController.text = item.quantity.toString();
    _minimumQuantityController.text = item.minimumQuantity.toString();
    _reorderPointController.text = item.reorderPoint.toString();
    _locationController.text = item.location;
    _selectedLocation = item.location;
    if (item.batchNumber != null) {
      _batchNumberController.text = item.batchNumber!;
    }
    if (item.expiryDate != null) {
      _expiryDate = item.expiryDate!;
    }
    if (item.cost != null) {
      _costController.text = item.cost.toString();
    }
    _lowStockThresholdController.text = item.lowStockThreshold.toString();

    // Get dairy-specific fields from additionalAttributes
    if (item.additionalAttributes != null) {
      _isPasteurized =
          item.additionalAttributes!['pasteurized'] as bool? ?? true;

      if (item.additionalAttributes!['fatContent'] != null) {
        _fatContent = item.additionalAttributes!['fatContent'] as double;
      }

      if (item.additionalAttributes!['processingDate'] != null) {
        _processingDate =
            item.additionalAttributes!['processingDate'] as DateTime;
      }
    }
  }

  @override
  void dispose() {
    _sapCodeController.dispose();
    _subCategoryController.dispose();
    _supplierController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _minimumQuantityController.dispose();
    _reorderPointController.dispose();
    _locationController.dispose();
    _batchNumberController.dispose();
    _costController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get categories and locations
    final categoriesAsync = ref.watch(inventoryCategoriesProvider);
    final locationsAsync = ref.watch(inventoryLocationsProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing
                  ? 'Edit Inventory Item'
                  : 'Create New Inventory Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Basic Information Section
            _buildSectionHeader('Basic Information'),
            TextFormField(
              controller: _sapCodeController,
              decoration: const InputDecoration(
                labelText: 'SAP Code',
                hintText: 'Enter legacy SAP code',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter SAP code';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter item name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Category dropdown or text field
            categoriesAsync.when(
              data: (categories) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Select a category',
                  ),
                  value: _selectedCategory,
                  items: [
                    ...categories.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: 'other',
                      child: Text('Other (Specify)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      if (value != 'other') {
                        _categoryController.text = value!;
                      } else {
                        _categoryController.text = '';
                      }
                    });
                  },
                  validator: (value) {
                    if (_categoryController.text.isEmpty) {
                      return 'Please select or enter a category';
                    }
                    return null;
                  },
                );
              },
              loading: () => TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Enter category',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              error: (_, __) => TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Enter category',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
            ),

            if (_selectedCategory == 'other') ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Custom Category',
                  hintText: 'Enter custom category',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 8),
            TextFormField(
              controller: _subCategoryController,
              decoration: const InputDecoration(
                labelText: 'Sub-Category',
                hintText: 'Enter sub-category',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sub-category';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g., liters, kg, pcs',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a unit';
                }
                return null;
              },
            ),

            // Quantities Section
            const SizedBox(height: 16),
            _buildSectionHeader('Quantities'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Current stock',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _minimumQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Quantity',
                      hintText: 'Minimum stock',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _reorderPointController,
                    decoration: const InputDecoration(
                      labelText: 'Reorder Point',
                      hintText: 'Reorder threshold',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _lowStockThresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Low Stock Alert',
                      hintText: 'Low stock threshold',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            // Location Section
            const SizedBox(height: 16),
            _buildSectionHeader('Storage Information'),
            locationsAsync.when(
              data: (locations) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Storage Location',
                    hintText: 'Select a location',
                  ),
                  value: _selectedLocation,
                  items: [
                    ...locations.map(
                      (location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: 'other',
                      child: Text('Other (Specify)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                      if (value != 'other') {
                        _locationController.text = value!;
                      } else {
                        _locationController.text = '';
                      }
                    });
                  },
                  validator: (value) {
                    if (_locationController.text.isEmpty) {
                      return 'Please select or enter a location';
                    }
                    return null;
                  },
                );
              },
              loading: () => TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Storage Location',
                  hintText: 'Where this item is stored',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              error: (_, __) => TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Storage Location',
                  hintText: 'Where this item is stored',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
            ),

            if (_selectedLocation == 'other') ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Custom Location',
                  hintText: 'Enter custom location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
            ],

            // Additional Information Section
            const SizedBox(height: 16),
            _buildSectionHeader('Additional Information (Optional)'),
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'Batch Number',
                hintText: 'Enter batch/lot number',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      hintText: 'Cost per unit',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier (Optional)',
                hintText: 'Enter supplier name',
              ),
            ),

            const SizedBox(height: 16),
            _buildDatePicker(
              labelText: 'Expiry Date',
              selectedDate: _expiryDate,
              onDateSelected: (date) {
                setState(() {
                  _expiryDate = date;
                });
              },
            ),

            // Dairy-Specific Information
            const SizedBox(height: 16),
            _buildSectionHeader('Dairy-Specific Information'),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    labelText: 'Processing Date',
                    selectedDate: _processingDate,
                    onDateSelected: (date) {
                      setState(() {
                        _processingDate = date;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fat Content (%)',
                      hintText: 'e.g., 3.5',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _fatContent?.toString() ?? '',
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _fatContent = double.tryParse(value);
                      } else {
                        _fatContent = null;
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Pasteurized'),
              value: _isPasteurized,
              onChanged: (value) {
                setState(() {
                  _isPasteurized = value;
                });
              },
            ),

            // Form Submission
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitForm,
                child: Text(
                  widget.isEditing ? 'Update Item' : 'Create Item',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDatePicker({
    required String labelText,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Build additionalAttributes map
      final Map<String, dynamic> additionalAttributes = {};

      // Add dairy-specific attributes
      additionalAttributes['pasteurized'] = _isPasteurized;
      if (_fatContent != null) {
        additionalAttributes['fatContent'] = _fatContent;
      }
      additionalAttributes['processingDate'] = _processingDate;

      final item = InventoryItem(
        id: widget.initialItem?.id ?? const Uuid().v4(),
        sapCode: _sapCodeController.text,
        subCategory: _subCategoryController.text,
        name: _nameController.text,
        category: _categoryController.text,
        unit: _unitController.text,
        quantity: double.parse(_quantityController.text),
        minimumQuantity: double.parse(_minimumQuantityController.text),
        reorderPoint: double.parse(_reorderPointController.text),
        location: _locationController.text,
        lastUpdated: DateTime.now(),
        batchNumber: _batchNumberController.text.isEmpty
            ? null
            : _batchNumberController.text,
        expiryDate: _expiryDate,
        additionalAttributes: additionalAttributes,
        cost: _costController.text.isEmpty
            ? null
            : double.parse(_costController.text),
        lowStockThreshold: int.parse(_lowStockThresholdController.text),
        supplier:
            _supplierController.text.isEmpty ? null : _supplierController.text,
        appItemId: '',
      );

      widget.onCreateItem(item);

      if (!widget.isEditing) {
        // Clear form if creating a new item
        _sapCodeController.clear();
        _subCategoryController.clear();
        _supplierController.clear();
        _nameController.clear();
        _categoryController.clear();
        _unitController.clear();
        _quantityController.clear();
        _minimumQuantityController.clear();
        _reorderPointController.clear();
        _locationController.clear();
        _batchNumberController.clear();
        _costController.clear();
        _lowStockThresholdController.text = '5';
        _fatContent = null;
        setState(() {
          _selectedCategory = null;
          _selectedLocation = null;
          _expiryDate = DateTime.now().add(const Duration(days: 90));
          _processingDate = DateTime.now();
          _isPasteurized = true;
        });
      }
    }
  }
}
