import 'package:flutter/material.dart';

class OrderFilterBar extends StatelessWidget {
  const OrderFilterBar({super.key});

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
              onChanged: (value) {
                // TODO: implement filter logic
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            hint: const Text('Status'),
            items: ['All', 'Pending', 'Completed', 'Cancelled']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {
              // TODO: implement status filter
            },
          ),
        ],
      ),
    );
  }
}
