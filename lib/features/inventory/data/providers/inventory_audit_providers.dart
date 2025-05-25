import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../domain/usecases/inventory_audit_log_usecases.dart';
import '../models/inventory_audit_log_model.dart';
import '../repositories/inventory_audit_log_repository.dart';

/// Provider for the audit log repository
final inventoryAuditLogRepositoryProvider =
    Provider<InventoryAuditLogRepository>((ref) {
  return InventoryAuditLogRepository(
    logger: Logger(),
  );
});

/// Provider for the create audit log use case
final createInventoryAuditLogUseCaseProvider =
    Provider<CreateInventoryAuditLogUseCase>((ref) {
  final repository = ref.watch(inventoryAuditLogRepositoryProvider);
  return CreateInventoryAuditLogUseCase(repository);
});

/// Provider for the get entity audit logs use case
final getEntityAuditLogsUseCaseProvider =
    Provider<GetEntityAuditLogsUseCase>((ref) {
  final repository = ref.watch(inventoryAuditLogRepositoryProvider);
  return GetEntityAuditLogsUseCase(repository);
});

/// Provider for the search audit logs use case
final searchAuditLogsUseCaseProvider = Provider<SearchAuditLogsUseCase>((ref) {
  final repository = ref.watch(inventoryAuditLogRepositoryProvider);
  return SearchAuditLogsUseCase(repository);
});

/// Provider for the export audit logs to CSV use case
final exportAuditLogsToCSVUseCaseProvider =
    Provider<ExportAuditLogsToCSVUseCase>((ref) {
  final repository = ref.watch(inventoryAuditLogRepositoryProvider);
  return ExportAuditLogsToCSVUseCase(repository);
});

/// Provider for the get user audit logs use case
final getUserAuditLogsUseCaseProvider =
    Provider<GetUserAuditLogsUseCase>((ref) {
  final repository = ref.watch(inventoryAuditLogRepositoryProvider);
  return GetUserAuditLogsUseCase(repository);
});

/// Notifier for audit logs state
class AuditLogsNotifier
    extends StateNotifier<AsyncValue<List<InventoryAuditLogModel>>> {
  AuditLogsNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  /// Search audit logs with filters
  Future<void> searchAuditLogs({
    String? userId,
    String? userEmail,
    AuditActionType? actionType,
    AuditEntityType? entityType,
    String? entityId,
    String? module,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(searchAuditLogsUseCaseProvider);
      final logs = await useCase.execute(
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
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Get audit logs for a specific entity
  Future<void> getEntityAuditLogs(String entityId, {int limit = 100}) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(getEntityAuditLogsUseCaseProvider);
      final logs = await useCase.execute(entityId, limit: limit);
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Get audit logs for a specific user
  Future<void> getUserAuditLogs(String userId, {int limit = 100}) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(getUserAuditLogsUseCaseProvider);
      final logs = await useCase.execute(userId, limit: limit);
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Export audit logs to CSV
  Future<String> exportToCSV({
    String? userId,
    String? entityId,
    AuditActionType? actionType,
    AuditEntityType? entityType,
    String? module,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 1000,
  }) async {
    try {
      final useCase = ref.read(exportAuditLogsToCSVUseCaseProvider);
      return await useCase.execute(
        userId: userId,
        entityId: entityId,
        actionType: actionType,
        entityType: entityType,
        module: module,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } catch (e) {
      return 'Error exporting audit logs: $e';
    }
  }
}

/// Provider for the audit logs notifier
final auditLogsProvider = StateNotifierProvider<AuditLogsNotifier,
    AsyncValue<List<InventoryAuditLogModel>>>(
  (ref) => AuditLogsNotifier(ref),
);
