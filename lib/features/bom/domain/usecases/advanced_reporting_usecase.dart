import 'dart:async';

import '../entities/report.dart';
import '../repositories/report_repository.dart';

class AdvancedReportingUseCase {

  AdvancedReportingUseCase(this._reportRepository);
  final ReportRepository _reportRepository;

  // Report Definition Management
  Future<List<ReportDefinition>> getAllReportDefinitions() async {
    return await _reportRepository.getAllReportDefinitions();
  }

  Future<ReportDefinition?> getReportDefinitionById(String id) async {
    return await _reportRepository.getReportDefinitionById(id);
  }

  Future<String> createReportDefinition(ReportDefinition definition) async {
    // Validate the report definition
    final validationErrors = await _validateReportDefinition(definition);
    if (validationErrors.isNotEmpty) {
      throw Exception(
          'Report validation failed: ${validationErrors.join(', ')}');
    }

    // Check name uniqueness
    final isUnique =
        await _reportRepository.isReportNameUnique(definition.name);
    if (!isUnique) {
      throw Exception('Report name already exists');
    }

    return await _reportRepository.createReportDefinition(definition);
  }

  Future<void> updateReportDefinition(ReportDefinition definition) async {
    // Validate the report definition
    final validationErrors = await _validateReportDefinition(definition);
    if (validationErrors.isNotEmpty) {
      throw Exception(
          'Report validation failed: ${validationErrors.join(', ')}');
    }

    // Check name uniqueness (excluding current report)
    final isUnique = await _reportRepository.isReportNameUnique(
      definition.name,
      excludeId: definition.id,
    );
    if (!isUnique) {
      throw Exception('Report name already exists');
    }

    await _reportRepository.updateReportDefinition(definition);
  }

  Future<void> deleteReportDefinition(String id) async {
    // Check if report has scheduled runs
    final schedules = await _reportRepository.getReportSchedules();
    final hasSchedules = schedules.any((s) => s.reportDefinitionId == id);

    if (hasSchedules) {
      throw Exception(
          'Cannot delete report with active schedules. Please delete schedules first.');
    }

    await _reportRepository.deleteReportDefinition(id);
  }

  // Report Templates
  Future<List<ReportDefinition>> getReportTemplates() async {
    return await _reportRepository.getReportTemplates();
  }

  Future<List<ReportDefinition>> getReportTemplatesByType(
      ReportType type) async {
    return await _reportRepository.getReportTemplatesByType(type);
  }

