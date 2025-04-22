import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../../common/widgets/detail_appbar.dart';
import '../../../../../common/widgets/loading_overlay.dart';
import '../../../../../common/widgets/error_dialog.dart';
import '../../../../../utils/formatters/currency_formatter.dart';
import '../../../../../utils/validators/form_validators.dart';
import '../../../domain/entities/purchase_order.dart' hide SupportingDocument;
import '../../../domain/entities/purchase_order.dart' as purchase_order
    show SupportingDocument;
import '../../../../suppliers/domain/entities/supplier.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../../../domain/entities/supporting_document.dart';
import '../../../../../core/exceptions/result.dart';
import '../../providers/purchase_order_providers.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/document_attachment_picker.dart';
import '../../widgets/purchase_order_item_form.dart';
import '../../../../suppliers/presentation/providers/supplier_provider.dart';

class PurchaseOrderCreateScreen extends ConsumerStatefulWidget {
  const PurchaseOrderCreateScreen({super.key});

  @override
  ConsumerState<PurchaseOrderCreateScreen> createState() =>
      _PurchaseOrderCreateScreenState();
}

class _PurchaseOrderCreateScreenState
    extends ConsumerState<PurchaseOrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Form controllers
  final _reasonController = TextEditingController();
  final _intendedUseController = TextEditingController();
  final _quantityJustificationController = TextEditingController();

  // Form data
  String _selectedSupplierId = '';
  final List<PurchaseOrderItem> _items = [];
  final List<SupportingDocument> _supportingDocuments = [];
  bool _isCalculatingCoverage = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _intendedUseController.dispose();
    _quantityJustificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(allSuppliersProvider);
    final itemsAsync = ref.watch(inventoryItemsProvider);

    return Scaffold(
      appBar: DetailAppBar(
        title: 'Create Purchase Order',
      ),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Supplier Selection
                const Text(
                  'Supplier Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                suppliersAsync.when(
                  data: (suppliers) => _buildSupplierDropdown(suppliers),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Text('Error loading suppliers: $error'),
                ),
                const SizedBox(height: 24),

                // Items
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                itemsAsync.when(
                  data: (items) => _selectedSupplierId.isEmpty
                      ? const Text('Please select a supplier first')
                      : _buildItemsList(items),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Text('Error loading items: $error'),
                ),
                const SizedBox(height: 24),

                // Order Information Fields
                const Text(
                  'Order Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Request *',
                    hintText: 'Why is this purchase necessary?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: FormValidators.required('Reason is required'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _intendedUseController,
                  decoration: const InputDecoration(
                    labelText: 'Intended Use *',
                    hintText: 'How will these materials be used?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator:
                      FormValidators.required('Intended use is required'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityJustificationController,
                  decoration: InputDecoration(
                    labelText: 'Quantity Justification *',
                    hintText: 'Justify the requested quantities',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isCalculatingCoverage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.calculate),
                            tooltip: 'Auto-calculate coverage period',
                            onPressed: _calculateCoveragePeriod,
                          ),
                  ),
                  maxLines: 3,
                  validator: FormValidators.required(
                      'Quantity justification is required'),
                ),
                const SizedBox(height: 24),

                // Supporting Documents
                const Text(
                  'Supporting Documents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DocumentAttachmentPicker(
                  documents: _supportingDocuments,
                  onDocumentsChanged: (docs) {
                    setState(() {
                      _supportingDocuments.clear();
                      _supportingDocuments.addAll(docs);
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Summary
                _buildOrderSummary(),
                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPurchaseOrder,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Submit Purchase Order'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown(List<Supplier> suppliers) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Supplier *',
        border: OutlineInputBorder(),
      ),
      value: _selectedSupplierId.isEmpty ? null : _selectedSupplierId,
      items: suppliers.map((supplier) {
        return DropdownMenuItem<String>(
          value: supplier.id,
          child: Text(supplier.name),
        );
      }).toList(),
      validator: FormValidators.required('Please select a supplier'),
      onChanged: (value) {
        setState(() {
          _selectedSupplierId = value ?? '';
          // Clear items when supplier changes
          _items.clear();
        });
      },
    );
  }

  Widget _buildItemsList(List<InventoryItem> allItems) {
    // Filter items for the selected supplier
    final supplierItems = allItems
        .where((item) => item.supplierIds.contains(_selectedSupplierId))
        .toList();

    if (supplierItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No items available from this supplier'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display current items
        ..._items.map((item) => PurchaseOrderItemForm(
              item: item,
              onUpdate: (updatedItem) {
                setState(() {
                  final index = _items.indexWhere((i) => i.id == item.id);
                  if (index >= 0 && updatedItem != null) {
                    _items[index] = updatedItem as PurchaseOrderItem;
                  }
                });
              },
              onRemove: () {
                setState(() {
                  _items.removeWhere((i) => i.id == item.id);
                });
              },
            )),

        // Add item button
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          onPressed: () => _showAddItemDialog(supplierItems),
        ),
      ],
    );
  }

  void _showAddItemDialog(List<InventoryItem> availableItems) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedItemId = '';
        double quantity = 0;
        final quantityController = TextEditingController();
        final notesController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Item',
                    border: OutlineInputBorder(),
                  ),
                  items: availableItems.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedItemId = value ?? '';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantity = double.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedItemId.isEmpty || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please select an item and enter a valid quantity')),
                  );
                  return;
                }

                final item = availableItems
                    .firstWhere((item) => item.id == selectedItemId);
                final newItem = PurchaseOrderItem(
                  id: _uuid.v4(),
                  itemId: item.id,
                  itemName: item.name,
                  quantity: quantity,
                  unit: item.unit,
                  unitPrice: item.price,
                  totalPrice: quantity * item.price,
                  requiredByDate: DateTime.now().add(const Duration(days: 14)),
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                setState(() {
                  _items.add(newItem);
                });

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderSummary() {
    double totalAmount = 0;
    for (final item in _items) {
      totalAmount += item.totalPrice;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text('Total Items: ${_items.length}'),
            const SizedBox(height: 8),
            Text('Total Amount: ${CurrencyFormatter.format(totalAmount)}'),
          ],
        ),
      ),
    );
  }

  void _calculateCoveragePeriod() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items first')),
      );
      return;
    }

    setState(() {
      _isCalculatingCoverage = true;
    });

    try {
      final usageRates = await ref.read(usageRateProvider).getItemUsageRates(
            _items.map((item) => item.itemId).toList(),
          );

      final buffer = StringBuffer();
      buffer.writeln('Quantities are based on the following production needs:');

      for (final item in _items) {
        final rate = usageRates[item.itemId];
        if (rate != null && rate > 0) {
          final months = (item.quantity / rate).toStringAsFixed(1);
          buffer.writeln('- ${item.itemName}: ${item.quantity} ${item.unit} '
              '(estimated to cover $months months of production)');
        } else {
          buffer.writeln('- ${item.itemName}: ${item.quantity} ${item.unit} '
              '(no usage data available)');
        }
      }

      _quantityJustificationController.text = buffer.toString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating coverage: $e')),
      );
    } finally {
      setState(() {
        _isCalculatingCoverage = false;
      });
    }
  }

  void _submitPurchaseOrder() async {
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
      _isSubmitting = true;
    });

    try {
      final supplierDetailAsync =
          ref.read(supplierProvider(_selectedSupplierId));
      final supplier = await supplierDetailAsync.valueOrNull;

      if (supplier == null) {
        throw Exception('Supplier not found');
      }

      final poNumber =
          'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final username = 'TODO-username'; // TODO: Integrate user context
      double totalAmount = _items.fold(0, (sum, item) => sum + item.totalPrice);

      // Convert SupportingDocument to purchase_order.SupportingDocument
      final convertedDocs = _supportingDocuments
          .map((doc) => purchase_order.SupportingDocument(
                id: doc.id,
                name: doc.name,
                type: doc.type.toString().split('.').last,
                url: doc.url,
                uploadDate: doc.uploadDate,
              ))
          .toList();

      final purchaseOrder = PurchaseOrder(
        id: _uuid.v4(),
        procurementPlanId: 'manual-entry', // For manually created POs
        poNumber: poNumber,
        requestDate: DateTime.now(),
        requestedBy: username,
        supplierId: _selectedSupplierId,
        supplierName: supplier.name,
        status: PurchaseOrderStatus.draft,
        items: _items,
        totalAmount: totalAmount,
        reasonForRequest: _reasonController.text,
        intendedUse: _intendedUseController.text,
        quantityJustification: _quantityJustificationController.text,
        supportingDocuments: convertedDocs,
      );

      final result = await ref
          .read(purchaseOrderDetailNotifierProvider(purchaseOrder.id).notifier)
          .createPurchaseOrder(purchaseOrder);

      if (result is Result<PurchaseOrder>) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Purchase order created successfully')),
          );
          context.pop();
        } else {
          showErrorDialog(
            context: context,
            title: 'Error Creating Purchase Order',
            message: result.failure?.message ?? 'Unknown error occurred',
          );
        }
      }
    } catch (e) {
      showErrorDialog(
        context: context,
        title: 'Error',
        message: 'Failed to create purchase order: $e',
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
