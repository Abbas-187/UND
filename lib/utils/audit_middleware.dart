import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audit_middleware.g.dart';

/// Middleware that logs all actions to a Firestore 'audit_logs' collection
class AuditMiddleware {
  AuditMiddleware({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> logAction({
    required String action,
    required String module,
    String? targetId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid;
      final userEmail = currentUser?.email;

      await _firestore.collection('audit_logs').add({
        'userId': userId,
        'userEmail': userEmail,
        'action': action,
        'module': module,
        'targetId': targetId,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging audit action: $e');
      // Consider how you want to handle errors here - silent fail or rethrow
    }
  }
}

@riverpod
AuditMiddleware auditMiddleware(AuditMiddlewareRef ref) {
  return AuditMiddleware();
}
