import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/domain/auth_provider.dart';

class WarehouseDashboardScreen extends ConsumerWidget {
  const WarehouseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            userAsync.when(
                data: (user) {
                  // Generic approach that avoids specific property access
                  return UserAccountsDrawerHeader(
                    accountName: Text('User'),
                    accountEmail: Text('Email'),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        'U',
                        style: const TextStyle(fontSize: 24.0),
                      ),
                    ),
                  );
                },
                loading: () => const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                error: (_, __) => const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Center(child: Text('Error loading user data')),
                    )),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () {
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              onTap: () {
                context.push('/inventory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.input),
              title: const Text('Receive Goods'),
              onTap: () {
                context.pop();
                // Navigate to receive goods screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.output),
              title: const Text('Issue Goods'),
              onTap: () {
                context.pop();
                // Navigate to issue goods screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                context.pop();
                // Navigate to settings screen
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userAsync.when(
          data: (user) {
            // Generic approach
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome, User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: <Widget>[
                      _buildActionCard(
                        context,
                        'Inventory Status',
                        Icons.inventory_2,
                        Colors.blue.shade100,
                        () {
                          context.push('/inventory');
                        },
                      ),
                      _buildActionCard(
                        context,
                        'Receive Goods',
                        Icons.input,
                        Colors.green.shade100,
                        () {
                          // Navigate to receive goods screen
                        },
                      ),
                      _buildActionCard(
                        context,
                        'Issue Goods',
                        Icons.output,
                        Colors.orange.shade100,
                        () {
                          // Navigate to issue goods screen
                        },
                      ),
                      _buildActionCard(
                        context,
                        'Stock Count',
                        Icons.list_alt,
                        Colors.purple.shade100,
                        () {
                          // Navigate to stock count screen
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                color,
                color.withAlpha((0.7 * 255).toInt()),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 48,
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
