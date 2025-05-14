import 'package:flutter/material.dart';
import '../../data/models/product_catalog_model.dart';
import 'package:intl/intl.dart'; // For date formatting

class ProductEditScreen extends StatefulWidget {
  final ProductCatalogModel? product; // Nullable for creating a new product

  const ProductEditScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductEditScreenState createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Existing Controllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _uomController;
  late TextEditingController _basePriceController;

  // New Controllers
  late TextEditingController _packagingTypeController;
  late TextEditingController _weightPerUnitController;
  late TextEditingController _weightUomController;
  late TextEditingController _allergensController; // Comma-separated
  late TextEditingController _minOrderQuantityController;
  late TextEditingController _multipleOrderQuantityController;
  late TextEditingController _shelfLifeDaysController;
  late TextEditingController _storageInstructionsController;
  late TextEditingController _tagsController; // Comma-separated
  late TextEditingController _reorderPointController;
  late TextEditingController _targetStockLevelController;
  late TextEditingController _nutritionalInfoController;
  late TextEditingController _ingredientsController;
  late TextEditingController
      _imageUrlController; // For displaying/editing image URL

  // State variables for new fields
  bool _isBatchTracked = false;
  bool _isPerishable = false;
  bool _isActive = true;
  bool _isSeasonal = false;
  String? _selectedCategory;
  DateTime? _availableFrom;
  DateTime? _availableTo;

