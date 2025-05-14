
enum CrmRole { admin, user, viewer }

class CrmPermissionService {
  static bool canViewCustomers(CrmRole role) => true;
  static bool canEditCustomers(CrmRole role) =>
      role == CrmRole.admin || role == CrmRole.user;
  static bool canDeleteCustomers(CrmRole role) => role == CrmRole.admin;
  static bool canExportData(CrmRole role) => role == CrmRole.admin;
  static bool canImportData(CrmRole role) => role == CrmRole.admin;
  static bool canViewAnalytics(CrmRole role) => role != CrmRole.viewer;
  static bool canManageReminders(CrmRole role) =>
      role == CrmRole.admin || role == CrmRole.user;
  // Add more permission checks as needed
}
