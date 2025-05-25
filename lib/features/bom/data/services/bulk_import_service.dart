import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/repositories/bom_repository.dart';
import '../../domain/usecases/bulk_operations_usecase.dart';
import '../cache/bom_cache_manager.dart';
import '../../utils/performance_monitor.dart';

/// Specialized service for bulk importing BOM data from various file formats
class BulkImportService {
  final BomRepository _bomRepository;
  final BomCacheManager _cacheManager;
  final PerformanceMonitor _performanceMonitor;
  final Logger _logger = Logger();

  BulkImportService({
    required BomRepository bomRepository,
    required BomCacheManager cacheManager,
    required PerformanceMonitor performanceMonitor,
  })  : _bomRepository = bomRepository,
        _cacheManager = cacheManager,
        _performanceMonitor = performanceMonitor;

  /// Import BOMs from CSV file
  Future<ImportResult> importFromCsvFile({
    required File csvFile,
    required String userId,
    bool validateOnly = false,
    ImportOptions? options,
    Function(ImportProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_import_csv_file',
      () => _executeFileImport(
          csvFile, userId, validateOnly, options, onProgress),
    );
  }

  /// Import BOMs from CSV string data
  Future<ImportResult> importFromCsvData({
    required String csvData,
    required String userId,
    bool validateOnly = false,
    ImportOptions? options,
    Function(ImportProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_import_csv_data',
      () =>
          _executeCsvImport(csvData, userId, validateOnly, options, onProgress),
    );
  }

  /// Import BOMs from Excel file
  Future<ImportResult> importFromExcelFile({
    required File excelFile,
    required String userId,
    bool validateOnly = false,
    ImportOptions? options,
    Function(ImportProgress)? onProgress,
  }) async {
    return await _performanceMonitor.recordTiming(
      'bulk_import_excel_file',
      () => _executeExcelImport(
          excelFile, userId, validateOnly, options, onProgress),
    );
  }

  /// Validate import data without importing
  Future<ValidationSummary> validateImportData({
    required String data,
    required ImportFormat format,
    ImportOptions? options,
  }) async {
    return await _performanceMonitor.recordTiming(
      'validate_import_data',
      () => _executeValidation(data, format, options),
    );
  }

  /// Get import template for CSV format
  String getCsvTemplate({bool includeItems = false}) {
    final headers = [
      'BOM Code',
      'BOM Name',
      'Product ID',
      'Product Code',
      'Product Name',
      'Version',
      'Base Quantity',
      'Base Unit',
      'BOM Type',
      'Description',
      'Notes',
    ];

    if (includeItems) {
      headers.addAll([
        'Item Code',
        'Item Name',
        'Item Quantity',
        'Item Unit',
        'Item Type',
        'Sequence Number',
        'Cost Per Unit',
        'Supplier Code',
        'Lead Time Days',
      ]);
    }

    return headers.join(',');
  }

  /// Get import template for Excel format
  Map<String, dynamic> getExcelTemplate({bool includeItems = false}) {
    return {
      'worksheets': {
        'BOMs': {
          'headers': [
            'BOM Code',
            'BOM Name',
            'Product ID',
            'Product Code',
            'Product Name',
            'Version',
            'Base Quantity',
            'Base Unit',
            'BOM Type',
            'Description',
            'Notes',
          ],
          'sample_data': [
            {
              'BOM Code': 'BOM-001',
              'BOM Name': 'Sample BOM',
              'Product ID': 'PROD-001',
              'Product Code': 'P001',
              'Product Name': 'Sample Product',
              'Version': '1.0',
              'Base Quantity': '1',
              'Base Unit': 'pcs',
              'BOM Type': 'production',
              'Description': 'Sample BOM description',
              'Notes': 'Sample notes',
            }
          ],
        },
        if (includeItems)
          'Items': {
            'headers': [
              'BOM Code',
              'Item Code',
              'Item Name',
              'Item Quantity',
              'Item Unit',
              'Item Type',
              'Sequence Number',
              'Cost Per Unit',
              'Supplier Code',
              'Lead Time Days',
            ],
            'sample_data': [
              {
                'BOM Code': 'BOM-001',
                'Item Code': 'ITEM-001',
                'Item Name': 'Sample Item',
                'Item Quantity': '2',
                'Item Unit': 'kg',
                'Item Type': 'rawMaterial',
                'Sequence Number': '1',
                'Cost Per Unit': '10.50',
                'Supplier Code': 'SUP-001',
                'Lead Time Days': '7',
              }
            ],
          },
        'Instructions': {
          'content': [
            'Import Instructions:',
            '1. Fill in the BOM data in the BOMs worksheet',
            '2. If including items, fill in the Items worksheet',
            '3. Ensure all required fields are filled',
            '4. Use the exact values for BOM Type: production, engineering, maintenance',
            '5. Use the exact values for Item Type: rawMaterial, packaging, labor, overhead',
            '6. Quantities must be positive numbers',
            '7. Dates should be in YYYY-MM-DD format',
            '',
            'Required Fields:',
            '- BOM Code (must be unique)',
            '- BOM Name',
            '- Product ID',
            '- Base Quantity',
            '- Base Unit',
            '',
            'Optional Fields:',
            '- Product Code, Product Name, Version, Description, Notes',
            '',
            'Item Fields (if including items):',
            '- BOM Code (must match a BOM)',
            '- Item Code, Item Name, Item Quantity, Item Unit, Item Type',
          ],
        },
      },
    };
  }

  /// Private implementation methods

  Future<ImportResult> _executeFileImport(
    File file,
    String userId,
    bool validateOnly,
    ImportOptions? options,
    Function(ImportProgress)? onProgress,
  ) async {
    try {
      final fileContent = await file.readAsString();
      return await _executeCsvImport(
          fileContent, userId, validateOnly, options, onProgress);
    } catch (e) {
      _logger.e('Failed to read import file: $e');
      return ImportResult(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        validateOnly: validateOnly,
        hasErrors: true,
      );
    }
  }

  Future<ImportResult> _executeCsvImport(
    String csvData,
    String userId,
    bool validateOnly,
    ImportOptions? options,
    Function(ImportProgress)? onProgress,
  ) async {
    final result = ImportResult(
      startTime: DateTime.now(),
      validateOnly: validateOnly,
    );

    try {
      _logger.i('Starting CSV import (validate only: $validateOnly)');

      // Parse CSV data
      final parsedData = _parseCsvData(csvData, options);
      result.totalRows = parsedData.length;

      if (parsedData.isEmpty) {
        return result.copyWith(
          endTime: DateTime.now(),
          hasErrors: true,
        );
      }

      // Process data in batches
      const batchSize = 50;
      for (int i = 0; i < parsedData.length; i += batchSize) {
        final batch = parsedData.skip(i).take(batchSize).toList();

        await _processBatch(
            batch, i, result, userId, validateOnly, options, onProgress);

        // Small delay between batches
        await Future.delayed(Duration(milliseconds: 50));
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

  Future<ImportResult> _executeExcelImport(
    File excelFile,
    String userId,
    bool validateOnly,
    ImportOptions? options,
    Function(ImportProgress)? onProgress,
  ) async {
    final result = ImportResult(
      startTime: DateTime.now(),
      validateOnly: validateOnly,
    );

    try {
      _logger.i('Starting Excel import (validate only: $validateOnly)');

      // This would use a package like excel to read Excel files
      // For now, we'll simulate Excel processing
      final excelData = await _parseExcelFile(excelFile);
      result.totalRows = excelData.length;

      // Process Excel data similar to CSV
      for (int i = 0; i < excelData.length; i++) {
        final row = excelData[i];

        try {
          final validationResult = _validateImportRow(row, i + 1, options);

          if (validationResult.isValid) {
            if (!validateOnly) {
              final bom = _createBomFromImportData(row, userId, options);
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
            totalRows: excelData.length,
            validRows: result.validRowCount,
            errorRows: result.errorRowCount,
            currentRow: i + 1,
            status: validateOnly
                ? 'Validating row ${i + 1}'
                : 'Importing row ${i + 1}',
          ));
        } catch (e) {
          result.addError(i + 1, e.toString());
          _logger.e('Failed to process Excel row ${i + 1}: $e');
        }
      }

      return result.copyWith(endTime: DateTime.now());
    } catch (e) {
      _logger.e('Excel import operation failed: $e');
      return result.copyWith(
        endTime: DateTime.now(),
        hasErrors: true,
      );
    }
  }

  Future<ValidationSummary> _executeValidation(
    String data,
    ImportFormat format,
    ImportOptions? options,
  ) async {
    final summary = ValidationSummary(startTime: DateTime.now());

    try {
      List<Map<String, dynamic>> parsedData;

      switch (format) {
        case ImportFormat.csv:
          parsedData = _parseCsvData(data, options);
          break;
        case ImportFormat.excel:
          // Would parse Excel data here
          parsedData = [];
          break;
        case ImportFormat.json:
          parsedData = _parseJsonData(data, options);
          break;
      }

      summary.totalRows = parsedData.length;

      for (int i = 0; i < parsedData.length; i++) {
        final row = parsedData[i];
        final validationResult = _validateImportRow(row, i + 1, options);

        if (validationResult.isValid) {
          summary.addValid(i + 1);
        } else {
          summary.addInvalid(i + 1, validationResult.errors);
        }
      }

      return summary.copyWith(endTime: DateTime.now());
    } catch (e) {
      _logger.e('Validation operation failed: $e');
      return summary.copyWith(
        endTime: DateTime.now(),
        hasErrors: true,
      );
    }
  }

  Future<void> _processBatch(
    List<Map<String, dynamic>> batch,
    int startIndex,
    ImportResult result,
    String userId,
    bool validateOnly,
    ImportOptions? options,
    Function(ImportProgress)? onProgress,
  ) async {
    for (int i = 0; i < batch.length; i++) {
      final rowIndex = startIndex + i + 1;
      final row = batch[i];

      try {
        final validationResult = _validateImportRow(row, rowIndex, options);

        if (validationResult.isValid) {
          if (!validateOnly) {
            final bom = _createBomFromImportData(row, userId, options);
            final bomId = await _bomRepository.createBom(bom);
            result.addSuccess(rowIndex, bomId);

            // Cache the new BOM
            await _cacheManager.cacheBom(bom);
          } else {
            result.addValidRow(rowIndex);
          }
        } else {
          result.addErrors(rowIndex, validationResult.errors);
        }

        // Report progress
        onProgress?.call(ImportProgress(
          processedRows: rowIndex,
          totalRows: result.totalRows,
          validRows: result.validRowCount,
          errorRows: result.errorRowCount,
          currentRow: rowIndex,
          status: validateOnly
              ? 'Validating row $rowIndex'
              : 'Importing row $rowIndex',
        ));
      } catch (e) {
        result.addError(rowIndex, e.toString());
        _logger.e('Failed to process import row $rowIndex: $e');
      }
    }
  }

  List<Map<String, dynamic>> _parseCsvData(
      String csvData, ImportOptions? options) {
    final lines =
        csvData.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [];

    final delimiter = options?.csvDelimiter ?? ',';
    final hasHeader = options?.hasHeader ?? true;

    final headerLine = hasHeader ? lines.first : null;
    final dataLines = hasHeader ? lines.skip(1).toList() : lines;

    List<String> headers;
    if (headerLine != null) {
      headers = headerLine
          .split(delimiter)
          .map((h) => h.trim().replaceAll('"', ''))
          .toList();
    } else {
      // Generate default headers
      final firstLine =
          dataLines.isNotEmpty ? dataLines.first.split(delimiter) : [];
      headers =
          List.generate(firstLine.length, (index) => 'Column${index + 1}');
    }

    final data = <Map<String, dynamic>>[];

    for (int i = 0; i < dataLines.length; i++) {
      final line = dataLines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCsvLine(line, delimiter);
      final row = <String, dynamic>{};

      for (int j = 0; j < headers.length && j < values.length; j++) {
        row[headers[j]] = values[j];
      }

      // Add row number for tracking
      row['_rowNumber'] = i + (hasHeader ? 2 : 1);

      data.add(row);
    }

    return data;
  }

  List<String> _parseCsvLine(String line, String delimiter) {
    final values = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == delimiter && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    values.add(buffer.toString().trim());
    return values;
  }

  Future<List<Map<String, dynamic>>> _parseExcelFile(File excelFile) async {
    // This would use a package like excel to parse Excel files
    // For now, return mock data
    return [
      {
        'BOM Code': 'BOM-EXCEL-001',
        'BOM Name': 'Excel Imported BOM',
        'Product ID': 'PROD-EXCEL-001',
        'Base Quantity': '1',
        'Base Unit': 'pcs',
        '_rowNumber': 2,
      }
    ];
  }

  List<Map<String, dynamic>> _parseJsonData(
      String jsonData, ImportOptions? options) {
    try {
      final decoded = jsonDecode(jsonData);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else if (decoded is Map && decoded.containsKey('boms')) {
        return (decoded['boms'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _logger.e('Failed to parse JSON data: $e');
      return [];
    }
  }

  ValidationResult _validateImportRow(
      Map<String, dynamic> row, int rowNumber, ImportOptions? options) {
    final errors = <String>[];
    final rules = options?.validationRules ?? _getDefaultValidationRules();

    // Apply validation rules
    for (final rule in rules) {
      try {
        if (!rule.validator(row)) {
          errors.add('${rule.name}: ${rule.description}');
        }
      } catch (e) {
        errors.add('${rule.name}: Validation error - $e');
      }
    }

    // Additional custom validations
    if (options?.customValidator != null) {
      try {
        final customResult = options!.customValidator!(row, rowNumber);
        if (!customResult.isValid) {
          errors.addAll(customResult.errors);
        }
      } catch (e) {
        errors.add('Custom validation error: $e');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  BillOfMaterials _createBomFromImportData(
      Map<String, dynamic> row, String userId, ImportOptions? options) {
    final bomType = _parseBomType(row['BOM Type']?.toString());
    final baseQuantity =
        double.tryParse(row['Base Quantity']?.toString() ?? '1') ?? 1.0;

    return BillOfMaterials(
      id: 'bom_${DateTime.now().millisecondsSinceEpoch}_${row['_rowNumber'] ?? 0}',
      bomCode: row['BOM Code']?.toString() ?? '',
      bomName: row['BOM Name']?.toString() ?? '',
      productId: row['Product ID']?.toString() ?? '',
      productCode: row['Product Code']?.toString() ?? '',
      productName: row['Product Name']?.toString() ?? '',
      bomType: bomType,
      version: row['Version']?.toString() ?? '1.0',
      baseQuantity: baseQuantity,
      baseUnit: row['Base Unit']?.toString() ?? 'pcs',
      status: BomStatus.draft,
      description: row['Description']?.toString(),
      notes: row['Notes']?.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: userId,
      updatedBy: userId,
    );
  }

  BomType _parseBomType(String? typeString) {
    if (typeString == null) return BomType.production;

    switch (typeString.toLowerCase()) {
      case 'production':
        return BomType.production;
      case 'engineering':
        return BomType.engineering;
      case 'sales':
        return BomType.sales;
      case 'costing':
        return BomType.costing;
      case 'planning':
        return BomType.planning;
      default:
        return BomType.production;
    }
  }

  List<ImportValidationRule> _getDefaultValidationRules() {
    return [
      ImportValidationRule(
        name: 'Required BOM Code',
        description: 'BOM Code is required and must not be empty',
        validator: (row) =>
            row['BOM Code']?.toString().trim().isNotEmpty ?? false,
      ),
      ImportValidationRule(
        name: 'Required BOM Name',
        description: 'BOM Name is required and must not be empty',
        validator: (row) =>
            row['BOM Name']?.toString().trim().isNotEmpty ?? false,
      ),
      ImportValidationRule(
        name: 'Required Product ID',
        description: 'Product ID is required and must not be empty',
        validator: (row) =>
            row['Product ID']?.toString().trim().isNotEmpty ?? false,
      ),
      ImportValidationRule(
        name: 'Valid Base Quantity',
        description: 'Base Quantity must be a positive number',
        validator: (row) {
          final qty = double.tryParse(row['Base Quantity']?.toString() ?? '');
          return qty != null && qty > 0;
        },
      ),
      ImportValidationRule(
        name: 'Valid BOM Type',
        description:
            'BOM Type must be one of: production, engineering, sales, costing, planning',
        validator: (row) {
          final type = row['BOM Type']?.toString().toLowerCase();
          return type == null ||
              ['production', 'engineering', 'sales', 'costing', 'planning']
                  .contains(type);
        },
      ),
    ];
  }
}

// Supporting classes and enums

enum ImportFormat {
  csv,
  excel,
  json,
}

class ImportOptions {
  final String csvDelimiter;
  final bool hasHeader;
  final List<ImportValidationRule> validationRules;
  final ValidationResult Function(Map<String, dynamic>, int)? customValidator;
  final bool skipEmptyRows;
  final bool trimWhitespace;
  final Map<String, String> fieldMapping;

  ImportOptions({
    this.csvDelimiter = ',',
    this.hasHeader = true,
    List<ImportValidationRule>? validationRules,
    this.customValidator,
    this.skipEmptyRows = true,
    this.trimWhitespace = true,
    Map<String, String>? fieldMapping,
  })  : validationRules = validationRules ?? [],
        fieldMapping = fieldMapping ?? {};
}

class ImportValidationRule {
  final String name;
  final String description;
  final bool Function(Map<String, dynamic>) validator;

  ImportValidationRule({
    required this.name,
    required this.description,
    required this.validator,
  });
}

class ValidationSummary {
  final DateTime startTime;
  final DateTime? endTime;
  int totalRows;
  final List<int> validRows;
  final Map<int, List<String>> invalidRows;
  final bool hasErrors;

  ValidationSummary({
    required this.startTime,
    this.endTime,
    this.totalRows = 0,
    List<int>? validRows,
    Map<int, List<String>>? invalidRows,
    this.hasErrors = false,
  })  : validRows = validRows ?? [],
        invalidRows = invalidRows ?? {};

  int get validCount => validRows.length;
  int get invalidCount => invalidRows.length;
  double get validPercentage =>
      totalRows > 0 ? (validCount / totalRows) * 100 : 0;

  void addValid(int rowNumber) {
    validRows.add(rowNumber);
  }

  void addInvalid(int rowNumber, List<String> errors) {
    invalidRows[rowNumber] = errors;
  }

  ValidationSummary copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? totalRows,
    List<int>? validRows,
    Map<int, List<String>>? invalidRows,
    bool? hasErrors,
  }) {
    return ValidationSummary(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalRows: totalRows ?? this.totalRows,
      validRows: validRows ?? this.validRows,
      invalidRows: invalidRows ?? this.invalidRows,
      hasErrors: hasErrors ?? this.hasErrors,
    );
  }
}

/// Provider for bulk import service
final bulkImportServiceProvider = Provider<BulkImportService>((ref) {
  throw UnimplementedError('Dependencies need to be implemented');
});
