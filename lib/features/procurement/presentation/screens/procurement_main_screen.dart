import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProcurementMainScreen extends StatelessWidget {
  const ProcurementMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Procurement',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage all procurement activities including purchase orders, approvals, quality, and reports.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: [
                  _buildNavCard(
                    context,
                    icon: Icons.dashboard,
                    color: Colors.blue,
                    title: 'Dashboard',
                    route: '/procurement/dashboard',
                  ),
                  _buildNavCard(
                    context,
                    icon: Icons.list_alt,
                    color: Colors.purple,
                    title: 'Purchase Orders',
                    route: '/procurement/purchase-orders',
                  ),
                  _buildNavCard(
                    context,
                    icon: Icons.check_circle_outline,
                    color: Colors.green.withAlpha((0.2 * 255).toInt()),
                    title: 'PO Approvals',
                    route: '/procurement/purchase-orders',
                  ),
                  _buildNavCard(
                    context,
                    icon: Icons.bar_chart,
                    color: Colors.teal,
                    title: 'Reports',
                    route: '/procurement/reports/dashboard',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String route}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha((0.15 * 255).toInt()),
                radius: 32,
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
