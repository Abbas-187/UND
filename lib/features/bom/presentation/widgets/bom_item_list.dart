import 'package:flutter/material.dart';

import '../../domain/entities/bom_item.dart';

// This file is a placeholder for BOM item list widgets
// The actual BOM item display is handled in the detail screen

class BomItemList extends StatelessWidget {
  const BomItemList({
    super.key,
    required this.items,
  });

  final List<BomItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.itemCode),
          subtitle: Text(item.itemName),
          trailing: Text('\$${item.totalCost.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
