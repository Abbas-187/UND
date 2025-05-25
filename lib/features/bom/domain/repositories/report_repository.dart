import '../entities/report.dart';

abstract class ReportRepository {
  // Report Definition Management
  Future<List<ReportDefinition>> getAllReportDefinitions();
  Future<ReportDefinition?> getReportDefinitionById(String id);
  Future<String> createReportDefinition(ReportDefinition definition);
  Future<void> updateReportDefinition(ReportDefinition definition);
  Future<void> deleteReportDefinition(String id);

  // Report Templates
  Future<List<ReportDefinition>> getReportTemplates();
  Future<List<ReportDefinition>> getReportTemplatesByType(ReportType type);
  Future<ReportDefinition?> getReportTemplateById(String id);

  // Report Generation
  Future<ReportResult> generateReport({
    required String definitionId,
    Map<String, dynamic>? parameters,
    List<ReportFilter>? additionalFilters,
  });

  Future<ReportResult> generateReportFromDefinition({
    required ReportDefinition definition,
    Map<String, dynamic>? parameters,
  });

  // Report Results Management
  Future<List<ReportResult>> getReportResults({
    String? definitionId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  });

  Future<ReportResult?> getReportResultById(String id);
  Future<void> deleteReportResult(String id);
  Future<void> deleteOldReportResults(DateTime beforeDate);

  // Report Export
  Future<String> exportReport({
    required String resultId,
    required ReportFormat format,
  });

  Future<String> exportReportData({
    required ReportResult result,
    required ReportFormat format,
  });

  // Report Scheduling
  Future<List<ReportSchedule>> getReportSchedules();
  Future<ReportSchedule?> getReportScheduleById(String id);
  Future<String> createReportSchedule(ReportSchedule schedule);
  Future<void> updateReportSchedule(ReportSchedule schedule);
  Future<void> deleteReportSchedule(String id);
  Future<void> executeScheduledReport(String scheduleId);

  // Data Source Management
  Future<List<ReportField>> getAvailableFields();
  Future<List<ReportField>> getFieldsBySource(String source);
  Future<Map<String, List<dynamic>>> getFieldValues(String fieldId);

  // Report Analytics
  Future<Map<String, dynamic>> getReportUsageStatistics();
  Future<Map<String, int>> getReportGenerationStats({
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<List<Map<String, dynamic>>> getPopularReports({int limit = 10});
  Future<Map<String, dynamic>> getReportPerformanceMetrics();

  // Validation
  Future<List<String>> validateReportDefinition(ReportDefinition definition);
  Future<bool> isReportNameUnique(String name, {String? excludeId});

  // Search and Filtering
  Future<List<ReportDefinition>> searchReportDefinitions({
    String? query,
    ReportType? type,
    String? createdBy,
    bool? isTemplate,
  });

  Future<List<ReportResult>> searchReportResults({
    String? query,
    String? definitionId,
    DateTime? fromDate,
    DateTime? toDate,
  });
}
