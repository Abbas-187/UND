import 'user_role.dart';

/// Defines the available permissions in the system
enum Permission {
  // Inventory permissions
  inventoryView,
  inventoryEdit,
  inventoryCreate,
  inventoryDelete,
  manageInventoryCategories,
  viewInventoryAlerts,
  printLabels,
  scanBarcodes,

  // Supplier permissions
  supplierView,
  supplierEdit,
  supplierCreate,
  supplierDelete,

  // Analytics permissions
  analyticsView,
  analyticsDashboard,
  analyticsExport,

  // Sales permissions
  salesView,
  salesCreate,
  salesEdit,
  salesDelete,

  // User management permissions
  userView,
  userEdit,
  userCreate,
  userDelete,
  userManage,
  manageRoles,

  // Settings permissions
  settingsView,
  settingsEdit,

  // Forecasting permissions
  forecastingView,
  forecastingCreate,
  forecastingEdit;

  /// Returns a user-friendly display name for the permission
  String get displayName {
    final name = toString().split('.').last;
    final result = name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    );
    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }
}

/// Maps user roles to their allowed permissions
class PermissionManager {
  /// Maps each role to its set of permissions
  static final Map<UserRole, Set<Permission>> _rolePermissions = {
    UserRole.admin: Permission.values.toSet(),
    UserRole.manager: {
      // Inventory permissions
      Permission.inventoryView,
      Permission.inventoryEdit,
      Permission.inventoryCreate,
      Permission.inventoryDelete,
      Permission.manageInventoryCategories,
      Permission.viewInventoryAlerts,
      Permission.printLabels,
      Permission.scanBarcodes,

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

      // User permissions (limited)
      Permission.userView,

      // Settings permissions
      Permission.settingsView,
      Permission.settingsEdit,

      // Forecasting permissions
      Permission.forecastingView,
      Permission.forecastingCreate,
      Permission.forecastingEdit,
    },
    UserRole.warehouseStaff: {
      // Inventory permissions
      Permission.inventoryView,
      Permission.inventoryEdit,
      Permission.inventoryCreate,
      Permission.viewInventoryAlerts,
      Permission.printLabels,
      Permission.scanBarcodes,

      // Limited supplier permissions
      Permission.supplierView,

      // Limited analytics
      Permission.analyticsView,
    },
    UserRole.salesStaff: {
      // Limited inventory
      Permission.inventoryView,
      Permission.viewInventoryAlerts,

      // Sales permissions
      Permission.salesView,
      Permission.salesCreate,
      Permission.salesEdit,

      // Limited analytics
      Permission.analyticsView,

      // Forecasting
      Permission.forecastingView,
    },
    UserRole.accountingStaff: {
      // View-only for inventory
      Permission.inventoryView,

      // View-only for suppliers
      Permission.supplierView,

      // Analytics
      Permission.analyticsView,
      Permission.analyticsExport,

      // View-only for sales
      Permission.salesView,

      // Forecasting view
      Permission.forecastingView,
    },
    UserRole.viewer: {
      // View-only permissions
      Permission.inventoryView,
      Permission.supplierView,
      Permission.analyticsView,
      Permission.salesView,
      Permission.forecastingView,
    },
  };

  /// Checks if the given role has the specified permission
  static bool hasPermission(UserRole role, Permission permission) {
    // Admin has all permissions
    if (role == UserRole.admin) return true;

    // Check if the role has the specific permission
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  /// Get all permissions for a given role
  static Set<Permission> getPermissionsForRole(UserRole role) {
    return _rolePermissions[role] ?? {};
  }
}
