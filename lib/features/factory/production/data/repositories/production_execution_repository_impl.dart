import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../../../production/domain/models/production_execution_model.dart';
import '../../../production/domain/repositories/production_execution_repository.dart';

/// Implementation of the ProductionExecutionRepository interface using Firestore
class ProductionExecutionRepositoryImpl
    implements ProductionExecutionRepository {

  /// Constructor that allows dependency injection
  ProductionExecutionRepositoryImpl({
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger();
  /// Collection name for production executions in Firestore
  static const String _collectionName = 'productionExecutions';

  /// Firebase instance
  final FirebaseFirestore _firestore;

  /// Logger for tracking operations
  final Logger _logger;

  /// Provides access to the productionExecutions collection
  CollectionReference<Map<String, dynamic>> get _executionsCollection =>
      _firestore.collection(_collectionName);

  /// Converts a DocumentSnapshot to a ProductionExecutionModel
  ProductionExecutionModel _snapshotToModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductionExecutionModel.fromJson(data);
  }

  /// Handles FirebaseException and converts to appropriate Failure
  Failure _handleFirebaseException(FirebaseException e, String operation) {
    _logger.e('Firebase error in $operation: ${e.message}', error: e);

    switch (e.code) {
      case 'permission-denied':
        return AuthFailure('Permission denied: ${e.message}');
      case 'not-found':
        return NotFoundFailure('Document not found: ${e.message}');
      case 'already-exists':
        return ValidationFailure('Document already exists: ${e.message}');
      case 'invalid-argument':
        return ValidationFailure('Invalid argument: ${e.message}');
      default:
        return ServerFailure('Firestore error: ${e.message}', details: e.code);
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> createProductionExecution(
      ProductionExecutionModel execution) async {
    try {
      _logger.i('Creating new production execution: ${execution.batchNumber}');

      // Generate ID if not provided
      final String id =
          execution.id.isEmpty ? _executionsCollection.doc().id : execution.id;

      // Create new model with ID
      final executionWithId =
          execution.id.isEmpty ? execution.copyWith(id: id) : execution;

      // Save to Firestore
      await _executionsCollection.doc(id).set(executionWithId.toJson());

      _logger.i('Successfully created production execution with ID: $id');
      return Result.success(executionWithId);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'createProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error creating production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to create production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> getProductionExecutionById(
      String id) async {
    try {
      _logger.i('Fetching production execution with ID: $id');

      final docSnapshot = await _executionsCollection.doc(id).get();

      if (!docSnapshot.exists) {
        _logger.w('Production execution not found with ID: $id');
        return Result.failure(
          NotFoundFailure('Production execution not found with ID: $id'),
        );
      }

      final execution = _snapshotToModel(docSnapshot);
      return Result.success(execution);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'getProductionExecutionById'));
    } catch (e, stackTrace) {
      _logger.e('Error fetching production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to fetch production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<ProductionExecutionModel>>> queryProductionExecutions({
    DateTime? startDate,
    DateTime? endDate,
    ProductionExecutionStatus? status,
    String? productId,
    String? productionLineId,
    String? searchQuery,
  }) async {
    try {
      _logger.i('Querying production executions with filters');

      // Start with base query
      Query<Map<String, dynamic>> query = _executionsCollection;

      // Apply filters if provided
      if (startDate != null) {
        query = query.where('scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('scheduledDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }

      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }

      if (productionLineId != null) {
        query = query.where('productionLineId', isEqualTo: productionLineId);
      }

      // Execute query
      final querySnapshot = await query.get();

      // Convert results to models
      final executions =
          querySnapshot.docs.map((doc) => _snapshotToModel(doc)).toList();

      // Apply search query filter in memory if provided
      // (Firestore doesn't support text search natively)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return Result.success(executions.where((execution) {
          return execution.productName.toLowerCase().contains(searchLower) ||
              execution.batchNumber.toLowerCase().contains(searchLower);
        }).toList());
      }

      return Result.success(executions);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'queryProductionExecutions'));
    } catch (e, stackTrace) {
      _logger.e('Error querying production executions',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to query production executions',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> updateProductionExecution(
      ProductionExecutionModel execution) async {
    try {
      _logger.i('Updating production execution: ${execution.id}');

      if (execution.id.isEmpty) {
        _logger.w('Cannot update execution with empty ID');
        return Result.failure(
          ValidationFailure('Production execution ID cannot be empty'),
        );
      }

      // Check if the document exists
      final docSnapshot = await _executionsCollection.doc(execution.id).get();
      if (!docSnapshot.exists) {
        _logger.w('Production execution not found with ID: ${execution.id}');
        return Result.failure(
          NotFoundFailure(
              'Production execution not found with ID: ${execution.id}'),
        );
      }

      // Update in Firestore
      await _executionsCollection.doc(execution.id).update(execution.toJson());

      _logger.i('Successfully updated production execution: ${execution.id}');
      return Result.success(execution);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'updateProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error updating production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to update production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteProductionExecution(String id) async {
    try {
      _logger.w('Deleting production execution: $id');

      // Check if the document exists
      final docSnapshot = await _executionsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        _logger.w('Production execution not found with ID: $id');
        return Result.failure(
          NotFoundFailure('Production execution not found with ID: $id'),
        );
      }

      // Delete from Firestore
      await _executionsCollection.doc(id).delete();

      _logger.i('Successfully deleted production execution: $id');
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'deleteProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error deleting production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to delete production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> updateProductionExecutionStatus(
      String id, ProductionExecutionStatus status) async {
    try {
      _logger.i('Updating production execution status: $id to $status');

      // Check if the document exists
      final docSnapshot = await _executionsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        return Result.failure(
          NotFoundFailure('Production execution not found with ID: $id'),
        );
      }

      // Get current execution
      final execution = _snapshotToModel(docSnapshot);

      // Create updated execution with new status
      final updatedExecution = execution.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _executionsCollection.doc(id).update({
        'status': status.toString(),
        'updatedAt': Timestamp.now(),
      });

      _logger.i(
          'Successfully updated production execution status: $id to $status');
      return Result.success(updatedExecution);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'updateProductionExecutionStatus'));
    } catch (e, stackTrace) {
      _logger.e('Error updating production execution status',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to update production execution status',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> updateProductionYield(
      String id, double actualYield, double? yieldEfficiency) async {
    try {
      _logger.i('Updating production execution yield: $id');

      // Check if the document exists
      final docSnapshot = await _executionsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        return Result.failure(
          NotFoundFailure('Production execution not found with ID: $id'),
        );
      }

      // Get current execution
      final execution = _snapshotToModel(docSnapshot);

      // Calculate efficiency if not provided
      final double calculatedEfficiency = yieldEfficiency ??
          (execution.expectedYield > 0
              ? (actualYield / execution.expectedYield) * 100
              : 0);

      // Create updated execution with new yield data
      final updatedExecution = execution.copyWith(
        actualYield: actualYield,
        yieldEfficiency: calculatedEfficiency,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _executionsCollection.doc(id).update({
        'actualYield': actualYield,
        'yieldEfficiency': calculatedEfficiency,
        'updatedAt': Timestamp.now(),
      });

      _logger.i('Successfully updated production execution yield: $id');
      return Result.success(updatedExecution);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'updateProductionYield'));
    } catch (e, stackTrace) {
      _logger.e('Error updating production execution yield',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to update production execution yield',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> updateMaterialUsage(
      String id, List<MaterialUsage> materials) async {
    try {
      _logger.i('Updating production execution materials: $id');

      // Check if the document exists
      final docSnapshot = await _executionsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        return Result.failure(
          NotFoundFailure('Production execution not found with ID: $id'),
        );
      }

      // Get current execution
      final execution = _snapshotToModel(docSnapshot);

      // Create updated execution with new materials
      final updatedExecution = execution.copyWith(
        materials: materials,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _executionsCollection.doc(id).update({
        'materials': materials.map((m) => m.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      });

      _logger.i('Successfully updated production execution materials: $id');
      return Result.success(updatedExecution);
    } on FirebaseException catch (e) {
      return Result.failure(_handleFirebaseException(e, 'updateMaterialUsage'));
    } catch (e, stackTrace) {
      _logger.e('Error updating production execution materials',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to update production execution materials',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> updateAssignedPersonnel(
      String id, List<AssignedPersonnel> personnel) async {
    try {
      _logger.i('Updating production execution personnel: $id');

      // Check if the document exists
      final docSnapshot = await _executionsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        return Result.failure(
          NotFoundFailure('Production execution not found with ID: $id'),
        );
      }

      // Get current execution
      final execution = _snapshotToModel(docSnapshot);

      // Create updated execution with new personnel
      final updatedExecution = execution.copyWith(
        assignedPersonnel: personnel,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _executionsCollection.doc(id).update({
        'assignedPersonnel': personnel.map((p) => p.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      });

      _logger.i('Successfully updated production execution personnel: $id');
      return Result.success(updatedExecution);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'updateAssignedPersonnel'));
    } catch (e, stackTrace) {
      _logger.e('Error updating production execution personnel',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to update production execution personnel',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> updateQualityMetrics(
      String id, QualityRating rating, String? qualityNotes) async {
    try {
      _logger.i('Updating production execution quality metrics: $id');

      // Check if the document exists
      final docSnapshot = await _executionsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        return Result.failure(
          NotFoundFailure('Production execution not found with ID: $id'),
        );
      }

      // Get current execution
      final execution = _snapshotToModel(docSnapshot);

      // Create updated execution with new quality metrics
      final updatedExecution = execution.copyWith(
        qualityRating: rating,
        qualityNotes: qualityNotes,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _executionsCollection.doc(id).update({
        'qualityRating': rating.toString(),
        'qualityNotes': qualityNotes,
        'updatedAt': Timestamp.now(),
      });

      _logger
          .i('Successfully updated production execution quality metrics: $id');
      return Result.success(updatedExecution);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'updateQualityMetrics'));
    } catch (e, stackTrace) {
      _logger.e('Error updating production execution quality metrics',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to update production execution quality metrics',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> startProductionExecution(
      String id) async {
    try {
      _logger.i('Starting production execution: $id');

      // Run as a transaction to ensure atomicity
      return await _firestore.runTransaction<Result<ProductionExecutionModel>>(
          (transaction) async {
        // Get the current document
        final docRef = _executionsCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          _logger.w('Production execution not found with ID: $id');
          return Result.failure(
            NotFoundFailure('Production execution not found with ID: $id'),
          );
        }

        // Get current execution
        final execution = _snapshotToModel(docSnapshot);

        // Validate current status
        if (execution.status != ProductionExecutionStatus.planned) {
          _logger.w(
              'Cannot start production execution with status: ${execution.status}');
          return Result.failure(
            ValidationFailure(
                'Cannot start production execution with status: ${execution.status}'),
          );
        }

        // Create updated execution
        final updatedExecution = execution.copyWith(
          status: ProductionExecutionStatus.inProgress,
          startTime: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Update in Firestore
        transaction.update(docRef, {
          'status': ProductionExecutionStatus.inProgress.toString(),
          'startTime': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        _logger.i('Successfully started production execution: $id');
        return Result.success(updatedExecution);
      });
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'startProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error starting production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to start production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> pauseProductionExecution(
      String id) async {
    try {
      _logger.i('Pausing production execution: $id');

      // Run as a transaction to ensure atomicity
      return await _firestore.runTransaction<Result<ProductionExecutionModel>>(
          (transaction) async {
        // Get the current document
        final docRef = _executionsCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          _logger.w('Production execution not found with ID: $id');
          return Result.failure(
            NotFoundFailure('Production execution not found with ID: $id'),
          );
        }

        // Get current execution
        final execution = _snapshotToModel(docSnapshot);

        // Validate current status
        if (execution.status != ProductionExecutionStatus.inProgress) {
          _logger.w(
              'Cannot pause production execution with status: ${execution.status}');
          return Result.failure(
            ValidationFailure(
                'Cannot pause production execution with status: ${execution.status}'),
          );
        }

        // Create updated execution
        final updatedExecution = execution.copyWith(
          status: ProductionExecutionStatus.paused,
          updatedAt: DateTime.now(),
        );

        // Update in Firestore
        transaction.update(docRef, {
          'status': ProductionExecutionStatus.paused.toString(),
          'updatedAt': Timestamp.now(),
        });

        _logger.i('Successfully paused production execution: $id');
        return Result.success(updatedExecution);
      });
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'pauseProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error pausing production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to pause production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> resumeProductionExecution(
      String id) async {
    try {
      _logger.i('Resuming production execution: $id');

      // Run as a transaction to ensure atomicity
      return await _firestore.runTransaction<Result<ProductionExecutionModel>>(
          (transaction) async {
        // Get the current document
        final docRef = _executionsCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          _logger.w('Production execution not found with ID: $id');
          return Result.failure(
            NotFoundFailure('Production execution not found with ID: $id'),
          );
        }

        // Get current execution
        final execution = _snapshotToModel(docSnapshot);

        // Validate current status
        if (execution.status != ProductionExecutionStatus.paused) {
          _logger.w(
              'Cannot resume production execution with status: ${execution.status}');
          return Result.failure(
            ValidationFailure(
                'Cannot resume production execution with status: ${execution.status}'),
          );
        }

        // Create updated execution
        final updatedExecution = execution.copyWith(
          status: ProductionExecutionStatus.inProgress,
          updatedAt: DateTime.now(),
        );

        // Update in Firestore
        transaction.update(docRef, {
          'status': ProductionExecutionStatus.inProgress.toString(),
          'updatedAt': Timestamp.now(),
        });

        _logger.i('Successfully resumed production execution: $id');
        return Result.success(updatedExecution);
      });
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'resumeProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error resuming production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to resume production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> completeProductionExecution(
    String id, {
    double? actualYield,
    QualityRating? qualityRating,
    String? qualityNotes,
  }) async {
    try {
      _logger.i('Completing production execution: $id');

      // Run as a transaction to ensure atomicity
      return await _firestore.runTransaction<Result<ProductionExecutionModel>>(
          (transaction) async {
        // Get the current document
        final docRef = _executionsCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          _logger.w('Production execution not found with ID: $id');
          return Result.failure(
            NotFoundFailure('Production execution not found with ID: $id'),
          );
        }

        // Get current execution
        final execution = _snapshotToModel(docSnapshot);

        // Validate current status
        if (execution.status != ProductionExecutionStatus.inProgress &&
            execution.status != ProductionExecutionStatus.paused) {
          _logger.w(
              'Cannot complete production execution with status: ${execution.status}');
          return Result.failure(
            ValidationFailure(
                'Cannot complete production execution with status: ${execution.status}'),
          );
        }

        // Calculate efficiency if actualYield is provided
        double? calculatedEfficiency;
        if (actualYield != null && execution.expectedYield > 0) {
          calculatedEfficiency = (actualYield / execution.expectedYield) * 100;
        }

        // Create updated execution
        final updatedExecution = execution.copyWith(
          status: ProductionExecutionStatus.completed,
          endTime: DateTime.now(),
          actualYield: actualYield ?? execution.actualYield,
          yieldEfficiency: calculatedEfficiency ?? execution.yieldEfficiency,
          qualityRating: qualityRating ?? execution.qualityRating,
          qualityNotes: qualityNotes ?? execution.qualityNotes,
          updatedAt: DateTime.now(),
        );

        // Prepare update map
        final Map<String, dynamic> updateData = {
          'status': ProductionExecutionStatus.completed.toString(),
          'endTime': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        if (actualYield != null) {
          updateData['actualYield'] = actualYield;
        }

        if (calculatedEfficiency != null) {
          updateData['yieldEfficiency'] = calculatedEfficiency;
        }

        if (qualityRating != null) {
          updateData['qualityRating'] = qualityRating.toString();
        }

        if (qualityNotes != null) {
          updateData['qualityNotes'] = qualityNotes;
        }

        // Update in Firestore
        transaction.update(docRef, updateData);

        _logger.i('Successfully completed production execution: $id');
        return Result.success(updatedExecution);
      });
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'completeProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error completing production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to complete production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<ProductionExecutionModel>> cancelProductionExecution(
      String id, String reason) async {
    try {
      _logger.i('Cancelling production execution: $id');

      // Run as a transaction to ensure atomicity
      return await _firestore.runTransaction<Result<ProductionExecutionModel>>(
          (transaction) async {
        // Get the current document
        final docRef = _executionsCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          _logger.w('Production execution not found with ID: $id');
          return Result.failure(
            NotFoundFailure('Production execution not found with ID: $id'),
          );
        }

        // Get current execution
        final execution = _snapshotToModel(docSnapshot);

        // Validate current status
        if (execution.status == ProductionExecutionStatus.completed ||
            execution.status == ProductionExecutionStatus.cancelled) {
          _logger.w(
              'Cannot cancel production execution with status: ${execution.status}');
          return Result.failure(
            ValidationFailure(
                'Cannot cancel production execution with status: ${execution.status}'),
          );
        }

        // Create updated execution
        final updatedExecution = execution.copyWith(
          status: ProductionExecutionStatus.cancelled,
          notes: execution.notes != null
              ? '${execution.notes}\nCancellation reason: $reason'
              : 'Cancellation reason: $reason',
          updatedAt: DateTime.now(),
        );

        // Update in Firestore
        transaction.update(docRef, {
          'status': ProductionExecutionStatus.cancelled.toString(),
          'notes': updatedExecution.notes,
          'updatedAt': Timestamp.now(),
        });

        _logger.i('Successfully cancelled production execution: $id');
        return Result.success(updatedExecution);
      });
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'cancelProductionExecution'));
    } catch (e, stackTrace) {
      _logger.e('Error cancelling production execution',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to cancel production execution',
            details: e.toString()),
      );
    }
  }

  @override
  Stream<ProductionExecutionModel> watchProductionExecution(String id) {
    _logger.i('Setting up watch for production execution: $id');

    return _executionsCollection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        _logger.w('Production execution does not exist: $id');
        throw Exception('Production execution not found with ID: $id');
      }
      return _snapshotToModel(snapshot);
    }).handleError((error) {
      _logger.e('Error watching production execution: $id', error: error);
      throw error;
    });
  }

  @override
  Stream<List<ProductionExecutionModel>> watchActiveProductionExecutions() {
    _logger.i('Setting up watch for active production executions');

    // Query for executions with inProgress or paused status
    return _executionsCollection
        .where('status', whereIn: [
          ProductionExecutionStatus.inProgress.toString(),
          ProductionExecutionStatus.paused.toString()
        ])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _snapshotToModel(doc)).toList())
        .handleError((error) {
          _logger.e('Error watching active production executions',
              error: error);
          throw error;
        });
  }

  @override
  Future<Result<List<ProductionExecutionModel>>>
      getTodaysProductionExecutions() async {
    try {
      _logger.i('Getting today\'s production executions');

      // Calculate start and end of today
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      // Query for executions scheduled today
      final querySnapshot = await _executionsCollection
          .where('scheduledDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      final executions =
          querySnapshot.docs.map((doc) => _snapshotToModel(doc)).toList();

      return Result.success(executions);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'getTodaysProductionExecutions'));
    } catch (e, stackTrace) {
      _logger.e('Error getting today\'s production executions',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to get today\'s production executions',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<ProductionExecutionModel>>>
      getProductionExecutionsForProduct(String productId) async {
    try {
      _logger.i('Getting production executions for product: $productId');

      // Query for executions with the specified product ID
      final querySnapshot = await _executionsCollection
          .where('productId', isEqualTo: productId)
          .get();

      final executions =
          querySnapshot.docs.map((doc) => _snapshotToModel(doc)).toList();

      return Result.success(executions);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'getProductionExecutionsForProduct'));
    } catch (e, stackTrace) {
      _logger.e('Error getting production executions for product',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to get production executions for product',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<ProductionExecutionModel>>> getProductionExecutionsForLine(
      String productionLineId) async {
    try {
      _logger.i('Fetching production executions for line: $productionLineId');

      final querySnapshot = await _executionsCollection
          .where('productionLineId', isEqualTo: productionLineId)
          .get();

      final executions =
          querySnapshot.docs.map((doc) => _snapshotToModel(doc)).toList();

      return Result.success(executions);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'getProductionExecutionsForLine'));
    } catch (e, stackTrace) {
      _logger.e('Error fetching production executions for line',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to fetch production executions for line',
            details: e.toString()),
      );
    }
  }

  @override
  Future<List<ProductionExecutionModel>> getProductionExecutionsByPlanId(
      String planId) async {
    try {
      _logger.i('Fetching production executions for plan: $planId');

      final querySnapshot = await _executionsCollection
          .where('productionOrderId', isEqualTo: planId)
          .get();

      return querySnapshot.docs.map((doc) => _snapshotToModel(doc)).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching production executions for plan',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<Result<Map<String, double>>> getProductionEfficiencyStats(
      DateTime startDate, DateTime endDate) async {
    try {
      _logger.i(
          'Getting production efficiency stats from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      // Query for completed executions in the date range
      final querySnapshot = await _executionsCollection
          .where('status',
              isEqualTo: ProductionExecutionStatus.completed.toString())
          .where('endTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('endTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // Group by product ID and calculate average efficiency
      final Map<String, List<double>> efficiencyByProduct = {};

      for (final doc in querySnapshot.docs) {
        final execution = _snapshotToModel(doc);

        if (execution.yieldEfficiency != null &&
            execution.productId.isNotEmpty) {
          efficiencyByProduct.putIfAbsent(execution.productId, () => []);
          efficiencyByProduct[execution.productId]!
              .add(execution.yieldEfficiency!);
        }
      }

      // Calculate averages
      final Map<String, double> result = {};

      efficiencyByProduct.forEach((productId, efficiencies) {
        if (efficiencies.isNotEmpty) {
          final sum = efficiencies.reduce((a, b) => a + b);
          result[productId] = sum / efficiencies.length;
        }
      });

      return Result.success(result);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'getProductionEfficiencyStats'));
    } catch (e, stackTrace) {
      _logger.e('Error getting production efficiency stats',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to get production efficiency stats',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<Map<String, double>>> getProductionOutputStats(
      DateTime startDate, DateTime endDate) async {
    try {
      _logger.i(
          'Getting production output stats from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      // Query for completed executions in the date range
      final querySnapshot = await _executionsCollection
          .where('status',
              isEqualTo: ProductionExecutionStatus.completed.toString())
          .where('endTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('endTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // Group by product ID and sum actual yields
      final Map<String, double> outputByProduct = {};

      for (final doc in querySnapshot.docs) {
        final execution = _snapshotToModel(doc);

        if (execution.actualYield != null && execution.productId.isNotEmpty) {
          outputByProduct.putIfAbsent(execution.productId, () => 0);
          outputByProduct[execution.productId] =
              outputByProduct[execution.productId]! + execution.actualYield!;
        }
      }

      return Result.success(outputByProduct);
    } on FirebaseException catch (e) {
      return Result.failure(
          _handleFirebaseException(e, 'getProductionOutputStats'));
    } catch (e, stackTrace) {
      _logger.e('Error getting production output stats',
          error: e, stackTrace: stackTrace);
      return Result.failure(
        UnknownFailure('Failed to get production output stats',
            details: e.toString()),
      );
    }
  }
}

/// Provider for the Production Execution Repository
final productionExecutionRepositoryProvider =
    Provider<ProductionExecutionRepository>((ref) {
  return ProductionExecutionRepositoryImpl();
});