  // Placeholder for categories - ideally fetched from a service
  final List<String> _categories = [
    'Default Category',
    'Dairy',
    'Juice',
    'Bakery',
    'Produce'
  ];
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    // Existing initializations
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _codeController = TextEditingController(text: widget.product?.code ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _uomController = TextEditingController(text: widget.product?.uom ?? '');
    _basePriceController =
        TextEditingController(text: widget.product?.basePrice.toString() ?? '');
    _isBatchTracked = widget.product?.isBatchTracked ?? false;
    _isPerishable = widget.product?.isPerishable ?? false;

    // New initializations
    _selectedCategory = widget.product?.category;
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!); // Add if not in default list
    }
    _imageUrlController =
        TextEditingController(text: widget.product?.imageUrl ?? '');
    _packagingTypeController =
        TextEditingController(text: widget.product?.packagingType ?? '');
    _weightPerUnitController = TextEditingController(
        text: widget.product?.weightPerUnit?.toString() ?? '');
    _weightUomController =
        TextEditingController(text: widget.product?.weightUom ?? '');
    _allergensController = TextEditingController(
        text: widget.product?.allergens?.join(', ') ?? '');
    _isActive = widget.product?.isActive ?? true;
    _minOrderQuantityController = TextEditingController(
        text: widget.product?.minOrderQuantity?.toString() ?? '');
    _multipleOrderQuantityController = TextEditingController(
        text: widget.product?.multipleOrderQuantity?.toString() ?? '');
    _availableFrom = widget.product?.availableFrom;
    _availableTo = widget.product?.availableTo;
    _shelfLifeDaysController = TextEditingController(
        text: widget.product?.shelfLifeDays?.toString() ?? '');
    _storageInstructionsController =
        TextEditingController(text: widget.product?.storageInstructions ?? '');
    _tagsController =
        TextEditingController(text: widget.product?.tags?.join(', ') ?? '');
    _isSeasonal = widget.product?.isSeasonal ?? false;
    _reorderPointController = TextEditingController(
        text: widget.product?.reorderPoint?.toString() ?? '');
    _targetStockLevelController = TextEditingController(
        text: widget.product?.targetStockLevel?.toString() ?? '');
    _nutritionalInfoController =
        TextEditingController(text: widget.product?.nutritionalInfo ?? '');
    _ingredientsController =
        TextEditingController(text: widget.product?.ingredients ?? '');
  }

  @override
  void dispose() {
    // Dispose existing controllers
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _uomController.dispose();
    _basePriceController.dispose();

    // Dispose new controllers
    _packagingTypeController.dispose();
    _weightPerUnitController.dispose();
    _weightUomController.dispose();
    _allergensController.dispose();
    _minOrderQuantityController.dispose();
    _multipleOrderQuantityController.dispose();
    _shelfLifeDaysController.dispose();
    _storageInstructionsController.dispose();
    _tagsController.dispose();
    _reorderPointController.dispose();
    _targetStockLevelController.dispose();
    _nutritionalInfoController.dispose();
    _ingredientsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          (isFromDate ? _availableFrom : _availableTo) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _availableFrom = picked;
        } else {
          _availableTo = picked;
        }
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Important for onSaved callbacks if any

      // TODO: Integrate with a proper state management solution (BLoC, Provider, Riverpod, etc.)
      // This would typically involve dispatching an event or calling a method on a notifier/controller.

      final updatedProduct = ProductCatalogModel(
        id: widget.product?.id,
        name: _nameController.text,
        code: _codeController.text,
        category: _selectedCategory ?? '',
        description: _descriptionController.text,
        uom: _uomController.text,
        basePrice: double.tryParse(_basePriceController.text) ?? 0.0,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
        packagingType: _packagingTypeController.text.isNotEmpty
            ? _packagingTypeController.text
            : null,
        weightPerUnit: double.tryParse(_weightPerUnitController.text),
        weightUom: _weightUomController.text.isNotEmpty
            ? _weightUomController.text
            : null,
        allergens: _allergensController.text.isNotEmpty
            ? _allergensController.text.split(',').map((e) => e.trim()).toList()
            : null,
        isActive: _isActive,
        minOrderQuantity: int.tryParse(_minOrderQuantityController.text),
        multipleOrderQuantity:
            int.tryParse(_multipleOrderQuantityController.text),
        availableFrom: _availableFrom,
        availableTo: _availableTo,
        // priceTiers: widget.product?.priceTiers, // Placeholder: Implement UI for price tiers
        // customerSpecificPrices: widget.product?.customerSpecificPrices, // Placeholder: Implement UI for customer specific prices
        shelfLifeDays: int.tryParse(_shelfLifeDaysController.text),
        storageInstructions: _storageInstructionsController.text.isNotEmpty
            ? _storageInstructionsController.text
            : null,
        tags: _tagsController.text.isNotEmpty
            ? _tagsController.text.split(',').map((e) => e.trim()).toList()
            : null,
        isSeasonal: _isSeasonal,
        reorderPoint: double.tryParse(_reorderPointController.text),
        targetStockLevel: double.tryParse(_targetStockLevelController.text),
        nutritionalInfo: _nutritionalInfoController.text.isNotEmpty
            ? _nutritionalInfoController.text
            : null,
        ingredients: _ingredientsController.text.isNotEmpty
            ? _ingredientsController.text
            : null,
        searchTerms: widget.product?.searchTerms ??
            [], // Usually auto-generated or managed separately
        isBatchTracked: _isBatchTracked,
        isPerishable: _isPerishable,
      );

      // TODO: Implement the actual save logic (e.g., call a BLoC event, repository method to interact with backend services)
      print('Saving product: ${updatedProduct.toJson()}');
      // Example: context.read<ProductBloc>().add(SaveProductEvent(updatedProduct));

      if (mounted) {
        Navigator.of(context)
            .pop(updatedProduct); // Pass the saved/updated product back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Existing Fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Product Code*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category*'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a category'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _uomController,
                decoration:
                    InputDecoration(labelText: 'Unit of Measure (UoM)*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Unit of Measure';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _basePriceController,
                decoration: InputDecoration(labelText: 'Base Price*'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a base price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Price cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // New Fields
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text('Upload Image'),
                onPressed: () {
                  // TODO: Implement image picking and uploading logic
                  // This would typically involve using a package like image_picker
                  // and then uploading to a service like Firebase Storage.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Image upload functionality not implemented yet.')),
                  );
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _packagingTypeController,
                decoration: InputDecoration(labelText: 'Packaging Type'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightPerUnitController,
                      decoration: InputDecoration(labelText: 'Weight/Unit'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weightUomController,
                      decoration: InputDecoration(labelText: 'Weight UoM'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _allergensController,
                decoration:
                    InputDecoration(labelText: 'Allergens (comma-separated)'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _minOrderQuantityController,
                decoration: InputDecoration(labelText: 'Min Order Qty'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      int.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      int.parse(value) < 0) {
                    return 'Cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _multipleOrderQuantityController,
                decoration: InputDecoration(labelText: 'Multiple Order Qty'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      int.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      int.parse(value) < 0) {
                    return 'Cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Available From',
                        hintText: _availableFrom == null
                            ? 'Select date'
                            : _dateFormatter.format(_availableFrom!),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Available To',
                          hintText: _availableTo == null
                              ? 'Select date'
                              : _dateFormatter.format(_availableTo!),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, false),
                        validator: (value) {
                          if (_availableFrom != null &&
                              _availableTo != null &&
                              _availableTo!.isBefore(_availableFrom!)) {
                            return '\'To\' date must be after \'From\' date';
                          }
                          return null;
                        }),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _shelfLifeDaysController,
                decoration: InputDecoration(labelText: 'Shelf Life (Days)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      int.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      int.parse(value) < 0) {
                    return 'Cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _storageInstructionsController,
                decoration: InputDecoration(labelText: 'Storage Instructions'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration:
                    InputDecoration(labelText: 'Tags (comma-separated)'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _reorderPointController,
                decoration: InputDecoration(labelText: 'Reorder Point'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      double.parse(value) < 0) {
                    return 'Cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _targetStockLevelController,
                decoration: InputDecoration(labelText: 'Target Stock Level'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      double.parse(value) < 0) {
                    return 'Cannot be negative';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nutritionalInfoController,
                decoration: InputDecoration(labelText: 'Nutritional Info'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(labelText: 'Ingredients'),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // TODO: Add UI for priceTiers and customerSpecificPrices if needed.
              // This would likely involve more complex widgets (e.g., a list of TextFormFields or a dedicated sub-form).

              SwitchListTile(
                title: Text('Is Active'),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Is Batch Tracked'),
                value: _isBatchTracked,
                onChanged: (bool value) {
                  setState(() {
                    _isBatchTracked = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Is Perishable'),
                value: _isPerishable,
                onChanged: (bool value) {
                  setState(() {
                    _isPerishable = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Is Seasonal'),
                value: _isSeasonal,
                onChanged: (bool value) {
                  setState(() {
                    _isSeasonal = value;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text('Save Product'),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
