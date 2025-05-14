import 'package:flutter/material.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryDataTable extends StatefulWidget {

  const InventoryDataTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
    this.isDesktop = false,
  });
  final List<InventoryItem> items;
  final Function(InventoryItem) onEdit;
  final Function(InventoryItem) onDelete;
  final bool isDesktop;

  @override
  State<InventoryDataTable> createState() => _InventoryDataTableState();
}

class _InventoryDataTableState extends State<InventoryDataTable> {
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<InventoryItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredItems();
  }

  @override
  void didUpdateWidget(InventoryDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _updateFilteredItems();
    }
  }

  void _updateFilteredItems() {
    _filteredItems = widget.items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.location.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    _sortItems();
  }

  void _sortItems() {
    _filteredItems.sort((a, b) {
      Object aValue, bValue;

      switch (_sortColumnIndex) {
        case 0: // Name
          aValue = a.name;
          bValue = b.name;
          break;
        case 1: // Category
          aValue = a.category;
          bValue = b.category;
          break;
        case 2: // Quantity
          aValue = a.quantity;
          bValue = b.quantity;
          break;
        case 3: // Location
          aValue = a.location;
          bValue = b.location;
          break;
        case 4: // Last Updated
          aValue = a.lastUpdated;
          bValue = b.lastUpdated;
          break;
        default:
          aValue = a.name;
          bValue = b.name;
      }

      int comparison;
      if (aValue is String && bValue is String) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = 0;
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Inventory',
              hintText: 'Search by name, category, or location',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _updateFilteredItems();
              });
            },
          ),
        ),
        Expanded(
          child: widget.isDesktop
              ? _buildDesktopTable()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildDataTable(),
                ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable() {
    return _filteredItems.isEmpty
        ? const Center(child: Text('No items match your search criteria'))
        : SingleChildScrollView(
            child: _buildDataTable(),
          );
  }

  Widget _buildDataTable() {
    return DataTable(
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn(
          label: const Text('Name'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
              _sortItems();
            });
          },
        ),
        DataColumn(
          label: const Text('Category'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
              _sortItems();
            });
          },
        ),
        DataColumn(
          label: const Text('Quantity'),
          numeric: true,
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
              _sortItems();
            });
          },
        ),
        DataColumn(
          label: const Text('Location'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
              _sortItems();
            });
          },
        ),
        DataColumn(
          label: const Text('Last Updated'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
              _sortItems();
            });
          },
        ),
        const DataColumn(
          label: Text('Actions'),
        ),
      ],
      rows: _filteredItems.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(item.name)),
            DataCell(Text(item.category)),
            DataCell(Text('${item.quantity} ${item.unit}')),
            DataCell(Text(item.location)),
            DataCell(Text(_formatDate(item.lastUpdated))),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => widget.onEdit(item),
                    tooltip: 'Edit Item',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => widget.onDelete(item),
                    tooltip: 'Delete Item',
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
