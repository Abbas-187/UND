import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/status_indicator.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../providers/bom_providers.dart';
import '../widgets/bom_list_item.dart';

class BomListScreen extends ConsumerStatefulWidget {
  const BomListScreen({super.key});

  @override
  ConsumerState<BomListScreen> createState() => _BomListScreenState();
}

class _BomListScreenState extends ConsumerState<BomListScreen> {
  final TextEditingController _searchController = TextEditingController();
  BomStatus? _selectedStatus;
  BomType? _selectedType;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get filtered BOMs based on current filters
    final bomsAsync = ref.watch(bomFilterProvider.call({
      'status': _selectedStatus,
      'type': _selectedType,
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill of Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/bom/create'),
            tooltip: 'Create New BOM',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => context.push('/bom/analytics'),
            tooltip: 'BOM Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilters(theme),

          // BOM List
          Expanded(
            child: bomsAsync.when(
              data: (boms) {
                final filteredBoms = _searchQuery.isEmpty
                    ? boms
                    : boms
                        .where((bom) =>
                            bom.bomCode
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            bom.bomName
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            bom.productCode
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filteredBoms.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(bomFilterProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBoms.length,
                    itemBuilder: (context, index) {
                      final bom = filteredBoms[index];
                      return BomListItem(
                        bom: bom,
                        onTap: () => context.push('/bom/detail/${bom.id}'),
                        onEdit: () => context.push('/bom/edit/${bom.id}'),
                        onDuplicate: () => _duplicateBom(bom),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bom/create'),
        tooltip: 'Create New BOM',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search BOMs by code, name, or product...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Filters Row
            Row(
              children: [
                // Status Filter
                Expanded(
                  child: DropdownButtonFormField<BomStatus>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<BomStatus>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...BomStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                StatusIndicator(
                                  isActive: status == BomStatus.active,
                                  size: 8,
                                ),
                                const SizedBox(width: 8),
                                Text(status.name.toUpperCase()),
                              ],
                            ),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Type Filter
                Expanded(
                  child: DropdownButtonFormField<BomType>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<BomType>(
                        value: null,
                        child: Text('All Types'),
                      ),
                      ...BomType.values.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No BOMs Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first BOM or adjust your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/bom/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create BOM'),
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
            'Error Loading BOMs',
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
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(bomFilterProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _duplicateBom(BillOfMaterials bom) {
    // Navigate to create screen with pre-filled data
    context.push('/bom/create?duplicate=${bom.id}');
  }
}
