
class CrmAuditLogEntry {

  CrmAuditLogEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.userId,
    required this.timestamp,
    required this.changes,
  });
  final String id;
  final String entityType; // e.g., 'customer', 'interaction', 'order'
  final String entityId;
  final String action; // e.g., 'create', 'update', 'delete'
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> changes;
}

class CrmAuditLogService {
  final List<CrmAuditLogEntry> _entries = [];

  List<CrmAuditLogEntry> get entries => List.unmodifiable(_entries);

  void logChange({
    required String entityType,
    required String entityId,
    required String action,
    required String userId,
    required Map<String, dynamic> changes,
  }) {
    final entry = CrmAuditLogEntry(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      entityType: entityType,
      entityId: entityId,
      action: action,
      userId: userId,
      timestamp: DateTime.now(),
      changes: changes,
    );
    _entries.add(entry);
  }

  List<CrmAuditLogEntry> getEntityHistory(String entityType, String entityId) {
    return _entries
        .where((e) => e.entityType == entityType && e.entityId == entityId)
        .toList();
  }
}
