import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../features/inventory/data/models/inventory_audit_log_model.dart';

part 'audit_middleware.g.dart';

/// Middleware that logs all actions to a Firestore audit logs collection
class AuditMiddleware {
  AuditMiddleware({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DeviceInfoPlugin? deviceInfo,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DeviceInfoPlugin _deviceInfo;
  final String _auditLogsCollection = 'inventory_audit_logs';

  /// Log an action to the audit trail
  Future<void> logAction({
    required String action,
    required String module,
    required AuditEntityType entityType,
    String? entityId,
    Map<String, dynamic>? beforeState,
    Map<String, dynamic>? afterState,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? 'unknown';
      final userEmail = currentUser?.email;

      // Map the action string to AuditActionType enum
      final actionType = _mapActionToType(action);

      // Get device information if available
      final deviceInfo = await _getDeviceInfo();

      // Create the audit log model
      final auditLog = InventoryAuditLogModel(
        id: const Uuid().v4(),
        userId: userId,
        userEmail: userEmail,
        userName: currentUser?.displayName,
        actionType: actionType,
        entityType: entityType,
        entityId: entityId ?? 'unknown',
        timestamp: DateTime.now(),
        module: module,
        description: description,
        beforeState: beforeState,
        afterState: afterState,
        deviceInfo: deviceInfo,
        metadata: metadata,
      );

      // Save to Firestore
      await _firestore
          .collection(_auditLogsCollection)
          .doc(auditLog.id)
          .set(auditLog.toFirestore());
    } catch (e) {
      debugPrint('Error logging audit action: $e');
      // Consider how you want to handle errors here - silent fail or rethrow
    }
  }

  /// Map action string to AuditActionType enum
  AuditActionType _mapActionToType(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return AuditActionType.create;
      case 'update':
        return AuditActionType.update;
      case 'delete':
        return AuditActionType.delete;
      case 'view':
        return AuditActionType.view;
      case 'export':
        return AuditActionType.export;
      case 'status_change':
      case 'statuschange':
        return AuditActionType.statusChange;
      case 'quality_change':
      case 'qualitychange':
        return AuditActionType.qualityChange;
      case 'location_change':
      case 'locationchange':
        return AuditActionType.locationChange;
      case 'quantity_adjustment':
      case 'quantityadjustment':
        return AuditActionType.quantityAdjustment;
      case 'batch_attribute_change':
      case 'batchattributechange':
        return AuditActionType.batchAttributeChange;
      case 'cost_update':
      case 'costupdate':
        return AuditActionType.costUpdate;
      default:
        return AuditActionType.other;
    }
  }

  /// Get device information
  Future<String?> _getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return '${webInfo.browserName}, ${webInfo.platform}';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}, Android ${androidInfo.version.release}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.name} ${iosInfo.systemName} ${iosInfo.systemVersion}';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return 'Windows ${windowsInfo.displayVersion}';
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return 'macOS ${macOsInfo.osRelease}';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return 'Linux ${linuxInfo.prettyName}';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return null;
    }
  }
}

@riverpod
AuditMiddleware auditMiddleware(AuditMiddlewareRef ref) {
  return AuditMiddleware();
}
