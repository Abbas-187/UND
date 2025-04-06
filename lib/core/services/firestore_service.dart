import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the Firestore service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

/// Service for handling Firestore database operations
class FirestoreService {

  /// Constructor
  FirestoreService(this._firestore);
  final FirebaseFirestore _firestore;

  /// Get a collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a document reference
  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  /// Get document from Firestore
  Future<Map<String, dynamic>?> getDocument(
      String collectionPath, String docId) async {
    final docRef = _firestore.collection(collectionPath).doc(docId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return null;
    }

    final data = docSnapshot.data();
    if (data == null) {
      return null;
    }

    // Include ID in the data
    return {'id': docSnapshot.id, ...data};
  }

  /// Get all documents from a collection
  Future<List<Map<String, dynamic>>> getCollection(
      String collectionPath) async {
    final querySnapshot = await _firestore.collection(collectionPath).get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  /// Query documents from a collection with filters
  Future<List<Map<String, dynamic>>> queryCollection(
    String collectionPath, {
    List<QueryFilter> filters = const [],
    List<QueryOrder> orders = const [],
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    // Apply filters
    for (final filter in filters) {
      query = filter.apply(query);
    }

    // Apply order
    for (final order in orders) {
      query = order.apply(query);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  /// Set document data in Firestore
  Future<void> setDocument(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    // Create a copy without the id field to avoid duplication
    final dataWithoutId = Map<String, dynamic>.from(data)..remove('id');

    // Add metadata for sync
    dataWithoutId['updatedAt'] = FieldValue.serverTimestamp();

    // Set the document
    await _firestore.collection(collectionPath).doc(docId).set(
          dataWithoutId,
          SetOptions(merge: true),
        );
  }

  /// Add a new document to a collection
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    // Create a copy without the id field to avoid duplication
    final dataWithoutId = Map<String, dynamic>.from(data)..remove('id');

    // Add metadata for sync
    dataWithoutId['createdAt'] = FieldValue.serverTimestamp();
    dataWithoutId['updatedAt'] = FieldValue.serverTimestamp();

    // Add the document
    return await _firestore.collection(collectionPath).add(dataWithoutId);
  }

  /// Update document data in Firestore
  Future<void> updateDocument(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    // Create a copy without the id field to avoid duplication
    final dataWithoutId = Map<String, dynamic>.from(data)..remove('id');

    // Add metadata for sync
    dataWithoutId['updatedAt'] = FieldValue.serverTimestamp();

    // Update the document
    await _firestore
        .collection(collectionPath)
        .doc(docId)
        .update(dataWithoutId);
  }

  /// Delete document from Firestore
  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _firestore.collection(collectionPath).doc(docId).delete();
  }

  /// Get documents updated since a specific time
  Future<List<Map<String, dynamic>>> getDocumentsModifiedSince(
    String collectionPath,
    DateTime? since,
  ) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    if (since != null) {
      query = query.where('updatedAt', isGreaterThan: since);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  /// Watch a document for real-time updates
  Stream<Map<String, dynamic>?> watchDocument(
      String collectionPath, String docId) {
    return _firestore
        .collection(collectionPath)
        .doc(docId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      if (data == null) {
        return null;
      }

      return {'id': snapshot.id, ...data};
    });
  }

  /// Watch a collection for real-time updates
  Stream<List<Map<String, dynamic>>> watchCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    });
  }
}

/// Filter for Firestore queries
class QueryFilter {

  QueryFilter({
    required this.field,
    required this.value,
    required this.operator,
  });
  final String field;
  final dynamic value;
  final FilterOperator operator;

  Query<Map<String, dynamic>> apply(Query<Map<String, dynamic>> query) {
    switch (operator) {
      case FilterOperator.isEqualTo:
        return query.where(field, isEqualTo: value);
      case FilterOperator.isNotEqualTo:
        return query.where(field, isNotEqualTo: value);
      case FilterOperator.isLessThan:
        return query.where(field, isLessThan: value);
      case FilterOperator.isLessThanOrEqualTo:
        return query.where(field, isLessThanOrEqualTo: value);
      case FilterOperator.isGreaterThan:
        return query.where(field, isGreaterThan: value);
      case FilterOperator.isGreaterThanOrEqualTo:
        return query.where(field, isGreaterThanOrEqualTo: value);
      case FilterOperator.arrayContains:
        return query.where(field, arrayContains: value);
      case FilterOperator.arrayContainsAny:
        return query.where(field, arrayContainsAny: value as List<dynamic>);
      case FilterOperator.whereIn:
        return query.where(field, whereIn: value as List<dynamic>);
      case FilterOperator.whereNotIn:
        return query.where(field, whereNotIn: value as List<dynamic>);
      case FilterOperator.isNull:
        return query.where(field, isNull: true);
    }
  }
}

/// Operators for Firestore query filters
enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}

/// Order for Firestore queries
class QueryOrder {

  QueryOrder({
    required this.field,
    this.descending = false,
  });
  final String field;
  final bool descending;

  Query<Map<String, dynamic>> apply(Query<Map<String, dynamic>> query) {
    return query.orderBy(field, descending: descending);
  }
}
