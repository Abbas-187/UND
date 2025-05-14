import '../models/audit_record_model.dart';

/// Repository interface for inventory audit records
abstract class InventoryAuditRepository {
  /// Creates an audit record
  Future<void> createRecord(AuditRecord record);

  /// Retrieves audit records for a specific movement
  Future<List<AuditRecord>> getRecordsByMovement(String movementId);
}
