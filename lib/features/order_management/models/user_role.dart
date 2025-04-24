// User/Role model for Order Management Module
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Defines the different roles in the system
enum RoleType {
  salesRepresentative,
  salesSupervisor,
  branchManager,
  regionalManager,
  productionManager,
  procurementManager,
  admin,
}

/// Defines the permissions for orders
enum OrderPermission {
  view,
  create,
  edit,
  cancel,
  approve,
  changeStatus,
  viewDiscussion,
  participateInDiscussion,
  viewAuditTrail,
  viewAllCustomerInfo,
}

/// Maps roles to permissions
@immutable
class UserRolePermission {
  final RoleType role;
  final Set<OrderPermission> permissions;
  final bool canManageSubordinateOrders;
  final bool canViewAllLocations;
  final bool canEditAfterProduction;
  final bool canCancelAfterApproval;
  final bool canOverrideInventoryCheck;

  const UserRolePermission({
    required this.role,
    required this.permissions,
    this.canManageSubordinateOrders = false,
    this.canViewAllLocations = false,
    this.canEditAfterProduction = false,
    this.canCancelAfterApproval = false,
    this.canOverrideInventoryCheck = false,
  });

  /// Check if the role has a specific permission
  bool hasPermission(OrderPermission permission) {
    return permissions.contains(permission);
  }

  /// Check if a role can access orders based on location and creator
  bool canAccessOrder({
    required String orderLocation,
    required String userLocation,
    required String orderCreator,
    required String userId,
  }) {
    // Admin, RegionalManager can access all orders
    if (role == RoleType.admin || role == RoleType.regionalManager) {
      return true;
    }

    // Branch managers can access all orders in their location
    if (role == RoleType.branchManager && orderLocation == userLocation) {
      return true;
    }

    // Production/Procurement managers can access all orders in their location
    if ((role == RoleType.productionManager ||
            role == RoleType.procurementManager) &&
        orderLocation == userLocation) {
      return true;
    }

    // Sales supervisors can access own orders and their subordinates'
    if (role == RoleType.salesSupervisor) {
      return orderLocation == userLocation &&
          (orderCreator == userId || canManageSubordinateOrders);
    }

    // Sales reps can only access their own orders
    if (role == RoleType.salesRepresentative) {
      return orderCreator == userId;
    }

    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRolePermission &&
        other.role == role &&
        setEquals(other.permissions, permissions) &&
        other.canManageSubordinateOrders == canManageSubordinateOrders &&
        other.canViewAllLocations == canViewAllLocations &&
        other.canEditAfterProduction == canEditAfterProduction &&
        other.canCancelAfterApproval == canCancelAfterApproval &&
        other.canOverrideInventoryCheck == canOverrideInventoryCheck;
  }

  @override
  int get hashCode => Object.hash(
        role,
        Object.hashAll(permissions),
        canManageSubordinateOrders,
        canViewAllLocations,
        canEditAfterProduction,
        canCancelAfterApproval,
        canOverrideInventoryCheck,
      );
}

/// Extension methods for RoleType
extension RoleTypeExtension on RoleType {
  String get displayName {
    switch (this) {
      case RoleType.admin:
        return 'Administrator';
      case RoleType.salesSupervisor:
        return 'Sales Supervisor';
      case RoleType.salesRepresentative:
        return 'Sales Representative';
      case RoleType.branchManager:
        return 'Branch Manager';
      case RoleType.regionalManager:
        return 'Regional Manager';
      case RoleType.productionManager:
        return 'Production Manager';
      case RoleType.procurementManager:
        return 'Procurement Manager';
      default:
        return toString().split('.').last;
    }
  }
}
