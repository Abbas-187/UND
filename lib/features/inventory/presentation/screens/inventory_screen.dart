import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/inventory_provider.dart';
import '../widgets/low_stock_alerts_banner.dart';
import '../widgets/inventory_filter_bar.dart';
import '../widgets/inventory_analytics_card.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/dashboard/inventory_dashboard_widgets.dart';
import '../../../procurement/presentation/data/in_memory_purchase_requests.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filteredItems = ref.watch(filteredInventoryItemsProvider);
    final filter = ref.watch(inventoryFilterProvider);
    final uniqueCategories = ref.watch(uniqueCategoriesProvider);
    final uniqueSubCategories = ref.watch(uniqueSubCategoriesProvider);
    final uniqueLocations = ref.watch(uniqueLocationsProvider);
    final uniqueSuppliers = ref.watch(uniqueSuppliersProvider);
    final isWide = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);

    void refreshInventory() {
      ref.refresh(filteredInventoryItemsProvider);
    }

    // For low stock preview and show all
    void showAllLowStock() {
      ref.read(inventoryFilterProvider.notifier).state =
          filter.copyWith(showLowStock: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.inventoryManagement ?? ''),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: l10n?.inventoryAnalytics,
            onPressed: () => context.go('/inventory/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: l10n?.inventoryReports,
            onPressed: () => context.go('/inventory/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.storage),
            tooltip: 'Database Management',
            onPressed: () => context.go('/inventory/database-management'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n?.settings,
            onPressed: () => context.go('/inventory/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Item',
            onPressed: () => context.go('/inventory/edit'),
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _LowStockPreviewBanner(onShowAll: showAllLowStock),
                ExpansionTile(
                  title: Text(l10n?.inventoryAnalytics ?? '',
                      style: theme.textTheme.titleMedium),
                  initiallyExpanded: false,
                  children: const [
                    InventoryAnalyticsCard(),
                  ],
                ),
                InventoryFilterBar(
                  filter: filter,
                  onFilterChanged: (newFilter) {
                    ref.read(inventoryFilterProvider.notifier).state =
                        newFilter;
                  },
                  availableCategories: uniqueCategories,
                  availableSubCategories: uniqueSubCategories,
                  availableLocations: uniqueLocations,
                  availableSuppliers: uniqueSuppliers,
                ),
                _InventoryTableSection(
                  filteredItems: filteredItems,
                  onRefresh: refreshInventory,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/inventory/edit'),
        icon: const Icon(Icons.add),
        label: Text('Add New Item'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}

void _showQuickActions(BuildContext context, dynamic item) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart_checkout),
              title: const Text('Send Purchase Request'),
              onTap: () {
                Navigator.pop(context);
                // --- Calculate suggested quantity and safety stock ---
                double rop = (item.reorderPoint ?? 0).toDouble();
                double? safetyStock = item.safetyStock != null
                    ? (item.safetyStock as num).toDouble()
                    : null;
                double currentStock = (item.quantity ?? 0).toDouble();
                double targetLevel = rop + (safetyStock ?? 0);
                double suggested = targetLevel - currentStock;
                if (suggested < 0) suggested = 0;
                // --- Add to InMemoryPurchaseRequests ---
                InMemoryPurchaseRequests.requests.add({
                  'item': item,
                  'quantity': suggested,
                  'safetyStock': safetyStock ?? 0,
                  'justification': '',
                  'supplier': item.supplier,
                  'timestamp': DateTime.now(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Purchase request created and added to Requests.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Track Purchase Order'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tracking purchase order (demo)')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Item Details'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).go('/inventory/item-details/${item.id}');
              },
            ),
          ],
        ),
      );
    },
  );
}

