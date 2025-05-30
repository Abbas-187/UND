import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';

import '../../domain/services/inventory_movement_service.dart';
import '../../models/inventory_movement_item_model.dart';
import '../../models/inventory_movement_model.dart';
import '../../models/inventory_movement_type.dart';

class CreateMovementPage extends ConsumerStatefulWidget {
  const CreateMovementPage({super.key});

  @override
  ConsumerState<CreateMovementPage> createState() => _CreateMovementPageState();
}

class _CreateMovementPageState extends ConsumerState<CreateMovementPage> {
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isProcessing = false;

  // Form data
  InventoryMovementType _movementType = InventoryMovementType.TRANSFER;
  String _sourceLocationId = '';
  String _sourceLocationName = '';
  String _destinationLocationId = '';
  String _destinationLocationName = '';
  final String _initiatingEmployeeId = ''; // Should come from auth
  final String _initiatingEmployeeName = ''; // Should come from auth
  String _reasonNotes = '';
  final List<String> _referenceDocuments = [];
  final List<InventoryMovementItemModel> _items = [];

  // Current item being added
  String _currentProductId = '';
  String _currentProductName = '';
  String _currentBatchLotNumber = '';
  double _currentQuantity = 0.0;
  String _currentUnitOfMeasurement = 'kg';
  final MovementItemStatus _currentItemStatus = MovementItemStatus.IN_TRANSIT;
  final DateTime _currentProductionDate = DateTime.now();
  final DateTime _currentExpirationDate =
      DateTime.now().add(const Duration(days: 365));
  final QualityStatus _currentQualityStatus = QualityStatus.REGULAR;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Inventory Movement'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _handleContinue,
          onStepCancel: _handleCancel,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  if (_currentStep < 3)
                    FilledButton(
                      onPressed: details.onStepContinue,
                      child: Text(_currentStep == 2 ? 'Add Item' : 'Continue'),
                    ),
                  if (_currentStep == 3)
                    FilledButton(
                      onPressed: _isProcessing ? null : details.onStepContinue,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : const Text('Create Movement'),
                    ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: Text(_currentStep == 3 ? 'Back' : 'Cancel'),
                    ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Movement Type and Basic Info
            Step(
              title: const Text('Movement Type'),
              content: _buildMovementTypeStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),

            // Step 2: Source and Destination
            Step(
              title: const Text('Locations'),
              content: _buildLocationsStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),

            // Step 3: Add Items
            Step(
              title: Text(l10n.addItems),
              content: _buildAddItemsStep(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),

            // Step 4: Review and Submit
            Step(
              title: Text(l10n.reviewAndSubmit),
              content: _buildReviewStep(),
              isActive: _currentStep >= 3,
              state: _isProcessing ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Movement Type and Basic Info
  Widget _buildMovementTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Movement Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<InventoryMovementType>(
          value: _movementType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Movement Type',
          ),
          items: InventoryMovementType.values
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _movementType = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a movement type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Notes/Reason',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          onChanged: (value) {
            _reasonNotes = value;
          },
        ),
      ],
    );
  }

  // Step 2: Source and Destination
  Widget _buildLocationsStep() {
    final showSourceField = _movementType != InventoryMovementType.RECEIPT;
    final showDestinationField =
        _movementType != InventoryMovementType.DISPOSAL;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSourceField) ...[
          const Text(
            'Source Location',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Source Location ID',
                  ),
                  initialValue: _sourceLocationId,
                  onChanged: (value) {
                    setState(() {
                      _sourceLocationId = value;
                    });
                  },
                  validator: showSourceField
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Source location is required';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Scan Location Barcode',
                onPressed: () {
                  // Implement barcode scanning for location
                  _scanSourceLocationBarcode();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Source Location Name',
            ),
            initialValue: _sourceLocationName,
            onChanged: (value) {
              setState(() {
                _sourceLocationName = value;
              });
            },
            validator: showSourceField
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Source location name is required';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
        ],
        if (showDestinationField) ...[
          const Text(
            'Destination Location',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Destination Location ID',
                  ),
                  initialValue: _destinationLocationId,
                  onChanged: (value) {
                    setState(() {
                      _destinationLocationId = value;
                    });
                  },
                  validator: showDestinationField
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Destination location is required';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Scan Location Barcode',
                onPressed: () {
                  // Implement barcode scanning for location
                  _scanDestinationLocationBarcode();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Destination Location Name',
            ),
            initialValue: _destinationLocationName,
            onChanged: (value) {
              setState(() {
                _destinationLocationName = value;
              });
            },
            validator: showDestinationField
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Destination location name is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ],
    );
  }

  // Step 3: Add Items
  Widget _buildAddItemsStep() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Items to Movement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Product details
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Product ID',
                ),
                onChanged: (value) {
                  setState(() {
                    _currentProductId = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan Product',
              onPressed: () {
                // Implement barcode scanning for product
                _scanProductBarcode();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Product Name',
          ),
          onChanged: (value) {
            setState(() {
              _currentProductName = value;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Batch/Lot Number',
                ),
                onChanged: (value) {
                  setState(() {
                    _currentBatchLotNumber = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan Batch',
              onPressed: () {
                // Implement barcode scanning for batch
                _scanBatchBarcode();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _currentQuantity = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _currentUnitOfMeasurement,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Unit',
                ),
                items: [
                  DropdownMenuItem(value: 'kg', child: Text(l10n.kilogram)),
                  DropdownMenuItem(value: 'l', child: Text('l')),
                  DropdownMenuItem(value: 'pc', child: Text(l10n.piece)),
                  DropdownMenuItem(value: 'box', child: Text(l10n.box)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentUnitOfMeasurement = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Display current items
        if (_items.isNotEmpty) ...[
          const Divider(),
          const Text(
            'Items in this Movement:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.productName),
                  subtitle: Text('Batch: ${item.batchLotNumber}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.quantity} ${item.unitOfMeasurement}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // Step 4: Review and Submit
  Widget _buildReviewStep() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Movement Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Movement type
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Movement Type',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _movementType.toString().split('.').last,
                  style: theme.textTheme.bodyLarge,
                ),
                if (_reasonNotes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes/Reason',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(_reasonNotes),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Locations
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Locations',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_movementType != InventoryMovementType.RECEIPT) ...[
                  Row(
                    children: [
                      const Text('From: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$_sourceLocationName ($_sourceLocationId)'),
                    ],
                  ),
                ],
                if (_movementType != InventoryMovementType.DISPOSAL) ...[
                  Row(
                    children: [
                      const Text('To: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          '$_destinationLocationName ($_destinationLocationId)'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Items
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_items.isEmpty)
                  const Text('No items added to this movement')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Batch: ${item.batchLotNumber}'),
                                ],
                              ),
                            ),
                            Text(
                              '${item.quantity} ${item.unitOfMeasurement}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // Warning if no items
        if (_items.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No items have been added to this movement. Please go back and add at least one item.',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addCurrentItem() {
    if (_currentProductId.isEmpty ||
        _currentProductName.isEmpty ||
        _currentBatchLotNumber.isEmpty ||
        _currentQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required item fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newItem = InventoryMovementItemModel(
      itemId: const Uuid().v4(),
      productId: _currentProductId,
      productName: _currentProductName,
      batchLotNumber: _currentBatchLotNumber,
      quantity: _currentQuantity,
      unitOfMeasurement: _currentUnitOfMeasurement,
      status: _currentItemStatus,
      productionDate: _currentProductionDate,
      expirationDate: _currentExpirationDate,
      qualityStatus: _currentQualityStatus,
    );

    setState(() {
      _items.add(newItem);

      // Reset current item fields
      _currentProductId = '';
      _currentProductName = '';
      _currentBatchLotNumber = '';
      _currentQuantity = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added to movement'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleContinue() {
    final FormState? formState = _formKey.currentState;

    if (_currentStep == 0) {
      if (formState!.validate()) {
        setState(() {
          _currentStep += 1;
        });
      }
    } else if (_currentStep == 1) {
      // Validate source and destination based on movement type
      if (_movementType == InventoryMovementType.RECEIPT &&
          _destinationLocationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Destination location is required for RECEIPT movements'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } else if (_movementType == InventoryMovementType.DISPOSAL &&
          _sourceLocationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Source location is required for DISPOSAL movements'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } else if (_sourceLocationId.isEmpty || _destinationLocationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Both source and destination locations are required for this movement type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _currentStep += 1;
      });
    } else if (_currentStep == 2) {
      _addCurrentItem();
    } else if (_currentStep == 3) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item to the movement'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _submitMovement();
    }
  }

  void _handleCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _scanSourceLocationBarcode() {
    // TODO: Implementation would go here
    // Simulated response for now
    setState(() {
      _sourceLocationId = 'LOC-001';
      _sourceLocationName = 'Warehouse A';
    });
  }

  void _scanDestinationLocationBarcode() {
    // TODO: Implementation would go here
    // Simulated response for now
    setState(() {
      _destinationLocationId = 'LOC-002';
      _destinationLocationName = 'Production Floor';
    });
  }

  void _scanProductBarcode() {
    // TODO: Implementation would go here
    // Simulated response for now
    setState(() {
      _currentProductId = 'PROD-001';
      _currentProductName = 'Raw Milk';
    });
  }

  void _scanBatchBarcode() {
    // TODO: Implementation would go here
    // Simulated response for now
    setState(() {
      _currentBatchLotNumber =
          'BATCH-${DateFormat('yyyyMMdd').format(DateTime.now())}-001';
    });
  }

  Future<void> _submitMovement() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final newMovement = InventoryMovementModel(
        movementId: const Uuid().v4(),
        timestamp: DateTime.now(),
        movementType: _movementType,
        sourceLocationId: _sourceLocationId,
        sourceLocationName: _sourceLocationName,
        destinationLocationId: _destinationLocationId,
        destinationLocationName: _destinationLocationName,
        initiatingEmployeeId: _initiatingEmployeeId.isNotEmpty
            ? _initiatingEmployeeId
            : 'EMP-001',
        initiatingEmployeeName: _initiatingEmployeeName.isNotEmpty
            ? _initiatingEmployeeName
            : 'Current User',
        approvalStatus: ApprovalStatus.PENDING,
        approverEmployeeId: null,
        approverEmployeeName: null,
        reasonNotes: _reasonNotes,
        referenceDocuments: _referenceDocuments,
        items: _items,
      );

      final service = ref.read(inventoryMovementServiceProvider);
      await service.createMovement(newMovement);

      // Show success message and pop back to list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inventory movement created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to the list
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating movement: $e'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
