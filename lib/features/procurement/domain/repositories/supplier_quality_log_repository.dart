import '../../../../core/exceptions/result.dart';
import '../entities/supplier_quality_log.dart';

/// Repository interface for supplier quality log operations
abstract class SupplierQualityLogRepository {
  /// Get all quality logs with optional filtering
  Future<Result<List<SupplierQualityLog>>> getQualityLogs({
    String? supplierId,
    String? purchaseOrderId,
    QualityStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get a quality log by ID
  Future<Result<SupplierQualityLog>> getQualityLogById(String id);

  /// Create a new quality log
  Future<Result<SupplierQualityLog>> createQualityLog(SupplierQualityLog log);

  /// Update an existing quality log
  Future<Result<SupplierQualityLog>> updateQualityLog(SupplierQualityLog log);

  /// Delete a quality log
  Future<Result<void>> deleteQualityLog(String id);

  /// Get quality logs requiring follow-up
  Future<Result<List<SupplierQualityLog>>> getQualityLogsRequiringFollowUp();

  /// Get quality logs for a supplier
  Future<Result<List<SupplierQualityLog>>> getQualityLogsForSupplier(
      String supplierId);

  /// Get quality logs for a purchase order
  Future<Result<List<SupplierQualityLog>>> getQualityLogsForPurchaseOrder(
      String purchaseOrderId);
}
