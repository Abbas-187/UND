import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/searchable_dropdown.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

class PurchaseRequestCreateScreen extends ConsumerStatefulWidget { // Should be InventoryItem, but dynamic for now
  const PurchaseRequestCreateScreen({super.key, this.item});
  final dynamic item;

  @override
  ConsumerState<PurchaseRequestCreateScreen> createState() =>
      _PurchaseRequestCreateScreenState();
}

class _PurchaseRequestCreateScreenState
    extends ConsumerState<PurchaseRequestCreateScreen> {
  int _step = 0;
  dynamic _selectedItem;
  String? _selectedSupplier;
  late TextEditingController _quantityController;
  late TextEditingController _safetyStockController;
  late TextEditingController _justificationController;
  String? _error;
  bool _isLoading = false;
  bool _showSuccess = false;
  List<String> _availableSuppliers = [];

  @override
  void initState() {
    super.initState();
    _justificationController = TextEditingController();
    if (widget.item != null) {
      _selectedItem = widget.item;
      _selectedSupplier = widget.item.supplier;
      _quantityController = TextEditingController(
          text: _suggestQuantity(widget.item).suggestedQuantity.toString());
      _safetyStockController = TextEditingController(
          text: _suggestQuantity(widget.item).safetyStock?.toString() ?? '');
      _availableSuppliers =
          widget.item.supplier != null ? [widget.item.supplier] : [];
    } else {
      _quantityController = TextEditingController();
      _safetyStockController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _safetyStockController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  void _onItemSelected(dynamic item) {
    setState(() {
      _selectedItem = item;
      _quantityController.text =
          _suggestQuantity(item).suggestedQuantity.toString();
      _safetyStockController.text =
          _suggestQuantity(item).safetyStock?.toString() ?? '';
      // Handle suppliers
      if (item.supplier != null && item.supplier is String) {
        _availableSuppliers = [item.supplier];
        _selectedSupplier = item.supplier;
      } else if (item.supplierIds != null &&
          item.supplierIds is List &&
          item.supplierIds.length > 1) {
        _availableSuppliers = List<String>.from(item.supplierIds);
        _selectedSupplier = null;
      } else {
        _availableSuppliers = [];
        _selectedSupplier = null;
      }
    });
  }

  void _onSupplierSelected(String supplier) {
    setState(() {
      _selectedSupplier = supplier;
    });
  }

  bool get _isPrefilled => widget.item != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allItemsAsync = ref.watch(allInventoryItemsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Purchase Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      body: Stack(
        children: [
          // Soft gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F7FA), Color(0xFFE4ECF7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _step,
              onStepContinue: () {
                if (_step == 0 && !_isPrefilled && _selectedItem == null) {
                  return;
                }
                if (_step == 1 &&
                    (_quantityController.text.isEmpty ||
                        _safetyStockController.text.isEmpty)) {
                  return;
                }
                if (_step == 2) {
                  _submit();
                  return;
                }
                setState(() => _step++);
              },
              onStepCancel: () {
                if (_step > 0) setState(() => _step--);
              },
              controlsBuilder: (context, details) {
                return Row(
                  children: <Widget>[
                    if (_step < 2)
                      ElevatedButton.icon(
                        icon: Icon(
                            _step == 1 ? Icons.check : Icons.arrow_forward),
                        label: Text(_step == 1 ? 'Review' : 'Next'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: _step == 1
                              ? Colors.green.shade600
                              : Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                        onPressed: details.onStepContinue,
                      ),
                    if (_step > 0)
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.blueGrey),
                        label: const Text('Back',
                            style: TextStyle(color: Colors.blueGrey)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                        ),
                        onPressed: details.onStepCancel,
                      ),
                  ],
                );
              },
              steps: [
                Step(
                  title: Row(
                    children: const [
                      Icon(Icons.inventory_2, color: Color(0xFF1976D2)),
                      SizedBox(width: 8),
                      Text('Select Item'),
                    ],
                  ),
                  isActive: _step >= 0,
                  state: _step > 0 ? StepState.complete : StepState.indexed,
                  content: _isPrefilled
                      ? _buildSummaryCard(_selectedItem, theme)
                      : allItemsAsync.when(
                          data: (items) => Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SearchableDropdown(
                                items: items,
                                itemLabel: (item) =>
                                    '${item.name} (${item.sapCode})',
                                onSelected: (item) => _onItemSelected(item),
                                hintText: 'Search item by name, SAP code, etc.',
                              ),
                            ),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Error: $e'),
                        ),
                ),
                Step(
                  title: Row(
                    children: const [
                      Icon(Icons.edit, color: Color(0xFFFF9800)),
                      SizedBox(width: 8),
                      Text('Details'),
                    ],
                  ),
                  isActive: _step >= 1,
                  state: _step > 1 ? StepState.complete : StepState.indexed,
                  content: (_selectedItem != null || _isPrefilled)
                      ? Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSummaryCard(_selectedItem, theme),
                                if (_availableSuppliers.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: SearchableDropdown<String>(
                                      items: _availableSuppliers,
                                      itemLabel: (s) => s,
                                      onSelected: _onSupplierSelected,
                                      hintText: 'Select supplier',
                                      initialValue: _selectedSupplier,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Quantity',
                                    prefixIcon: const Icon(Icons.numbers),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                    helperText: 'Enter the quantity to request',
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.blue.shade400,
                                          width: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _safetyStockController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Safety Stock',
                                    prefixIcon: const Icon(Icons.security),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.orange.shade50,
                                    helperText:
                                        'If not set, please enter a value',
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.orange.shade400,
                                          width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Step(
                  title: Row(
                    children: const [
                      Icon(Icons.comment, color: Color(0xFF43A047)),
                      SizedBox(width: 8),
                      Text('Justification'),
                    ],
                  ),
                  isActive: _step >= 2,
                  state: StepState.indexed,
                  content: (_selectedItem != null || _isPrefilled) && _step >= 2
                      ? Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _justificationController,
                                  decoration: InputDecoration(
                                    labelText: 'Justification (optional)',
                                    prefixIcon: const Icon(Icons.info_outline),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.green.shade50,
                                    helperText:
                                        'Why is this purchase needed? (optional)',
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.green.shade400,
                                          width: 2),
                                    ),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.send),
                                    label: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Text('Submit Purchase Request'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade600,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(200, 48),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 3,
                                    ),
                                    onPressed: _isLoading ? null : _submit,
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 12),
                                  Text(_error!,
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ],
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          if (_showSuccess)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade100, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 96),
                      const SizedBox(height: 24),
                      const Text(
                        'Purchase request submitted!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(dynamic item, ThemeData theme) {
    if (item == null) return const SizedBox.shrink();
    final isLowStock = item.quantity <= item.minimumQuantity;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.blueGrey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900)),
                const SizedBox(width: 8),
                if (isLowStock)
                  Chip(
                    label: const Text('Low Stock'),
                    backgroundColor: Colors.red.shade100,
                    labelStyle: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _infoChip(Icons.qr_code, 'SAP: ${item.sapCode ?? '-'}',
                    Colors.blue.shade100),
                _infoChip(Icons.code, 'App: ${item.appItemId ?? '-'}',
                    Colors.blueGrey.shade100),
                _infoChip(Icons.category, 'Cat: ${item.category ?? '-'}',
                    Colors.orange.shade100),
                _infoChip(Icons.straighten, 'Unit: ${item.unit ?? '-'}',
                    Colors.blue.shade50),
                _infoChip(Icons.inventory, 'Stock: ${item.quantity}',
                    Colors.green.shade100),
                _infoChip(Icons.warning, 'Min: ${item.minimumQuantity}',
                    Colors.red.shade50),
                _infoChip(Icons.repeat, 'ROP: ${item.reorderPoint}',
                    Colors.purple.shade100),
                _infoChip(Icons.security, 'Safety: ${item.safetyStock ?? '-'}',
                    Colors.orange.shade100),
                _infoChip(
                    Icons.local_shipping,
                    'Supplier: ${_selectedSupplier ?? item.supplier ?? '-'}',
                    Colors.purple.shade100),
                _infoChip(Icons.location_on, 'Loc: ${item.location ?? '-'}',
                    Colors.blueGrey.shade50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.blueGrey.shade700),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      elevation: 1,
    );
  }

  _PurchaseSuggestion _suggestQuantity(dynamic item) {
    final double rop = (item.reorderPoint ?? 0).toDouble();
    final double? safetyStock =
        item.safetyStock != null ? (item.safetyStock as num).toDouble() : null;
    final double currentStock = (item.quantity ?? 0).toDouble();

    double targetLevel = rop + (safetyStock ?? 0);
    double suggested = targetLevel - currentStock;
    if (suggested < 0) suggested = 0;

    return _PurchaseSuggestion(
      suggestedQuantity: suggested,
      safetyStock: safetyStock,
    );
  }

  void _submit() async {
    final qty = double.tryParse(_quantityController.text);
    final safety = double.tryParse(_safetyStockController.text);
    if (qty == null || qty <= 0) {
      setState(() => _error = 'Please enter a valid quantity.');
      return;
    }
    if (safety == null || safety <= 0) {
      setState(() => _error = 'Please enter a valid safety stock.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final item = _selectedItem;
      // Store the request in memory instead of submitting to Firestore
      InMemoryPurchaseRequests.requests.add({
        'item': item,
        'quantity': qty,
        'safetyStock': safety,
        'justification': _justificationController.text,
        'supplier': _selectedSupplier ?? item.supplier,
        'timestamp': DateTime.now(),
      });
      setState(() => _showSuccess = false); // Hide overlay if shown
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Submitted'),
          content: const Text(
              'The purchase requisition has been submitted and the procurement department will be notified.\n\nYou can track your requests in the Requested Purchase Orders screen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      // Optionally clear the form for a new request
      setState(() {
        _step = 0;
        _selectedItem = null;
        _selectedSupplier = null;
        _quantityController.clear();
        _safetyStockController.clear();
        _justificationController.clear();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to submit: \\${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _PurchaseSuggestion {
  _PurchaseSuggestion({required this.suggestedQuantity, this.safetyStock});
  final double suggestedQuantity;
  final double? safetyStock;
}

// Move this to the top-level so it can be imported elsewhere
class InMemoryPurchaseRequests {
  static final List<Map<String, dynamic>> requests = [];
}
