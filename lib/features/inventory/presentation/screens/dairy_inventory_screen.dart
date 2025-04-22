import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/dairy_inventory_repository.dart';
import '../../domain/entities/inventory_item.dart';

class DairyInventoryScreen extends ConsumerStatefulWidget {
  const DairyInventoryScreen({super.key});

  @override
  ConsumerState<DairyInventoryScreen> createState() =>
      _DairyInventoryScreenState();
}

class _DairyInventoryScreenState extends ConsumerState<DairyInventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  bool _showLowStock = false;
  bool _showExpiring = false;

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(dairyInventoryRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dairy Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _confirmReset(repository),
            tooltip: 'Reset Inventory',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search dairy products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<InventoryItem>>(
              future: _getFilteredItems(repository),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items found.'),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildInventoryCard(item, repository);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInventoryDialog(context, repository),
        child: const Icon(Icons.add),
        tooltip: 'Add Dairy Product',
      ),
    );
  }

  Future<List<InventoryItem>> _getFilteredItems(
      DairyInventoryRepository repository) async {
    List<InventoryItem> items = await repository.getItems();

    // Load all categories if first time
    if (_categories.length <= 1) {
      final categories = items.map((item) => item.category).toSet().toList();
      categories.sort();
      setState(() {
        _categories = ['All', ...categories];
      });
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      items =
          items.where((item) => item.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item.name.toLowerCase().contains(_searchQuery) ||
              item.category.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Apply low stock filter
    if (_showLowStock) {
      items =
          items.where((item) => item.quantity <= item.minimumQuantity).toList();
    }

    // Apply expiring filter
    if (_showExpiring) {
      final now = DateTime.now();
      items = items
          .where((item) =>
              item.expiryDate != null &&
              item.expiryDate!.difference(now).inDays <= 7)
          .toList();
    }

    return items;
  }

  Widget _buildInventoryCard(
      InventoryItem item, DairyInventoryRepository repository) {
    final isLowStock = item.quantity <= item.minimumQuantity;
    final isExpiring = item.expiryDate != null &&
        item.expiryDate!.difference(DateTime.now()).inDays <= 7;

    final numberFormat = NumberFormat('#,##0.00');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item.category),
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
                      Text(
                          'Quantity: ${numberFormat.format(item.quantity)} ${item.unit}'),
                      if (item.cost != null)
                        Text(
                            'Cost: ﷼${numberFormat.format(item.cost!)} / ${item.unit}'),
                      if (item.expiryDate != null)
                        Text(
                            'Expires: ${DateFormat('MMM dd, yyyy').format(item.expiryDate!)}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Storage: ${item.location}'),
                      Text(
                          'Reorder at: ${numberFormat.format(item.reorderPoint)} ${item.unit}'),
                      Text(
                          'Min Qty: ${numberFormat.format(item.minimumQuantity)} ${item.unit}'),
                    ],
                  ),
                ),
              ],
            ),
            if (isLowStock || isExpiring) const SizedBox(height: 8),
            if (isLowStock)
              const Chip(
                label: Text('Low Stock'),
                backgroundColor: Colors.red,
                labelStyle: TextStyle(color: Colors.white),
              ),
            if (isExpiring)
              Chip(
                label: const Text('Expiring Soon'),
                backgroundColor: Colors.orange,
                labelStyle: TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      _showAdjustQuantityDialog(context, item, repository),
                  child: const Text('Adjust'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showItemDetails(context, item),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Inventory'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category:'),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Show only low stock items'),
                    value: _showLowStock,
                    onChanged: (value) {
                      setState(() {
                        _showLowStock = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Show only expiring items'),
                    value: _showExpiring,
                    onChanged: (value) {
                      setState(() {
                        _showExpiring = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      // Update the state in the parent widget
                      _selectedCategory = _selectedCategory;
                      _showLowStock = _showLowStock;
                      _showExpiring = _showExpiring;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('APPLY'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAdjustQuantityDialog(BuildContext context, InventoryItem item,
      DairyInventoryRepository repository) {
    double adjustment = 0;
    String reason = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adjust ${item.name} Quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current quantity: ${item.quantity} ${item.unit}'),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Adjustment (${item.unit})',
                  hintText: 'Enter positive or negative value',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                onChanged: (value) {
                  adjustment = double.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Enter reason for adjustment',
                ),
                onChanged: (value) {
                  reason = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                if (adjustment == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adjustment cannot be zero')),
                  );
                  return;
                }

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a reason')),
                  );
                  return;
                }

                try {
                  await repository.adjustQuantity(item.id, adjustment, reason);
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {}); // Refresh UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Adjusted ${item.name} by $adjustment ${item.unit}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('ADJUST'),
            ),
          ],
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, InventoryItem item) {
    final additionalAttributes = item.additionalAttributes ?? {};

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const Divider(),
                  _buildDetailItem('Batch Number', item.batchNumber ?? 'N/A'),
                  _buildDetailItem('Location', item.location),
                  _buildDetailItem(
                      'Current Quantity', '${item.quantity} ${item.unit}'),
                  _buildDetailItem('Minimum Quantity',
                      '${item.minimumQuantity} ${item.unit}'),
                  _buildDetailItem(
                      'Reorder Point', '${item.reorderPoint} ${item.unit}'),
                  _buildDetailItem(
                      'Last Updated',
                      DateFormat('MMM dd, yyyy HH:mm')
                          .format(item.lastUpdated)),
                  if (item.expiryDate != null)
                    _buildDetailItem('Expiry Date',
                        DateFormat('MMM dd, yyyy').format(item.expiryDate!)),
                  if (item.cost != null)
                    _buildDetailItem('Cost',
                        '﷼${NumberFormat('#,##0.00').format(item.cost!)} / ${item.unit}'),
                  const Divider(),
                  const Text(
                    'Dairy-Specific Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (additionalAttributes['currentTemperature'] != null)
                    _buildDetailItem('Current Temperature',
                        '${additionalAttributes['currentTemperature']}°C'),
                  if (additionalAttributes['storageCondition'] != null)
                    _buildDetailItem('Storage Condition',
                        '${additionalAttributes['storageCondition']}'),
                  if (additionalAttributes['overallQualityStatus'] != null)
                    _buildDetailItem('Quality Status',
                        '${additionalAttributes['overallQualityStatus']}'),
                  if (additionalAttributes['fatContent'] != null)
                    _buildDetailItem('Fat Content',
                        '${additionalAttributes['fatContent']}%'),
                  _buildDetailItem(
                      'Pasteurized',
                      additionalAttributes['pasteurized'] == true
                          ? 'Yes'
                          : 'No'),
                  if (additionalAttributes['sourceInfo'] != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Source Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...(additionalAttributes['sourceInfo']
                            as Map<String, dynamic>)
                        .entries
                        .map((e) => _buildDetailItem(
                            e.key.toString().capitalize(), e.value.toString()))
                        .toList(),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('CLOSE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddInventoryDialog(
      BuildContext context, DairyInventoryRepository repository) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String category = _categories.contains('Milk')
        ? 'Milk'
        : _categories[_categories.length > 1 ? 1 : 0];
    String unit = 'Liters';
    double quantity = 0;
    double minimumQuantity = 0;
    double reorderPoint = 0;
    String location = 'Cold Storage A';
    double? cost;
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Dairy Product'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        name = value ?? '';
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      value: category,
                      items: _categories
                          .where((c) => c != 'All')
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        category = value ?? 'Milk';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      value: unit,
                      items: const [
                        DropdownMenuItem(
                            value: 'Liters', child: Text('Liters')),
                        DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                        DropdownMenuItem(value: 'Units', child: Text('Units')),
                      ],
                      onChanged: (value) {
                        unit = value ?? 'Liters';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a unit';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Quantity ($unit)',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        quantity = double.tryParse(value!) ?? 0;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Minimum Quantity ($unit)',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter minimum quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        minimumQuantity = double.tryParse(value!) ?? 0;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Reorder Point ($unit)',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter reorder point';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        reorderPoint = double.tryParse(value!) ?? 0;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                      ),
                      value: location,
                      items: const [
                        DropdownMenuItem(
                            value: 'Cold Storage A',
                            child: Text('Cold Storage A')),
                        DropdownMenuItem(
                            value: 'Cold Storage B',
                            child: Text('Cold Storage B')),
                        DropdownMenuItem(
                            value: 'Cold Storage C',
                            child: Text('Cold Storage C')),
                        DropdownMenuItem(
                            value: 'Cold Storage D',
                            child: Text('Cold Storage D')),
                      ],
                      onChanged: (value) {
                        location = value ?? 'Cold Storage A';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a location';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cost (Optional)',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          cost = double.tryParse(value);
                        }
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (selectedDate != null) {
                          expiryDate = selectedDate;
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date (Optional)',
                        ),
                        child: Text(
                          expiryDate != null
                              ? DateFormat('MMM dd, yyyy').format(expiryDate!)
                              : 'Tap to select date',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();

                  try {
                    final newItem = InventoryItem(
                      id: '', // Will be assigned by the repository
                      name: name,
                      category: category,
                      unit: unit,
                      quantity: quantity,
                      minimumQuantity: minimumQuantity,
                      reorderPoint: reorderPoint,
                      location: location,
                      lastUpdated: DateTime.now(),
                      expiryDate: expiryDate,
                      cost: cost,
                      batchNumber:
                          'BATCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      additionalAttributes: {
                        'storageCondition': 'Refrigerated',
                        'pasteurized': true,
                      },
                    );

                    await repository.addItem(newItem);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {}); // Refresh UI
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $name to inventory'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  void _confirmReset(DairyInventoryRepository repository) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Inventory'),
        content: const Text(
            'Are you sure you want to reset the dairy inventory to default values? '
            'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await repository.resetInventory();
                if (mounted) {
                  setState(() {}); // Refresh UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inventory has been reset'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
