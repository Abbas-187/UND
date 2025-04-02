import 'permission.dart';

/// Defines the possible user roles in the system
enum UserRole {
  /// Administrator with full access to all features
  admin,

  /// Manager with high-level access to most features
  manager,

  /// Staff responsible for warehouse operations
  warehouseStaff,

  /// Staff responsible for sales operations
  salesStaff,

  /// Staff responsible for accounting operations
  accountingStaff,

  /// Basic user with limited read-only access
  viewer;

  /// Get a user-friendly display name for the role
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.warehouseStaff:
        return 'Warehouse Staff';
      case UserRole.salesStaff:
        return 'Sales Staff';
      case UserRole.accountingStaff:
        return 'Accounting Staff';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  /// Get the permissions for this role
  List<Permission> get permissions {
    switch (this) {
      case UserRole.admin:
        // Admin has all permissions
        return Permission.values.toList();

      case UserRole.manager:
        // Manager has most permissions, but not user management
        return [
          // Inventory permissions
          Permission.inventoryView,
          Permission.inventoryEdit,
          Permission.inventoryCreate,
          Permission.inventoryDelete,

          // Supplier permissions
          Permission.supplierView,
          Permission.supplierEdit,
          Permission.supplierCreate,
          Permission.supplierDelete,

          // Analytics permissions
          Permission.analyticsView,
          Permission.analyticsDashboard,
          Permission.analyticsExport,

          // Sales permissions
          Permission.salesView,
          Permission.salesCreate,
          Permission.salesEdit,
          Permission.salesDelete,

          // Forecasting permissions
          Permission.forecastingView,
          Permission.forecastingCreate,
          Permission.forecastingEdit,

          // Settings permissions
          Permission.settingsView,
          Permission.settingsEdit,
        ];

      case UserRole.warehouseStaff:
        // Warehouse staff focused on inventory
        return [
          // Inventory permissions
          Permission.inventoryView,
          Permission.inventoryEdit,
          Permission.inventoryCreate,

          // Supplier permissions (view only)
          Permission.supplierView,

          // Analytics permissions (limited)
          Permission.analyticsView,

          // Settings permissions (view only)
          Permission.settingsView,
        ];

      case UserRole.salesStaff:
        // Sales staff focused on sales and customers
        return [
          // Inventory permissions (view only)
          Permission.inventoryView,

          // Supplier permissions (view only)
          Permission.supplierView,

          // Sales permissions
          Permission.salesView,
          Permission.salesCreate,
          Permission.salesEdit,

          // Analytics permissions (limited)
          Permission.analyticsView,

          // Settings permissions (view only)
          Permission.settingsView,
        ];

      case UserRole.accountingStaff:
        // Accounting staff focused on finances
        return [
          // Inventory permissions (view only)
          Permission.inventoryView,

          // Sales permissions (view only)
          Permission.salesView,

          // Analytics permissions
          Permission.analyticsView,
          Permission.analyticsExport,

          // Settings permissions (view only)
          Permission.settingsView,
        ];

      case UserRole.viewer:
        // Viewer has read-only access to basic features
        return [
          // Inventory permissions (view only)
          Permission.inventoryView,

          // Supplier permissions (view only)
          Permission.supplierView,

          // Sales permissions (view only)
          Permission.salesView,
        ];
    }
  }

  /// Check if this role has a specific permission
  bool hasPermission(Permission permission) {
    return permissions.contains(permission);
  }

  /// Check if this role has higher or equal privileges than another role
  bool hasHigherOrEqualPrivilegesThan(UserRole otherRole) {
    // Define the hierarchy of roles (higher index = lower privileges)
    final roleHierarchy = [
      UserRole.admin,
      UserRole.manager,
      UserRole.accountingStaff,
      UserRole.salesStaff,
      UserRole.warehouseStaff,
      UserRole.viewer,
    ];

    final thisIndex = roleHierarchy.indexOf(this);
    final otherIndex = roleHierarchy.indexOf(otherRole);

    // Lower index means higher privileges
    return thisIndex <= otherIndex;
  }

  /// Parse a role from a string
  static UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.viewer;

    try {
      return UserRole.values.firstWhere(
        (role) => role.name == roleStr,
        orElse: () => UserRole.viewer,
      );
    } catch (_) {
      return UserRole.viewer;
    }
  }
}
