import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../providers/bom_providers.dart';
import '../widgets/bom_form.dart';

class BomCreateScreen extends ConsumerStatefulWidget {
  const BomCreateScreen({
    super.key,
    this.duplicateFromId,
  });

  final String? duplicateFromId;

  @override
  ConsumerState<BomCreateScreen> createState() => _BomCreateScreenState();
}

class _BomCreateScreenState extends ConsumerState<BomCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bomCodeController = TextEditingController();
  final _bomNameController = TextEditingController();
  final _productIdController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _baseQuantityController = TextEditingController();
  final _baseUnitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0.0');

  BomType _selectedType = BomType.production;
  BomStatus _selectedStatus = BomStatus.draft;
  final List<BomItem> _bomItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.duplicateFromId != null) {
      _loadBomForDuplication();
    }
  }

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

  Future<void> _loadBomForDuplication() async {
    if (widget.duplicateFromId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(bomRepositoryProvider);
      final originalBom = await repository.getBomById(widget.duplicateFromId!);

      if (originalBom != null) {
        _bomCodeController.text = '${originalBom.bomCode}_COPY';
        _bomNameController.text = '${originalBom.bomName} (Copy)';
        _productIdController.text = originalBom.productId;
        _productCodeController.text = originalBom.productCode;
        _productNameController.text = originalBom.productName;
        _baseQuantityController.text = originalBom.baseQuantity.toString();
        _baseUnitController.text = originalBom.baseUnit;
        _descriptionController.text = originalBom.description ?? '';
        _selectedType = originalBom.bomType;

        // Load items
        final items = await repository.getBomItems(originalBom.id);
        setState(() {
          _bomItems.clear();
          _bomItems.addAll(items.map((item) => item.copyWith(
                id: '', // New ID will be generated
                bomId: '', // Will be set when BOM is created
              )));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading BOM for duplication: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.duplicateFromId != null ? 'Duplicate BOM' : 'Create BOM'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDraft,
            child: const Text('Save Draft'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _createBom,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
          const SizedBox(width: 16),
        ],
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
                    // Basic Information Card
                    _buildBasicInfoCard(theme),
                    const SizedBox(height: 24),

                    // Product Information Card
                    _buildProductInfoCard(theme),
                    const SizedBox(height: 24),

                    // BOM Items Card
                    _buildBomItemsCard(theme),
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
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
                      hintText: 'e.g., BOM-001',
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
                      hintText: 'e.g., 1.0.0',
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
                hintText: 'Enter descriptive name',
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
                    items: [BomStatus.draft, BomStatus.underReview]
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
                hintText: 'Optional description',
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
                      hintText: 'Enter product ID',
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
                      hintText: 'e.g., PROD-001',
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
                hintText: 'Enter product name',
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
                      hintText: 'e.g., 1',
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
                      hintText: 'e.g., kg, pcs, liters',
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

  Widget _buildBomItemsCard(ThemeData theme) {
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
            if (_bomItems.isEmpty)
              _buildEmptyItemsState(theme)
            else
              ..._bomItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildBomItemCard(item, index, theme);
              }),
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

  Widget _buildBomItemCard(BomItem item, int index, ThemeData theme) {
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
                      onPressed: () => _editBomItem(index),
                      tooltip: 'Edit Item',
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.delete, size: 20, color: Colors.red[400]),
                      onPressed: () => _removeBomItem(index),
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

  void _addBomItem() {
    // TODO: Show add item dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add item functionality coming soon')),
    );
  }

  void _editBomItem(int index) {
    // TODO: Show edit item dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit item functionality coming soon')),
    );
  }

  void _removeBomItem(int index) {
    setState(() {
      _bomItems.removeAt(index);
    });
  }

  Future<void> _saveDraft() async {
    await _createBom(isDraft: true);
  }

  Future<void> _createBom({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final bom = BillOfMaterials(
        id: '', // Will be generated by Firestore
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
        items: _bomItems,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final repository = ref.read(bomRepositoryProvider);
      final bomId = await repository.createBom(bom);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isDraft ? 'BOM saved as draft' : 'BOM created successfully'),
          ),
        );
        context.go('/bom/detail/$bomId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating BOM: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
