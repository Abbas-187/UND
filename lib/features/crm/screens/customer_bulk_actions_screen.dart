import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerBulkActionsScreen extends StatefulWidget {

  const CustomerBulkActionsScreen(
      {super.key, required this.customers, required this.onBulkAction});
  final List<Customer> customers;
  final void Function(List<Customer> selected, String action) onBulkAction;

  @override
  State<CustomerBulkActionsScreen> createState() =>
      _CustomerBulkActionsScreenState();
}

class _CustomerBulkActionsScreenState extends State<CustomerBulkActionsScreen> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _performAction(String action) {
    final selected =
        widget.customers.where((c) => _selectedIds.contains(c.id)).toList();
    widget.onBulkAction(selected, action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bulk Actions')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: widget.customers.map((customer) {
                final selected = _selectedIds.contains(customer.id);
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text('${customer.email} | ${customer.phone}'),
                  leading: Checkbox(
                    value: selected,
                    onChanged: (_) => _toggleSelection(customer.id),
                  ),
                  onTap: () => _toggleSelection(customer.id),
                );
              }).toList(),
            ),
          ),
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _performAction('message'),
                    child: Text('Bulk Message'),
                  ),
                  ElevatedButton(
                    onPressed: () => _performAction('update'),
                    child: Text('Bulk Update'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
