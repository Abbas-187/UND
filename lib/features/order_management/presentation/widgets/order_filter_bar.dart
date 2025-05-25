import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';

class OrderFilterBar extends StatelessWidget {
  const OrderFilterBar({super.key, this.onSearchChanged, this.onStatusChanged});
  final void Function(String searchQuery)? onSearchChanged;
  final void Function(String? status)? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search orders',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            hint: const Text('Status'),
            items: ['All', ...OrderStatus.values.map((e) => e.name)]
                .map((status) => DropdownMenuItem(
                      value: status,
                      child:
                          Text(status[0].toUpperCase() + status.substring(1)),
                    ))
                .toList(),
            onChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}
