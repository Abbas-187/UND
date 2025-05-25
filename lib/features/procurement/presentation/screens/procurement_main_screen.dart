import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'purchase_request_create_screen.dart';

class ProcurementMainScreen extends StatelessWidget {
  const ProcurementMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Module'),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE4ECF7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_bag,
                          color: Colors.blue.shade800, size: 40),
                      const SizedBox(width: 16),
                      Text(
                        'Welcome to Procurement',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage all procurement activities including purchase orders, approvals, quality, and reports.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth > 900 ? 3 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 28,
                          mainAxisSpacing: 28,
                          childAspectRatio: isWide ? 1.2 : 1,
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
                              color: Colors.green,
                              title: 'PO Approvals',
                              route: '/procurement/po-approvals',
                            ),
                            _buildNavCard(
                              context,
                              icon: Icons.bar_chart,
                              color: Colors.teal,
                              title: 'Reports',
                              route: '/procurement/reports/dashboard',
                            ),
                            _buildNavCard(
                              context,
                              icon: Icons.receipt_long,
                              color: Colors.orange,
                              title: 'Requested Purchase Orders',
                              route: '/procurement/requested-purchase-orders',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    // Removed: now in dashboard
    return const SizedBox.shrink();
  }

  Widget _buildNavCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String route}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(route),
        hoverColor: color.withOpacity(0.08),
        splashColor: color.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.13),
                radius: 34,
                child: Icon(icon, color: color, size: 38),
              ),
              const SizedBox(height: 22),
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