  Future<ReportDefinition> createReportFromTemplate({
    required String templateId,
    required String name,
    required String description,
    Map<String, dynamic>? parameters,
    List<ReportFilter>? additionalFilters,
  }) async {
    final template = await _reportRepository.getReportTemplateById(templateId);
    if (template == null) {
      throw Exception('Template not found');
    }

    // Create new report definition from template
    final newDefinition = template.copyWith(
      id: '', // Will be generated
      name: name,
      description: description,
      isTemplate: false,
      parameters: {...template.parameters, ...?parameters},
      filters: [...template.filters, ...?additionalFilters],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final reportId = await createReportDefinition(newDefinition);
    return newDefinition.copyWith(id: reportId);
  }

  // Report Generation
  Future<ReportResult> generateReport({
    required String definitionId,
    Map<String, dynamic>? parameters,
    List<ReportFilter>? additionalFilters,
    Function(String)? onProgress,
  }) async {
    onProgress?.call('Loading report definition...');

    final definition =
        await _reportRepository.getReportDefinitionById(definitionId);
    if (definition == null) {
      throw Exception('Report definition not found');
    }

    onProgress?.call('Validating parameters...');

    // Validate required parameters
    final missingParams = _validateRequiredParameters(definition, parameters);
    if (missingParams.isNotEmpty) {
      throw Exception(
          'Missing required parameters: ${missingParams.join(', ')}');
    }

    onProgress?.call('Generating report...');

    return await _reportRepository.generateReport(
      definitionId: definitionId,
      parameters: parameters,
      additionalFilters: additionalFilters,
    );
  }

  Future<ReportResult> generateReportFromDefinition({
    required ReportDefinition definition,
    Map<String, dynamic>? parameters,
    Function(String)? onProgress,
  }) async {
    onProgress?.call('Validating report definition...');

    final validationErrors = await _validateReportDefinition(definition);
    if (validationErrors.isNotEmpty) {
      throw Exception(
          'Report validation failed: ${validationErrors.join(', ')}');
    }

    onProgress?.call('Generating report...');

    return await _reportRepository.generateReportFromDefinition(
      definition: definition,
      parameters: parameters,
    );
  }

  // Predefined Report Generators
  Future<ReportResult> generateCostAnalysisReport({
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? bomIds,
    List<String>? productIds,
  }) async {
    final definition = _createCostAnalysisReportDefinition();

    final parameters = <String, dynamic>{
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'bomIds': bomIds,
      'productIds': productIds,
    };

    return await generateReportFromDefinition(
      definition: definition,
      parameters: parameters,
    );
  }

  Future<ReportResult> generateMaterialUsageReport({
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? materialTypes,
    List<String>? supplierIds,
  }) async {
    final definition = _createMaterialUsageReportDefinition();

    final parameters = <String, dynamic>{
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'materialTypes': materialTypes,
      'supplierIds': supplierIds,
    };

    return await generateReportFromDefinition(
      definition: definition,
      parameters: parameters,
    );
  }

  Future<ReportResult> generateSupplierPerformanceReport({
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? supplierIds,
  }) async {
    final definition = _createSupplierPerformanceReportDefinition();

    final parameters = <String, dynamic>{
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'supplierIds': supplierIds,
    };

    return await generateReportFromDefinition(
      definition: definition,
      parameters: parameters,
    );
  }

  // Report Results Management
  Future<List<ReportResult>> getReportResults({
    String? definitionId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    return await _reportRepository.getReportResults(
      definitionId: definitionId,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
    );
  }

  Future<ReportResult?> getReportResultById(String id) async {
    return await _reportRepository.getReportResultById(id);
  }

  Future<void> deleteReportResult(String id) async {
    await _reportRepository.deleteReportResult(id);
  }

  Future<void> cleanupOldReports({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    await _reportRepository.deleteOldReportResults(cutoffDate);
  }

  // Report Export
  Future<String> exportReport({
    required String resultId,
    required ReportFormat format,
  }) async {
    return await _reportRepository.exportReport(
      resultId: resultId,
      format: format,
    );
  }

  Future<String> exportReportData({
    required ReportResult result,
    required ReportFormat format,
  }) async {
    return await _reportRepository.exportReportData(
      result: result,
      format: format,
    );
  }

  // Report Scheduling
  Future<List<ReportSchedule>> getReportSchedules() async {
    return await _reportRepository.getReportSchedules();
  }

  Future<String> createReportSchedule(ReportSchedule schedule) async {
    // Validate cron expression
    if (!_isValidCronExpression(schedule.cronExpression)) {
      throw Exception('Invalid cron expression');
    }

    // Validate report definition exists
    final definition = await _reportRepository.getReportDefinitionById(
      schedule.reportDefinitionId,
    );
    if (definition == null) {
      throw Exception('Report definition not found');
    }

    return await _reportRepository.createReportSchedule(schedule);
  }

  Future<void> updateReportSchedule(ReportSchedule schedule) async {
    if (!_isValidCronExpression(schedule.cronExpression)) {
      throw Exception('Invalid cron expression');
    }

    await _reportRepository.updateReportSchedule(schedule);
  }

  Future<void> deleteReportSchedule(String id) async {
    await _reportRepository.deleteReportSchedule(id);
  }

  Future<void> executeScheduledReport(String scheduleId) async {
    await _reportRepository.executeScheduledReport(scheduleId);
  }

  // Data Source Management
  Future<List<ReportField>> getAvailableFields() async {
    return await _reportRepository.getAvailableFields();
  }

  Future<List<ReportField>> getFieldsBySource(String source) async {
    return await _reportRepository.getFieldsBySource(source);
  }

  Future<Map<String, List<dynamic>>> getFieldValues(String fieldId) async {
    return await _reportRepository.getFieldValues(fieldId);
  }

  // Analytics and Statistics
  Future<Map<String, dynamic>> getReportUsageStatistics() async {
    return await _reportRepository.getReportUsageStatistics();
  }

  Future<Map<String, int>> getReportGenerationStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _reportRepository.getReportGenerationStats(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<List<Map<String, dynamic>>> getPopularReports({int limit = 10}) async {
    return await _reportRepository.getPopularReports(limit: limit);
  }

  Future<Map<String, dynamic>> getReportPerformanceMetrics() async {
    return await _reportRepository.getReportPerformanceMetrics();
  }

  // Search and Filtering
  Future<List<ReportDefinition>> searchReportDefinitions({
    String? query,
    ReportType? type,
    String? createdBy,
    bool? isTemplate,
  }) async {
    return await _reportRepository.searchReportDefinitions(
      query: query,
      type: type,
      createdBy: createdBy,
      isTemplate: isTemplate,
    );
  }

  Future<List<ReportResult>> searchReportResults({
    String? query,
    String? definitionId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _reportRepository.searchReportResults(
      query: query,
      definitionId: definitionId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  // Private helper methods
  Future<List<String>> _validateReportDefinition(
      ReportDefinition definition) async {
    final errors = <String>[];

    // Basic validation
    if (definition.name.trim().isEmpty) {
      errors.add('Report name is required');
    }

    if (definition.description.trim().isEmpty) {
      errors.add('Report description is required');
    }

    if (definition.fields.isEmpty) {
      errors.add('Report must have at least one field');
    }

    // Field validation
    for (final field in definition.fields) {
      if (field.name.trim().isEmpty) {
        errors.add('Field name is required');
      }
      if (field.source.trim().isEmpty) {
        errors.add('Field source is required');
      }
    }

    // Chart validation
    for (final chart in definition.charts) {
      if (chart.title.trim().isEmpty) {
        errors.add('Chart title is required');
      }

      final hasXField = definition.fields.any((f) => f.id == chart.xAxisField);
      if (!hasXField) {
        errors.add('Chart X-axis field not found in report fields');
      }

      final hasYField = definition.fields.any((f) => f.id == chart.yAxisField);
      if (!hasYField) {
        errors.add('Chart Y-axis field not found in report fields');
      }
    }

    // Filter validation
    for (final filter in definition.filters) {
      final hasField = definition.fields.any((f) => f.id == filter.fieldId);
      if (!hasField) {
        errors.add('Filter field not found in report fields');
      }
    }

    return errors;
  }

  List<String> _validateRequiredParameters(
    ReportDefinition definition,
    Map<String, dynamic>? parameters,
  ) {
    final missing = <String>[];
    final providedParams = parameters ?? {};

    // Check for required fields that need parameters
    for (final field in definition.fields.where((f) => f.isRequired)) {
      if (!providedParams.containsKey(field.id)) {
        missing.add(field.name);
      }
    }

    return missing;
  }

  bool _isValidCronExpression(String cronExpression) {
    // Basic cron expression validation
    // In a real implementation, use a proper cron parser
    final parts = cronExpression.split(' ');
    return parts.length == 5 || parts.length == 6;
  }

  // Predefined report definitions
  ReportDefinition _createCostAnalysisReportDefinition() {
    return ReportDefinition(
      id: 'cost_analysis_template',
      name: 'BOM Cost Analysis',
      description:
          'Comprehensive cost analysis of BOMs including material, labor, and overhead costs',
      type: ReportType.costAnalysis,
      fields: [
        const ReportField(
          id: 'bom_code',
          name: 'BOM Code',
          dataType: 'string',
          source: 'boms',
          isGroupable: true,
          isFilterable: true,
          isSortable: true,
        ),
        const ReportField(
          id: 'bom_name',
          name: 'BOM Name',
          dataType: 'string',
          source: 'boms',
          isFilterable: true,
          isSortable: true,
        ),
        const ReportField(
          id: 'product_name',
          name: 'Product Name',
          dataType: 'string',
          source: 'boms',
          isGroupable: true,
          isFilterable: true,
          isSortable: true,
        ),
        const ReportField(
          id: 'total_cost',
          name: 'Total Cost',
          dataType: 'decimal',
          source: 'boms',
          aggregationType: AggregationType.sum,
          format: 'currency',
          isSortable: true,
        ),
        const ReportField(
          id: 'material_cost',
          name: 'Material Cost',
          dataType: 'decimal',
          source: 'bom_items',
          aggregationType: AggregationType.sum,
          format: 'currency',
          isSortable: true,
        ),
        const ReportField(
          id: 'labor_cost',
          name: 'Labor Cost',
          dataType: 'decimal',
          source: 'boms',
          aggregationType: AggregationType.sum,
          format: 'currency',
          isSortable: true,
        ),
        const ReportField(
          id: 'overhead_cost',
          name: 'Overhead Cost',
          dataType: 'decimal',
          source: 'boms',
          aggregationType: AggregationType.sum,
          format: 'currency',
          isSortable: true,
        ),
      ],
      charts: [
        const ReportChart(
          id: 'cost_breakdown',
          title: 'Cost Breakdown by BOM',
          type: ChartType.bar,
          xAxisField: 'bom_name',
          yAxisField: 'total_cost',
        ),
        const ReportChart(
          id: 'cost_distribution',
          title: 'Cost Distribution',
          type: ChartType.pie,
          xAxisField: 'cost_type',
          yAxisField: 'cost_amount',
        ),
      ],
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ReportDefinition _createMaterialUsageReportDefinition() {
    return ReportDefinition(
      id: 'material_usage_template',
      name: 'Material Usage Report',
      description: 'Analysis of material consumption across BOMs',
      type: ReportType.materialUsage,
      fields: [
        const ReportField(
          id: 'item_code',
          name: 'Item Code',
          dataType: 'string',
          source: 'bom_items',
          isGroupable: true,
          isFilterable: true,
          isSortable: true,
        ),
        const ReportField(
          id: 'item_name',
          name: 'Item Name',
          dataType: 'string',
          source: 'bom_items',
          isFilterable: true,
          isSortable: true,
        ),
        const ReportField(
          id: 'item_type',
          name: 'Item Type',
          dataType: 'string',
          source: 'bom_items',
          isGroupable: true,
          isFilterable: true,
        ),
        const ReportField(
          id: 'total_quantity',
          name: 'Total Quantity Used',
          dataType: 'decimal',
          source: 'bom_items',
          aggregationType: AggregationType.sum,
          isSortable: true,
        ),
        const ReportField(
          id: 'unit',
          name: 'Unit',
          dataType: 'string',
          source: 'bom_items',
        ),
        const ReportField(
          id: 'supplier_name',
          name: 'Supplier',
          dataType: 'string',
          source: 'suppliers',
          isGroupable: true,
          isFilterable: true,
        ),
      ],
      charts: [
        const ReportChart(
          id: 'usage_by_type',
          title: 'Material Usage by Type',
          type: ChartType.pie,
          xAxisField: 'item_type',
          yAxisField: 'total_quantity',
        ),
        const ReportChart(
          id: 'top_materials',
          title: 'Top 10 Most Used Materials',
          type: ChartType.bar,
          xAxisField: 'item_name',
          yAxisField: 'total_quantity',
        ),
      ],
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ReportDefinition _createSupplierPerformanceReportDefinition() {
    return ReportDefinition(
      id: 'supplier_performance_template',
      name: 'Supplier Performance Report',
      description: 'Analysis of supplier performance metrics',
      type: ReportType.supplierPerformance,
      fields: [
        const ReportField(
          id: 'supplier_code',
          name: 'Supplier Code',
          dataType: 'string',
          source: 'suppliers',
          isGroupable: true,
          isFilterable: true,
          isSortable: true,
        ),
        const ReportField(
          id: 'supplier_name',
          name: 'Supplier Name',
          dataType: 'string',
          source: 'suppliers',
          isFilterable: true,
          isSortable: true,
        ),
        const ReportField(
          id: 'total_orders',
          name: 'Total Orders',
          dataType: 'integer',
          source: 'purchase_orders',
          aggregationType: AggregationType.count,
          isSortable: true,
        ),
        const ReportField(
          id: 'on_time_delivery_rate',
          name: 'On-Time Delivery Rate',
          dataType: 'decimal',
          source: 'purchase_orders',
          aggregationType: AggregationType.percentage,
          format: 'percentage',
          isSortable: true,
        ),
        const ReportField(
          id: 'quality_rating',
          name: 'Quality Rating',
          dataType: 'decimal',
          source: 'quality_assessments',
          aggregationType: AggregationType.average,
          isSortable: true,
        ),
        const ReportField(
          id: 'total_value',
          name: 'Total Order Value',
          dataType: 'decimal',
          source: 'purchase_orders',
          aggregationType: AggregationType.sum,
          format: 'currency',
          isSortable: true,
        ),
      ],
      charts: [
        const ReportChart(
          id: 'supplier_performance',
          title: 'Supplier Performance Overview',
          type: ChartType.scatter,
          xAxisField: 'on_time_delivery_rate',
          yAxisField: 'quality_rating',
          groupByField: 'supplier_name',
        ),
        const ReportChart(
          id: 'order_value_by_supplier',
          title: 'Order Value by Supplier',
          type: ChartType.bar,
          xAxisField: 'supplier_name',
          yAxisField: 'total_value',
        ),
      ],
      isTemplate: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
