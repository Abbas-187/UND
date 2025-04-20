import 'package:flutter/material.dart';
import '../screens/dairy_inventory_screen.dart';

class DairyInventoryMenu extends StatelessWidget {
  const DairyInventoryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'dairy_inventory') {
          _navigateToDairyInventory(context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'dairy_inventory',
          child: ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Dairy Inventory'),
            subtitle: Text('Manage dairy products'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chip(
          avatar: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.inventory, size: 16, color: Colors.blue),
          ),
          label: const Text('Dairy'),
          backgroundColor: Theme.of(context).primaryColor,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToDairyInventory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DairyInventoryScreen(),
      ),
    );
  }
}

class DairyInventoryFloatingActionButton extends StatelessWidget {
  const DairyInventoryFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToDairyInventory(context),
      tooltip: 'Dairy Inventory',
      child: const Icon(Icons.inventory),
    );
  }

  void _navigateToDairyInventory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DairyInventoryScreen(),
      ),
    );
  }
}
