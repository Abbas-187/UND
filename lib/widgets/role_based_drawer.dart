import 'package:flutter/material.dart';

import '../core/routes/navigation_item.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class RoleBasedDrawer extends StatelessWidget {
  RoleBasedDrawer({super.key});
  final AuthService _authService = AuthService();

  final List<NavigationItem> _navigationItems = [
    // Warehouse Section
    NavigationItem(
      title: 'Warehouse',
      icon: Icons.warehouse,
      allowedRoles: ['system_admin', 'warehouse_admin', 'inventory_operator'],
      children: [
        NavigationItem(
          title: 'Dashboard',
          route: '/warehouse/dashboard',
          icon: Icons.dashboard,
          allowedRoles: [
            'system_admin',
            'warehouse_admin',
            'inventory_operator'
          ],
        ),
        NavigationItem(
          title: 'Receive Goods',
          route: '/warehouse/receive',
          icon: Icons.input,
          allowedRoles: [
            'system_admin',
            'warehouse_admin',
            'inventory_operator'
          ],
        ),
        NavigationItem(
          title: 'Issue Goods',
          route: '/warehouse/issue',
          icon: Icons.output,
          allowedRoles: [
            'system_admin',
            'warehouse_admin',
            'inventory_operator'
          ],
        ),
        NavigationItem(
          title: 'Stock Count',
          route: '/warehouse/count',
          icon: Icons.inventory_2,
          allowedRoles: [
            'system_admin',
            'warehouse_admin',
            'inventory_operator'
          ],
        ),
        NavigationItem(
          title: 'Locations',
          route: '/warehouse/locations',
          icon: Icons.grid_on,
          allowedRoles: ['system_admin', 'warehouse_admin'],
        ),
      ],
    ),

    // Factory Section
    NavigationItem(
      title: 'Factory',
      icon: Icons.precision_manufacturing,
      allowedRoles: ['system_admin', 'factory_admin', 'production_operator'],
      children: [
        NavigationItem(
          title: 'Production Dashboard',
          route: '/factory/dashboard',
          icon: Icons.dashboard,
          allowedRoles: [
            'system_admin',
            'factory_admin',
            'production_operator'
          ],
        ),
        NavigationItem(
          title: 'Recipe Management',
          route: '/factory/recipes',
          icon: Icons.menu_book,
          allowedRoles: ['system_admin', 'factory_admin'],
        ),
        NavigationItem(
          title: 'Production Orders',
          route: '/factory/orders',
          icon: Icons.assignment,
          allowedRoles: [
            'system_admin',
            'factory_admin',
            'production_operator'
          ],
        ),
        NavigationItem(
          title: 'Production Execution',
          route: '/factory/production/executions',
          icon: Icons.settings_applications,
          allowedRoles: [
            'system_admin',
            'factory_admin',
            'production_operator'
          ],
        ),
        NavigationItem(
          title: 'Material Requisition',
          route: '/factory/requisition',
          icon: Icons.shopping_cart,
          allowedRoles: [
            'system_admin',
            'factory_admin',
            'production_operator'
          ],
        ),
      ],
    ),

    // Sales Section
    NavigationItem(
      title: 'Sales',
      icon: Icons.point_of_sale,
      allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
      children: [
        NavigationItem(
          title: 'Sales Dashboard',
          route: '/sales/dashboard',
          icon: Icons.dashboard,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'Customers',
          route: '/sales/customers',
          icon: Icons.people,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'New Order',
          route: '/sales/new-order',
          icon: Icons.add_shopping_cart,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'Order History',
          route: '/sales/orders',
          icon: Icons.history,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'Analytics',
          route: '/sales/analytics',
          icon: Icons.analytics,
          allowedRoles: ['system_admin', 'sales_admin'],
        ),
      ],
    ),

    // Logistics Section
    NavigationItem(
      title: 'Logistics',
      icon: Icons.local_shipping,
      allowedRoles: ['system_admin', 'logistics_admin', 'delivery_operator'],
      children: [
        NavigationItem(
          title: 'Logistics Dashboard',
          route: '/logistics/dashboard',
          icon: Icons.dashboard,
          allowedRoles: [
            'system_admin',
            'logistics_admin',
            'delivery_operator'
          ],
        ),
        NavigationItem(
          title: 'Vehicles',
          route: '/logistics/vehicles',
          icon: Icons.directions_car,
          allowedRoles: ['system_admin', 'logistics_admin'],
        ),
        NavigationItem(
          title: 'Route Planning',
          route: '/logistics/routes',
          icon: Icons.map,
          allowedRoles: [
            'system_admin',
            'logistics_admin',
            'delivery_operator'
          ],
        ),
        NavigationItem(
          title: 'Live Tracking',
          route: '/logistics/tracking',
          icon: Icons.gps_fixed,
          allowedRoles: [
            'system_admin',
            'logistics_admin',
            'delivery_operator',
            'sales_admin',
            'sales_operator'
          ],
        ),
        NavigationItem(
          title: 'Delivery History',
          route: '/logistics/history',
          icon: Icons.history,
          allowedRoles: [
            'system_admin',
            'logistics_admin',
            'delivery_operator'
          ],
        ),
      ],
    ),

    // Settings Section (Admin only)
    NavigationItem(
      title: 'Settings',
      icon: Icons.settings,
      allowedRoles: ['system_admin'],
      children: [
        NavigationItem(
          title: 'User Management',
          route: '/admin/users',
          icon: Icons.people,
          allowedRoles: ['system_admin'],
        ),
        NavigationItem(
          title: 'System Settings',
          route: '/admin/settings',
          icon: Icons.tune,
          allowedRoles: ['system_admin'],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole?>(
      stream: _authService.userRoleStream,
      builder: (context, snapshot) {
        final UserRole? userRole = snapshot.data;
        final String? roleName = userRole?.toString().split('.').last;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UND Warehouse Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.data?.name ?? 'Loading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      roleName?.toUpperCase() ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Dynamically generate navigation items based on user role
              ...buildMenuItems(context, _navigationItems, userRole),

              const Divider(),

              // Logout is available to everyone
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await _signOut(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> buildMenuItems(
      BuildContext context, List<NavigationItem> items, UserRole? userRole) {
    List<Widget> widgets = [];

    for (var item in items) {
      // Skip items that the user doesn't have access to
      if (userRole == null || !item.allowedRoles.contains(userRole.name)) {
        continue;
      }

      // If this is a section header with children
      if (item.children != null && item.children!.isNotEmpty) {
        widgets.add(
          ExpansionTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            children:
                buildMenuItems(context, item.children!, userRole).map((widget) {
              // Add indentation for child items
              if (widget is ListTile) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: widget,
                );
              }
              return widget;
            }).toList(),
          ),
        );
      }
      // If this is a direct navigation item
      else if (item.route != null) {
        widgets.add(
          ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(item.route!);
            },
          ),
        );
      }
    }

    return widgets;
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      // Handle error
      print('Error signing out: $e');
    }
  }
}
