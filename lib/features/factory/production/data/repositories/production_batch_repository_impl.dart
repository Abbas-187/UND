import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/models/production_batch_model.dart';
import '../../domain/repositories/production_batch_repository.dart';

/// Implementation of the ProductionBatchRepository interface
class ProductionBatchRepositoryImpl implements ProductionBatchRepository {
  /// Constructor for dependency injection
  ProductionBatchRepositoryImpl(this._firestore, this._authRepository) {
    _batchCollection = _firestore.collection('productionBatches');
  }
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final Uuid _uuid = const Uuid();

  /// Collection reference for production batches
  late final CollectionReference<Map<String, dynamic>> _batchCollection;

  @override
  Future<Result<ProductionBatchModel>> createBatch(
      ProductionBatchModel batch) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();

      // Create a new batch ID if not provided
      final id = batch.id.isEmpty ? _uuid.v4() : batch.id;

      // Set creation and update timestamps
      final now = DateTime.now();
      final newBatch = batch.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
        updatedBy: userId,
      );

      // Save to Firestore
      await _batchCollection.doc(id).set(newBatch.toJson());

      return Result.success(newBatch);
    } catch (e) {
      return Result.failure(
          ServerFailure('Failed to create batch', details: e.toString()));
    }
  }

  @override
  Future<Result<ProductionBatchModel>> getBatchById(String id) async {
    try {
      final doc = await _batchCollection.doc(id).get();
      if (!doc.exists) {
        return Result.failure(NotFoundFailure('Batch with ID $id not found'));
      }

      return Result.success(
          ProductionBatchModel.fromFirestore(doc as DocumentSnapshot));
    } catch (e) {
      return Result.failure(
          ServerFailure('Failed to get batch', details: e.toString()));
    }
  }

  @override
  Future<Result<List<ProductionBatchModel>>> getBatchesByExecutionId(
      String executionId) async {
    try {
      final snapshot = await _batchCollection
          .where('executionId', isEqualTo: executionId)
          .get();

      final batches = snapshot.docs
          .map((doc) =>
              ProductionBatchModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(batches);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to get batches by execution ID',
          details: e.toString()));
    }
  }

  @override
  Future<Result<ProductionBatchModel>> updateBatch(
      ProductionBatchModel batch) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update timestamp
      final updatedBatch = batch.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _batchCollection.doc(batch.id).update(updatedBatch.toJson());

      return Result.success(updatedBatch);
    } catch (e) {
      return Result.failure(
          ServerFailure('Failed to update batch', details: e.toString()));
    }
  }

  @override
  Future<Result<ProductionBatchModel>> updateBatchStatus(
      String id, BatchStatus status) async {
    try {
      // Get current batch
      final batchResult = await getBatchById(id);
      if (batchResult.isFailure) {
        return batchResult;
      }

      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update batch with new status
      final updatedBatch = batchResult.data!.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _batchCollection.doc(id).update(updatedBatch.toJson());

      return Result.success(updatedBatch);
    } catch (e) {
      return Result.failure(ServerFailure('Failed to update batch status',
          details: e.toString()));
    }
  }

  @override
  Future<Result<ProductionBatchModel>> startBatch(String id) async {
    try {
      // Get current batch
      final batchResult = await getBatchById(id);
      if (batchResult.isFailure) {
        return batchResult;
      }

      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update batch with in-progress status and start time
      final updatedBatch = batchResult.data!.copyWith(
        status: BatchStatus.inProgress,
        startTime: DateTime.now(),
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _batchCollection.doc(id).update(updatedBatch.toJson());

      return Result.success(updatedBatch);
    } catch (e) {
      return Result.failure(
          ServerFailure('Failed to start batch', details: e.toString()));
    }
  }

  @override
  Future<Result<ProductionBatchModel>> completeBatch(
      String id, double actualQuantity) async {
    try {
      // Get current batch
      final batchResult = await getBatchById(id);
      if (batchResult.isFailure) {
        return batchResult;
      }

      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update batch with completed status, end time, and actual quantity
      final updatedBatch = batchResult.data!.copyWith(
        status: BatchStatus.completed,
        endTime: DateTime.now(),
        actualQuantity: actualQuantity,
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _batchCollection.doc(id).update(updatedBatch.toJson());

      return Result.success(updatedBatch);
    } catch (e) {
      return Result.failure(
          ServerFailure('Failed to complete batch', details: e.toString()));
    }
  }

  @override
  Future<Result<ProductionBatchModel>> failBatch(
      String id, String reason) async {
    try {
      // Get current batch
      final batchResult = await getBatchById(id);
      if (batchResult.isFailure) {
        return batchResult;
      }

      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update batch with failed status, end time, and notes
      final updatedBatch = batchResult.data!.copyWith(
        status: BatchStatus.failed,
        endTime: DateTime.now(),
        notes: reason,
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _batchCollection.doc(id).update(updatedBatch.toJson());

      return Result.success(updatedBatch);
    } catch (e) {
      return Result.failure(
          ServerFailure('Failed to fail batch', details: e.toString()));
    }
  }

  @override
  Future<Result<ProductionBatchModel>> updateBatchParameters(
      String id, Map<String, dynamic> parameters) async {
    try {
      // Get current batch
      final batchResult = await getBatchById(id);
      if (batchResult.isFailure) {
        return batchResult;
      }

      // Get current user ID
      final userId = await _getCurrentUserId();

      // Merge existing parameters with new ones
      final currentParams = batchResult.data!.processParameters ?? {};
      final mergedParams = {...currentParams, ...parameters};

      // Update batch with new parameters
      final updatedBatch = batchResult.data!.copyWith(
        processParameters: mergedParams,
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _batchCollection.doc(id).update(updatedBatch.toJson());

      return Result.success(updatedBatch);
    } catch (e) {
      return Result.failure(ServerFailure('Failed to update batch parameters',
          details: e.toString()));
    }
  }

  @override
  Stream<ProductionBatchModel> watchBatch(String id) {
    return _batchCollection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw NotFoundFailure('Batch with ID $id not found');
      }
      return ProductionBatchModel.fromFirestore(snapshot as DocumentSnapshot);
    });
  }

  @override
  Stream<List<ProductionBatchModel>> watchBatchesByExecutionId(
      String executionId) {
    return _batchCollection
        .where('executionId', isEqualTo: executionId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductionBatchModel.fromFirestore(doc as DocumentSnapshot))
            .toList());
  }

  @override
  Future<Result<List<ProductionBatchModel>>> getBatchesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _batchCollection
          .where('createdAt',
              isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      final batches = snapshot.docs
          .map((doc) =>
              ProductionBatchModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(batches);
    } catch (e) {
      return Result.failure(ServerFailure('Failed to get batches by date range',
          details: e.toString()));
    }
  }

  @override
  Future<Result<List<ProductionBatchModel>>> getBatchesByProductId(
      String productId) async {
    try {
      final snapshot =
          await _batchCollection.where('productId', isEqualTo: productId).get();

      final batches = snapshot.docs
          .map((doc) =>
              ProductionBatchModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(batches);
    } catch (e) {
      return Result.failure(ServerFailure('Failed to get batches by product ID',
          details: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteBatch(String id) async {
    try {
      await _batchCollection.doc(id).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
          ServerFailure('Failed to delete batch', details: e.toString()));
    }
  }

  /// Helper method to get the current user ID
  Future<String> _getCurrentUserId() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw AuthFailure('Failed to get current user');
    }
    return user.id;
  }
}
