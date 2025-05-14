import 'package:flutter/material.dart';

/// Defines the different user roles in the application
@immutable
class UserRole {

  const UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.allowedModules,
    this.canAccessSettings = true,
    this.canAccessNotifications = true,
  });
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> allowedModules;
  final bool canAccessSettings;
  final bool canAccessNotifications;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRole && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Predefined user roles for testing
class UserRoles {
  // Admin has access to everything
  static const UserRole admin = UserRole(
    id: 'admin',
    name: 'Administrator',
    description: 'Full access to all features',
    icon: Icons.admin_panel_settings,
    allowedModules: [
      'inventory',
      'factory',
      'milk_reception',
      'procurement',
      'analytics',
      'forecasting',
      'crm',
      'order_management'
    ],
    canAccessSettings: true,
    canAccessNotifications: true,
  );

  // Manager has access to most features except some sensitive settings
  static const UserRole manager = UserRole(
    id: 'manager',
    name: 'Manager',
    description: 'Access to management features',
    icon: Icons.manage_accounts,
    allowedModules: [
      'inventory',
      'factory',
      'milk_reception',
      'procurement',
      'analytics',
      'forecasting',
      'crm',
      'order_management'
    ],
  );

  // Worker has limited access focused on production and inventory
  static const UserRole worker = UserRole(
    id: 'worker',
    name: 'Factory Worker',
    description: 'Access to factory and inventory only',
    icon: Icons.engineering,
    allowedModules: ['factory', 'inventory'],
    canAccessSettings: false,
  );

  // Procurement specialist focused on purchasing
  static const UserRole procurement = UserRole(
    id: 'procurement',
    name: 'Procurement Specialist',
    description: 'Access to purchasing and inventory',
    icon: Icons.shopping_cart,
    allowedModules: ['procurement', 'inventory'],
  );

  // Analytics specialist focused on data analysis
  static const UserRole analyst = UserRole(
    id: 'analyst',
    name: 'Analyst',
    description: 'Access to analytics and forecasting',
    icon: Icons.analytics,
    allowedModules: ['analytics', 'forecasting'],
  );

  // CRM specialist focused on customer relations
  static const UserRole crmSpecialist = UserRole(
    id: 'crm',
    name: 'CRM Specialist',
    description: 'Access to CRM and order management',
    icon: Icons.people,
    allowedModules: ['crm', 'order_management'],
  );

  // List of all available roles
  static const List<UserRole> allRoles = [
    admin,
    manager,
    worker,
    procurement,
    analyst,
    crmSpecialist,
  ];
}
