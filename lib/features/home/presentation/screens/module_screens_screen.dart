import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModuleScreen {
  final String name;
  final String route;
  final IconData icon;
  final String description;

  ModuleScreen({
    required this.name,
    required this.route,
    required this.icon,
    required this.description,
  });
}

class ModuleScreensScreen extends ConsumerWidget {
  final String moduleName;
  final List<ModuleScreen> screens;

  const ModuleScreensScreen({
    super.key,
    required this.moduleName,
    required this.screens,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$moduleName Screens'),
      ),
      body: screens.isEmpty
          ? const Center(
              child: Text('No screens available in this module'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: screens.length,
              itemBuilder: (context, index) {
                final screen = screens[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      screen.icon,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      screen.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(screen.description),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, screen.route);
                    },
                  ),
                );
              },
            ),
    );
  }
}
