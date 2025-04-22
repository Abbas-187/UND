import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/purchase_order.dart';

class PurchaseOrderItemList extends StatelessWidget {
  final List<PurchaseOrderItem> items;

  const PurchaseOrderItemList({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Item',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Quantity',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Unit Price',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),

        // Table rows
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              item.itemName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${item.quantity} ${item.unit}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              currencyFormat.format(item.unitPrice),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              currencyFormat.format(item.totalPrice),
                              textAlign: TextAlign.end,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Expanded(
                            flex: 5,
                            child: Text(
                              'Required by:',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Text(
                              dateFormat.format(item.requiredByDate),
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          'Notes: ${item.notes}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      // Divider after each item except the last one
                      if (item != items.last)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Divider(),
                        ),
                    ],
                  ),
                ))
            .toList(),

        // Total row at the bottom
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 5,
                child: Text(
                  'Grand Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                flex: 4,
                child: SizedBox(),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  currencyFormat.format(_calculateTotal()),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    return items.fold(0, (total, item) => total + item.totalPrice);
  }
}
