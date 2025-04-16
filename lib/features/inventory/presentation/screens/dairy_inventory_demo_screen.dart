import 'package:flutter/material.dart';
import '../widgets/dairy_inventory_entry.dart';

/// A demo screen showing how to integrate dairy inventory functionality
/// into any existing screen without modifying core app code
class DairyInventoryDemoScreen extends StatelessWidget {
  const DairyInventoryDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dairy Inventory Demo'),
        actions: const [
          // Option 1: Add as an AppBar action
          DairyInventoryAppBarAction(),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory,
                  size: 64,
                  color: Colors.lightBlue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dairy Inventory Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track, manage, and monitor your dairy products',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Option 3: Add as a card in existing UI
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Integration Options',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '1. As an AppBar action (see top right)',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '2. As a floating action button (see bottom right)',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '3. As a Dashboard card (see below)',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      const DairyInventoryDashboardCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Option 2: Add as a positioned floating action button
          const DairyInventoryLauncher(
            position: DairyLauncherPosition.bottomRight,
            offset: Offset(16, 80), // Offset to avoid overlap with default FAB
          ),
        ],
      ),
    );
  }
}

/// A simple button that navigates to the demo screen
class DairyInventoryDemoButton extends StatelessWidget {
  const DairyInventoryDemoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const DairyInventoryDemoScreen(),
          ),
        );
      },
      icon: const Icon(Icons.inventory),
      label: const Text('Open Dairy Inventory Demo'),
    );
  }
}
