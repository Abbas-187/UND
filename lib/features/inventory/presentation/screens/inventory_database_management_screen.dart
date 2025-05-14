import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_builder.dart';
import '../../domain/entities/inventory_item.dart';
import '../controllers/inventory_database_controller.dart';
import '../widgets/inventory_create_form.dart';
import '../widgets/inventory_data_table.dart';
import '../widgets/inventory_import_export.dart';

class InventoryDatabaseManagementScreen extends ConsumerStatefulWidget {
  const InventoryDatabaseManagementScreen({super.key});

  static const routeName = '/inventory/database-management';

  @override
  ConsumerState<InventoryDatabaseManagementScreen> createState() =>
      _InventoryDatabaseManagementScreenState();
}

class _InventoryDatabaseManagementScreenState
    extends ConsumerState<InventoryDatabaseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<InventoryItem> _filteredItems = [];
  String? _filterCategory;
  String? _filterSubCategory;
  String? _filterLocation;
  String? _filterSupplier;
  bool _filterLowStock = false;
  bool _filterNeedsReorder = false;
  bool _filterExpired = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Database Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Manage Items', icon: Icon(Icons.inventory_2)),
            Tab(text: 'Create Item', icon: Icon(Icons.add_circle)),
            Tab(text: 'Import/Export', icon: Icon(Icons.import_export)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Inventory Items Management Tab
          ResponseBuilder(
            mobile: (context) => _buildFilteredItemsList(context),
            tablet: (context) => _buildFilteredItemsList(context),
            desktop: (context) => _buildFilteredItemsList(context),
          ),

          // Create New Item Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ResponseBuilder(
              mobile: (context) => SingleChildScrollView(
                child: InventoryCreateForm(
                  onCreateItem: (InventoryItem item) {
                    ref
                        .read(inventoryDatabaseControllerProvider.notifier)
                        .createInventoryItem(item);
                    _tabController.animateTo(0); // Switch back to items list
                  },
                ),
              ),
              tablet: (context) => SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: InventoryCreateForm(
                      onCreateItem: (InventoryItem item) {
                        ref
                            .read(inventoryDatabaseControllerProvider.notifier)
                            .createInventoryItem(item);
                        _tabController.animateTo(0);
                      },
                    ),
                  ),
                ),
              ),
              desktop: (context) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InventoryCreateForm(
                        onCreateItem: (InventoryItem item) {
                          ref
                              .read(
                                  inventoryDatabaseControllerProvider.notifier)
                              .createInventoryItem(item);
                          _tabController.animateTo(0);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Import/Export Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InventoryImportExport(
              onImportComplete: () {
                ref.refresh(inventoryItemsProvider);
                _tabController.animateTo(0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredItemsList(BuildContext context) {
    return Column(
      children: [
        // Filter controls
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            DropdownButton<String>(
              hint: const Text('Category'),
              value: _filterCategory,
              items: ['Milk', 'Yogurt', 'Cheese', 'Butter', 'Other']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _filterCategory = v),
            ),
            DropdownButton<String>(
              hint: const Text('Sub-Category'),
              value: _filterSubCategory,
              items: ['Bottle', 'Cups', 'Roll', 'Sticker', 'Other']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _filterSubCategory = v),
            ),
            DropdownButton<String>(
              hint: const Text('Location'),
              value: _filterLocation,
              items: [
                'Main Warehouse',
                'Cold Storage A',
                'Cold Storage B',
                'Other'
              ].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _filterLocation = v),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                decoration: const InputDecoration(hintText: 'Supplier'),
                onChanged: (v) =>
                    setState(() => _filterSupplier = v.isEmpty ? null : v),
              ),
            ),
            FilterChip(
              label: const Text('Low Stock'),
              selected: _filterLowStock,
              onSelected: (v) => setState(() => _filterLowStock = v),
            ),
            FilterChip(
              label: const Text('Needs Reorder'),
              selected: _filterNeedsReorder,
              onSelected: (v) => setState(() => _filterNeedsReorder = v),
            ),
            FilterChip(
              label: const Text('Expired'),
              selected: _filterExpired,
              onSelected: (v) => setState(() => _filterExpired = v),
            ),
            ElevatedButton(
              onPressed: () async {
                final items = await ref
                    .read(inventoryDatabaseControllerProvider.notifier)
                    .filterItems(
                      category: _filterCategory,
                      subCategory: _filterSubCategory,
                      location: _filterLocation,
                      supplier: _filterSupplier,
                      lowStock: _filterLowStock,
                      needsReorder: _filterNeedsReorder,
                      expired: _filterExpired,
                    );
                setState(() => _filteredItems = items);
              },
              child: const Text('Apply Filters'),
            ),
            ElevatedButton(
              onPressed: () async {
                final items = await ref
                    .read(inventoryDatabaseControllerProvider.notifier)
                    .getMostExpensiveItems(5);
                setState(() => _filteredItems = items);
              },
              child: const Text('Top 5 Expensive'),
            ),
          ],
        ),
        Expanded(
          child: _filteredItems.isEmpty
              ? const Center(child: Text('No items found.'))
              : InventoryDataTable(
                  items: _filteredItems,
                  onEdit: _showEditDialog,
                  onDelete: _confirmDelete,
                  isDesktop: true,
                ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(InventoryItem item) async {
    // Show a bottom sheet or dialog with edit form
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: InventoryCreateForm(
            initialItem: item,
            onCreateItem: (updatedItem) {
              ref
                  .read(inventoryDatabaseControllerProvider.notifier)
                  .updateInventoryItem(updatedItem);
              Navigator.pop(context);
            },
            isEditing: true,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(InventoryItem item) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete "${item.name}" from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(inventoryDatabaseControllerProvider.notifier)
                  .deleteInventoryItem(item.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
