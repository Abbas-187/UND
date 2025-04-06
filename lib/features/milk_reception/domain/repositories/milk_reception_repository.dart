import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/exceptions.dart';
import '../../domain/models/milk_reception_model.dart';

/// Provider for the milk reception repository
final milkReceptionRepositoryProvider =
    Provider<MilkReceptionRepository>((ref) {
  return FirestoreMilkReceptionRepository();
});

/// Repository interface for milk receptions
abstract class MilkReceptionRepository {
  /// Add a new milk reception to the database
  Future<String> addReception(MilkReceptionModel reception);

  /// Update an existing milk reception
  Future<void> updateReception(MilkReceptionModel reception);

  /// Get a milk reception by its ID
  Future<MilkReceptionModel> getReceptionById(String id);

  /// Alias for getReceptionById
  Future<MilkReceptionModel> getReception(String id);

  /// Create a new reception
  Future<String> createReception(MilkReceptionModel reception);

  /// Get all receptions from a specific supplier
  Future<List<MilkReceptionModel>> getReceptionsBySupplier(String supplierId,
      {int? limit, DocumentSnapshot? startAfter});

  /// Get receptions within a specific date range
  Future<List<MilkReceptionModel>> getReceptionsByDateRange(
      DateTime start, DateTime end,
      {int? limit, DocumentSnapshot? startAfter});

  /// Get receptions by status
  Future<List<MilkReceptionModel>> getReceptionsByStatus(ReceptionStatus status,
      {int? limit, DocumentSnapshot? startAfter});

  /// Get today's receptions
  Future<List<MilkReceptionModel>> getTodayReceptions();

  /// Link a quality test to a reception
  Future<void> linkQualityTestToReception(String receptionId, String testId);

  /// Update the status of a reception
  Future<void> updateReceptionStatus(String id, ReceptionStatus newStatus);

  /// Clear the cache for a specific reception
  Future<void> clearCache(String id);

  /// Clear all cached receptions
  Future<void> clearAllCache();
}

/// Firestore implementation of the MilkReceptionRepository
class FirestoreMilkReceptionRepository implements MilkReceptionRepository {
  FirestoreMilkReceptionRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _receptionCollection = 'milk_receptions';
  final _testCollection = 'milk_quality_tests';

  // Cache for storing frequently accessed receptions
  final Map<String, MilkReceptionModel> _cache = {};

  // Utility getter for collection reference
  CollectionReference<Map<String, dynamic>> get _receptions =>
      _firestore.collection(_receptionCollection);

