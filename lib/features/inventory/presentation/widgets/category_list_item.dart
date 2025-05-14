import 'package:flutter/material.dart';
import '../../domain/entities/inventory_category.dart';

class CategoryListItem extends StatefulWidget {
  const CategoryListItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.children,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryCategory category;
  final bool isSelected;
  final List<InventoryCategory> children;
  final Function(String) onSelect;
  final Function(InventoryCategory) onEdit;
  final Function(String) onDelete;

  @override
  State<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.children.isNotEmpty;
    final category = widget.category;

    final categoryColor = Color(
        int.tryParse('0xFF${category.colorCode.replaceAll('#', '')}') ??
            0xFFAAAAAA);

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: categoryColor,
            child: Text(
              category.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: ThemeData.estimateBrightnessForColor(categoryColor) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          title: Text(
            category.name,
            style: TextStyle(
              fontWeight:
                  widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            '${category.itemCount} items',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasChildren)
                IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  tooltip: _isExpanded ? 'Collapse' : 'Expand',
                ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => widget.onEdit(category),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: hasChildren
                    ? null // Disable delete if has children
                    : () => _confirmDelete(context),
                tooltip: hasChildren
                    ? 'Cannot delete (has child categories)'
                    : 'Delete',
              ),
            ],
          ),
          selected: widget.isSelected,
          selectedTileColor: Colors.blue.withValues(alpha: 0.1 * 255),
          onTap: () => widget.onSelect(category.id),
        ),
        if (_isExpanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              children: widget.children.map((child) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.tryParse(
                            '0xFF${child.colorCode.replaceAll('#', '')}') ??
                        0xFFAAAAAA),
                    radius: 16,
                    child: Text(
                      child.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeData.estimateBrightnessForColor(
                                  Color(int.tryParse(
                                          '0xFF${child.colorCode.replaceAll('#', '')}') ??
                                      0xFFAAAAAA),
                                ) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  title: Text(
                    child.name,
                    style: TextStyle(
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${child.itemCount} items',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => widget.onEdit(child),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => _confirmDeleteChild(context, child),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                  dense: true,
                  selected: widget.isSelected && child.id == widget.category.id,
                  selectedTileColor: Colors.blue.withValues(alpha: 0.1 * 255),
                  onTap: () => widget.onSelect(child.id),
                );
              }).toList(),
            ),
          ),
        const Divider(),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${widget.category.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete(widget.category.id);
    }
  }

  Future<void> _confirmDeleteChild(
      BuildContext context, InventoryCategory child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${child.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete(child.id);
    }
  }
}
