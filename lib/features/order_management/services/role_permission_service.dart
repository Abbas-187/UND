import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import '../models/order.dart';

/// Service for handling role-based permissions in the order management module
class RolePermissionService {
  // Default permission mappings for different roles
  final Map<RoleType, UserRolePermission> _rolePermissions = {
    RoleType.admin: UserRolePermission(
      role: RoleType.admin,
      permissions: {
        OrderPermission.view,
        OrderPermission.create,
        OrderPermission.edit,
        OrderPermission.cancel,
        OrderPermission.approve,
        OrderPermission.changeStatus,
        OrderPermission.viewDiscussion,
        OrderPermission.participateInDiscussion,
        OrderPermission.viewAuditTrail,
        OrderPermission.viewAllCustomerInfo,
      },
      canManageSubordinateOrders: true,
      canViewAllLocations: true,
      canEditAfterProduction: true,
      canCancelAfterApproval: true,
      canOverrideInventoryCheck: true,
    ),
    RoleType.regionalManager: UserRolePermission(
      role: RoleType.regionalManager,
      permissions: {
        OrderPermission.view,
        OrderPermission.create,
        OrderPermission.edit,
        OrderPermission.cancel,
        OrderPermission.approve,
        OrderPermission.changeStatus,
        OrderPermission.viewDiscussion,
        OrderPermission.participateInDiscussion,
        OrderPermission.viewAuditTrail,
        OrderPermission.viewAllCustomerInfo,
      },
      canManageSubordinateOrders: true,
      canViewAllLocations: true,
      canEditAfterProduction: false,
      canCancelAfterApproval: true,
      canOverrideInventoryCheck: true,
    ),
    RoleType.branchManager: UserRolePermission(
      role: RoleType.branchManager,
      permissions: {
        OrderPermission.view,
        OrderPermission.create,
        OrderPermission.edit,
        OrderPermission.cancel,
        OrderPermission.approve,
        OrderPermission.changeStatus,
        OrderPermission.viewDiscussion,
        OrderPermission.participateInDiscussion,
        OrderPermission.viewAuditTrail,
        OrderPermission.viewAllCustomerInfo,
      },
      canManageSubordinateOrders: true,
      canViewAllLocations: false,
      canEditAfterProduction: false,
      canCancelAfterApproval: true,
      canOverrideInventoryCheck: false,
    ),
    RoleType.salesSupervisor: UserRolePermission(
      role: RoleType.salesSupervisor,
      permissions: {
        OrderPermission.view,
        OrderPermission.create,
        OrderPermission.edit,
        OrderPermission.cancel,
        OrderPermission.viewDiscussion,
        OrderPermission.participateInDiscussion,
      },
      canManageSubordinateOrders: true,
      canViewAllLocations: false,
      canEditAfterProduction: false,
      canCancelAfterApproval: false,
      canOverrideInventoryCheck: false,
    ),
    RoleType.salesRepresentative: UserRolePermission(
      role: RoleType.salesRepresentative,
      permissions: {
        OrderPermission.view,
        OrderPermission.create,
        OrderPermission.participateInDiscussion,
      },
      canManageSubordinateOrders: false,
      canViewAllLocations: false,
      canEditAfterProduction: false,
      canCancelAfterApproval: false,
      canOverrideInventoryCheck: false,
    ),
    RoleType.productionManager: UserRolePermission(
      role: RoleType.productionManager,
      permissions: {
        OrderPermission.view,
        OrderPermission.changeStatus,
        OrderPermission.viewDiscussion,
        OrderPermission.participateInDiscussion,
      },
      canManageSubordinateOrders: false,
      canViewAllLocations: false,
      canEditAfterProduction: false,
      canCancelAfterApproval: false,
      canOverrideInventoryCheck: false,
    ),
    RoleType.procurementManager: UserRolePermission(
      role: RoleType.procurementManager,
      permissions: {
        OrderPermission.view,
        OrderPermission.changeStatus,
        OrderPermission.viewDiscussion,
        OrderPermission.participateInDiscussion,
      },
      canManageSubordinateOrders: false,
      canViewAllLocations: false,
      canEditAfterProduction: false,
      canCancelAfterApproval: false,
      canOverrideInventoryCheck: false,
    ),
  };

  // Customer-specific role permissions (for special customers/key accounts)
  final Map<String, Map<RoleType, UserRolePermission>>
      _customerSpecificPermissions = {};

  /// Check if a user has permission to perform an action on an order
  bool hasPermission(
    String userId,
    RoleType userRole,
    String userLocation,
    OrderPermission permission,
    Order order,
  ) {
    // First check if there are customer-specific permissions for this order's customer
    if (_customerSpecificPermissions.containsKey(order.customer)) {
      final customerPermissions = _customerSpecificPermissions[order.customer];
      if (customerPermissions != null &&
          customerPermissions.containsKey(userRole)) {
        final rolePermission = customerPermissions[userRole]!;

        // Check if user can access this order based on location and creator
        final canAccess = rolePermission.canAccessOrder(
          orderLocation: order.location,
          userLocation: userLocation,
          orderCreator: order.createdBy,
          userId: userId,
        );

        if (!canAccess) {
          return false;
        }

        // Check specific permission
        return rolePermission.hasPermission(permission);
      }
    }

    // Fall back to default role permissions
    final rolePermission = _rolePermissions[userRole];
    if (rolePermission == null) {
      return false;
    }

    // Check if user can access this order based on location and creator
    final canAccess = rolePermission.canAccessOrder(
      orderLocation: order.location,
      userLocation: userLocation,
      orderCreator: order.createdBy,
      userId: userId,
    );

    if (!canAccess) {
      return false;
    }

    // Check specific permission
    return rolePermission.hasPermission(permission);
  }