  @override
  Future<String> addReception(MilkReceptionModel reception) async {
    try {
      // Create a new document with auto-generated ID if none provided
      final String id =
          reception.id.isEmpty ? _receptions.doc().id : reception.id;

      // Create a reception with the ID
      final receptionWithId =
          reception.id.isEmpty ? reception.copyWith(id: id) : reception;

      // Save to Firestore
      await _receptions.doc(id).set(receptionWithId.toJson());

      // Update cache
      _cache[id] = receptionWithId;

      return id;
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'addReception');
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to add reception: $e');
    }
  }

  @override
  Future<void> updateReception(MilkReceptionModel reception) async {
    try {
      if (reception.id.isEmpty) {
        throw ValidationException('Reception ID cannot be empty');
      }

      // Update in Firestore
      await _receptions.doc(reception.id).update(reception.toJson());

      // Update cache
      _cache[reception.id] = reception;
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'updateReception');
      rethrow;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Failed to update reception: $e');
    }
  }

  @override
  Future<MilkReceptionModel> getReceptionById(String id) async {
    try {
      // Check cache first
      if (_cache.containsKey(id)) {
        return _cache[id]!;
      }

      // Fetch from Firestore
      final doc = await _receptions.doc(id).get();

      if (!doc.exists) {
        throw NotFoundException('Reception with ID $id not found');
      }

      final reception = MilkReceptionModel.fromJson(doc.data()!);

      // Update cache
      _cache[id] = reception;

      return reception;
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'getReceptionById');
      rethrow;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to get reception: $e');
    }
  }

  @override
  Future<List<MilkReceptionModel>> getReceptionsBySupplier(String supplierId,
      {int? limit, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _receptions
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('timestamp', descending: true);

      // Add pagination if requested
      query = _applyPagination(query, limit, startAfter);

      final querySnapshot = await query.get();

      return _processQuerySnapshot(querySnapshot);
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'getReceptionsBySupplier');
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get receptions by supplier: $e');
    }
  }

  @override
  Future<List<MilkReceptionModel>> getReceptionsByDateRange(
      DateTime start, DateTime end,
      {int? limit, DocumentSnapshot? startAfter}) async {
    try {
      final startTimestamp = Timestamp.fromDate(start);
      final endTimestamp = Timestamp.fromDate(end);

      Query<Map<String, dynamic>> query = _receptions
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true);

      // Add pagination if requested
      query = _applyPagination(query, limit, startAfter);

      final querySnapshot = await query.get();

      return _processQuerySnapshot(querySnapshot);
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'getReceptionsByDateRange');
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get receptions by date range: $e');
    }
  }

  @override
  Future<List<MilkReceptionModel>> getReceptionsByStatus(ReceptionStatus status,
      {int? limit, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _receptions
          .where('receptionStatus', isEqualTo: status.toString())
          .orderBy('timestamp', descending: true);

      // Add pagination if requested
      query = _applyPagination(query, limit, startAfter);

      final querySnapshot = await query.get();

      return _processQuerySnapshot(querySnapshot);
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'getReceptionsByStatus');
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get receptions by status: $e');
    }
  }

  @override
  Future<List<MilkReceptionModel>> getTodayReceptions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return getReceptionsByDateRange(startOfDay, endOfDay);
  }

  @override
  Future<void> linkQualityTestToReception(
      String receptionId, String testId) async {
    try {
      // Run as a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Get the reception document
        final receptionDoc = _receptions.doc(receptionId);
        final receptionSnapshot = await transaction.get(receptionDoc);

        if (!receptionSnapshot.exists) {
          throw NotFoundException('Reception with ID $receptionId not found');
        }

        // Get the test document
        final testDoc = _firestore.collection(_testCollection).doc(testId);
        final testSnapshot = await transaction.get(testDoc);

        if (!testSnapshot.exists) {
          throw NotFoundException('Quality test with ID $testId not found');
        }

        // Update the reception with the test ID
        final receptionData = receptionSnapshot.data()!;
        List<String> linkedTests = [];

        if (receptionData.containsKey('linkedTestIds')) {
          linkedTests = List<String>.from(receptionData['linkedTestIds'] ?? []);
        }

        if (!linkedTests.contains(testId)) {
          linkedTests.add(testId);
          transaction.update(receptionDoc, {'linkedTestIds': linkedTests});
        }

        // Update the test with the reception ID
        transaction.update(testDoc, {'receptionId': receptionId});

        // Clear cache for this reception
        _cache.remove(receptionId);
      });
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'linkQualityTestToReception');
      rethrow;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to link quality test to reception: $e');
    }
  }

  @override
  Future<void> updateReceptionStatus(
      String id, ReceptionStatus newStatus) async {
    try {
      await _receptions
          .doc(id)
          .update({'receptionStatus': newStatus.toString()});

      // Update cache if the reception is cached
      if (_cache.containsKey(id)) {
        _cache[id] = _cache[id]!.copyWith(receptionStatus: newStatus);
      }
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'updateReceptionStatus');
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update reception status: $e');
    }
  }

  @override
  Future<void> clearCache(String id) async {
    _cache.remove(id);
  }

  @override
  Future<void> clearAllCache() async {
    _cache.clear();
  }

  @override
  Future<String> createReception(MilkReceptionModel reception) {
    return addReception(reception);
  }

  @override
  Future<MilkReceptionModel> getReception(String id) {
    return getReceptionById(id);
  }

  // Helper method to handle Firebase exceptions
  void _handleFirebaseException(FirebaseException e, String operation) {
    debugPrint('Firestore error in $operation: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'permission-denied':
        throw PermissionException(
            'Permission denied for operation: $operation');
      case 'not-found':
        throw NotFoundException('Document not found for operation: $operation');
      case 'unavailable':
        throw NetworkException('Network unavailable for operation: $operation');
      default:
        throw DatabaseException(
            'Firestore error in $operation: ${e.code} - ${e.message}');
    }
  }

  // Helper method to apply pagination to a query
  Query<Map<String, dynamic>> _applyPagination(
    Query<Map<String, dynamic>> query,
    int? limit,
    DocumentSnapshot? startAfter,
  ) {
    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query;
  }

  // Helper method to process query snapshots into model lists
  List<MilkReceptionModel> _processQuerySnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final receptions = snapshot.docs
        .map((doc) => MilkReceptionModel.fromJson(doc.data()))
        .toList();

    // Update cache with these results
    for (final reception in receptions) {
      _cache[reception.id] = reception;
    }

    return receptions;
  }
}
