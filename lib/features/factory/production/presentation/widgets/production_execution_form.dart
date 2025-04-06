import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/utils/form_utils.dart';
import '../../../../sales/data/models/product_catalog_model.dart';
import '../../../production/domain/models/production_execution_model.dart';

class ProductionExecutionForm extends ConsumerStatefulWidget {

  const ProductionExecutionForm({
    super.key,
    this.initialValue,
    required this.onSubmit,
    this.isEditing = false,
  });
  final ProductionExecutionModel? initialValue;
  final Function(ProductionExecutionModel) onSubmit;
  final bool isEditing;

  @override
  ConsumerState<ProductionExecutionForm> createState() =>
      _ProductionExecutionFormState();
}

class _ProductionExecutionFormState
    extends ConsumerState<ProductionExecutionForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _materialFormKey = GlobalKey<FormState>();
  final _personnelFormKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController _batchNumberController;
  late TextEditingController _productionOrderIdController;
  late TextEditingController _targetQuantityController;
  late TextEditingController _unitOfMeasureController;
  late TextEditingController _productionLineIdController;
  late TextEditingController _productionLineNameController;
  late TextEditingController _expectedYieldController;
  late TextEditingController _notesController;

  // Form data
  late DateTime _scheduledDate;
  late String _productId;
  late String _productName;
  late List<MaterialUsage> _materials = [];
  late List<AssignedPersonnel> _assignedPersonnel = [];

  // Material form controllers
  final _materialIdController = TextEditingController();
  final _materialNameController = TextEditingController();
  final _plannedQuantityController = TextEditingController();
  final _actualQuantityController = TextEditingController();
  final _materialUomController = TextEditingController();
  final _batchNumberMatController = TextEditingController();

  // Personnel form controllers
  final _personnelIdController = TextEditingController();
  final _personnelNameController = TextEditingController();
  final _roleController = TextEditingController();
  late DateTime _assignedStartTime;
  DateTime? _assignedEndTime;

  // For product dropdown
  List<ProductCatalogModel> _products = [];
  ProductCatalogModel? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Initialize with default values or from existing model
    if (widget.initialValue != null) {
      _batchNumberController =
          TextEditingController(text: widget.initialValue!.batchNumber);
      _productionOrderIdController =
          TextEditingController(text: widget.initialValue!.productionOrderId);
      _targetQuantityController = TextEditingController(
          text: widget.initialValue!.targetQuantity.toString());
      _unitOfMeasureController =
          TextEditingController(text: widget.initialValue!.unitOfMeasure);
      _productionLineIdController =
          TextEditingController(text: widget.initialValue!.productionLineId);
      _productionLineNameController =
          TextEditingController(text: widget.initialValue!.productionLineName);
      _expectedYieldController = TextEditingController(
          text: widget.initialValue!.expectedYield.toString());
      _notesController =
          TextEditingController(text: widget.initialValue!.notes ?? '');

      _scheduledDate = widget.initialValue!.scheduledDate;
      _productId = widget.initialValue!.productId;
      _productName = widget.initialValue!.productName;
      _materials = List.from(widget.initialValue!.materials);
      _assignedPersonnel = List.from(widget.initialValue!.assignedPersonnel);
    } else {
      _batchNumberController =
          TextEditingController(text: _generateBatchNumber());
      _productionOrderIdController = TextEditingController();
      _targetQuantityController = TextEditingController();
      _unitOfMeasureController = TextEditingController(text: 'kg');
      _productionLineIdController = TextEditingController();
      _productionLineNameController = TextEditingController();
      _expectedYieldController = TextEditingController();
      _notesController = TextEditingController();

      _scheduledDate = DateTime.now();
      _productId = '';
      _productName = '';
    }

    _assignedStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _productionOrderIdController.dispose();
    _targetQuantityController.dispose();
    _unitOfMeasureController.dispose();
    _productionLineIdController.dispose();
    _productionLineNameController.dispose();
    _expectedYieldController.dispose();
    _notesController.dispose();

    _materialIdController.dispose();
    _materialNameController.dispose();
    _plannedQuantityController.dispose();
    _actualQuantityController.dispose();
    _materialUomController.dispose();
    _batchNumberMatController.dispose();

    _personnelIdController.dispose();
    _personnelNameController.dispose();
    _roleController.dispose();

    super.dispose();
  }

  // Fetch product catalog for dropdown
  Future<void> _fetchProducts() async {
    // TODO: Replace with actual product fetching logic
    // This is a placeholder. In a real implementation, you would fetch from a repository
    setState(() {
      _products = [
        ProductCatalogModel(
          id: 'p1',
          name: 'Whole Milk',
          code: 'WM-001',
          category: 'Dairy',
          description: 'Fresh whole milk',
          uom: 'L',
          basePrice: 2.5,
        ),
        ProductCatalogModel(
          id: 'p2',
          name: 'Low-fat Milk',
          code: 'LM-001',
          category: 'Dairy',
          description: 'Low-fat milk',
          uom: 'L',
          basePrice: 2.7,
        ),
        ProductCatalogModel(
          id: 'p3',
          name: 'Yogurt',
          code: 'YG-001',
          category: 'Dairy',
          description: 'Plain yogurt',
          uom: 'kg',
          basePrice: 3.5,
        ),
      ];
    });
  }

  // Generate a unique batch number
  String _generateBatchNumber() {
    final now = DateTime.now();
    final date = DateFormat('yyyyMMdd').format(now);
    final uuid = const Uuid().v4().substring(0, 4);
    return 'B$date-$uuid';
  }

  // Handle product selection
  void _handleProductSelect(ProductCatalogModel product) {
    setState(() {
      _selectedProduct = product;
      _productId = product.id ?? '';
      _productName = product.name;
      _unitOfMeasureController.text = product.uom;
    });
  }

  // Add a new material to the list
  void _addMaterial() {
    final formValid = _materialFormKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() {
      _materials.add(
        MaterialUsage(
          materialId: _materialIdController.text,
          materialName: _materialNameController.text,
          plannedQuantity: double.parse(_plannedQuantityController.text),
          actualQuantity: double.parse(_actualQuantityController.text),
          unitOfMeasure: _materialUomController.text,
          batchNumber: _batchNumberMatController.text.isNotEmpty
              ? _batchNumberMatController.text
              : null,
        ),
      );

      // Clear the form
      _materialIdController.clear();
      _materialNameController.clear();
      _plannedQuantityController.clear();
      _actualQuantityController.clear();
      _materialUomController.clear();
      _batchNumberMatController.clear();
    });
  }

  // Remove a material from the list
  void _removeMaterial(int index) {
    setState(() {
      _materials.removeAt(index);
    });
  }

  // Add a new personnel to the list
  void _addPersonnel() {
    final formValid = _personnelFormKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() {
      _assignedPersonnel.add(
        AssignedPersonnel(
          personnelId: _personnelIdController.text,
          personnelName: _personnelNameController.text,
          role: _roleController.text,
          assignedStartTime: _assignedStartTime,
          assignedEndTime: _assignedEndTime,
        ),
      );

      // Clear the form
      _personnelIdController.clear();
      _personnelNameController.clear();
      _roleController.clear();
      _assignedStartTime = DateTime.now();
      _assignedEndTime = null;
    });
  }

  // Remove a personnel from the list
  void _removePersonnel(int index) {
    setState(() {
      _assignedPersonnel.removeAt(index);
    });
  }

  // Submit the form
  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validate materials and personnel lists are not empty
    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one material')),
      );
      return;
    }

    if (_assignedPersonnel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign at least one personnel')),
      );
      return;
    }

    final execution = widget.initialValue?.copyWith(
          batchNumber: _batchNumberController.text,
          productionOrderId: _productionOrderIdController.text,
          scheduledDate: _scheduledDate,
          productId: _productId,
          productName: _productName,
          targetQuantity: double.parse(_targetQuantityController.text),
          unitOfMeasure: _unitOfMeasureController.text,
          status: widget.isEditing
              ? widget.initialValue!.status
              : ProductionExecutionStatus.planned,
          productionLineId: _productionLineIdController.text,
          productionLineName: _productionLineNameController.text,
          assignedPersonnel: _assignedPersonnel,
          materials: _materials,
          expectedYield: double.parse(_expectedYieldController.text),
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
          updatedAt: DateTime.now(),
        ) ??
        ProductionExecutionModel(
          id: const Uuid().v4(),
          batchNumber: _batchNumberController.text,
          productionOrderId: _productionOrderIdController.text,
          scheduledDate: _scheduledDate,
          productId: _productId,
          productName: _productName,
          targetQuantity: double.parse(_targetQuantityController.text),
          unitOfMeasure: _unitOfMeasureController.text,
          status: ProductionExecutionStatus.planned,
          productionLineId: _productionLineIdController.text,
          productionLineName: _productionLineNameController.text,
          assignedPersonnel: _assignedPersonnel,
          materials: _materials,
          expectedYield: double.parse(_expectedYieldController.text),
          createdAt: DateTime.now(),
          createdBy: 'current-user', // Replace with actual user ID
          updatedAt: DateTime.now(),
          updatedBy: 'current-user', // Replace with actual user ID
        );

    widget.onSubmit(execution);
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
            // Batch Number
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'Batch Number',
                hintText: 'Auto-generated batch number',
              ),
              validator: FormUtils.requiredValidator,
              readOnly: true, // Auto-generated, so read-only
            ),
            const SizedBox(height: 16),

            // Production Order ID
            TextFormField(
              controller: _productionOrderIdController,
              decoration: const InputDecoration(
                labelText: 'Production Order ID',
                hintText: 'Enter production order ID',
              ),
              validator: FormUtils.requiredValidator,
            ),
            const SizedBox(height: 16),

            // Scheduled Date
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  setState(() {
                    _scheduledDate = pickedDate;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Date',
                    hintText: 'Select a date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _dateFormat.format(_scheduledDate),
                  ),
                  validator: FormUtils.requiredValidator,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Selection
            DropdownButtonFormField<ProductCatalogModel>(
              decoration: const InputDecoration(
                labelText: 'Product',
                hintText: 'Select a product',
              ),
              value: _selectedProduct,
              items: _products.map((product) {
                return DropdownMenuItem<ProductCatalogModel>(
                  value: product,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (product) {
                if (product != null) {
                  _handleProductSelect(product);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a product';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Target Quantity and UOM
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _targetQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Target Quantity',
                      hintText: 'Enter target quantity',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter target quantity';
                      }
                      final quantity = double.tryParse(value);
                      if (quantity == null) {
                        return 'Please enter a valid number';
                      }
                      if (quantity <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitOfMeasureController,
                    decoration: const InputDecoration(
                      labelText: 'Unit of Measure',
                      hintText: 'e.g., kg, L',
                    ),
                    validator: FormUtils.requiredValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Production Line
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productionLineIdController,
                    decoration: const InputDecoration(
                      labelText: 'Production Line ID',
                      hintText: 'Enter production line ID',
                    ),
                    validator: FormUtils.requiredValidator,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _productionLineNameController,
                    decoration: const InputDecoration(
                      labelText: 'Production Line Name',
                      hintText: 'Enter production line name',
                    ),
                    validator: FormUtils.requiredValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expected Yield
            TextFormField(
              controller: _expectedYieldController,
              decoration: const InputDecoration(
                labelText: 'Expected Yield',
                hintText: 'Enter expected yield',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter expected yield';
                }
                final yield = double.tryParse(value);
                if (yield == null) {
                  return 'Please enter a valid number';
                }
                if (yield <= 0) {
                  return 'Expected yield must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Materials Section
            const Text(
              'Materials',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Materials List
            ..._materials.asMap().entries.map((entry) {
              final index = entry.key;
              final material = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(material.materialName),
                  subtitle: Text(
                      'Planned: ${material.plannedQuantity} ${material.unitOfMeasure}'
                      '${material.batchNumber != null ? ' | Batch: ${material.batchNumber}' : ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMaterial(index),
                  ),
                ),
              );
            }),

            // Add Material Form
            Card(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _materialFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Material',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _materialIdController,
                              decoration: const InputDecoration(
                                labelText: 'Material ID',
                                hintText: 'Enter material ID',
                              ),
                              validator: FormUtils.requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _materialNameController,
                              decoration: const InputDecoration(
                                labelText: 'Material Name',
                                hintText: 'Enter material name',
                              ),
                              validator: FormUtils.requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _plannedQuantityController,
                              decoration: const InputDecoration(
                                labelText: 'Planned Quantity',
                                hintText: 'Enter planned quantity',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final quantity = double.tryParse(value);
                                if (quantity == null) {
                                  return 'Invalid number';
                                }
                                if (quantity <= 0) {
                                  return 'Must be > 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _actualQuantityController,
                              decoration: const InputDecoration(
                                labelText: 'Actual Quantity',
                                hintText: 'Usually filled later',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final quantity = double.tryParse(value);
                                if (quantity == null) {
                                  return 'Invalid number';
                                }
                                if (quantity < 0) {
                                  return 'Must be >= 0';
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
                              controller: _materialUomController,
                              decoration: const InputDecoration(
                                labelText: 'Unit of Measure',
                                hintText: 'e.g., kg, L',
                              ),
                              validator: FormUtils.requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _batchNumberMatController,
                              decoration: const InputDecoration(
                                labelText: 'Batch Number (Optional)',
                                hintText: 'Enter batch if known',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addMaterial,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Material'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Personnel Section
            const Text(
              'Assigned Personnel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Personnel List
            ..._assignedPersonnel.asMap().entries.map((entry) {
              final index = entry.key;
              final personnel = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(personnel.personnelName),
                  subtitle: Text('Role: ${personnel.role}\n'
                      'Start: ${_dateFormat.format(personnel.assignedStartTime)}'
                      '${personnel.assignedEndTime != null ? ' | End: ${_dateFormat.format(personnel.assignedEndTime!)}' : ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removePersonnel(index),
                  ),
                ),
              );
            }),

            // Add Personnel Form
            Card(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _personnelFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Personnel',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _personnelIdController,
                              decoration: const InputDecoration(
                                labelText: 'Personnel ID',
                                hintText: 'Enter personnel ID',
                              ),
                              validator: FormUtils.requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _personnelNameController,
                              decoration: const InputDecoration(
                                labelText: 'Personnel Name',
                                hintText: 'Enter personnel name',
                              ),
                              validator: FormUtils.requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _roleController,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          hintText: 'Enter role (e.g., Supervisor, Operator)',
                        ),
                        validator: FormUtils.requiredValidator,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _assignedStartTime,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _assignedStartTime = pickedDate;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Date',
                                    hintText: 'Select start date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text:
                                        _dateFormat.format(_assignedStartTime),
                                  ),
                                  validator: FormUtils.requiredValidator,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _assignedEndTime ??
                                      DateTime.now()
                                          .add(const Duration(days: 1)),
                                  firstDate: _assignedStartTime,
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _assignedEndTime = pickedDate;
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'End Date (Optional)',
                                    hintText: 'Select end date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: _assignedEndTime != null
                                        ? _dateFormat.format(_assignedEndTime!)
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addPersonnel,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Personnel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter additional notes (optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.isEditing
                    ? 'Update Production Execution'
                    : 'Create Production Execution'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
