import '../../domain/entities/supplier_quality_log.dart';
import '../../domain/repositories/supplier_quality_log_repository.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';

/// Mock implementation of [SupplierQualityLogRepository] to demonstrate structure
/// In a real application, this would communicate with a data source
class SupplierQualityLogRepositoryImpl implements SupplierQualityLogRepository {
  /// Mock data for demonstration purposes
  final List<SupplierQualityLog> _mockQualityLogs = [];

  @override
  Future<Result<List<SupplierQualityLog>>> getQualityLogs({
    String? supplierId,
    String? purchaseOrderId,
    QualityStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // This would normally filter from a data source
      // Here we're just filtering the mock data
      var filteredLogs = _mockQualityLogs;

      if (supplierId != null) {
        filteredLogs =
            filteredLogs.where((log) => log.supplierId == supplierId).toList();
      }

      if (purchaseOrderId != null) {
        filteredLogs = filteredLogs
            .where((log) => log.purchaseOrderId == purchaseOrderId)
            .toList();
      }

      if (status != null) {
        filteredLogs =
            filteredLogs.where((log) => log.status == status).toList();
      }

      if (fromDate != null) {
        filteredLogs = filteredLogs
            .where((log) => log.inspectionDate.isAfter(fromDate))
            .toList();
      }

      if (toDate != null) {
        filteredLogs = filteredLogs
            .where((log) => log.inspectionDate.isBefore(toDate))
            .toList();
      }

      return Result.success(filteredLogs);
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<SupplierQualityLog>> getQualityLogById(String id) async {
    try {
      final log = _mockQualityLogs.firstWhere(
        (log) => log.id == id,
        orElse: () => throw Exception('Quality log not found'),
      );

      return Result.success(log);
    } catch (e) {
      return Result.failure(
        NotFoundFailure('Quality log not found with ID: $id'),
      );
    }
  }

  @override
  Future<Result<SupplierQualityLog>> createQualityLog(
      SupplierQualityLog log) async {
    try {
      // In a real implementation, this would save to a database
      _mockQualityLogs.add(log);
      return Result.success(log);
    } catch (e) {
      return Result.failure(
        ServerFailure('Failed to create quality log', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<SupplierQualityLog>> updateQualityLog(
      SupplierQualityLog log) async {
    try {
      // Validate ID
      if (log.id.isEmpty) {
        return Result.failure(
          ValidationFailure('Quality log ID is required for update'),
        );
      }

      // Find and update the log in our mock data
      final index = _mockQualityLogs.indexWhere((l) => l.id == log.id);

      if (index == -1) {
        return Result.failure(
          NotFoundFailure('Quality log not found with ID: ${log.id}'),
        );
      }

      _mockQualityLogs[index] = log;
      return Result.success(log);
    } catch (e) {
      return Result.failure(
        ServerFailure('Failed to update quality log', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteQualityLog(String id) async {
    try {
      // Remove from mock data
      final initialLength = _mockQualityLogs.length;
      _mockQualityLogs.removeWhere((log) => log.id == id);

      if (_mockQualityLogs.length == initialLength) {
        return Result.failure(
          NotFoundFailure('Quality log not found with ID: $id'),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Failed to delete quality log', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<SupplierQualityLog>>>
      getQualityLogsRequiringFollowUp() async {
    try {
      final logsRequiringFollowUp =
          _mockQualityLogs.where((log) => log.requiresFollowUp).toList();
      return Result.success(logsRequiringFollowUp);
    } catch (e) {
      return Result.failure(
        ServerFailure('Failed to get quality logs requiring follow-up',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<SupplierQualityLog>>> getQualityLogsForSupplier(
      String supplierId) async {
    try {
      final supplierLogs = _mockQualityLogs
          .where((log) => log.supplierId == supplierId)
          .toList();
      return Result.success(supplierLogs);
    } catch (e) {
      return Result.failure(
        ServerFailure('Failed to get quality logs for supplier',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<SupplierQualityLog>>> getQualityLogsForPurchaseOrder(
      String purchaseOrderId) async {
    try {
      final poLogs = _mockQualityLogs
          .where((log) => log.purchaseOrderId == purchaseOrderId)
          .toList();
      return Result.success(poLogs);
    } catch (e) {
      return Result.failure(
        ServerFailure('Failed to get quality logs for purchase order',
            details: e.toString()),
      );
    }
  }
}
