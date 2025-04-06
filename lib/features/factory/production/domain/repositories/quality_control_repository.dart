import '../../../../../core/exceptions/result.dart';
import '../models/quality_control_result_model.dart';

/// Repository interface for quality control operations in production
abstract class QualityControlRepository {
  /// Records a new quality control result
  Future<Result<QualityControlResultModel>> recordQualityControlResult(
      QualityControlResultModel result);

  /// Gets a quality control result by its ID
  Future<Result<QualityControlResultModel>> getQualityControlResultById(
      String id);

  /// Gets all quality control results for a specific batch
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsByBatchId(String batchId);

  /// Gets all quality control results for a specific execution
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsByExecutionId(String executionId);

  /// Updates an existing quality control result
  Future<Result<QualityControlResultModel>> updateQualityControlResult(
      QualityControlResultModel result);

  /// Records corrective action for a failed quality control check
  Future<Result<QualityControlResultModel>> recordCorrectiveAction(
      String id, String correctiveAction);

  /// Reviews a quality control result
  Future<Result<QualityControlResultModel>> reviewQualityControlResult(
      String id, String reviewedBy);

  /// Gets a real-time stream of quality control result updates
  Stream<QualityControlResultModel> watchQualityControlResult(String id);

  /// Gets a real-time stream of all quality control results for a batch
  Stream<List<QualityControlResultModel>> watchQualityControlResultsByBatchId(
      String batchId);

  /// Gets a real-time stream of all quality control results for an execution
  Stream<List<QualityControlResultModel>>
      watchQualityControlResultsByExecutionId(String executionId);

  /// Gets quality control results created within a date range
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsByDateRange(DateTime startDate, DateTime endDate);

  /// Gets failed quality control results requiring corrective action
  Future<Result<List<QualityControlResultModel>>>
      getFailedQualityControlResults();

  /// Gets critical quality control results that need immediate attention
  Future<Result<List<QualityControlResultModel>>>
      getCriticalQualityControlResults();

  /// Deletes a quality control result (for administrative purposes only)
  Future<Result<void>> deleteQualityControlResult(String id);
}
