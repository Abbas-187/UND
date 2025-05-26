import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/cache/bom_cache_manager.dart';
import '../../utils/performance_monitor.dart';
import '../entities/bill_of_materials.dart';
import '../entities/bom_item.dart';
import '../repositories/bom_repository.dart';

/// Comprehensive bulk operations use case for BOM management
class BulkOperationsUseCase {

  BulkOperationsUseCase({
    required BomRepository bomRepository,
    required BomCacheManager cacheManager,
    required PerformanceMonitor performanceMonitor,
  })  : _bomRepository = bomRepository,
        _cacheManager = cacheManager,
        _performanceMonitor = performanceMonitor;
  final BomRepository _bomRepository;
  final BomCacheManager _cacheManager;
  final PerformanceMonitor _performanceMonitor;
  final Logger _logger = Logger();

  /// Bulk update BOMs with progress tracking
  Future<BulkOperationResult> bulkUpdateBoms({
    required List<String> bomIds,
    required Map<String, dynamic> updates,
    String? userId,
    Function(BulkProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_update_boms',
      () => _executeBulkUpdate(bomIds, updates, userId, onProgress),
    );
  }

  /// Bulk delete BOMs with confirmation
  Future<BulkOperationResult> bulkDeleteBoms({
    required List<String> bomIds,
    required String userId,
    bool forceDelete = false,
    Function(BulkProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_delete_boms',
      () => _executeBulkDelete(bomIds, userId, forceDelete, onProgress),
    );
  }

  /// Bulk copy/clone BOMs
  Future<BulkOperationResult> bulkCopyBoms({
    required List<String> bomIds,
    required String userId,
    String? namePrefix,
    bool copyItems = true,
    Function(BulkProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_copy_boms',
      () => _executeBulkCopy(bomIds, userId, namePrefix, copyItems, onProgress),
    );
  }

  /// Bulk status change
  Future<BulkOperationResult> bulkChangeStatus({
    required List<String> bomIds,
    required BomStatus newStatus,
    required String userId,
    String? reason,
    Function(BulkProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_change_status',
      () => _executeBulkStatusChange(
          bomIds, newStatus, userId, reason, onProgress),
    );
  }

  /// Bulk cost recalculation
  Future<BulkOperationResult> bulkRecalculateCosts({
    required List<String> bomIds,
    bool updateCache = true,
    Function(BulkProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_recalculate_costs',
      () => _executeBulkCostRecalculation(bomIds, updateCache, onProgress),
    );
  }

  /// Import BOMs from CSV
  Future<ImportResult> importBomsFromCsv({
    required String csvData,
    required String userId,
    bool validateOnly = false,
    Function(ImportProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'import_boms_csv',
      () => _executeImportFromCsv(csvData, userId, validateOnly, onProgress),
    );
  }

  /// Export BOMs to CSV
  Future<ExportResult> exportBomsToCSV({
    required List<String> bomIds,
    bool includeItems = true,
    bool includeCosts = true,
    Function(ExportProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'export_boms_csv',
      () => _executeExportToCsv(bomIds, includeItems, includeCosts, onProgress),
    );
  }

  /// Export BOMs to Excel
  Future<ExportResult> exportBomsToExcel({
    required List<String> bomIds,
    bool includeItems = true,
    bool includeCosts = true,
    bool includeCharts = false,
    Function(ExportProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'export_boms_excel',
      () => _executeExportToExcel(
          bomIds, includeItems, includeCosts, includeCharts, onProgress),
    );
  }

  /// Validate BOMs in bulk
  Future<BulkValidationResult> bulkValidateBoms({
    required List<String> bomIds,
    List<ValidationRule>? customRules,
    Function(ValidationProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_validate_boms',
      () => _executeBulkValidation(bomIds, customRules, onProgress),
    );
  }

  /// Private implementation methods

  Future<BulkOperationResult> _executeBulkUpdate(
    List<String> bomIds,
    Map<String, dynamic> updates,
    String? userId,
    Function(BulkProgress)? onProgress,
  ) async {
    final result = BulkOperationResult(
      operationType: BulkOperationType.update,
      totalItems: bomIds.length,
      startTime: DateTime.now(),
    );

    try {
      _logger.i('Starting bulk update for ${bomIds.length} BOMs');

      // Validate all BOMs exist and user has permissions
      final validationResult = await _validateBomAccess(bomIds, userId);
      if (!validationResult.isValid) {
        result.addErrors(validationResult.errors);
        return result.copyWith(status: BulkOperationStatus.failed);
      }

      // Process in batches
      const batchSize = 10;
      for (int i = 0; i < bomIds.length; i += batchSize) {
        final batch = bomIds.skip(i).take(batchSize).toList();

        for (final bomId in batch) {
          try {
            // Get current BOM
            final currentBom = await _bomRepository.getBomById(bomId);
            if (currentBom == null) {
              result.addError(bomId, 'BOM not found');
              continue;
            }

            // Apply updates
            final updatedBom = _applyUpdates(currentBom, updates, userId);

            // Save updated BOM
            await _bomRepository.updateBom(updatedBom);

            // Invalidate cache
            await _cacheManager.invalidateBomCache(bomId);

            result.addSuccess(bomId);

            // Report progress
            onProgress?.call(BulkProgress(
              completed: result.successCount + result.errorCount,
              total: bomIds.length,
              currentItem: bomId,
              status: 'Updated BOM $bomId',
            ));
          } catch (e) {
            result.addError(bomId, e.toString());
            _logger.e('Failed to update BOM $bomId: $e');
          }
        }

        // Small delay between batches
        await Future.delayed(Duration(milliseconds: 100));
      }

      final status = result.errorCount == 0
          ? BulkOperationStatus.completed
          : result.successCount > 0
              ? BulkOperationStatus.partiallyCompleted
              : BulkOperationStatus.failed;

      return result.copyWith(
        status: status,
        endTime: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Bulk update operation failed: $e');
      return result.copyWith(
        status: BulkOperationStatus.failed,
        endTime: DateTime.now(),
      );
    }
  }

  Future<BulkOperationResult> _executeBulkDelete(
    List<String> bomIds,
    String userId,
    bool forceDelete,
    Function(BulkProgress)? onProgress,
  ) async {
    final result = BulkOperationResult(
      operationType: BulkOperationType.delete,
      totalItems: bomIds.length,
      startTime: DateTime.now(),
    );

    try {
      _logger.i('Starting bulk delete for ${bomIds.length} BOMs');

      for (int i = 0; i < bomIds.length; i++) {
        final bomId = bomIds[i];

        try {
          // Check if BOM can be deleted
          if (!forceDelete) {
            final canDelete = await _canDeleteBom(bomId);
            if (!canDelete.allowed) {
              result.addError(bomId, canDelete.reason ?? 'Cannot delete BOM');
              continue;
            }
          }

          // Delete BOM
          await _bomRepository.deleteBom(bomId);

          // Invalidate cache
          await _cacheManager.invalidateBomCache(bomId);

          result.addSuccess(bomId);

          // Report progress
          onProgress?.call(BulkProgress(
            completed: i + 1,
            total: bomIds.length,
            currentItem: bomId,
            status: 'Deleted BOM $bomId',
          ));
        } catch (e) {
          result.addError(bomId, e.toString());
          _logger.e('Failed to delete BOM $bomId: $e');
        }
      }

      final status = result.errorCount == 0
          ? BulkOperationStatus.completed
          : result.successCount > 0
              ? BulkOperationStatus.partiallyCompleted
              : BulkOperationStatus.failed;

      return result.copyWith(
        status: status,
        endTime: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Bulk delete operation failed: $e');
      return result.copyWith(
        status: BulkOperationStatus.failed,
        endTime: DateTime.now(),
      );
    }
  }

  Future<BulkOperationResult> _executeBulkCopy(
    List<String> bomIds,
    String userId,
    String? namePrefix,
    bool copyItems,
    Function(BulkProgress)? onProgress,
  ) async {
    final result = BulkOperationResult(
      operationType: BulkOperationType.copy,
      totalItems: bomIds.length,
      startTime: DateTime.now(),
    );

    try {
      _logger.i('Starting bulk copy for ${bomIds.length} BOMs');

      for (int i = 0; i < bomIds.length; i++) {
        final bomId = bomIds[i];

        try {
          // Get source BOM
          final sourceBom = await _bomRepository.getBomById(bomId);
          if (sourceBom == null) {
            result.addError(bomId, 'Source BOM not found');
            continue;
          }

          // Create copy
          final copiedBom =
              _createBomCopy(sourceBom, namePrefix, copyItems, userId);

          // Save copied BOM
          final newBomId = await _bomRepository.createBom(copiedBom);

          result.addSuccess(bomId, metadata: {'newBomId': newBomId});

          // Report progress
          onProgress?.call(BulkProgress(
            completed: i + 1,
            total: bomIds.length,
            currentItem: bomId,
            status: 'Copied BOM $bomId to $newBomId',
          ));
        } catch (e) {
          result.addError(bomId, e.toString());
          _logger.e('Failed to copy BOM $bomId: $e');
        }
      }

      final status = result.errorCount == 0
          ? BulkOperationStatus.completed
          : result.successCount > 0
              ? BulkOperationStatus.partiallyCompleted
              : BulkOperationStatus.failed;

      return result.copyWith(
        status: status,
        endTime: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Bulk copy operation failed: $e');
      return result.copyWith(
        status: BulkOperationStatus.failed,
        endTime: DateTime.now(),
      );
    }
  }

  Future<BulkOperationResult> _executeBulkStatusChange(
    List<String> bomIds,
    BomStatus newStatus,
    String userId,
    String? reason,
    Function(BulkProgress)? onProgress,
  ) async {
    final result = BulkOperationResult(
      operationType: BulkOperationType.statusChange,
      totalItems: bomIds.length,
      startTime: DateTime.now(),
    );

    try {
      _logger.i(
          'Starting bulk status change for ${bomIds.length} BOMs to $newStatus');

      for (int i = 0; i < bomIds.length; i++) {
        final bomId = bomIds[i];

        try {
          // Get current BOM
          final currentBom = await _bomRepository.getBomById(bomId);
          if (currentBom == null) {
            result.addError(bomId, 'BOM not found');
            continue;
          }

          // Check if status change is allowed
          final canChange = _canChangeStatus(currentBom.status, newStatus);
          if (!canChange.allowed) {
            result.addError(
                bomId, canChange.reason ?? 'Status change not allowed');
            continue;
          }

          // Update status
          final updatedBom = currentBom.copyWith(
            status: newStatus,
            updatedAt: DateTime.now(),
            updatedBy: userId,
          );

          await _bomRepository.updateBom(updatedBom);

          // Invalidate cache
          await _cacheManager.invalidateBomCache(bomId);

          result.addSuccess(bomId);

          // Report progress
          onProgress?.call(BulkProgress(
            completed: i + 1,
            total: bomIds.length,
            currentItem: bomId,
            status: 'Changed status of BOM $bomId to $newStatus',
          ));
        } catch (e) {
          result.addError(bomId, e.toString());
          _logger.e('Failed to change status of BOM $bomId: $e');
        }
      }

      final status = result.errorCount == 0
          ? BulkOperationStatus.completed
          : result.successCount > 0
              ? BulkOperationStatus.partiallyCompleted
              : BulkOperationStatus.failed;

      return result.copyWith(
        status: status,
        endTime: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Bulk status change operation failed: $e');
      return result.copyWith(
        status: BulkOperationStatus.failed,
        endTime: DateTime.now(),
      );
    }
  }

  Future<BulkOperationResult> _executeBulkCostRecalculation(
    List<String> bomIds,
    bool updateCache,
    Function(BulkProgress)? onProgress,
  ) async {
    final result = BulkOperationResult(
      operationType: BulkOperationType.costRecalculation,
      totalItems: bomIds.length,
      startTime: DateTime.now(),
    );

    try {
      _logger.i('Starting bulk cost recalculation for ${bomIds.length} BOMs');

      for (int i = 0; i < bomIds.length; i++) {
        final bomId = bomIds[i];

        try {
          // Get current BOM
          final currentBom = await _bomRepository.getBomById(bomId);
          if (currentBom == null) {
            result.addError(bomId, 'BOM not found');
            continue;
          }

          // Recalculate costs
          final newTotalCost =
              currentBom.calculateTotalBomCost(currentBom.baseQuantity);

          // Update BOM with new cost
          final updatedBom = currentBom.copyWith(
            totalCost: newTotalCost,
            updatedAt: DateTime.now(),
          );

          await _bomRepository.updateBom(updatedBom);

          // Update cache if requested
          if (updateCache) {
            await _cacheManager.cacheBom(updatedBom);

            // Cache cost calculation
            final itemCosts = <String, double>{};
            for (final item in currentBom.items) {
              itemCosts[item.id] =
                  item.calculateTotalCost(currentBom.baseQuantity);
            }
            await _cacheManager.cacheBomCost(bomId, newTotalCost, itemCosts);
          }

          result.addSuccess(bomId, metadata: {'newCost': newTotalCost});

          // Report progress
          onProgress?.call(BulkProgress(
            completed: i + 1,
            total: bomIds.length,
            currentItem: bomId,
            status:
                'Recalculated cost for BOM $bomId: \$${newTotalCost.toStringAsFixed(2)}',
          ));
        } catch (e) {
          result.addError(bomId, e.toString());
          _logger.e('Failed to recalculate cost for BOM $bomId: $e');
        }
      }

      final status = result.errorCount == 0
          ? BulkOperationStatus.completed
          : result.successCount > 0
              ? BulkOperationStatus.partiallyCompleted
              : BulkOperationStatus.failed;

      return result.copyWith(
        status: status,
        endTime: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Bulk cost recalculation operation failed: $e');
      return result.copyWith(
        status: BulkOperationStatus.failed,
        endTime: DateTime.now(),
      );
    }
  }

  Future<ImportResult> _executeImportFromCsv(
    String csvData,
    String userId,
    bool validateOnly,
    Function(ImportProgress)? onProgress,
  ) async {
    final result = ImportResult(
      startTime: DateTime.now(),
      validateOnly: validateOnly,
    );

    try {
      _logger.i('Starting CSV import (validate only: $validateOnly)');

      // Parse CSV data
      final parsedData = _parseCsvData(csvData);
      result.totalRows = parsedData.length;

      // Validate data
      for (int i = 0; i < parsedData.length; i++) {
        final row = parsedData[i];

        try {
          final validationResult = _validateImportRow(row, i + 1);

          if (validationResult.isValid) {
            if (!validateOnly) {
              // Create BOM from row data
              final bom = _createBomFromImportData(row, userId);
              final bomId = await _bomRepository.createBom(bom);
              result.addSuccess(i + 1, bomId);
            } else {
              result.addValidRow(i + 1);
            }
          } else {
            result.addErrors(i + 1, validationResult.errors);
          }

          // Report progress
          onProgress?.call(ImportProgress(
            processedRows: i + 1,
            totalRows: parsedData.length,
            validRows: result.validRowCount,
            errorRows: result.errorRowCount,
            currentRow: i + 1,
            status: validateOnly
                ? 'Validating row ${i + 1}'
                : 'Importing row ${i + 1}',
          ));
        } catch (e) {
          result.addError(i + 1, e.toString());
          _logger.e('Failed to process import row ${i + 1}: $e');
        }
      }

      return result.copyWith(endTime: DateTime.now());
    } catch (e) {
      _logger.e('CSV import operation failed: $e');
      return result.copyWith(
        endTime: DateTime.now(),
        hasErrors: true,
      );
    }
  }

  Future<ExportResult> _executeExportToCsv(
    List<String> bomIds,
    bool includeItems,
    bool includeCosts,
    Function(ExportProgress)? onProgress,
  ) async {
    final result = ExportResult(
      format: ExportFormat.csv,
      startTime: DateTime.now(),
      totalItems: bomIds.length,
    );

    try {
      _logger.i('Starting CSV export for ${bomIds.length} BOMs');

      final csvData = StringBuffer();

      // Add header
      csvData.writeln(_getCsvHeader(includeItems, includeCosts));

      for (int i = 0; i < bomIds.length; i++) {
        final bomId = bomIds[i];

        try {
          final bom = await _bomRepository.getBomById(bomId);
          if (bom == null) {
            result.addError(bomId, 'BOM not found');
            continue;
          }

          // Add BOM data to CSV
          csvData.writeln(_bomToCsvRow(bom, includeItems, includeCosts));

          result.addSuccess(bomId);

          // Report progress
          onProgress?.call(ExportProgress(
            processedItems: i + 1,
            totalItems: bomIds.length,
            currentItem: bomId,
            status: 'Exported BOM $bomId',
          ));
        } catch (e) {
          result.addError(bomId, e.toString());
          _logger.e('Failed to export BOM $bomId: $e');
        }
      }

      result.data = csvData.toString();
      result.fileName =
          'boms_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      return result.copyWith(endTime: DateTime.now());
    } catch (e) {
      _logger.e('CSV export operation failed: $e');
      return result.copyWith(
        endTime: DateTime.now(),
        hasErrors: true,
      );
    }
  }

  Future<ExportResult> _executeExportToExcel(
    List<String> bomIds,
    bool includeItems,
    bool includeCosts,
    bool includeCharts,
    Function(ExportProgress)? onProgress,
  ) async {
    final result = ExportResult(
      format: ExportFormat.excel,
      startTime: DateTime.now(),
      totalItems: bomIds.length,
    );

    try {
      _logger.i('Starting Excel export for ${bomIds.length} BOMs');

      // This would use a package like excel to create Excel files
      // For now, we'll create a structured data representation
      final excelData = <String, dynamic>{
        'worksheets': <String, List<Map<String, dynamic>>>{
          'BOMs': [],
          'Items': [],
          'Summary': [],
        },
        'charts': includeCharts ? [] : null,
      };

      for (int i = 0; i < bomIds.length; i++) {
        final bomId = bomIds[i];

        try {
          final bom = await _bomRepository.getBomById(bomId);
          if (bom == null) {
            result.addError(bomId, 'BOM not found');
            continue;
          }

          // Add BOM to worksheets
          excelData['worksheets']['BOMs']
              .add(_bomToExcelRow(bom, includeCosts));

          if (includeItems) {
            for (final item in bom.items) {
              excelData['worksheets']['Items']
                  .add(_bomItemToExcelRow(item, bom.id));
            }
          }

          result.addSuccess(bomId);

          // Report progress
          onProgress?.call(ExportProgress(
            processedItems: i + 1,
            totalItems: bomIds.length,
            currentItem: bomId,
            status: 'Exported BOM $bomId to Excel',
          ));
        } catch (e) {
          result.addError(bomId, e.toString());
          _logger.e('Failed to export BOM $bomId to Excel: $e');
        }
      }

      // Add summary data
      excelData['worksheets']['Summary'] =
          _generateExcelSummary(bomIds, result);

      result.data = jsonEncode(excelData);
      result.fileName =
          'boms_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      return result.copyWith(endTime: DateTime.now());
    } catch (e) {
      _logger.e('Excel export operation failed: $e');
      return result.copyWith(
        endTime: DateTime.now(),
        hasErrors: true,
      );
    }
  }

  Future<BulkValidationResult> _executeBulkValidation(
    List<String> bomIds,
    List<ValidationRule>? customRules,
    Function(ValidationProgress)? onProgress,
  ) async {
    final result = BulkValidationResult(
      startTime: DateTime.now(),
      totalItems: bomIds.length,
    );

    try {
      _logger.i('Starting bulk validation for ${bomIds.length} BOMs');

      final rules = customRules ?? _getDefaultValidationRules();

      for (int i = 0; i < bomIds.length; i++) {
        final bomId = bomIds[i];

        try {
          final bom = await _bomRepository.getBomById(bomId);
          if (bom == null) {
            result.addError(bomId, 'BOM not found');
            continue;
          }

          // Validate BOM against rules
          final validationResult = _validateBomAgainstRules(bom, rules);

          if (validationResult.isValid) {
            result.addValid(bomId);
          } else {
            result.addInvalid(bomId, validationResult.errors);
          }

          // Report progress
          onProgress?.call(ValidationProgress(
            processedItems: i + 1,
            totalItems: bomIds.length,
            validItems: result.validCount,
            invalidItems: result.invalidCount,
            currentItem: bomId,
            status: 'Validated BOM $bomId',
          ));
        } catch (e) {
          result.addError(bomId, e.toString());
          _logger.e('Failed to validate BOM $bomId: $e');
        }
      }

      return result.copyWith(endTime: DateTime.now());
    } catch (e) {
      _logger.e('Bulk validation operation failed: $e');
      return result.copyWith(
        endTime: DateTime.now(),
        hasErrors: true,
      );
    }
  }

  // Helper methods

  Future<ValidationResult> _validateBomAccess(
      List<String> bomIds, String? userId) async {
    // Implementation would check user permissions for each BOM
    return ValidationResult(isValid: true, errors: []);
  }

  BillOfMaterials _applyUpdates(
      BillOfMaterials bom, Map<String, dynamic> updates, String? userId) {
    // Apply updates to BOM fields
    return bom.copyWith(
      bomName: updates['bomName'] ?? bom.bomName,
      description: updates['description'] ?? bom.description,
      status: updates['status'] != null
          ? BomStatus.values.firstWhere(
              (s) => s.toString().split('.').last == updates['status'],
              orElse: () => bom.status,
            )
          : bom.status,
      updatedAt: DateTime.now(),
      updatedBy: userId,
    );
  }

  Future<DeletionCheck> _canDeleteBom(String bomId) async {
    // Check if BOM can be deleted (not referenced by other BOMs, not in production, etc.)
    return DeletionCheck(allowed: true);
  }

  BillOfMaterials _createBomCopy(BillOfMaterials source, String? namePrefix,
      bool copyItems, String userId) {
    final prefix = namePrefix ?? 'Copy of ';
    final newId = 'bom_${DateTime.now().millisecondsSinceEpoch}';

    return source.copyWith(
      id: newId,
      bomCode: '${source.bomCode}_COPY',
      bomName: '$prefix${source.bomName}',
      status: BomStatus.draft,
      items: copyItems
          ? source.items
              .map((item) => item.copyWith(
                    id: 'item_${DateTime.now().millisecondsSinceEpoch}_${item.sequenceNumber}',
                  ))
              .toList()
          : [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: userId,
      updatedBy: userId,
    );
  }

  StatusChangeCheck _canChangeStatus(
      BomStatus currentStatus, BomStatus newStatus) {
    // Define allowed status transitions
    final allowedTransitions = <BomStatus, List<BomStatus>>{
      BomStatus.draft: [BomStatus.underReview, BomStatus.active],
      BomStatus.underReview: [
        BomStatus.approved,
        BomStatus.rejected,
        BomStatus.draft
      ],
      BomStatus.approved: [BomStatus.active],
      BomStatus.active: [BomStatus.inactive, BomStatus.obsolete],
      BomStatus.inactive: [BomStatus.active, BomStatus.obsolete],
      BomStatus.rejected: [BomStatus.draft],
      BomStatus.obsolete: [],
    };

    final allowed =
        allowedTransitions[currentStatus]?.contains(newStatus) ?? false;
    return StatusChangeCheck(
      allowed: allowed,
      reason: allowed
          ? null
          : 'Cannot change status from $currentStatus to $newStatus',
    );
  }

  List<Map<String, dynamic>> _parseCsvData(String csvData) {
    // Simple CSV parsing - in production, use a proper CSV parser
    final lines = csvData.split('\n');
    if (lines.isEmpty) return [];

    final headers = lines.first.split(',').map((h) => h.trim()).toList();
    final data = <Map<String, dynamic>>[];

    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;

      final values = lines[i].split(',').map((v) => v.trim()).toList();
      final row = <String, dynamic>{};

      for (int j = 0; j < headers.length && j < values.length; j++) {
        row[headers[j]] = values[j];
      }

      data.add(row);
    }

    return data;
  }

  ValidationResult _validateImportRow(Map<String, dynamic> row, int rowNumber) {
    final errors = <String>[];

    // Validate required fields
    if (row['bomCode']?.toString().isEmpty ?? true) {
      errors.add('BOM Code is required');
    }
    if (row['bomName']?.toString().isEmpty ?? true) {
      errors.add('BOM Name is required');
    }
    if (row['productId']?.toString().isEmpty ?? true) {
      errors.add('Product ID is required');
    }

    // Validate data types
    try {
      if (row['baseQuantity'] != null) {
        double.parse(row['baseQuantity'].toString());
      }
    } catch (e) {
      errors.add('Base Quantity must be a valid number');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  BillOfMaterials _createBomFromImportData(
      Map<String, dynamic> row, String userId) {
    return BillOfMaterials(
      id: 'bom_${DateTime.now().millisecondsSinceEpoch}',
      bomCode: row['bomCode'].toString(),
      bomName: row['bomName'].toString(),
      productId: row['productId'].toString(),
      productCode: row['productCode']?.toString() ?? '',
      productName: row['productName']?.toString() ?? '',
      bomType: BomType.production,
      version: row['version']?.toString() ?? '1.0',
      baseQuantity:
          double.tryParse(row['baseQuantity']?.toString() ?? '1') ?? 1.0,
      baseUnit: row['baseUnit']?.toString() ?? 'pcs',
      status: BomStatus.draft,
      description: row['description']?.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: userId,
      updatedBy: userId,
    );
  }

  String _getCsvHeader(bool includeItems, bool includeCosts) {
    final headers = [
      'BOM Code',
      'BOM Name',
      'Product ID',
      'Product Name',
      'Version',
      'Status',
      'Base Quantity',
      'Base Unit',
      'Description',
    ];

    if (includeCosts) {
      headers.addAll(['Total Cost', 'Labor Cost', 'Overhead Cost']);
    }

    if (includeItems) {
      headers.addAll(['Item Count', 'Raw Materials', 'Packaging Materials']);
    }

    return headers.join(',');
  }

  String _bomToCsvRow(
      BillOfMaterials bom, bool includeItems, bool includeCosts) {
    final values = [
      bom.bomCode,
      bom.bomName,
      bom.productId,
      bom.productName,
      bom.version,
      bom.status.toString().split('.').last,
      bom.baseQuantity.toString(),
      bom.baseUnit,
      bom.description ?? '',
    ];

    if (includeCosts) {
      values.addAll([
        bom.totalCost.toString(),
        bom.laborCost.toString(),
        bom.overheadCost.toString(),
      ]);
    }

    if (includeItems) {
      values.addAll([
        bom.items.length.toString(),
        bom.rawMaterials.length.toString(),
        bom.packagingMaterials.length.toString(),
      ]);
    }

    return values.map((v) => '"$v"').join(',');
  }

  Map<String, dynamic> _bomToExcelRow(BillOfMaterials bom, bool includeCosts) {
    final row = <String, dynamic>{
      'BOM Code': bom.bomCode,
      'BOM Name': bom.bomName,
      'Product ID': bom.productId,
      'Product Name': bom.productName,
      'Version': bom.version,
      'Status': bom.status.toString().split('.').last,
      'Base Quantity': bom.baseQuantity,
      'Base Unit': bom.baseUnit,
      'Description': bom.description ?? '',
      'Item Count': bom.items.length,
      'Created At': bom.createdAt.toIso8601String(),
      'Updated At': bom.updatedAt.toIso8601String(),
    };

    if (includeCosts) {
      row.addAll({
        'Total Cost': bom.totalCost,
        'Labor Cost': bom.laborCost,
        'Overhead Cost': bom.overheadCost,
        'Setup Cost': bom.setupCost,
      });
    }

    return row;
  }

  Map<String, dynamic> _bomItemToExcelRow(BomItem item, String bomId) {
    return {
      'BOM ID': bomId,
      'Item Code': item.itemCode,
      'Item Name': item.itemName,
      'Quantity': item.quantity,
      'Unit': item.unit,
      'Item Type': item.itemType.toString().split('.').last,
      'Sequence': item.sequenceNumber,
      'Cost Per Unit': item.costPerUnit,
      'Total Cost': item.calculateTotalCost(1.0),
      'Supplier Code': item.supplierCode ?? '',
      'Status': item.status.toString().split('.').last,
    };
  }

  List<Map<String, dynamic>> _generateExcelSummary(
      List<String> bomIds, ExportResult result) {
    return [
      {
        'Metric': 'Total BOMs',
        'Value': bomIds.length,
      },
      {
        'Metric': 'Successfully Exported',
        'Value': result.successCount,
      },
      {
        'Metric': 'Export Errors',
        'Value': result.errorCount,
      },
      {
        'Metric': 'Export Date',
        'Value': DateTime.now().toIso8601String(),
      },
    ];
  }

  List<ValidationRule> _getDefaultValidationRules() {
    return [
      ValidationRule(
        name: 'Required Fields',
        description: 'Check that all required fields are present',
        validator: (bom) => bom.bomCode.isNotEmpty && bom.bomName.isNotEmpty,
      ),
      ValidationRule(
        name: 'Valid Quantities',
        description: 'Check that quantities are positive',
        validator: (bom) =>
            bom.baseQuantity > 0 &&
            bom.items.every((item) => item.quantity > 0),
      ),
      ValidationRule(
        name: 'Active Items',
        description: 'Check that BOM has at least one active item',
        validator: (bom) => bom.items.any((item) => item.isActive),
      ),
    ];
  }

  ValidationResult _validateBomAgainstRules(
      BillOfMaterials bom, List<ValidationRule> rules) {
    final errors = <String>[];

    for (final rule in rules) {
      try {
        if (!rule.validator(bom)) {
          errors.add('${rule.name}: ${rule.description}');
        }
      } catch (e) {
        errors.add('${rule.name}: Validation error - $e');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

// Supporting classes and enums

enum BulkOperationType {
  update,
  delete,
  copy,
  statusChange,
  costRecalculation,
}

enum BulkOperationStatus {
  pending,
  running,
  completed,
  partiallyCompleted,
  failed,
  cancelled,
}

enum ExportFormat {
  csv,
  excel,
  pdf,
  json,
}

class BulkOperationResult {

  BulkOperationResult({
    required this.operationType,
    this.status = BulkOperationStatus.pending,
    required this.totalItems,
    required this.startTime,
    this.endTime,
    List<String>? successfulItems,
    Map<String, String>? errors,
    Map<String, Map<String, dynamic>>? metadata,
  })  : successfulItems = successfulItems ?? [],
        errors = errors ?? {},
        metadata = metadata ?? {};
  final BulkOperationType operationType;
  final BulkOperationStatus status;
  final int totalItems;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> successfulItems;
  final Map<String, String> errors;
  final Map<String, Map<String, dynamic>> metadata;

  int get successCount => successfulItems.length;
  int get errorCount => errors.length;
  Duration? get duration => endTime?.difference(startTime);
  bool get isCompleted => status == BulkOperationStatus.completed;
  bool get hasErrors => errors.isNotEmpty;

  void addSuccess(String itemId, {Map<String, dynamic>? metadata}) {
    successfulItems.add(itemId);
    if (metadata != null) {
      this.metadata[itemId] = metadata;
    }
  }

  void addError(String itemId, String error) {
    errors[itemId] = error;
  }

  void addErrors(List<String> errorList) {
    for (final error in errorList) {
      errors[DateTime.now().millisecondsSinceEpoch.toString()] = error;
    }
  }

  BulkOperationResult copyWith({
    BulkOperationType? operationType,
    BulkOperationStatus? status,
    int? totalItems,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? successfulItems,
    Map<String, String>? errors,
    Map<String, Map<String, dynamic>>? metadata,
  }) {
    return BulkOperationResult(
      operationType: operationType ?? this.operationType,
      status: status ?? this.status,
      totalItems: totalItems ?? this.totalItems,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      successfulItems: successfulItems ?? this.successfulItems,
      errors: errors ?? this.errors,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ImportResult {

  ImportResult({
    required this.startTime,
    this.endTime,
    required this.validateOnly,
    this.totalRows = 0,
    List<int>? validRows,
    Map<int, List<String>>? errors,
    Map<int, String>? successfulImports,
    this.hasErrors = false,
  })  : validRows = validRows ?? [],
        errors = errors ?? {},
        successfulImports = successfulImports ?? {};
  final DateTime startTime;
  final DateTime? endTime;
  final bool validateOnly;
  int totalRows;
  final List<int> validRows;
  final Map<int, List<String>> errors;
  final Map<int, String> successfulImports;
  final bool hasErrors;

  int get validRowCount => validRows.length;
  int get errorRowCount => errors.length;
  int get successCount => successfulImports.length;

  void addValidRow(int rowNumber) {
    validRows.add(rowNumber);
  }

  void addSuccess(int rowNumber, String bomId) {
    successfulImports[rowNumber] = bomId;
  }

  void addError(int rowNumber, String error) {
    errors.putIfAbsent(rowNumber, () => []).add(error);
  }

  void addErrors(int rowNumber, List<String> errorList) {
    errors.putIfAbsent(rowNumber, () => []).addAll(errorList);
  }

  ImportResult copyWith({
    DateTime? startTime,
    DateTime? endTime,
    bool? validateOnly,
    int? totalRows,
    List<int>? validRows,
    Map<int, List<String>>? errors,
    Map<int, String>? successfulImports,
    bool? hasErrors,
  }) {
    return ImportResult(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      validateOnly: validateOnly ?? this.validateOnly,
      totalRows: totalRows ?? this.totalRows,
      validRows: validRows ?? this.validRows,
      errors: errors ?? this.errors,
      successfulImports: successfulImports ?? this.successfulImports,
      hasErrors: hasErrors ?? this.hasErrors,
    );
  }
}

class ExportResult {

  ExportResult({
    required this.format,
    required this.startTime,
    this.endTime,
    required this.totalItems,
    List<String>? successfulItems,
    Map<String, String>? errors,
    this.hasErrors = false,
    this.data,
    this.fileName,
  })  : successfulItems = successfulItems ?? [],
        errors = errors ?? {};
  final ExportFormat format;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalItems;
  final List<String> successfulItems;
  final Map<String, String> errors;
  final bool hasErrors;
  String? data;
  String? fileName;

  int get successCount => successfulItems.length;
  int get errorCount => errors.length;

  void addSuccess(String itemId) {
    successfulItems.add(itemId);
  }

  void addError(String itemId, String error) {
    errors[itemId] = error;
  }

  ExportResult copyWith({
    ExportFormat? format,
    DateTime? startTime,
    DateTime? endTime,
    int? totalItems,
    List<String>? successfulItems,
    Map<String, String>? errors,
    bool? hasErrors,
    String? data,
    String? fileName,
  }) {
    return ExportResult(
      format: format ?? this.format,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalItems: totalItems ?? this.totalItems,
      successfulItems: successfulItems ?? this.successfulItems,
      errors: errors ?? this.errors,
      hasErrors: hasErrors ?? this.hasErrors,
      data: data ?? this.data,
      fileName: fileName ?? this.fileName,
    );
  }
}

class BulkValidationResult {

  BulkValidationResult({
    required this.startTime,
    this.endTime,
    required this.totalItems,
    List<String>? validItems,
    Map<String, List<String>>? invalidItems,
    Map<String, String>? errors,
    this.hasErrors = false,
  })  : validItems = validItems ?? [],
        invalidItems = invalidItems ?? {},
        errors = errors ?? {};
  final DateTime startTime;
  final DateTime? endTime;
  final int totalItems;
  final List<String> validItems;
  final Map<String, List<String>> invalidItems;
  final Map<String, String> errors;
  final bool hasErrors;

  int get validCount => validItems.length;
  int get invalidCount => invalidItems.length;
  int get errorCount => errors.length;

  void addValid(String itemId) {
    validItems.add(itemId);
  }

  void addInvalid(String itemId, List<String> validationErrors) {
    invalidItems[itemId] = validationErrors;
  }

  void addError(String itemId, String error) {
    errors[itemId] = error;
  }

  BulkValidationResult copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? totalItems,
    List<String>? validItems,
    Map<String, List<String>>? invalidItems,
    Map<String, String>? errors,
    bool? hasErrors,
  }) {
    return BulkValidationResult(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalItems: totalItems ?? this.totalItems,
      validItems: validItems ?? this.validItems,
      invalidItems: invalidItems ?? this.invalidItems,
      errors: errors ?? this.errors,
      hasErrors: hasErrors ?? this.hasErrors,
    );
  }
}

// Progress tracking classes
class BulkProgress {

  BulkProgress({
    required this.completed,
    required this.total,
    required this.currentItem,
    required this.status,
  });
  final int completed;
  final int total;
  final String currentItem;
  final String status;

  double get percentage => total > 0 ? (completed / total) * 100 : 0;
}

class ImportProgress {

  ImportProgress({
    required this.processedRows,
    required this.totalRows,
    required this.validRows,
    required this.errorRows,
    required this.currentRow,
    required this.status,
  });
  final int processedRows;
  final int totalRows;
  final int validRows;
  final int errorRows;
  final int currentRow;
  final String status;

  double get percentage =>
      totalRows > 0 ? (processedRows / totalRows) * 100 : 0;
}

class ExportProgress {

  ExportProgress({
    required this.processedItems,
    required this.totalItems,
    required this.currentItem,
    required this.status,
  });
  final int processedItems;
  final int totalItems;
  final String currentItem;
  final String status;

  double get percentage =>
      totalItems > 0 ? (processedItems / totalItems) * 100 : 0;
}

class ValidationProgress {

  ValidationProgress({
    required this.processedItems,
    required this.totalItems,
    required this.validItems,
    required this.invalidItems,
    required this.currentItem,
    required this.status,
  });
  final int processedItems;
  final int totalItems;
  final int validItems;
  final int invalidItems;
  final String currentItem;
  final String status;

  double get percentage =>
      totalItems > 0 ? (processedItems / totalItems) * 100 : 0;
}

// Validation classes
class ValidationResult {

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
  final bool isValid;
  final List<String> errors;
}

class ValidationRule {

  ValidationRule({
    required this.name,
    required this.description,
    required this.validator,
  });
  final String name;
  final String description;
  final bool Function(BillOfMaterials) validator;
}

class DeletionCheck {

  DeletionCheck({
    required this.allowed,
    this.reason,
  });
  final bool allowed;
  final String? reason;
}

class StatusChangeCheck {

  StatusChangeCheck({
    required this.allowed,
    this.reason,
  });
  final bool allowed;
  final String? reason;
}

/// Provider for bulk operations use case
final bulkOperationsUseCaseProvider = Provider<BulkOperationsUseCase>((ref) {
  // Note: bomRepositoryProvider should be defined in the repository file
  // For now, we'll create a placeholder that needs to be replaced
  throw UnimplementedError(
      'bomRepositoryProvider needs to be implemented in the repository layer');
});