  /// Check if a user can edit an order after it's in production
  bool canEditAfterProduction(String userId, RoleType userRole, Order order) {
    // First check customer-specific permissions
    if (_customerSpecificPermissions.containsKey(order.customer)) {
      final customerPermissions = _customerSpecificPermissions[order.customer];
      if (customerPermissions != null &&
          customerPermissions.containsKey(userRole)) {
        return customerPermissions[userRole]!.canEditAfterProduction;
      }
    }

    // Fall back to default permissions
    final rolePermission = _rolePermissions[userRole];
    return rolePermission?.canEditAfterProduction ?? false;
  }

  /// Check if a user can cancel an order after it's been approved
  bool canCancelAfterApproval(String userId, RoleType userRole, Order order) {
    // First check customer-specific permissions
    if (_customerSpecificPermissions.containsKey(order.customer)) {
      final customerPermissions = _customerSpecificPermissions[order.customer];
      if (customerPermissions != null &&
          customerPermissions.containsKey(userRole)) {
        return customerPermissions[userRole]!.canCancelAfterApproval;
      }
    }

    // Fall back to default permissions
    final rolePermission = _rolePermissions[userRole];
    return rolePermission?.canCancelAfterApproval ?? false;
  }

  /// Check if a user can override inventory checks for an order
  bool canOverrideInventoryCheck(
      String userId, RoleType userRole, Order order) {
    // First check customer-specific permissions
    if (_customerSpecificPermissions.containsKey(order.customer)) {
      final customerPermissions = _customerSpecificPermissions[order.customer];
      if (customerPermissions != null &&
          customerPermissions.containsKey(userRole)) {
        return customerPermissions[userRole]!.canOverrideInventoryCheck;
      }
    }

    // Fall back to default permissions
    final rolePermission = _rolePermissions[userRole];
    return rolePermission?.canOverrideInventoryCheck ?? false;
  }

  /// Set up customer-specific permissions (for key accounts)
  void setCustomerSpecificPermissions(
      String customerId, RoleType role, UserRolePermission permissions) {
    if (!_customerSpecificPermissions.containsKey(customerId)) {
      _customerSpecificPermissions[customerId] = {};
    }

    _customerSpecificPermissions[customerId]![role] = permissions;
  }

  /// Get all roles that a user can see in the UI based on their role
  Set<RoleType> getVisibleRolesForUser(RoleType userRole) {
    switch (userRole) {
      case RoleType.admin:
      case RoleType.regionalManager:
        return Set.from(RoleType.values); // All roles

      case RoleType.branchManager:
        return {
          RoleType.branchManager,
          RoleType.salesSupervisor,
          RoleType.salesRepresentative,
          RoleType.productionManager,
          RoleType.procurementManager,
        };

      case RoleType.salesSupervisor:
        return {
          RoleType.salesSupervisor,
          RoleType.salesRepresentative,
        };

      default:
        return {userRole}; // Only own role
    }
  }

  /// Determine if order fields should be enabled or disabled in UI based on permissions
  Map<String, bool> getEnabledOrderFields(
    String userId,
    RoleType userRole,
    String userLocation,
    Order order,
  ) {
    final bool canEdit = hasPermission(
        userId, userRole, userLocation, OrderPermission.edit, order);

    final bool canCancel = hasPermission(
        userId, userRole, userLocation, OrderPermission.cancel, order);

    final bool canChangeStatus = hasPermission(
        userId, userRole, userLocation, OrderPermission.changeStatus, order);

    // Check if order is in a state that allows editing
    bool orderStateAllowsEdit = order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.completed;

    // Special check for orders in production
    if (order.status == OrderStatus.inProduction) {
      orderStateAllowsEdit = canEditAfterProduction(userId, userRole, order);
    }

    // Special check for orders that have been approved
    bool orderStateAllowsCancel = order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.completed;

    if (order.status == OrderStatus.approved) {
      orderStateAllowsCancel = canCancelAfterApproval(userId, userRole, order);
    }

    return {
      'customer': canEdit && orderStateAllowsEdit,
      'items': canEdit && orderStateAllowsEdit,
      'location': canEdit && orderStateAllowsEdit,
      'status': canChangeStatus,
      'recipeId': canEdit && orderStateAllowsEdit,
      'cancel': canCancel && orderStateAllowsCancel,
    };
  }
}

// Provider for the RolePermissionService
final rolePermissionServiceProvider = Provider<RolePermissionService>((ref) {
  return RolePermissionService();
});