class _LowStockPreviewBanner extends ConsumerWidget {
  final VoidCallback onShowAll;
  const _LowStockPreviewBanner({required this.onShowAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockItems = ref.watch(filteredInventoryItemsProvider.select(
      (items) => items.whenData(
        (items) => items
            .where((item) => item.quantity <= item.minimumQuantity)
            .toList(),
      ),
    ));
    final theme = Theme.of(context);
    return lowStockItems.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        final preview = items.take(3).toList();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.red.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Low Stock Alert',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (items.length > 3)
                    TextButton(
                      onPressed: onShowAll,
                      child: const Text('Show All'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ...preview.map((item) => GestureDetector(
                    onTap: () => _showQuickActions(context, item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2,
                              size: 18, color: Colors.red.shade400),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${item.name} (${item.quantity} ${item.unit})',
                              style: TextStyle(color: Colors.red.shade900),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.more_vert,
                              color: Colors.red.shade300, size: 18),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class _InventoryTableSection extends StatefulWidget {
  final AsyncValue<List<dynamic>> filteredItems;
  final VoidCallback onRefresh;
  const _InventoryTableSection(
      {required this.filteredItems, required this.onRefresh});

  @override
  State<_InventoryTableSection> createState() => _InventoryTableSectionState();
}

class _InventoryTableSectionState extends State<_InventoryTableSection> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  List<dynamic> _sortItems(List<dynamic> items) {
    List<dynamic> sorted = List.from(items);
    int column = _sortColumnIndex;
    bool ascending = _sortAscending;
    int compare(dynamic a, dynamic b) {
      dynamic aValue, bValue;
      switch (column) {
        case 0:
          aValue = a.name;
          bValue = b.name;
          break;
        case 1:
          aValue = a.sapCode;
          bValue = b.sapCode;
          break;
        case 2:
          aValue = a.appItemId;
          bValue = b.appItemId;
          break;
        case 3:
          aValue = a.category;
          bValue = b.category;
          break;
        case 4:
          aValue = a.subCategory;
          bValue = b.subCategory;
          break;
        case 5:
          aValue = a.reorderPoint;
          bValue = b.reorderPoint;
          break;
        case 6:
          aValue = a.quantity;
          bValue = b.quantity;
          break;
        default:
          aValue = a.name;
          bValue = b.name;
      }
      int cmp;
      if (aValue is String && bValue is String) {
        cmp = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        cmp = aValue.compareTo(bValue);
      } else {
        cmp = 0;
      }
      return ascending ? cmp : -cmp;
    }

    sorted.sort(compare);
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.filteredItems.when(
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.noItemsFound ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Overview of inventory status and metrics',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              final sortedItems = _sortItems(items);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  headingRowColor: MaterialStateProperty.all(
                      theme.colorScheme.surfaceVariant),
                  columns: [
                    DataColumn(
                      label: Text(l10n?.name ?? 'Name'),
                      onSort: (col, asc) => setState(() {
                        _sortColumnIndex = col;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(
                      label: Text(l10n?.sapCode ?? 'SAP Code'),
                      onSort: (col, asc) => setState(() {
                        _sortColumnIndex = col;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(
                      label: Text(l10n?.appItemId ?? 'App Code'),
                      onSort: (col, asc) => setState(() {
                        _sortColumnIndex = col;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(
                      label: Text(l10n?.category ?? 'Category'),
                      onSort: (col, asc) => setState(() {
                        _sortColumnIndex = col;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(
                      label: Text(l10n?.subCategory ?? 'Sub-Category'),
                      onSort: (col, asc) => setState(() {
                        _sortColumnIndex = col;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(
                      label: Text(l10n?.reorderPoint ?? 'Reorder Point'),
                      numeric: true,
                      onSort: (col, asc) => setState(() {
                        _sortColumnIndex = col;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(
                      label: Text(l10n?.quantity ?? 'Quantity'),
                      numeric: true,
                      onSort: (col, asc) => setState(() {
                        _sortColumnIndex = col;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn(label: Text(l10n?.status ?? 'Status')),
                    DataColumn(label: Text(l10n?.actions ?? 'Actions')),
                  ],
                  rows: sortedItems.map<DataRow>((item) {
                    final bool isLowStock =
                        (item.quantity ?? 0) <= (item.lowStockThreshold ?? 0);
                    final bool needsReorder =
                        (item.quantity ?? 0) <= (item.reorderPoint ?? 0);
                    final bool isExpired = item.isExpired == true;
                    final String statusText = isExpired
                        ? (l10n?.expired ?? 'Expired')
                        : isLowStock
                            ? (l10n?.lowStock ?? 'Low Stock')
                            : needsReorder
                                ? (l10n?.reorder ?? 'Reorder')
                                : (l10n?.inStock ?? 'In Stock');
                    final Color statusColor = isExpired
                        ? Colors.red.shade700
                        : isLowStock
                            ? Colors.orange.shade700
                            : needsReorder
                                ? Colors.amber.shade800
                                : Colors.green.shade600;
                    return DataRow(
                      cells: [
                        DataCell(
                          GestureDetector(
                            onTap: () => _showQuickActions(context, item),
                            child: Text(item.name ?? '-',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary)),
                          ),
                        ),
                        DataCell(Text(
                            item.sapCode?.isNotEmpty == true
                                ? item.sapCode
                                : '-',
                            style: theme.textTheme.bodySmall)),
                        DataCell(Text(
                            item.appItemId?.isNotEmpty == true
                                ? item.appItemId
                                : '-',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.primary))),
                        DataCell(Text(
                            item.category?.isNotEmpty == true
                                ? item.category
                                : '-',
                            style: theme.textTheme.bodySmall)),
                        DataCell(Text(
                            item.subCategory?.isNotEmpty == true
                                ? item.subCategory
                                : '-',
                            style: theme.textTheme.bodySmall)),
                        DataCell(Text(
                            item.reorderPoint != null
                                ? item.reorderPoint.toString()
                                : '-',
                            style: theme.textTheme.bodySmall)),
                        DataCell(Row(
                          children: [
                            Icon(Icons.inventory_2,
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              (item.quantity != null && item.unit != null)
                                  ? '${item.quantity.toStringAsFixed(2)} ${item.unit}'
                                  : '-',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isExpired
                                    ? Icons.event_busy
                                    : isLowStock
                                        ? Icons.warning_amber_rounded
                                        : needsReorder
                                            ? Icons.autorenew
                                            : Icons.check_circle_outline,
                                color: statusColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined),
                              tooltip: 'View',
                              onPressed: item.id != null &&
                                      item.id.toString().isNotEmpty
                                  ? () => GoRouter.of(context)
                                      .go('/inventory/item-details/${item.id}')
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Edit',
                              onPressed: item.id != null &&
                                      item.id.toString().isNotEmpty
                                  ? () => GoRouter.of(context)
                                      .go('/inventory/edit?itemId=${item.id}')
                                  : null,
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'purchase') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Purchase request sent (demo)')));
                                } else if (value == 'track') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Tracking purchase order (demo)')));
                                } else if (value == 'details') {
                                  GoRouter.of(context)
                                      .go('/inventory/item-details/${item.id}');
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'purchase',
                                  child: ListTile(
                                    leading: Icon(Icons.shopping_cart_checkout),
                                    title: Text('Send Purchase Request'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'track',
                                  child: ListTile(
                                    leading: Icon(Icons.track_changes),
                                    title: Text('Track Purchase Order'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'details',
                                  child: ListTile(
                                    leading: Icon(Icons.info_outline),
                                    title: Text('Item Details'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.errorWithMessage(error.toString()) ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryModernCard extends StatelessWidget {
  final dynamic item;
  const _InventoryModernCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLowStock = item.quantity <= item.lowStockThreshold;
    final bool needsReorder = item.quantity <= item.reorderPoint;
    final bool isExpired = item.isExpired == true;
    final String? qualityStatus =
        item.additionalAttributes?['qualityStatus'] as String?;
    final bool isQualityAcceptable = qualityStatus == null ||
        qualityStatus == 'excellent' ||
        qualityStatus == 'good' ||
        qualityStatus == 'acceptable';

    Color statusColor;
    String statusText;
    IconData statusIcon;
    if (isExpired) {
      statusColor = Colors.red.shade700;
      statusText = 'Expired';
      statusIcon = Icons.event_busy;
    } else if (isLowStock) {
      statusColor = Colors.orange.shade700;
      statusText = 'Low Stock';
      statusIcon = Icons.warning_amber_rounded;
    } else if (needsReorder) {
      statusColor = Colors.amber.shade800;
      statusText = 'Reorder';
      statusIcon = Icons.autorenew;
    } else {
      statusColor = Colors.green.shade600;
      statusText = 'In Stock';
      statusIcon = Icons.check_circle_outline;
    }

    return InkWell(
      onTap: isQualityAcceptable
          ? () => GoRouter.of(context).go('/inventory/item-details/${item.id}')
          : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            Container(
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (qualityStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _QualityStatusChip(status: qualityStatus),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${item.sapCode}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category} > ${item.subCategory}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.inventory_2,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('${item.quantity.toStringAsFixed(2)} ${item.unit}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.supplier != null && item.supplier!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.business,
                              size: 16, color: theme.colorScheme.secondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.supplier!,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.batchNumber != null || item.expiryDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          if (item.batchNumber != null)
                            Row(
                              children: [
                                Icon(Icons.confirmation_number,
                                    size: 16,
                                    color: theme.colorScheme.secondary),
                                const SizedBox(width: 2),
                                Text('Batch: ${item.batchNumber}',
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                          if (item.expiryDate != null)
                            Row(
                              children: [
                                Icon(Icons.event,
                                    size: 16,
                                    color: isExpired
                                        ? Colors.red
                                        : theme.colorScheme.secondary),
                                const SizedBox(width: 2),
                                Text('Exp: ${item.expiryDate}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: isExpired ? Colors.red : null)),
                              ],
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityStatusChip extends StatelessWidget {
  final String status;
  const _QualityStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'excellent':
        color = Colors.green;
        break;
      case 'good':
        color = Colors.lightGreen;
        break;
      case 'acceptable':
        color = Colors.orange;
        break;
      case 'damaged':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
