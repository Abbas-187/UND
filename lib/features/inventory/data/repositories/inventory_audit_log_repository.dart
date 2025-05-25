import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../models/inventory_audit_log_model.dart';

/// Repository for managing inventory audit logs
class InventoryAuditLogRepository {
  InventoryAuditLogRepository({
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger();

  final FirebaseFirestore _firestore;
  final Logger _logger;
  static const String _collectionName = 'inventory_audit_logs';

  /// Get reference to the audit logs collection
  CollectionReference<Map<String, dynamic>> get _auditLogsCollection =>
      _firestore.collection(_collectionName);

  /// Create a new audit log entry
  Future<void> createAuditLog(InventoryAuditLogModel log) async {
    try {
      await _auditLogsCollection.doc(log.id).set(log.toFirestore());
    } catch (e, stackTrace) {
      _logger.e('Error creating audit log', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get audit logs by entity ID (e.g., for a specific inventory item)
  Future<List<InventoryAuditLogModel>> getAuditLogsByEntityId(
    String entityId, {
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _auditLogsCollection
          .where('entityId', isEqualTo: entityId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return _processQuerySnapshot(querySnapshot);
    } catch (e, stackTrace) {
      _logger.e('Error getting audit logs by entity ID: $entityId',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get audit logs by user ID
  Future<List<InventoryAuditLogModel>> getAuditLogsByUserId(
    String userId, {
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _auditLogsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return _processQuerySnapshot(querySnapshot);
    } catch (e, stackTrace) {
      _logger.e('Error getting audit logs by user ID: $userId',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get audit logs for a specific module
  Future<List<InventoryAuditLogModel>> getAuditLogsByModule(
    String module, {
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _auditLogsCollection
          .where('module', isEqualTo: module)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return _processQuerySnapshot(querySnapshot);
    } catch (e, stackTrace) {
      _logger.e('Error getting audit logs by module: $module',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get audit logs by action type
  Future<List<InventoryAuditLogModel>> getAuditLogsByActionType(
    AuditActionType actionType, {
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _auditLogsCollection
          .where('actionType', isEqualTo: actionType.toString().split('.').last)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return _processQuerySnapshot(querySnapshot);
    } catch (e, stackTrace) {
      _logger.e('Error getting audit logs by action type: $actionType',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get audit logs for a specific entity type
  Future<List<InventoryAuditLogModel>> getAuditLogsByEntityType(
    AuditEntityType entityType, {
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _auditLogsCollection
          .where('entityType', isEqualTo: entityType.toString().split('.').last)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return _processQuerySnapshot(querySnapshot);
    } catch (e, stackTrace) {
      _logger.e('Error getting audit logs by entity type: $entityType',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get audit logs within a specific date range
  Future<List<InventoryAuditLogModel>> getAuditLogsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int limit = 100,
  }) async {
    try {
      // Convert DateTime to Timestamp for Firestore query
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate);

      final querySnapshot = await _auditLogsCollection
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return _processQuerySnapshot(querySnapshot);
    } catch (e, stackTrace) {
      _logger.e('Error getting audit logs by date range',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Advanced search for audit logs with multiple filters
  Future<List<InventoryAuditLogModel>> searchAuditLogs({
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
    try {
      // Start with a base query
      Query<Map<String, dynamic>> query = _auditLogsCollection;

      // Add filters if provided
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (userEmail != null) {
        query = query.where('userEmail', isEqualTo: userEmail);
      }

      if (actionType != null) {
        query = query.where('actionType',
            isEqualTo: actionType.toString().split('.').last);
      }

      if (entityType != null) {
        query = query.where('entityType',
            isEqualTo: entityType.toString().split('.').last);
      }

      if (entityId != null) {
        query = query.where('entityId', isEqualTo: entityId);
      }

      if (module != null) {
        query = query.where('module', isEqualTo: module);
      }

      // Add date range filters if provided
      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      // Add order by timestamp and limit
      query = query.orderBy('timestamp', descending: true).limit(limit);

      // Execute the query
      final querySnapshot = await query.get();
      return _processQuerySnapshot(querySnapshot);
    } catch (e, stackTrace) {
      _logger.e('Error searching audit logs', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Export audit logs to CSV format
  Future<String> exportAuditLogsToCSV({
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
      // Get filtered logs
      final logs = await searchAuditLogs(
        userId: userId,
        entityId: entityId,
        actionType: actionType,
        entityType: entityType,
        module: module,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // CSV header
      final csvContent = StringBuffer(
          'ID,User ID,User Email,Action Type,Entity Type,Entity ID,Timestamp,Module,Description\n');

      // Add each log as a CSV row
      for (final log in logs) {
        csvContent.writeln('${log.id},'
            '${log.userId},'
            '${log.userEmail ?? ""},'
            '${log.actionType},'
            '${log.entityType},'
            '${log.entityId},'
            '${log.timestamp.toIso8601String()},'
            '${log.module},'
            '"${log.description?.replaceAll('"', '""') ?? ""}"');
      }

      return csvContent.toString();
    } catch (e, stackTrace) {
      _logger.e('Error exporting audit logs to CSV',
          error: e, stackTrace: stackTrace);
      return 'Error exporting audit logs: $e';
    }
  }

  /// Helper method to process query snapshots into InventoryAuditLogModel list
  List<InventoryAuditLogModel> _processQuerySnapshot(
      QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final data = doc.data();

      // Ensure the ID is included
      if (!data.containsKey('id')) {
        data['id'] = doc.id;
      }

      // Convert Firestore timestamp to DateTime
      if (data['timestamp'] is Timestamp) {
        data['timestamp'] =
            (data['timestamp'] as Timestamp).toDate().toIso8601String();
      }

      return InventoryAuditLogModel.fromJson(data);
    }).toList();
  }
}
