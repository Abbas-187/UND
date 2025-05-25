import '../../data/models/inventory_audit_log_model.dart';
import '../../data/repositories/inventory_audit_log_repository.dart';

/// Use case for creating audit logs
class CreateInventoryAuditLogUseCase {
  CreateInventoryAuditLogUseCase(this._repository);
  final InventoryAuditLogRepository _repository;

  /// Execute the use case to create an audit log
  Future<void> execute(InventoryAuditLogModel log) async {
    return _repository.createAuditLog(log);
  }
}

/// Use case for retrieving audit logs for a specific entity
class GetEntityAuditLogsUseCase {
  GetEntityAuditLogsUseCase(this._repository);
  final InventoryAuditLogRepository _repository;

  /// Execute the use case to get audit logs for an entity
  Future<List<InventoryAuditLogModel>> execute(String entityId,
      {int limit = 100}) {
    return _repository.getAuditLogsByEntityId(entityId, limit: limit);
  }
}

/// Use case for searching audit logs with multiple criteria
class SearchAuditLogsUseCase {
  SearchAuditLogsUseCase(this._repository);
  final InventoryAuditLogRepository _repository;

  /// Execute the use case to search audit logs
  Future<List<InventoryAuditLogModel>> execute({
    String? userId,
    String? userEmail,
    AuditActionType? actionType,
    AuditEntityType? entityType,
    String? entityId,
    String? module,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    return _repository.searchAuditLogs(
      userId: userId,
      userEmail: userEmail,
      actionType: actionType,
      entityType: entityType,
      entityId: entityId,
      module: module,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
}

/// Use case for exporting audit logs to CSV
class ExportAuditLogsToCSVUseCase {
  ExportAuditLogsToCSVUseCase(this._repository);
  final InventoryAuditLogRepository _repository;

  /// Execute the use case to export audit logs to CSV
  Future<String> execute({
    String? userId,
    String? entityId,
    AuditActionType? actionType,
    AuditEntityType? entityType,
    String? module,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 1000,
  }) {
    return _repository.exportAuditLogsToCSV(
      userId: userId,
      entityId: entityId,
      actionType: actionType,
      entityType: entityType,
      module: module,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
}

/// Use case for retrieving user activity audit logs
class GetUserAuditLogsUseCase {
  GetUserAuditLogsUseCase(this._repository);
  final InventoryAuditLogRepository _repository;

  /// Execute the use case to get audit logs for a user
  Future<List<InventoryAuditLogModel>> execute(String userId,
      {int limit = 100}) {
    return _repository.getAuditLogsByUserId(userId, limit: limit);
  }
}
