import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/status_indicator.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../providers/bom_providers.dart';
import '../widgets/bom_cost_breakdown.dart';

class BomDetailScreen extends ConsumerWidget {
  const BomDetailScreen({
    super.key,
    required this.bomId,
  });

  final String bomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bomAsync = ref.watch(bomByIdProvider(bomId));
    final bomItemsAsync = ref.watch(bomItemsProvider(bomId));

    return Scaffold(
      body: bomAsync.when(
        data: (bom) {
          if (bom == null) {
            return _buildNotFoundState(context);
          }
          return _buildBomDetail(context, ref, bom, bomItemsAsync, theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildBomDetail(
    BuildContext context,
    WidgetRef ref,
    BillOfMaterials bom,
    AsyncValue<List<BomItem>> bomItemsAsync,
    ThemeData theme,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(bom.bomCode),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // Space for app bar
                    Text(
                      bom.bomName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusIndicator(
                          isActive: bom.status == BomStatus.active,
                          size: 12,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bom.status.name.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'v${bom.version}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/bom/edit/$bomId'),
              tooltip: 'Edit BOM',
            ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(context, ref, value, bom),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Duplicate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Export'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'version',
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('Version History'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (bom.status == BomStatus.draft)
                  const PopupMenuItem(
                    value: 'approve',
                    child: ListTile(
                      leading: Icon(Icons.check_circle),
                      title: Text('Approve'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),

        // BOM Information
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(bom, theme),
                const SizedBox(height: 24),
                _buildCostSection(bom, theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // BOM Items Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'BOM Items',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push('/bom/edit/$bomId?tab=items'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),

        // BOM Items List
        bomItemsAsync.when(
          data: (items) => items.isEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptyItemsState(context, theme),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return BomItemCard(
                          item: item,
                          onEdit: () => _editItem(context, item),
                          onDelete: () => _deleteItem(context, ref, item),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: _buildItemsErrorState(context, error.toString()),
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BillOfMaterials bom, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Product', '${bom.productCode} - ${bom.productName}', theme),
            _buildInfoRow('Type', bom.bomType.name.toUpperCase(), theme),
            _buildInfoRow(
                'Base Quantity', '${bom.baseQuantity} ${bom.baseUnit}', theme),
            if (bom.description != null)
              _buildInfoRow('Description', bom.description!, theme),
            _buildInfoRow('Created', _formatDateTime(bom.createdAt), theme),
            _buildInfoRow('Updated', _formatDateTime(bom.updatedAt), theme),
            if (bom.approvedBy != null)
              _buildInfoRow('Approved By', bom.approvedBy!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection(BillOfMaterials bom, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BomCostBreakdown(bom: bom),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState(BuildContext context, ThemeData theme) {
    return Padding(
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/bom/edit/$bomId?tab=items'),
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BOM Not Found')),
      body: Center(
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
            const SizedBox(height: 8),
            Text(
              'The requested BOM could not be found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
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
      ),
    );
  }

  Widget _buildItemsErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        ],
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, WidgetRef ref, String action, BillOfMaterials bom) {
    switch (action) {
      case 'duplicate':
        context.push('/bom/create?duplicate=${bom.id}');
        break;
      case 'export':
        _exportBom(context, ref, bom);
        break;
      case 'version':
        context.push('/bom/versions/${bom.productId}');
        break;
      case 'approve':
        _approveBom(context, ref, bom);
        break;
      case 'delete':
        _deleteBom(context, ref, bom);
        break;
    }
  }

  void _editItem(BuildContext context, BomItem item) {
    context.push('/bom/edit/${item.bomId}?tab=items&item=${item.id}');
  }

  void _deleteItem(BuildContext context, WidgetRef ref, BomItem item) {
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
                ref.invalidate(bomItemsProvider(item.bomId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
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

  void _exportBom(BuildContext context, WidgetRef ref, BillOfMaterials bom) {
    // TODO: Implement BOM export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _approveBom(BuildContext context, WidgetRef ref, BillOfMaterials bom) {
    // TODO: Implement BOM approval functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Approval functionality coming soon')),
    );
  }

  void _deleteBom(BuildContext context, WidgetRef ref, BillOfMaterials bom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete BOM'),
        content: Text('Are you sure you want to delete ${bom.bomCode}?'),
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
                await repository.deleteBom(bom.id);
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('BOM deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting BOM: $e')),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// BOM Item Card Widget
class BomItemCard extends StatelessWidget {
  const BomItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  final BomItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Edit Item',
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete,
                            size: 20, color: Colors.red[400]),
                        onPressed: onDelete,
                        tooltip: 'Delete Item',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.numbers,
                  label: '${item.quantity} ${item.unit}',
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.attach_money,
                  label: '\$${item.costPerUnit.toStringAsFixed(2)}',
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.category,
                  label: item.itemType.name,
                  theme: theme,
                ),
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
