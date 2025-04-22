import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/transfer_stock_usecase.dart';
import '../providers/inventory_provider.dart';
import '../../domain/providers/inventory_provider.dart';

class InventoryTransferScreen extends ConsumerStatefulWidget {
  const InventoryTransferScreen({
    super.key,
    required this.sourceItemId,
  });
  final String sourceItemId;

  @override
  ConsumerState<InventoryTransferScreen> createState() =>
      _InventoryTransferScreenState();
}

class _InventoryTransferScreenState
    extends ConsumerState<InventoryTransferScreen> {
  InventoryItem? _sourceItem;
  InventoryItem? _destinationItem;
  List<InventoryItem> _compatibleItems = [];
  bool _isLoading = true;
  bool _isTransferring = false;

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(inventoryRepositoryProvider);

      // Load source item
      _sourceItem = await repository.getItem(widget.sourceItemId);

      // Load all items of the same type (same name, category, and unit)
      final allItems = await repository.getItems();

      _compatibleItems = allItems
          .where((item) =>
              item.id != widget.sourceItemId &&
              item.name == _sourceItem!.name &&
              item.category == _sourceItem!.category &&
              item.unit == _sourceItem!.unit)
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _transferStock() async {
    if (!_formKey.currentState!.validate() || _destinationItem == null) {
      return;
    }

    setState(() {
      _isTransferring = true;
    });

    try {
      final transferUseCase =
          TransferStockUseCase(ref.read(inventoryRepositoryProvider));

      await transferUseCase.execute(
        sourceItemId: widget.sourceItemId,
        destinationItemId: _destinationItem!.id,
        quantity: double.parse(_quantityController.text),
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer completed successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error transferring stock: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTransferring = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Stock'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source item card
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Source',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _sourceItem!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text('Category: ${_sourceItem!.category}'),
                            Text('Location: ${_sourceItem!.location}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Available: '),
                                Text(
                                  '${_sourceItem!.quantity} ${_sourceItem!.unit}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Destination item selection
                    if (_compatibleItems.isEmpty)
                      const Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No compatible items found for transfer. Create the same item in a different location first.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    else
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<InventoryItem>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Destination Location',
                                  border: OutlineInputBorder(),
                                ),
                                value: _destinationItem,
                                items: _compatibleItems.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child:
                                        Text('${item.name} (${item.location})'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _destinationItem = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a destination';
                                  }
                                  return null;
                                },
                              ),
                              if (_destinationItem != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                    'Current Stock: ${_destinationItem!.quantity} ${_destinationItem!.unit}'),
                              ],
                            ],
                          ),
                        ),
                      ),

                    // Transfer details
                    if (_compatibleItems.isNotEmpty)
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transfer Details',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _quantityController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Quantity to Transfer (${_sourceItem!.unit})',
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
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

                                  if (quantity > _sourceItem!.quantity) {
                                    return 'Cannot transfer more than available quantity';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _reasonController,
                                decoration: const InputDecoration(
                                  labelText: 'Reason for Transfer',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a reason';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _compatibleItems.isEmpty || _isTransferring
                            ? null
                            : _transferStock,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isTransferring
                            ? const CircularProgressIndicator()
                            : const Text('TRANSFER STOCK'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
