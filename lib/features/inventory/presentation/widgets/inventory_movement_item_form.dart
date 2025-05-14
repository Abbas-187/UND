import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_movement_item_model.dart';
import '../providers/inventory_item_picker_provider.dart';
import 'batch_information_form.dart';

/// Form widget for adding or editing inventory movement items
/// Includes fields for batch information and cost when required
class InventoryMovementItemForm extends ConsumerStatefulWidget {
  const InventoryMovementItemForm({
    super.key,
    this.item,
    required this.isInbound,
    required this.requiresBatchTracking,
    required this.onSave,
    this.scrollController,
  });

  final InventoryMovementItemModel? item;
  final bool isInbound;
  final bool requiresBatchTracking;
  final Function(InventoryMovementItemModel) onSave;
  final ScrollController? scrollController;

  @override
  ConsumerState<InventoryMovementItemForm> createState() =>
      _InventoryMovementItemFormState();
}

class _InventoryMovementItemFormState
    extends ConsumerState<InventoryMovementItemForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItemId;
  String _itemCode = '';
  String _itemName = '';
  final _quantityController = TextEditingController();
  String _uom = '';
  final _costController = TextEditingController();
  String? _batchLotNumber;
  DateTime? _productionDate;
  DateTime? _expirationDate;
  String? _locationId;
  final _notesController = TextEditingController();

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _selectedItemId = widget.item!.itemId;
      _itemCode = widget.item!.itemCode;
      _itemName = widget.item!.itemName;
      _quantityController.text = widget.item!.quantity.toString();
      _uom = widget.item!.uom;
      _costController.text = widget.item!.costAtTransaction?.toString() ?? '';
      _batchLotNumber = widget.item!.batchLotNumber;
      _productionDate = widget.item!.productionDate;
      _expirationDate = widget.item!.expirationDate;
      _locationId = widget.item!.locationId;
      _notesController.text = widget.item!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item selection
              _buildItemSelection(),

              const SizedBox(height: 16),

              // Quantity and UOM
              _buildQuantityField(),

              const SizedBox(height: 16),

              // Cost field (for inbound movements)
              if (widget.isInbound) _buildCostField(),

              if (widget.isInbound) const SizedBox(height: 16),

              // Batch Information
              _buildBatchInformation(),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Enter any additional notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          // For editing, just show item info
          _buildSelectedItemInfo()
        else
          // For new items, allow selection
          Consumer(
            builder: (context, ref, child) {
              final itemsAsyncValue = ref.watch(inventoryItemsProvider);

              return itemsAsyncValue.when(
                data: (items) => DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedItemId,
                  decoration: const InputDecoration(
                    labelText: 'Select Item',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.itemCode} - ${item.name}'),
                      onTap: () {
                        setState(() {
                          _itemCode = item.itemCode;
                          _itemName = item.name;
                          _uom = item.uom;
                        });
                      },
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItemId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an item';
                    }
                    return null;
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSelectedItemInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _itemName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Item Code: $_itemCode',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'UOM: $_uom',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    final quantitySign = widget.isInbound ? 1.0 : -1.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Quantity ${widget.isInbound ? "(+)" : "(-)"}',
              hintText: 'Enter quantity',
              border: const OutlineInputBorder(),
              suffixText: _uom,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a quantity';
              }
              final quantity = double.tryParse(value);
              if (quantity == null) {
                return 'Please enter a valid number';
              }
              if (quantity <= 0) {
                return 'Quantity must be greater than zero';
              }
              return null;
            },
          ),
        ),
        if (!_isEditing && _uom.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 12.0),
            child: Text(
              _uom,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
      ],
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: _costController,
      decoration: const InputDecoration(
        labelText: 'Cost per Unit',
        hintText: 'Enter cost per unit',
        border: OutlineInputBorder(),
        prefixText: '\$',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (!widget.isInbound) return null;

        if (value == null || value.isEmpty) {
          return 'Please enter a cost';
        }
        final cost = double.tryParse(value);
        if (cost == null) {
          return 'Please enter a valid cost';
        }
        if (cost <= 0) {
          return 'Cost must be greater than zero';
        }
        return null;
      },
    );
  }

  Widget _buildBatchInformation() {
    return BatchInformationForm(
      batchLotNumber: _batchLotNumber,
      productionDate: _productionDate,
      expirationDate: _expirationDate,
      onBatchLotNumberChanged: (value) {
        setState(() {
          _batchLotNumber = value;
        });
      },
      onProductionDateChanged: (value) {
        setState(() {
          _productionDate = value;
        });
      },
      onExpirationDateChanged: (value) {
        setState(() {
          _expirationDate = value;
        });
      },
      isRequired: widget.requiresBatchTracking && widget.isInbound,
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final double quantity =
          double.parse(_quantityController.text) * (widget.isInbound ? 1 : -1);

      double? cost;
      if (widget.isInbound && _costController.text.isNotEmpty) {
        cost = double.parse(_costController.text);
      }

      final item = InventoryMovementItemModel(
        id: widget.item?.id,
        itemId: _selectedItemId!,
        itemCode: _itemCode,
        itemName: _itemName,
        quantity: quantity,
        uom: _uom,
        costAtTransaction: cost,
        batchLotNumber: _batchLotNumber,
        productionDate: _productionDate,
        expirationDate: _expirationDate,
        locationId: _locationId,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      widget.onSave(item);
    }
  }
}
