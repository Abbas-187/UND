import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../providers/bom_providers.dart';

class BomEditScreen extends ConsumerStatefulWidget {
  const BomEditScreen({
    super.key,
    required this.bomId,
  });

  final String bomId;

  @override
  ConsumerState<BomEditScreen> createState() => _BomEditScreenState();
}

class _BomEditScreenState extends ConsumerState<BomEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bomCodeController = TextEditingController();
  final _bomNameController = TextEditingController();
  final _productIdController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _baseQuantityController = TextEditingController();
  final _baseUnitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController();

  BomType _selectedType = BomType.production;
  BomStatus _selectedStatus = BomStatus.draft;
  final List<BomItem> _bomItems = [];
  bool _isLoading = false;
  BillOfMaterials? _originalBom;

  @override
  void dispose() {
    _bomCodeController.dispose();
    _bomNameController.dispose();
    _productIdController.dispose();
    _productCodeController.dispose();
    _productNameController.dispose();
    _baseQuantityController.dispose();
    _baseUnitController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  void _loadBomData(BillOfMaterials bom) {
    _originalBom = bom;
    _bomCodeController.text = bom.bomCode;
    _bomNameController.text = bom.bomName;
    _productIdController.text = bom.productId;
    _productCodeController.text = bom.productCode;
    _productNameController.text = bom.productName;
    _baseQuantityController.text = bom.baseQuantity.toString();
    _baseUnitController.text = bom.baseUnit;
    _descriptionController.text = bom.description ?? '';
    _versionController.text = bom.version;
    _selectedType = bom.bomType;
    _selectedStatus = bom.status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bomAsync = ref.watch(bomByIdProvider(widget.bomId));
    final bomItemsAsync = ref.watch(bomItemsProvider(widget.bomId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit BOM'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDraft,
            child: const Text('Save Draft'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateBom,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: bomAsync.when(
        data: (bom) {
          if (bom == null) {
            return _buildNotFoundState();
          }

          // Load data only once
          if (_originalBom == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadBomData(bom);
            });
          }

          return _buildEditForm(theme, bomItemsAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildEditForm(
      ThemeData theme, AsyncValue<List<BomItem>> bomItemsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Card
            _buildBasicInfoCard(theme),
            const SizedBox(height: 24),

            // Product Information Card
            _buildProductInfoCard(theme),
            const SizedBox(height: 24),

            // BOM Items Card
            _buildBomItemsCard(theme, bomItemsAsync),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bomCodeController,
                    decoration: const InputDecoration(
                      labelText: 'BOM Code *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'BOM code is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _versionController,
                    decoration: const InputDecoration(
                      labelText: 'Version *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Version is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bomNameController,
              decoration: const InputDecoration(
                labelText: 'BOM Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'BOM name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<BomType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'BOM Type',
                      border: OutlineInputBorder(),
                    ),
                    items: BomType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<BomStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: BomStatus.values
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productIdController,
                    decoration: const InputDecoration(
                      labelText: 'Product ID *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Product ID is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _productCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Product Code *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Product code is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Base Quantity *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Base quantity is required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _baseUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Base Unit *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Base unit is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBomItemsCard(
      ThemeData theme, AsyncValue<List<BomItem>> bomItemsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'BOM Items',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addBomItem,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            bomItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _buildEmptyItemsState(theme);
                }
                return Column(
                  children: items
                      .map((item) => _buildBomItemCard(item, theme))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading items: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Items Added',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to this BOM to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBomItemCard(BomItem item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemCode,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.itemName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editBomItem(item),
                      tooltip: 'Edit Item',
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.delete, size: 20, color: Colors.red[400]),
                      onPressed: () => _deleteBomItem(item),
                      tooltip: 'Delete Item',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${item.quantity} ${item.unit}'),
                const SizedBox(width: 16),
                Text('\$${item.costPerUnit.toStringAsFixed(2)}/unit'),
                const Spacer(),
                Text(
                  '\$${item.totalCost.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'BOM Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading BOM',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _addBomItem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add item functionality coming soon')),
    );
  }

  void _editBomItem(BomItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit item functionality coming soon')),
    );
  }

  void _deleteBomItem(BomItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.itemCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(bomRepositoryProvider);
                await repository.removeBomItem(item.bomId, item.itemId);
                ref.invalidate(bomItemsProvider(widget.bomId));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting item: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDraft() async {
    await _updateBom(isDraft: true);
  }

  Future<void> _updateBom({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate() || _originalBom == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBom = _originalBom!.copyWith(
        bomCode: _bomCodeController.text.trim(),
        bomName: _bomNameController.text.trim(),
        productId: _productIdController.text.trim(),
        productCode: _productCodeController.text.trim(),
        productName: _productNameController.text.trim(),
        bomType: _selectedType,
        version: _versionController.text.trim(),
        baseQuantity: double.parse(_baseQuantityController.text),
        baseUnit: _baseUnitController.text.trim(),
        status: isDraft ? BomStatus.draft : _selectedStatus,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(bomRepositoryProvider);
      await repository.updateBom(updatedBom);

      // Invalidate providers to refresh data
      ref.invalidate(bomByIdProvider(widget.bomId));
      ref.invalidate(allBomsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isDraft ? 'BOM saved as draft' : 'BOM updated successfully'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating BOM: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
