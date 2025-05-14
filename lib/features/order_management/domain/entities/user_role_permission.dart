enum RoleType {
  salesRepresentative,
  salesSupervisor,
  branchManager,
  regionalManager,
  productionManager,
  procurementManager,
  admin,
}

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

class UserRolePermission {

  const UserRolePermission({
    required this.role,
    required this.permissions,
    this.canManageSubordinateOrders = false,
    this.canViewAllLocations = false,
    this.canEditAfterProduction = false,
    this.canCancelAfterApproval = false,
    this.canOverrideInventoryCheck = false,
  });
  final RoleType role;
  final Set<OrderPermission> permissions;
  final bool canManageSubordinateOrders;
  final bool canViewAllLocations;
  final bool canEditAfterProduction;
  final bool canCancelAfterApproval;
  final bool canOverrideInventoryCheck;

  bool hasPermission(OrderPermission permission) =>
      permissions.contains(permission);
}
