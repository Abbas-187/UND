import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../../common/widgets/detail_appbar.dart';
import '../../../../../common/widgets/loading_overlay.dart';
import '../../../../../domain/entities/supporting_document.dart';
import '../../../../../utils/formatters/currency_formatter.dart';
import '../../../../../utils/validators/form_validators.dart';
import '../../../../inventory/domain/entities/inventory_item.dart' as invitem;
import '../../../../suppliers/domain/entities/supplier.dart';
import '../../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../../domain/entities/inventory_item.dart' as pitem;
import '../../../domain/entities/purchase_order.dart' hide SupportingDocument;
import '../../../domain/utils/inventory_item_mapper.dart';
import '../../data/in_memory_purchase_requests.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/document_attachment_picker.dart';
import '../../widgets/purchase_order_item_form.dart';

class PurchaseOrderCreateScreen extends ConsumerStatefulWidget {
  const PurchaseOrderCreateScreen(
      {super.key,
      this.initialItem,
      this.initialQuantity,
      this.initialSupplier});
  final dynamic initialItem;
  final double? initialQuantity;
  final String? initialSupplier;

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
  bool _includeVAT = false;
  static const double _vatRate = 0.15;

  @override
  void initState() {
    super.initState();
    // Prefill from initialItem/quantity/supplier if provided
    if (widget.initialItem != null && widget.initialQuantity != null) {
      final item = widget.initialItem;
      _items.add(PurchaseOrderItem(
        id: _uuid.v4(),
        itemId: item.id,
        itemName: item.name,
        quantity: widget.initialQuantity!,
        unit: item.unit,
        unitPrice: item.cost ?? 0,
        totalPrice: (widget.initialQuantity! * (item.cost ?? 0)),
        requiredByDate: DateTime.now().add(const Duration(days: 14)),
        notes: null,
      ));
    }
    if (widget.initialSupplier != null) {
      _selectedSupplierId = widget.initialSupplier!;
    }
  }

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
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;
    final hasInitialItem =
        widget.initialItem != null && widget.initialQuantity != null;
    return Scaffold(
      appBar: DetailAppBar(
        title: 'Create Purchase Order',
      ),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F7FA), Color(0xFFE4ECF7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Scrollable form content
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: MediaQuery.of(context).padding.top +
                                  kToolbarHeight +
                                  8,
                              bottom: 16,
                            ),
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Ordered Items
                                    _SectionCard(
                                      color: Colors.green.shade700,
                                      icon: Icons.shopping_cart,
                                      title: 'Order Items',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: itemsAsync.when(
                                          data: (items) {
                                            return _buildItemsList(
                                                items, hasInitialItem);
                                          },
                                          loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          error: (error, stackTrace) => Text(
                                              'Error loading items: $error'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // 2. Supplier
                                    _SectionCard(
                                      color: Colors.blue.shade700,
                                      icon: Icons.business,
                                      title: 'Supplier Information',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: suppliersAsync.when(
                                          data: (suppliers) =>
                                              _buildSupplierDropdown(suppliers),
                                          loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          error: (error, stackTrace) => Text(
                                              'Error loading suppliers: $error'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // 3. Order Information
                                    _SectionCard(
                                      color: Colors.purple.shade700,
                                      icon: Icons.description,
                                      title: 'Order Information',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Column(
                                          children: [
                                            _ThemedTextField(
                                              controller: _reasonController,
                                              label: 'Reason for Request *',
                                              hint:
                                                  'Why is this purchase necessary?',
                                              icon: Icons.help_outline,
                                              validator:
                                                  FormValidators.required(
                                                      'Reason is required'),
                                            ),
                                            const SizedBox(height: 8),
                                            _ThemedTextField(
                                              controller:
                                                  _intendedUseController,
                                              label: 'Intended Use *',
                                              hint:
                                                  'How will these materials be used?',
                                              icon: Icons.lightbulb_outline,
                                              validator: FormValidators.required(
                                                  'Intended use is required'),
                                            ),
                                            const SizedBox(height: 8),
                                            _ThemedTextField(
                                              controller:
                                                  _quantityJustificationController,
                                              label: 'Quantity Justification *',
                                              hint:
                                                  'Justify the requested quantities',
                                              icon: Icons.calculate,
                                              maxLines: 3,
                                              suffix: _isCalculatingCoverage
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2))
                                                  : IconButton(
                                                      icon: const Icon(
                                                          Icons.auto_awesome),
                                                      tooltip:
                                                          'Auto-calculate coverage period',
                                                      onPressed:
                                                          _calculateCoveragePeriod,
                                                    ),
                                              validator: FormValidators.required(
                                                  'Quantity justification is required'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // 4. Attachments
                                    _SectionCard(
                                      color: Colors.amber.shade700,
                                      icon: Icons.attach_file,
                                      title: 'Supporting Documents',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: DocumentAttachmentPicker(
                                          documents: _supportingDocuments,
                                          onDocumentsChanged: (docs) {
                                            setState(() {
                                              _supportingDocuments.clear();
                                              _supportingDocuments.addAll(docs);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Center(
                                      child: SizedBox(
                                        width: 220,
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 22),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            foregroundColor:
                                                theme.colorScheme.onPrimary,
                                            elevation: 3,
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: _submitPurchaseOrder,
                                          label: const Text(
                                              'Submit Purchase Order'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Right: Pinned summary
                        SizedBox(
                          width: 340,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16, right: 8, left: 8),
                            child: _PinnedOrderSummary(
                              items: _items,
                              includeVAT: _includeVAT,
                              onVATChanged: (val) {
                                setState(() {
                                  _includeVAT = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: MediaQuery.of(context).padding.top +
                            kToolbarHeight +
                            8,
                        bottom: 16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Ordered Items
                            _SectionCard(
                              color: Colors.green.shade700,
                              icon: Icons.shopping_cart,
                              title: 'Order Items',
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: itemsAsync.when(
                                  data: (items) {
                                    return _buildItemsList(
                                        items, hasInitialItem);
                                  },
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (error, stackTrace) =>
                                      Text('Error loading items: $error'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 2. Supplier
                            _SectionCard(
                              color: Colors.blue.shade700,
                              icon: Icons.business,
                              title: 'Supplier Information',
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: suppliersAsync.when(
                                  data: (suppliers) =>
                                      _buildSupplierDropdown(suppliers),
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (error, stackTrace) =>
                                      Text('Error loading suppliers: $error'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 3. Order Information
                            _SectionCard(
                              color: Colors.purple.shade700,
                              icon: Icons.description,
                              title: 'Order Information',
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  children: [
                                    _ThemedTextField(
                                      controller: _reasonController,
                                      label: 'Reason for Request *',
                                      hint: 'Why is this purchase necessary?',
                                      icon: Icons.help_outline,
                                      validator: FormValidators.required(
                                          'Reason is required'),
                                    ),
                                    const SizedBox(height: 8),
                                    _ThemedTextField(
                                      controller: _intendedUseController,
                                      label: 'Intended Use *',
                                      hint: 'How will these materials be used?',
                                      icon: Icons.lightbulb_outline,
                                      validator: FormValidators.required(
                                          'Intended use is required'),
                                    ),
                                    const SizedBox(height: 8),
                                    _ThemedTextField(
                                      controller:
                                          _quantityJustificationController,
                                      label: 'Quantity Justification *',
                                      hint: 'Justify the requested quantities',
                                      icon: Icons.calculate,
                                      maxLines: 3,
                                      suffix: _isCalculatingCoverage
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2))
                                          : IconButton(
                                              icon: const Icon(
                                                  Icons.auto_awesome),
                                              tooltip:
                                                  'Auto-calculate coverage period',
                                              onPressed:
                                                  _calculateCoveragePeriod,
                                            ),
                                      validator: FormValidators.required(
                                          'Quantity justification is required'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 4. Attachments
                            _SectionCard(
                              color: Colors.amber.shade700,
                              icon: Icons.attach_file,
                              title: 'Supporting Documents',
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: DocumentAttachmentPicker(
                                  documents: _supportingDocuments,
                                  onDocumentsChanged: (docs) {
                                    setState(() {
                                      _supportingDocuments.clear();
                                      _supportingDocuments.addAll(docs);
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: SizedBox(
                                width: 220,
                                height: 48,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline,
                                      size: 22),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    elevation: 3,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: _submitPurchaseOrder,
                                  label: const Text('Submit Purchase Order'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _PinnedOrderSummary(
                              items: _items,
                              includeVAT: _includeVAT,
                              onVATChanged: (val) {
                                setState(() {
                                  _includeVAT = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown(List<Supplier> suppliers) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Supplier',
        border: OutlineInputBorder(),
      ),
      value: _selectedSupplierId.isEmpty ? null : _selectedSupplierId,
      items: suppliers.map((supplier) {
        return DropdownMenuItem<String>(
          value: supplier.id,
          child: Text(supplier.name),
        );
      }).toList(),
      // Supplier is now optional
      onChanged: (value) {
        setState(() {
          _selectedSupplierId = value ?? '';
          // Clear items when supplier changes
          _items.clear();
        });
      },
    );
  }

  Widget _buildItemsList(
      List<invitem.InventoryItem> allItems, bool hasInitialItem) {
    // Otherwise, allow adding/removing items
    final supplierItems = allItems
        .where((item) =>
            item.supplier != null && item.supplier == _selectedSupplierId)
        .map((item) => mapInventoryToProcurement(item))
        .toList();

    // Determine if there are any requested items from the same category or subcategory
    bool hasRequestedFromSameCatOrSubcat = false;
    if (allItems.isNotEmpty) {
      for (final item in allItems) {
        final itemCat = item.category;
        final itemSubCat = item.subCategory;
        final exists = InMemoryPurchaseRequests.requests.any((req) {
          final reqItem = req['item'];
          return reqItem?.category == itemCat ||
              reqItem?.subCategory == itemSubCat;
        });
        if (exists) {
          hasRequestedFromSameCatOrSubcat = true;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._items.map((item) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PurchaseOrderItemForm(
                    item: item,
                    onUpdate: (updatedItem) {
                      setState(() {
                        final index = _items.indexWhere((i) => i.id == item.id);
                        if (index >= 0) {
                          _items[index] = updatedItem;
                        }
                      });
                    },
                    onRemove: () {
                      setState(() {
                        _items.removeWhere((i) => i.id == item.id);
                      });
                    },
                    currencySymbol: '﷼',
                  ),
                ),
                // Add + button for adding more items with the same subcategory
                IconButton(
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                  tooltip:
                      'Add item from requests (choose, then filter by subcat/supplier)',
                  onPressed: () async {
                    // Step 1: Show all requested items
                    final allRequested = InMemoryPurchaseRequests.requests
                        .map((req) => req['item'] as invitem.InventoryItem)
                        .toList();
                    if (allRequested.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No requested items available.')),
                      );
                      return;
                    }
                    final selectedRequested =
                        await showDialog<invitem.InventoryItem>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Select Requested Item'),
                        children: allRequested
                            .map((item) => SimpleDialogOption(
                                  child: Text(item.name),
                                  onPressed: () =>
                                      Navigator.of(context).pop(item),
                                ))
                            .toList(),
                      ),
                    );
                    if (selectedRequested == null) return;

                    // Step 2: Filter requests for those with same subcat or category as the current PO item (no inventory lookup)
                    final selectedSubCat = selectedRequested.subCategory;
                    final selectedCat = selectedRequested.category;
                    final filtered = InMemoryPurchaseRequests.requests
                        .where((req) {
                          final reqItem = req['item'] as invitem.InventoryItem;
                          // Match by subcategory, or fallback to category if subcategory does not match
                          if (reqItem.subCategory == selectedSubCat) {
                            return true;
                          }
                          // Fallback: match by category
                          return reqItem.category == selectedCat;
                        })
                        .map((req) => req['item'] as invitem.InventoryItem)
                        .toList();
                    if (filtered.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'No requested items match this item by subcategory or category.')),
                      );
                      return;
                    }
                    final selectedFiltered = filtered.length == 1
                        ? filtered.first
                        : await showDialog<invitem.InventoryItem>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text(
                                  'Select Item (Same Subcat/Category)'),
                              children: filtered
                                  .map((item) => SimpleDialogOption(
                                        child: Text(item.name),
                                        onPressed: () =>
                                            Navigator.of(context).pop(item),
                                      ))
                                  .toList(),
                            ),
                          );
                    if (selectedFiltered != null) {
                      _showAddRequestedItemDialog(selectedFiltered);
                    }
                  },
                ),
              ],
            )),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          onPressed: () async {
            // Find all requested items that match any inventory item's category or supplier
            final List<invitem.InventoryItem> matches = [];
            for (final req in InMemoryPurchaseRequests.requests) {
              final reqItem = req['item'];
              final reqSupplier = req['supplier'];
              final reqCat = reqItem?.category;
              final reqSubCat = reqItem?.subCategory;
              final found = allItems.any((inv) =>
                  inv.category == reqCat ||
                  inv.subCategory == reqSubCat ||
                  (inv.supplier != null && inv.supplier == reqSupplier));
              if (found) {
                matches.add(reqItem);
              }
            }
            if (matches.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'No requested items match any inventory item by category or supplier.')),
              );
              return;
            }
            // If only one match, add it directly
            if (matches.length == 1) {
              _showAddRequestedItemDialog(matches.first);
              return;
            }
            // If multiple, show a dialog to select
            final selected = await showDialog<invitem.InventoryItem>(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text('Select Requested Item to Add'),
                children: matches
                    .map((item) => SimpleDialogOption(
                          child: Text(item.name),
                          onPressed: () => Navigator.of(context).pop(item),
                        ))
                    .toList(),
              ),
            );
            if (selected != null) {
              _showAddRequestedItemDialog(selected);
            }
          },
        ),
      ],
    );
  }

  void _showAddItemDialog(List<pitem.InventoryItem> availableItems) {
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
              onPressed: () async {
                if (selectedItemId.isEmpty || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Please select an item and enter a valid quantity')),
                  );
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) Navigator.of(context).pop();
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

  void _showAddRequestedItemDialog(invitem.InventoryItem baseItem) async {
    // Find matching requests by subcategory and not already in PO
    final existingItemIds = _items.map((i) => i.itemId).toSet();
    final requests = InMemoryPurchaseRequests.requests.where((req) {
      final reqItem = req['item'];
      // Defensive: check subCategory property
      final reqSubCat = reqItem?.subCategory ?? '';
      final baseSubCat = baseItem.subCategory ?? '';
      return reqSubCat == baseSubCat && !existingItemIds.contains(reqItem.id);
    }).toList();

    if (requests.isEmpty) {
      // Show message: no matching items
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No matching requests'),
            content: const Text(
                'No requested items with the same subcategory. Please add items manually.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Add Item (Subcategory: ${baseItem.subCategory})'),
        children: requests
            .map<Widget>((req) => SimpleDialogOption(
                  child: Text(req['item'].name),
                  onPressed: () => Navigator.of(context).pop(req),
                ))
            .toList(),
      ),
    );

    if (selected != null) {
      final reqItem = selected['item'];
      final reqQty = selected['quantity'] ?? 1.0;
      final reqSupplier = selected['supplier'];
      setState(() {
        _items.add(PurchaseOrderItem(
          id: _uuid.v4(),
          itemId: reqItem.id,
          itemName: reqItem.name,
          quantity: reqQty is num ? reqQty.toDouble() : 1.0,
          unit: reqItem.unit,
          unitPrice: reqItem.cost ?? 0,
          totalPrice:
              (reqQty is num ? reqQty.toDouble() : 1.0) * (reqItem.cost ?? 0),
          requiredByDate: DateTime.now().add(const Duration(days: 14)),
          notes: null,
        ));
        // Remove from requests
        InMemoryPurchaseRequests.requests
            .removeWhere((r) => r['item'].id == reqItem.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added item: ${reqItem.name}')),
        );
      }
    }
  }

  Widget _buildOrderSummary() {
    double totalAmount = 0;
    for (final item in _items) {
      totalAmount += item.totalPrice;
    }
    double vat = _includeVAT ? totalAmount * _vatRate : 0;
    double grandTotal = totalAmount + vat;
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
            Text('Subtotal: ${CurrencyFormatter.format(totalAmount)} ﷼'),
            if (_includeVAT) ...[
              const SizedBox(height: 4),
              Text('VAT (15%): ${CurrencyFormatter.format(vat)} ﷼',
                  style: const TextStyle(color: Colors.teal)),
            ],
            const SizedBox(height: 8),
            Text('Total: ${CurrencyFormatter.format(grandTotal)} ﷼',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      // In-memory PO creation
      final poNumber =
          'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final username = 'TODO-username'; // TODO: Integrate user context
      double totalAmount = _items.fold(0, (sum, item) => sum + item.totalPrice);

      final purchaseOrder = {
        'id': _uuid.v4(),
        'poNumber': poNumber,
        'requestDate': DateTime.now(),
        'requestedBy': username,
        'supplierId': _selectedSupplierId,
        'supplierName': _selectedSupplierId,
        'status': 'draft',
        'items': _items,
        'totalAmount': totalAmount,
        'reasonForRequest': _reasonController.text,
        'intendedUse': _intendedUseController.text,
        'quantityJustification': _quantityJustificationController.text,
        'supportingDocuments': _supportingDocuments,
      };
      InMemoryPurchaseOrders.orders.add(purchaseOrder);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Submitted'),
            content: const Text(
                'The purchase order has been submitted. You can track its status in the Purchase Orders list.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        // Navigate to requested purchase orders screen
        if (mounted) {
          context.go('/procurement/requested-purchase-orders');
        }
        // Optionally reset the form for a new order
        setState(() {
          _items.clear();
          _selectedSupplierId = '';
          _reasonController.clear();
          _intendedUseController.clear();
          _quantityJustificationController.clear();
          _supportingDocuments.clear();
          _includeVAT = false;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to create purchase order: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.child,
  });
  final Color color;
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemedTextField extends StatelessWidget {
  const _ThemedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 2,
    this.suffix,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.primary.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

// Add a new widget for the pinned summary
class _PinnedOrderSummary extends StatelessWidget {
  const _PinnedOrderSummary({
    required this.items,
    required this.includeVAT,
    required this.onVATChanged,
  });
  final List<PurchaseOrderItem> items;
  final bool includeVAT;
  final ValueChanged<bool> onVATChanged;

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;
    for (final item in items) {
      totalAmount += item.totalPrice;
    }
    double vat = includeVAT ? totalAmount * 0.15 : 0;
    double grandTotal = totalAmount + vat;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.summarize, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text('Order Summary',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            Text('Items: ${items.length}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(item.itemName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('${item.quantity} ${item.unit}',
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('${item.unitPrice.toStringAsFixed(2)} ﷼',
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('${item.totalPrice.toStringAsFixed(2)} ﷼',
                            textAlign: TextAlign.end,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            const Divider(),
            Text('Subtotal: ${totalAmount.toStringAsFixed(2)} ﷼'),
            if (includeVAT) ...[
              const SizedBox(height: 4),
              Text('VAT (15%): ${vat.toStringAsFixed(2)} ﷼',
                  style: const TextStyle(color: Colors.teal)),
            ],
            const SizedBox(height: 8),
            Text('Total: ${grandTotal.toStringAsFixed(2)} ﷼',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: includeVAT,
                  onChanged: (val) => onVATChanged(val ?? false),
                ),
                const Text('Include VAT (15%)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
