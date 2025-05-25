import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_bar_with_back.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../providers/auth_provider.dart';
import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../providers/inventory_movement_provider.dart';
import '../widgets/inventory_movement_item_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Screen for creating and managing inventory movements
/// with batch tracking and FIFO/LIFO costing
class InventoryMovementScreen extends ConsumerStatefulWidget {
  const InventoryMovementScreen({
    super.key,
    this.movementId,
  });

  final String? movementId;

  @override
  ConsumerState<InventoryMovementScreen> createState() =>
      _InventoryMovementScreenState();
}

class _InventoryMovementScreenState
    extends ConsumerState<InventoryMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _reasonNotesController = TextEditingController();
  DateTime _movementDate = DateTime.now();
  InventoryMovementType _movementType = InventoryMovementType.receipt;
  String? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    // If editing an existing movement, load it
    if (widget.movementId != null) {
      Future.microtask(() {
        ref
            .read(inventoryMovementProvider.notifier)
            .loadMovement(widget.movementId!);
      });
    }
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _referenceNumberController.dispose();
    _reasonNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movementState = ref.watch(inventoryMovementProvider);
    final movementNotifier = ref.read(inventoryMovementProvider.notifier);

    // Populate form fields when editing an existing movement
    if (movementState.currentMovement != null &&
        !movementState.isFormPopulated) {
      _populateFormFields(movementState.currentMovement!);
      ref.read(inventoryMovementProvider.notifier).setFormPopulated(true);
    }

    return Scaffold(
      appBar: AppBarWithBack(
        title: widget.movementId == null
            ? 'New Inventory Movement'
            : 'Edit Inventory Movement',
        actions: widget.movementId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context),
                  tooltip: 'Delete Movement',
                ),
              ]
            : null,
      ),
      body: movementState.isLoading
          ? const LoadingIndicator()
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Movement type selection
                          _buildMovementTypeSelector(),

                          const SizedBox(height: 16),

                          // Basic information
                          _buildBasicInformation(),

                          const SizedBox(height: 16),

                          // Items section
                          _buildItemsSection(movementState, movementNotifier),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  _buildActionButtons(context, movementState, movementNotifier),
                ],
              ),
            ),
    );
  }

  Widget _buildMovementTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movement Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<InventoryMovementType>(
              value: _movementType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: InventoryMovementType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getMovementTypeName(type)),
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
            const SizedBox(height: 8),
            Text(
              _getMovementTypeDescription(_movementType),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Document Number
            TextFormField(
              controller: _documentNumberController,
              decoration: const InputDecoration(
                labelText: 'Document Number',
                hintText: 'Enter document number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a document number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Movement Date
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Movement Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MM/dd/yyyy').format(_movementDate),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Warehouse selection
            Consumer(
              builder: (context, ref, child) {
                final warehousesAsyncValue = ref.watch(warehousesProvider);

                return warehousesAsyncValue.when(
                  data: (warehouses) => DropdownButtonFormField<String>(
                    value: _selectedWarehouseId,
                    decoration: const InputDecoration(
                      labelText: 'Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    items: warehouses
                        .map((warehouse) => DropdownMenuItem(
                              value: warehouse.id,
                              child: Text(warehouse.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWarehouseId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a warehouse';
                      }
                      return null;
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),

            const SizedBox(height: 16),

            // Reference Number (optional)
            TextFormField(
              controller: _referenceNumberController,
              decoration: const InputDecoration(
                labelText: 'Reference Number (Optional)',
                hintText: 'Enter reference number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Reason / Notes
            TextFormField(
              controller: _reasonNotesController,
              decoration: const InputDecoration(
                labelText: 'Reason / Notes',
                hintText: 'Enter reason or notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(
    InventoryMovementState movementState,
    InventoryMovementNotifier movementNotifier,
  ) {
    return Card(
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  onPressed: () => _showAddItemDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items list
            if (movementState.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No items added yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: movementState.items.length,
                itemBuilder: (context, index) {
                  final item = movementState.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(item.itemName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${item.quantity} ${item.uom}'),
                          if (item.costAtTransaction != null)
                            Text(
                                'Cost: \$${item.costAtTransaction!.toStringAsFixed(2)}'),
                          if (item.batchLotNumber != null)
                            Text('Batch: ${item.batchLotNumber}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showEditItemDialog(context, index, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => movementNotifier.removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    InventoryMovementState movementState,
    InventoryMovementNotifier movementNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PrimaryButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.white,
            textColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          movementState.isSaving
              ? const CircularProgressIndicator()
              : PrimaryButton(
                  text: widget.movementId == null
                      ? 'Create Movement'
                      : 'Update Movement',
                  onPressed: () => _saveMovement(context, movementNotifier),
                ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _movementDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _movementDate) {
      setState(() {
        _movementDate = picked;
      });
    }
  }

  void _showAddItemDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return InventoryMovementItemForm(
              isInbound: _isInboundMovement(_movementType),
              requiresBatchTracking: true,
              scrollController: scrollController,
              onSave: (item) {
                ref.read(inventoryMovementProvider.notifier).addItem(item);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  void _showEditItemDialog(
      BuildContext context, int index, InventoryMovementItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return InventoryMovementItemForm(
              isInbound: _isInboundMovement(_movementType),
              requiresBatchTracking: true,
              item: item,
              scrollController: scrollController,
              onSave: (updatedItem) {
                ref
                    .read(inventoryMovementProvider.notifier)
                    .updateItem(index, updatedItem);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  void _saveMovement(
      BuildContext context, InventoryMovementNotifier movementNotifier) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Unable to determine current user. Please log in again.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      if (ref.read(inventoryMovementProvider).items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')),
        );
        return;
      }

      final result = await movementNotifier.saveMovement(
        id: widget.movementId,
        documentNumber: _documentNumberController.text,
        movementDate: _movementDate,
        movementType: _movementType,
        warehouseId: _selectedWarehouseId!,
        referenceNumber: _referenceNumberController.text.isEmpty
            ? null
            : _referenceNumberController.text,
        reasonNotes: _reasonNotesController.text.isEmpty
            ? null
            : _reasonNotesController.text,
        initiatingEmployeeId: user.id,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.movementId == null
                ? 'Inventory movement created successfully'
                : 'Inventory movement updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.errors.join(', ')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this inventory movement? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Store context reference before async gap
              final currentContext = context;
              Navigator.of(currentContext).pop();
              final result = await ref
                  .read(inventoryMovementProvider.notifier)
                  .deleteMovement(widget.movementId!);

              if (result && mounted) {
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Inventory movement deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(currentContext).pop(true); // Return success
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete inventory movement'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _populateFormFields(InventoryMovementModel movement) {
    _documentNumberController.text = movement.documentNumber;
    _referenceNumberController.text = movement.referenceNumber ?? '';
    _reasonNotesController.text = movement.reasonNotes ?? '';
    _movementDate = movement.movementDate;
    _movementType = movement.movementType;
    _selectedWarehouseId = movement.warehouseId;
  }

  String _getMovementTypeName(InventoryMovementType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case InventoryMovementType.receipt:
        return l10n?.receipt as String? ?? 'Receipt';
      case InventoryMovementType.issue:
        return l10n?.issue as String? ?? 'Issue';
      case InventoryMovementType.transfer:
        return l10n?.transfer as String? ?? 'Transfer';
      case InventoryMovementType.return_:
        return l10n?.returnMovement as String? ?? 'Return';
      case InventoryMovementType.adjustment:
        return l10n?.adjustment as String? ?? 'Adjustment';
      case InventoryMovementType.production:
        return l10n?.production as String? ?? 'Production';
      case InventoryMovementType.consumption:
        return l10n?.consumption as String? ?? 'Consumption';
      case InventoryMovementType.waste:
        return l10n?.waste as String? ?? 'Waste';
      case InventoryMovementType.expiry:
        return l10n?.expiry as String? ?? 'Expiry';
      case InventoryMovementType.qualityStatusChange:
        return l10n?.qualityStatusChange as String? ?? 'Quality Status Change';
      case InventoryMovementType.repack:
        return l10n?.repack as String? ?? 'Repack';
      case InventoryMovementType.sample:
        return l10n?.sample as String? ?? 'Sample';
      case InventoryMovementType.salesIssue:
        return l10n?.salesIssue as String? ?? 'Sales Issue';
      case InventoryMovementType.purchaseReceipt:
        return l10n?.purchaseReceipt as String? ?? 'Purchase Receipt';
      case InventoryMovementType.productionConsumption:
        return l10n?.productionConsumption as String? ??
            'Production Consumption';
      case InventoryMovementType.productionOutput:
        return l10n?.productionOutput as String? ?? 'Production Output';
      case InventoryMovementType.interWarehouseTransfer:
        return l10n?.interWarehouseTransfer as String? ??
            'Inter-Warehouse Transfer';
      case InventoryMovementType.intraWarehouseTransfer:
        return l10n?.intraWarehouseTransfer as String? ??
            'Intra-Warehouse Transfer';
      case InventoryMovementType.scrapDisposal:
        return l10n?.scrapDisposal as String? ?? 'Scrap Disposal';
      case InventoryMovementType.qualityHold:
        return l10n?.qualityHold as String? ?? 'Quality Hold';
      case InventoryMovementType.initialBalanceAdjustment:
        return l10n?.initialBalanceAdjustment as String? ??
            'Initial Balance Adjustment';
      case InventoryMovementType.reservationAdjustment:
        return l10n?.reservationAdjustment as String? ??
            'Reservation Adjustment';
      case InventoryMovementType.poReceipt:
        return l10n?.poReceipt as String? ?? 'PO Receipt';
      case InventoryMovementType.transferIn:
        return l10n?.transferIn as String? ?? 'Transfer In';
      case InventoryMovementType.productionIssue:
        return l10n?.productionIssue as String? ?? 'Production Issue';
      case InventoryMovementType.salesReturn:
        return l10n?.salesReturn as String? ?? 'Sales Return';
      case InventoryMovementType.adjustmentOther:
        return l10n?.adjustmentOther as String? ?? 'Other Adjustment';
      case InventoryMovementType.transferOut:
        return l10n?.transferOut as String? ?? 'Transfer Out';
      case InventoryMovementType.saleShipment:
        return l10n?.saleShipment as String? ?? 'Sale Shipment';
      case InventoryMovementType.adjustmentDamage:
        return l10n?.adjustmentDamage as String? ?? 'Damage Adjustment';
      case InventoryMovementType.adjustmentCycleCountGain:
        return l10n?.adjustmentCycleCountGain as String? ?? 'Cycle Count Gain';
      case InventoryMovementType.adjustmentCycleCountLoss:
        return l10n?.adjustmentCycleCountLoss as String? ?? 'Cycle Count Loss';
      case InventoryMovementType.qualityStatusUpdate:
        return l10n?.qualityStatusUpdate as String? ?? 'Quality Status Update';
    }
  }

  String _getMovementTypeDescription(InventoryMovementType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case InventoryMovementType.receipt:
        return l10n?.receiptDesc ??
            'Record goods received from suppliers or other sources';
      case InventoryMovementType.issue:
        return l10n?.issueDesc ??
            'Issue goods to customers or for internal use';
      case InventoryMovementType.transfer:
        return l10n?.transferDesc ??
            'Move goods between warehouses or locations';
      case InventoryMovementType.return_:
        return l10n?.returnDesc ?? 'Record goods returned from customers';
      case InventoryMovementType.adjustment:
        return l10n?.adjustmentDesc ??
            'Adjust inventory quantities (positive or negative)';
      case InventoryMovementType.production:
        return l10n?.productionDesc ?? 'Record goods produced in manufacturing';
      case InventoryMovementType.consumption:
        return l10n?.consumptionDesc ??
            'Record materials consumed in production';
      case InventoryMovementType.waste:
        return l10n?.wasteDesc ?? 'Record waste or scrap';
      case InventoryMovementType.expiry:
        return l10n?.expiryDesc ?? 'Record expired inventory write-off';
      case InventoryMovementType.qualityStatusChange:
        return l10n?.qualityStatusChangeDesc ??
            'Record quality status changes of inventory';
      case InventoryMovementType.repack:
        return l10n?.repackDesc ?? 'Repacking operations';
      case InventoryMovementType.sample:
        return l10n?.sampleDesc ?? 'Sample for quality testing';
      case InventoryMovementType.salesIssue:
        return l10n?.salesIssueDesc ?? 'Specific issue for sales order';
      case InventoryMovementType.purchaseReceipt:
        return l10n?.purchaseReceiptDesc ??
            'Specific receipt against purchase order';
      case InventoryMovementType.productionConsumption:
        return l10n?.productionConsumptionDesc ??
            'Consumption in production process';
      case InventoryMovementType.productionOutput:
        return l10n?.productionOutputDesc ?? 'Output from production process';
      case InventoryMovementType.interWarehouseTransfer:
        return l10n?.interWarehouseTransferDesc ??
            'Transfer between warehouses';
      case InventoryMovementType.intraWarehouseTransfer:
        return l10n?.intraWarehouseTransferDesc ??
            'Transfer within warehouse locations';
      case InventoryMovementType.scrapDisposal:
        return l10n?.scrapDisposalDesc ?? 'Scrapping of damaged goods';
      case InventoryMovementType.qualityHold:
        return l10n?.qualityHoldDesc ?? 'Quality hold/release operations';
      case InventoryMovementType.initialBalanceAdjustment:
        return l10n?.initialBalanceAdjustmentDesc ??
            'Initial balance adjustment';
      case InventoryMovementType.reservationAdjustment:
        return l10n?.reservationAdjustmentDesc ?? 'Reservation adjustments';
      case InventoryMovementType.poReceipt:
        return l10n?.poReceiptDesc ?? 'Purchase order receipt';
      case InventoryMovementType.transferIn:
        return l10n?.transferInDesc ?? 'Transfer in';
      case InventoryMovementType.productionIssue:
        return l10n?.productionIssueDesc ?? 'Production issue';
      case InventoryMovementType.salesReturn:
        return l10n?.salesReturnDesc ?? 'Sales return';
      case InventoryMovementType.adjustmentOther:
        return l10n?.adjustmentOtherDesc ?? 'Other adjustment';
      case InventoryMovementType.transferOut:
        return l10n?.transferOutDesc ?? 'Transfer out';
      case InventoryMovementType.saleShipment:
        return l10n?.saleShipmentDesc ?? 'Sale shipment';
      case InventoryMovementType.adjustmentDamage:
        return l10n?.adjustmentDamageDesc ?? 'Damage adjustment';
      case InventoryMovementType.adjustmentCycleCountGain:
        return l10n?.adjustmentCycleCountGainDesc ?? 'Cycle count gain';
      case InventoryMovementType.adjustmentCycleCountLoss:
        return l10n?.adjustmentCycleCountLossDesc ?? 'Cycle count loss';
      case InventoryMovementType.qualityStatusUpdate:
        return l10n?.qualityStatusUpdateDesc ?? 'Quality status update';
    }
  }

  bool _isInboundMovement(InventoryMovementType type) {
    return type == InventoryMovementType.receipt ||
        type == InventoryMovementType.return_ ||
        type == InventoryMovementType.production;
  }
}
