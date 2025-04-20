import 'package:flutter/material.dart';
import '../screens/dairy_inventory_screen.dart';

/// A widget that can be placed in any screen to add a floating action button
/// that navigates to the Dairy Inventory screen
class DairyInventoryLauncher extends StatelessWidget {
  const DairyInventoryLauncher({
    super.key,
    this.position = DairyLauncherPosition.bottomRight,
    this.offset = const Offset(16, 16),
  });

  /// The position of the launcher on the screen
  final DairyLauncherPosition position;

  /// Additional offset from the specified position
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: position == DairyLauncherPosition.bottomRight ||
              position == DairyLauncherPosition.topRight
          ? offset.dx
          : null,
      left: position == DairyLauncherPosition.bottomLeft ||
              position == DairyLauncherPosition.topLeft
          ? offset.dx
          : null,
      bottom: position == DairyLauncherPosition.bottomRight ||
              position == DairyLauncherPosition.bottomLeft
          ? offset.dy
          : null,
      top: position == DairyLauncherPosition.topRight ||
              position == DairyLauncherPosition.topLeft
          ? offset.dy
          : null,
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToDairyInventory(context),
        label: const Text('Dairy Inventory'),
        icon: const Icon(Icons.inventory),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
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

/// An AppBar action that opens the Dairy Inventory screen
class DairyInventoryAppBarAction extends StatelessWidget {
  const DairyInventoryAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.inventory),
      tooltip: 'Dairy Inventory',
      onPressed: () => _navigateToDairyInventory(context),
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

/// Positions for the DairyInventoryLauncher widget
enum DairyLauncherPosition {
  bottomRight,
  bottomLeft,
  topRight,
  topLeft,
}

/// A card widget that can be added to a dashboard to showcase dairy inventory
class DairyInventoryDashboardCard extends StatelessWidget {
  const DairyInventoryDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _navigateToDairyInventory(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dairy Inventory',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(Icons.inventory),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage dairy products inventory, track stock levels, and more.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _navigateToDairyInventory(context),
                  child: const Text('OPEN'),
                ),
              ),
            ],
          ),
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
