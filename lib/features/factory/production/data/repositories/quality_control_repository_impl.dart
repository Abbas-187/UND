import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/models/quality_control_result_model.dart';
import '../../domain/repositories/quality_control_repository.dart';

/// Implementation of the QualityControlRepository interface
class QualityControlRepositoryImpl implements QualityControlRepository {
  /// Constructor for dependency injection
  QualityControlRepositoryImpl(this._firestore, this._authRepository) {
    _qualityControlCollection = _firestore.collection('qualityControlResults');
  }
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final Uuid _uuid = const Uuid();

  /// Collection reference for quality control results
  late final CollectionReference<Map<String, dynamic>>
      _qualityControlCollection;

  @override
  Future<Result<QualityControlResultModel>> recordQualityControlResult(
      QualityControlResultModel result) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();

      // Create a new result ID if not provided
      final id = result.id.isEmpty ? _uuid.v4() : result.id;

      // Set creation and update timestamps
      final now = DateTime.now();
      final newResult = result.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
        updatedBy: userId,
      );

      // Save to Firestore
      await _qualityControlCollection.doc(id).set(newResult.toJson());

      return Result.success(newResult);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to record quality control result',
          details: e.toString()));
    }
  }

  @override
  Future<Result<QualityControlResultModel>> getQualityControlResultById(
      String id) async {
    try {
      final doc = await _qualityControlCollection.doc(id).get();
      if (!doc.exists) {
        return Result.failure(
            NotFoundFailure('Quality control result with ID $id not found'));
      }

      return Result.success(
          QualityControlResultModel.fromFirestore(doc as DocumentSnapshot));
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to get quality control result',
          details: e.toString()));
    }
  }

  @override
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsByBatchId(String batchId) async {
    try {
      final snapshot = await _qualityControlCollection
          .where('batchId', isEqualTo: batchId)
          .get();

      final results = snapshot.docs
          .map((doc) =>
              QualityControlResultModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to get quality control results by batch ID',
          details: e.toString()));
    }
  }

  @override
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsByExecutionId(String executionId) async {
    try {
      final snapshot = await _qualityControlCollection
          .where('executionId', isEqualTo: executionId)
          .get();

      final results = snapshot.docs
          .map((doc) =>
              QualityControlResultModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to get quality control results by execution ID',
          details: e.toString()));
    }
  }

  @override
  Future<Result<QualityControlResultModel>> updateQualityControlResult(
      QualityControlResultModel result) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update timestamp
      final updatedResult = result.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _qualityControlCollection
          .doc(result.id)
          .update(updatedResult.toJson());

      return Result.success(updatedResult);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to update quality control result',
          details: e.toString()));
    }
  }

  @override
  Future<Result<QualityControlResultModel>> recordCorrectiveAction(
      String id, String correctiveAction) async {
    try {
      // Get current result
      final resultResult = await getQualityControlResultById(id);
      if (resultResult.isFailure) {
        return resultResult;
      }

      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update result with corrective action
      final updatedResult = resultResult.data!.copyWith(
        correctiveAction: correctiveAction,
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _qualityControlCollection.doc(id).update(updatedResult.toJson());

      return Result.success(updatedResult);
    } catch (e) {
      return Result.failure(ServerFailure('Failed to record corrective action',
          details: e.toString()));
    }
  }

  @override
  Future<Result<QualityControlResultModel>> reviewQualityControlResult(
      String id, String reviewedBy) async {
    try {
      // Get current result
      final resultResult = await getQualityControlResultById(id);
      if (resultResult.isFailure) {
        return resultResult;
      }

      // Get current user ID
      final userId = await _getCurrentUserId();

      // Update result with review information
      final updatedResult = resultResult.data!.copyWith(
        reviewedBy: reviewedBy,
        reviewedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        updatedBy: userId,
      );

      // Update in Firestore
      await _qualityControlCollection.doc(id).update(updatedResult.toJson());

      return Result.success(updatedResult);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to review quality control result',
          details: e.toString()));
    }
  }

  @override
  Stream<QualityControlResultModel> watchQualityControlResult(String id) {
    return _qualityControlCollection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw NotFoundFailure('Quality control result with ID $id not found');
      }
      return QualityControlResultModel.fromFirestore(
          snapshot as DocumentSnapshot);
    });
  }

  @override
  Stream<List<QualityControlResultModel>> watchQualityControlResultsByBatchId(
      String batchId) {
    return _qualityControlCollection
        .where('batchId', isEqualTo: batchId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QualityControlResultModel.fromFirestore(
                doc as DocumentSnapshot))
            .toList());
  }

  @override
  Stream<List<QualityControlResultModel>>
      watchQualityControlResultsByExecutionId(String executionId) {
    return _qualityControlCollection
        .where('executionId', isEqualTo: executionId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QualityControlResultModel.fromFirestore(
                doc as DocumentSnapshot))
            .toList());
  }

  @override
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsByDateRange(
          DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _qualityControlCollection
          .where('performedAt',
              isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('performedAt', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      final results = snapshot.docs
          .map((doc) =>
              QualityControlResultModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to get quality control results by date range',
          details: e.toString()));
    }
  }

  @override
  Future<Result<List<QualityControlResultModel>>>
      getFailedQualityControlResults() async {
    try {
      final snapshot = await _qualityControlCollection
          .where('result',
              isEqualTo: QualityCheckResult.fail.toString().split('.').last)
          .get();

      final results = snapshot.docs
          .map((doc) =>
              QualityControlResultModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to get failed quality control results',
          details: e.toString()));
    }
  }

  @override
  Future<Result<List<QualityControlResultModel>>>
      getCriticalQualityControlResults() async {
    try {
      final snapshot = await _qualityControlCollection
          .where('isCritical', isEqualTo: true)
          .get();

      final results = snapshot.docs
          .map((doc) =>
              QualityControlResultModel.fromFirestore(doc as DocumentSnapshot))
          .toList();

      return Result.success(results);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to get critical quality control results',
          details: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteQualityControlResult(String id) async {
    try {
      await _qualityControlCollection.doc(id).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(
          'Failed to delete quality control result',
          details: e.toString()));
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
