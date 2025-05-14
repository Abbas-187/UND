import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../domain/providers/inventory_costing_provider.dart';

class InventoryMovementFormScreen extends ConsumerStatefulWidget {
  const InventoryMovementFormScreen({
    super.key,
    required this.movementType,
    this.warehouseId,
    this.warehouseName,
  });

  final InventoryMovementType movementType;
  final String? warehouseId;
  final String? warehouseName;

  @override
  ConsumerState<InventoryMovementFormScreen> createState() =>
      _InventoryMovementFormScreenState();
}

class _InventoryMovementFormScreenState
    extends ConsumerState<InventoryMovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _movementDate = DateTime.now();
  String? _selectedWarehouseId;
  String? _selectedWarehouseName;
  final List<InventoryMovementItemModel> _items = [];
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _validateBatchTracking = true;

  @override
  void initState() {
    super.initState();
    _selectedWarehouseId = widget.warehouseId;
    _selectedWarehouseName = widget.warehouseName;

    // Generate a document number
    _documentNumberController.text = _generateDocumentNumber();
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _referenceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateDocumentNumber() {
    final movementPrefix = widget.movementType
        .toString()
        .split('.')
        .last
        .substring(0, 3)
        .toUpperCase();
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final randomSuffix = const Uuid().v4().substring(0, 4).toUpperCase();
    return '$movementPrefix-$dateStr-$randomSuffix';
  }

  String _getScreenTitle() {
    switch (widget.movementType) {
      case InventoryMovementType.receipt:
        return 'Goods Receipt';
      case InventoryMovementType.issue:
        return 'Goods Issue';
      case InventoryMovementType.transfer:
        return 'Inventory Transfer';
      case InventoryMovementType.return_:
        return 'Returns Processing';
      case InventoryMovementType.adjustment:
        return 'Stock Count/Adjustment';
      default:
        return 'Inventory Movement';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ],
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const Divider(),
                  _buildItemsSection(),
                  if (_errorMessage != null) _buildErrorMessage(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movement Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _documentNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Document Number',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Document number is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Movement Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormat('MMM d, yyyy').format(_movementDate),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWarehouseSelector(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _referenceNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Reference Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _validateBatchTracking,
                onChanged: (value) {
                  setState(() {
                    _validateBatchTracking = value ?? true;
                  });
                },
              ),
              const Text('Enforce batch/lot tracking for perishable items'),
              const Tooltip(
                message:
                    'When enabled, perishable items will require batch/lot numbers, production dates, and expiration dates.',
                child: Icon(Icons.info_outline, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector() {
    // In a real app, this would fetch warehouses from a provider
    final warehouses = [
      if (_selectedWarehouseId != null && _selectedWarehouseName != null)
        {'id': _selectedWarehouseId!, 'name': _selectedWarehouseName!},
      {'id': 'warehouse1', 'name': 'Main Warehouse'},
      {'id': 'warehouse2', 'name': 'Production Warehouse'},
      {'id': 'warehouse3', 'name': 'Distribution Center'},
    ];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Warehouse',
        border: OutlineInputBorder(),
      ),
      value: _selectedWarehouseId,
      items: warehouses.map((warehouse) {
        return DropdownMenuItem<String>(
          value: warehouse['id'],
          child: Text(warehouse['name']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedWarehouseId = value;
          _selectedWarehouseName =
              warehouses.firstWhere((w) => w['id'] == value)['name'];
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Warehouse is required';
        }
        return null;
      },
    );
  }

  Widget _buildItemsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_items.length} items',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'No items added yet.\nTap the + button to add items.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _buildItemCard(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(InventoryMovementItemModel item, int index) {
    final inboundMovement = [
      InventoryMovementType.receipt,
      InventoryMovementType.return_,
      InventoryMovementType.adjustment,
    ].contains(widget.movementType);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editItem(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${item.quantity.abs().toStringAsFixed(2)} ${item.uom}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (inboundMovement && item.costAtTransaction != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unit Cost',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '\$${item.costAtTransaction!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.batchLotNumber != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Batch/Lot',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          item.batchLotNumber!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (item.expirationDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${DateFormat('MMM d, yyyy').format(item.expirationDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _movementDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (newDate != null) {
      setState(() {
        _movementDate = newDate;
      });
    }
  }

  void _addItem() async {
    // In a real app, this would show a search dialog to select an item
    // and then a form to enter quantity, cost, batch/lot, etc.
    final newItem = await _showItemForm();
    if (newItem != null) {
      setState(() {
        _items.add(newItem);
      });
    }
  }

  void _editItem(int index) async {
    final editedItem = await _showItemForm(_items[index]);
    if (editedItem != null) {
      setState(() {
        _items[index] = editedItem;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<InventoryMovementItemModel?> _showItemForm(
      [InventoryMovementItemModel? existingItem]) async {
    // This is a simplified form, in a real app you would have a more comprehensive UI
    // and probably use a separate screen or a bottom sheet

    final isInboundMovement = [
      InventoryMovementType.receipt,
      InventoryMovementType.return_,
      InventoryMovementType.adjustment,
    ].contains(widget.movementType);

    final formKey = GlobalKey<FormState>();
    final itemIdController =
        TextEditingController(text: existingItem?.itemId ?? '');
    final itemCodeController =
        TextEditingController(text: existingItem?.itemCode ?? '');
    final itemNameController =
        TextEditingController(text: existingItem?.itemName ?? '');
    final quantityController = TextEditingController(
      text: existingItem != null ? existingItem.quantity.abs().toString() : '',
    );
    final uomController = TextEditingController(text: existingItem?.uom ?? '');
    final batchLotController =
        TextEditingController(text: existingItem?.batchLotNumber ?? '');
    final costController = TextEditingController(
      text: existingItem?.costAtTransaction?.toString() ?? '',
    );

    DateTime? expirationDate = existingItem?.expirationDate;
    DateTime? productionDate = existingItem?.productionDate;

    // For demo purposes, we'll use hardcoded values for some fields
    if (itemIdController.text.isEmpty) itemIdController.text = 'ITEM001';
    if (itemCodeController.text.isEmpty) itemCodeController.text = 'I001';
    if (itemNameController.text.isEmpty) {
      itemNameController.text = 'Sample Item';
    }
    if (uomController.text.isEmpty) uomController.text = 'PCS';

    bool isPerishable = existingItem?.customAttributes?['isPerishable'] == true;

    InventoryMovementItemModel? result;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existingItem == null ? 'Add Item' : 'Edit Item'),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Item selection (simplified)
                        TextFormField(
                          controller: itemNameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            border: OutlineInputBorder(),
                          ),
                          readOnly:
                              true, // In a real app, this would open a search
                          onTap: () {
                            // Here you would show a dialog to select an item
                            // For now we'll just use the hardcoded value
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Item name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Perishable checkbox
                            Checkbox(
                              value: isPerishable,
                              onChanged: (value) {
                                setStateDialog(() {
                                  isPerishable = value ?? false;
                                });
                              },
                            ),
                            const Text('Perishable Item'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Quantity
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Quantity is required';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'Enter a valid positive number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: uomController,
                                decoration: const InputDecoration(
                                  labelText: 'UOM',
                                  border: OutlineInputBorder(),
                                ),
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        if (isInboundMovement) ...[
                          const SizedBox(height: 16),
                          // Cost
                          TextFormField(
                            controller: costController,
                            decoration: const InputDecoration(
                              labelText: 'Unit Cost',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (isInboundMovement) {
                                if (value == null || value.isEmpty) {
                                  return 'Cost is required for inbound movements';
                                }
                                if (double.tryParse(value) == null ||
                                    double.parse(value) <= 0) {
                                  return 'Enter a valid positive number';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                        if (isPerishable) ...[
                          const SizedBox(height: 16),
                          // Batch/Lot
                          TextFormField(
                            controller: batchLotController,
                            decoration: const InputDecoration(
                              labelText: 'Batch/Lot Number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (isPerishable && _validateBatchTracking) {
                                if (value == null || value.isEmpty) {
                                  return 'Batch/Lot is required for perishable items';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Production Date
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: productionDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setStateDialog(() {
                                  productionDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Production Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                productionDate != null
                                    ? DateFormat('MMM d, yyyy')
                                        .format(productionDate!)
                                    : 'Select date',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Expiration Date
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: expirationDate ??
                                    DateTime.now()
                                        .add(const Duration(days: 365)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setStateDialog(() {
                                  expirationDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Expiration Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                expirationDate != null
                                    ? DateFormat('MMM d, yyyy')
                                        .format(expirationDate!)
                                    : 'Select date',
                              ),
                            ),
                          ),
                        ],
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
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Quantity sign depends on movement type
                      double quantity = double.parse(quantityController.text);
                      if ([
                        InventoryMovementType.issue,
                        InventoryMovementType.consumption,
                      ].contains(widget.movementType)) {
                        quantity = -quantity; // Negative for outbound
                      }

                      // Create item
                      result = InventoryMovementItemModel(
                        id: existingItem?.id ?? const Uuid().v4(),
                        itemId: itemIdController.text,
                        itemCode: itemCodeController.text,
                        itemName: itemNameController.text,
                        quantity: quantity,
                        uom: uomController.text,
                        batchLotNumber: batchLotController.text.isNotEmpty
                            ? batchLotController.text
                            : null,
                        expirationDate: expirationDate,
                        productionDate: productionDate,
                        costAtTransaction:
                            isInboundMovement && costController.text.isNotEmpty
                                ? double.parse(costController.text)
                                : null,
                        customAttributes: {
                          'isPerishable': isPerishable,
                        },
                      );

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        setState(() {
          _errorMessage = 'Please add at least one item to the movement';
        });
        return;
      }

      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        // Create the movement model
        final movement = InventoryMovementModel(
          id: null, // New movement, will be assigned by repository
          documentNumber: _documentNumberController.text,
          movementType: widget.movementType,
          warehouseId: _selectedWarehouseId!,
          movementDate: _movementDate,
          referenceNumber: _referenceNumberController.text,
          reasonNotes: _notesController.text,
          items: _items,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          initiatingEmployeeId: 'TODO_USER_ID',
        );

        // Process the movement
        final result =
            await ref.read(processInventoryMovementUseCaseProvider).execute(
                  movement: movement,
                  validateBatchTracking: _validateBatchTracking,
                );

        if (result.success) {
          // Navigate back with success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_getScreenTitle()} saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          // Show error
          setState(() {
            _isSubmitting = false;
            _errorMessage = result.errors.join('\n');
          });
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }
}
