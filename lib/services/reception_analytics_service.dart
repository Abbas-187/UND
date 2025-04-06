import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/milk_reception/domain/models/milk_quality_test_model.dart';
import '../features/milk_reception/domain/models/milk_reception_model.dart';
import '../features/milk_reception/domain/repositories/milk_reception_repository.dart';
import '../utils/exceptions.dart';

/// Service for analyzing milk reception data and generating reports
class ReceptionAnalyticsService {
  ReceptionAnalyticsService({
    required MilkReceptionRepository receptionRepository,
    FirebaseFirestore? firestore,
  })  : _receptionRepository = receptionRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final MilkReceptionRepository _receptionRepository;
  final FirebaseFirestore _firestore;

  /// Calculate trends in supplier milk quality over time
  Future<Map<String, dynamic>> calculateSupplierQualityTrends(
      String supplierId, DateRange period) async {
    try {
      // Get receptions for the specified supplier and period
      final receptions = await _receptionRepository.getReceptionsBySupplier(
        supplierId,
        limit: 100,
      );

      // Filter by date range
      final filteredReceptions = receptions
          .where((reception) =>
              reception.timestamp.isAfter(period.start) &&
              reception.timestamp.isBefore(period.end))
          .toList();

      // If no data found
      if (filteredReceptions.isEmpty) {
        return {
          'supplierId': supplierId,
          'period': {
            'start': period.start.toIso8601String(),
            'end': period.end.toIso8601String(),
          },
          'dataPoints': 0,
          'message': 'No data available for this period',
        };
      }

      // Organize by time periods
      final periodData = _organizeDataByTimePeriods(
          filteredReceptions, period.start, period.end);

      // Get quality test data for these receptions
      final qualityTests = await _getQualityTestsForReceptions(
          filteredReceptions.map((r) => r.id).toList());

      // Calculate trends for different quality parameters
      final results = await _calculateQualityTrends(
          filteredReceptions, qualityTests, periodData);

      return {
        'supplierId': supplierId,
        'supplierName': filteredReceptions.first.supplierName,
        'period': {
          'start': period.start.toIso8601String(),
          'end': period.end.toIso8601String(),
        },
        'dataPoints': filteredReceptions.length,
        'trends': results,
      };
    } catch (e) {
      throw AnalyticsException(
          'Failed to calculate supplier quality trends: $e');
    }
  }

  /// Analyze reception volumes by date range and grouping
  Future<Map<String, dynamic>> analyzeReceptionVolumes(
      DateRange dateRange, GroupBy groupBy) async {
    try {
      // Get receptions for the specified date range
      final receptions = await _receptionRepository.getReceptionsByDateRange(
        dateRange.start,
        dateRange.end,
        limit: 500, // Consider pagination for large datasets
      );

      if (receptions.isEmpty) {
        return {
          'period': {
            'start': dateRange.start.toIso8601String(),
            'end': dateRange.end.toIso8601String(),
          },
          'dataPoints': 0,
          'message': 'No data available for this period',
        };
      }

      // Group the data based on the specified grouping
      final groupedData = _groupVolumeData(receptions, groupBy);

      // Calculate statistics
      final stats = _calculateVolumeStatistics(receptions);

      return {
        'period': {
          'start': dateRange.start.toIso8601String(),
          'end': dateRange.end.toIso8601String(),
        },
        'dataPoints': receptions.length,
        'groupedBy': groupBy.toString().split('.').last,
        'volumeData': groupedData,
        'statistics': stats,
      };
    } catch (e) {
      throw AnalyticsException('Failed to analyze reception volumes: $e');
    }
  }

  /// Calculate rejection statistics for milk receptions
  Future<Map<String, dynamic>> calculateRejectionStatistics(
      DateRange dateRange) async {
    try {
      // Get all receptions for the date range
      final receptions = await _receptionRepository.getReceptionsByDateRange(
        dateRange.start,
        dateRange.end,
        limit: 500,
      );

      // Filter rejected receptions
      final rejectedReceptions = receptions
          .where((r) => r.receptionStatus == ReceptionStatus.rejected)
          .toList();

      if (receptions.isEmpty) {
        return {
          'period': {
            'start': dateRange.start.toIso8601String(),
            'end': dateRange.end.toIso8601String(),
          },
          'message': 'No data available for this period',
        };
      }

      // Calculate rejection rate
      final rejectionRate =
          (rejectedReceptions.length / receptions.length) * 100;

      // Group rejection reasons
      final rejectionReasons = _analyzeRejectionReasons(rejectedReceptions);

      // Group by supplier
      final supplierRejections =
          _analyzeRejectionsBySupplier(rejectedReceptions, receptions);

      return {
        'period': {
          'start': dateRange.start.toIso8601String(),
          'end': dateRange.end.toIso8601String(),
        },
        'totalReceptions': receptions.length,
        'rejectedReceptions': rejectedReceptions.length,
        'rejectionRate': rejectionRate,
        'rejectionReasons': rejectionReasons,
        'supplierAnalysis': supplierRejections,
      };
    } catch (e) {
      throw AnalyticsException('Failed to calculate rejection statistics: $e');
    }
  }

  /// Analyze trends in specific quality parameters
  Future<Map<String, dynamic>> analyzeQualityParametersTrend(
      List<String> parameters, DateRange dateRange) async {
    try {
      // Get receptions for the date range
      final receptions = await _receptionRepository.getReceptionsByDateRange(
        dateRange.start,
        dateRange.end,
        limit: 500,
      );

      if (receptions.isEmpty) {
        return {
          'period': {
            'start': dateRange.start.toIso8601String(),
            'end': dateRange.end.toIso8601String(),
          },
          'message': 'No data available for this period',
        };
      }

      // Get quality tests for these receptions
      final qualityTests = await _getQualityTestsForReceptions(
          receptions.map((r) => r.id).toList());

      // Analyze trends for requested parameters
      final parameterTrends =
          await _analyzeParameterTrends(qualityTests, parameters, dateRange);

      return {
        'period': {
          'start': dateRange.start.toIso8601String(),
          'end': dateRange.end.toIso8601String(),
        },
        'parameters': parameters,
        'dataPoints': qualityTests.length,
        'trends': parameterTrends,
      };
    } catch (e) {
      throw AnalyticsException(
          'Failed to analyze quality parameters trend: $e');
    }
  }

  /// Predict future milk reception volumes
  Future<Map<String, dynamic>> predictFutureVolumes(
      DateRange forecastPeriod) async {
    try {
      // Calculate the historical period (3x the forecast period for better prediction)
      final historicalDays =
          forecastPeriod.end.difference(forecastPeriod.start).inDays;
      final historicalStart =
          forecastPeriod.start.subtract(Duration(days: historicalDays * 3));

      // Get historical receptions
      final historicalReceptions =
          await _receptionRepository.getReceptionsByDateRange(
        historicalStart,
        forecastPeriod.start.subtract(const Duration(days: 1)),
        limit: 1000,
      );

      if (historicalReceptions.isEmpty) {
        return {
          'forecastPeriod': {
            'start': forecastPeriod.start.toIso8601String(),
            'end': forecastPeriod.end.toIso8601String(),
          },
          'message': 'Insufficient historical data for prediction',
        };
      }

      // Generate forecast using simple moving average or another forecasting method
      final forecast = _generateForecast(
          historicalReceptions, forecastPeriod.start, forecastPeriod.end);

      return {
        'forecastPeriod': {
          'start': forecastPeriod.start.toIso8601String(),
          'end': forecastPeriod.end.toIso8601String(),
        },
        'historicalDataPoints': historicalReceptions.length,
        'forecastMethod': 'movingAverage',
        'forecast': forecast,
      };
    } catch (e) {
      throw AnalyticsException('Failed to predict future volumes: $e');
    }
  }

  /// Generate a comprehensive performance report for a supplier
  Future<Map<String, dynamic>> generateSupplierPerformanceReport(
      String supplierId, DateRange dateRange) async {
    try {
      // Get supplier receptions for the date range
      final receptions = await _receptionRepository.getReceptionsBySupplier(
        supplierId,
        limit: 200,
      );

      final filteredReceptions = receptions
          .where((reception) =>
              reception.timestamp.isAfter(dateRange.start) &&
              reception.timestamp.isBefore(dateRange.end))
          .toList();

      if (filteredReceptions.isEmpty) {
        return {
          'supplierId': supplierId,
          'period': {
            'start': dateRange.start.toIso8601String(),
            'end': dateRange.end.toIso8601String(),
          },
          'message': 'No data available for this period',
        };
      }

      // Get quality tests
      final qualityTests = await _getQualityTestsForReceptions(
          filteredReceptions.map((r) => r.id).toList());

      // Build comprehensive report
      final report = {
        'supplierId': supplierId,
        'supplierName': filteredReceptions.first.supplierName,
        'period': {
          'start': dateRange.start.toIso8601String(),
          'end': dateRange.end.toIso8601String(),
        },
        'totalDeliveries': filteredReceptions.length,
        'totalVolume': filteredReceptions.fold(
            0.0, (sum, reception) => sum + reception.quantityLiters),
        'acceptanceRate': _calculateAcceptanceRate(filteredReceptions),
        'qualityDistribution': _calculateQualityDistribution(qualityTests),
        'volumeTrend': _calculateVolumeTrend(filteredReceptions, dateRange),
        'qualityTrend': _calculateQualityTrend(qualityTests, dateRange),
        'topIssues': _identifyTopIssues(filteredReceptions, qualityTests),
      };

      return report;
    } catch (e) {
      throw ReportGenerationException(
          'Failed to generate supplier performance report: $e');
    }
  }

  /// Generate a report on quality deviations
  Future<Map<String, dynamic>> generateQualityDeviationReport(
      DateRange dateRange) async {
    try {
      // Get all receptions for the date range
      final receptions = await _receptionRepository.getReceptionsByDateRange(
        dateRange.start,
        dateRange.end,
        limit: 500,
      );

      if (receptions.isEmpty) {
        return {
          'period': {
            'start': dateRange.start.toIso8601String(),
            'end': dateRange.end.toIso8601String(),
          },
          'message': 'No data available for this period',
        };
      }

      // Get quality tests
      final qualityTests = await _getQualityTestsForReceptions(
          receptions.map((r) => r.id).toList());

      // Calculate deviations
      final deviations = _calculateQualityDeviations(qualityTests);

      return {
        'period': {
          'start': dateRange.start.toIso8601String(),
          'end': dateRange.end.toIso8601String(),
        },
        'totalReceptions': receptions.length,
        'totalQualityTests': qualityTests.length,
        'deviations': deviations,
      };
    } catch (e) {
      throw ReportGenerationException(
          'Failed to generate quality deviation report: $e');
    }
  }

  /// Generate a daily reception summary
  Future<Map<String, dynamic>> generateDailyReceptionSummary(
      DateTime date) async {
    try {
      // Define the date range for the entire day
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Get receptions for this day
      final receptions = await _receptionRepository.getReceptionsByDateRange(
        startOfDay,
        endOfDay,
        limit: 100,
      );

      if (receptions.isEmpty) {
        return {
          'date': date.toIso8601String().substring(0, 10),
          'message': 'No receptions recorded for this day',
        };
      }

      // Calculate summary statistics
      final summary = {
        'date': date.toIso8601String().substring(0, 10),
        'totalReceptions': receptions.length,
        'totalVolume': receptions.fold(
            0.0, (sum, reception) => sum + reception.quantityLiters),
        'acceptedVolume': receptions
            .where((r) => r.receptionStatus == ReceptionStatus.accepted)
            .fold(0.0, (sum, reception) => sum + reception.quantityLiters),
        'rejectedVolume': receptions
            .where((r) => r.receptionStatus == ReceptionStatus.rejected)
            .fold(0.0, (sum, reception) => sum + reception.quantityLiters),
        'supplierCount': receptions.map((r) => r.supplierId).toSet().length,
        'milkTypes': _summarizeMilkTypes(receptions),
        'hourlyDistribution': _calculateHourlyDistribution(receptions),
        'qualitySummary': await _getDailyQualitySummary(receptions),
      };

      return summary;
    } catch (e) {
      throw ReportGenerationException(
          'Failed to generate daily reception summary: $e');
    }
  }

  /// Generate a monthly volume report
  Future<Map<String, dynamic>> generateMonthlyVolumeReport(
      int month, int year) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = month < 12
          ? DateTime(year, month + 1, 1).subtract(const Duration(days: 1))
          : DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));

      // Get receptions for the month
      final receptions = await _receptionRepository.getReceptionsByDateRange(
        startDate,
        endDate.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
        limit: 1000,
      );

      if (receptions.isEmpty) {
        return {
          'month': month,
          'year': year,
          'message': 'No receptions recorded for this month',
        };
      }

      // Group by day
      final dailyVolumes =
          _calculateDailyVolumes(receptions, startDate, endDate);

      // Group by milk type
      final milkTypeVolumes = _summarizeMilkTypes(receptions);

      // Group by supplier (top 10)
      final supplierVolumes = _calculateSupplierVolumes(receptions);

      return {
        'month': month,
        'year': year,
        'totalVolume': receptions.fold(
            0.0, (sum, reception) => sum + reception.quantityLiters),
        'receptionCount': receptions.length,
        'acceptanceRate': _calculateAcceptanceRate(receptions),
        'dailyVolumes': dailyVolumes,
        'milkTypeDistribution': milkTypeVolumes,
        'topSuppliers': supplierVolumes.take(10).toList(),
      };
    } catch (e) {
      throw ReportGenerationException(
          'Failed to generate monthly volume report: $e');
    }
  }

  // Helper methods below

  Future<List<MilkQualityTestModel>> _getQualityTestsForReceptions(
      List<String> receptionIds) async {
    try {
      if (receptionIds.isEmpty) return [];

      // Firestore has limits on 'in' queries, so batch if needed
      const batchSize = 10;
      final resultTests = <MilkQualityTestModel>[];

      for (var i = 0; i < receptionIds.length; i += batchSize) {
        final endIdx = (i + batchSize < receptionIds.length)
            ? i + batchSize
            : receptionIds.length;
        final batchIds = receptionIds.sublist(i, endIdx);

        final querySnapshot = await _firestore
            .collection('milk_quality_tests')
            .where('receptionId', whereIn: batchIds)
            .get();

        final batchTests = querySnapshot.docs
            .map((doc) => MilkQualityTestModel.fromJson(
                doc.data()))
            .toList();

        resultTests.addAll(batchTests);
      }

      return resultTests;
    } catch (e) {
      throw DatabaseException('Failed to fetch quality tests: $e');
    }
  }

  Map<String, dynamic> _organizeDataByTimePeriods(
      List<MilkReceptionModel> receptions, DateTime start, DateTime end) {
    // Implementation depends on how you want to organize time periods
    // This is a placeholder for the data structure
    return {
      'timePeriods': [],
      // Additional fields would be populated based on requirements
    };
  }

  Future<Map<String, dynamic>> _calculateQualityTrends(
      List<MilkReceptionModel> receptions,
      List<MilkQualityTestModel> qualityTests,
      Map<String, dynamic> periodData) async {
    // This would implement the actual trend calculation logic
    return {
      'fatContent': {'trend': 'stable', 'data': []},
      'proteinContent': {'trend': 'increasing', 'data': []},
      'somaticCellCount': {'trend': 'decreasing', 'data': []},
      // Other parameters
    };
  }

  Map<String, dynamic> _groupVolumeData(
      List<MilkReceptionModel> receptions, GroupBy groupBy) {
    // Implementation depends on the grouping strategy
    return {};
  }

  Map<String, dynamic> _calculateVolumeStatistics(
      List<MilkReceptionModel> receptions) {
    // Calculate mean, median, min, max, etc.
    return {};
  }

  Map<String, dynamic> _analyzeRejectionReasons(
      List<MilkReceptionModel> rejectedReceptions) {
    // Group and count rejection reasons
    return {};
  }

  Map<String, dynamic> _analyzeRejectionsBySupplier(
      List<MilkReceptionModel> rejectedReceptions,
      List<MilkReceptionModel> allReceptions) {
    // Calculate rejection rate by supplier
    return {};
  }

  Future<Map<String, dynamic>> _analyzeParameterTrends(
      List<MilkQualityTestModel> qualityTests,
      List<String> parameters,
      DateRange dateRange) async {
    // Analyze trends for each requested parameter
    return {};
  }

  Map<String, dynamic> _generateForecast(
      List<MilkReceptionModel> historicalData,
      DateTime forecastStart,
      DateTime forecastEnd) {
    // Implement forecasting algorithm
    return {};
  }

  double _calculateAcceptanceRate(List<MilkReceptionModel> receptions) {
    final acceptedCount = receptions
        .where((r) => r.receptionStatus == ReceptionStatus.accepted)
        .length;
    return (acceptedCount / receptions.length) * 100;
  }

  Map<String, dynamic> _calculateQualityDistribution(
      List<MilkQualityTestModel> qualityTests) {
    // Calculate distribution of quality grades
    return {};
  }

  Map<String, dynamic> _calculateVolumeTrend(
      List<MilkReceptionModel> receptions, DateRange dateRange) {
    // Calculate volume trends over time
    return {};
  }

  Map<String, dynamic> _calculateQualityTrend(
      List<MilkQualityTestModel> qualityTests, DateRange dateRange) {
    // Calculate quality parameter trends
    return {};
  }

  List<Map<String, dynamic>> _identifyTopIssues(
      List<MilkReceptionModel> receptions,
      List<MilkQualityTestModel> qualityTests) {
    // Identify and rank top quality issues
    return [];
  }

  Map<String, dynamic> _calculateQualityDeviations(
      List<MilkQualityTestModel> qualityTests) {
    // Calculate deviations from quality standards
    return {};
  }

  Map<String, dynamic> _summarizeMilkTypes(
      List<MilkReceptionModel> receptions) {
    // Group and sum volumes by milk type
    return {};
  }

  Map<String, dynamic> _calculateHourlyDistribution(
      List<MilkReceptionModel> receptions) {
    // Distribution of receptions by hour of day
    return {};
  }

  Future<Map<String, dynamic>> _getDailyQualitySummary(
      List<MilkReceptionModel> receptions) async {
    // Summary of quality metrics for the day
    return {};
  }

  Map<String, dynamic> _calculateDailyVolumes(
      List<MilkReceptionModel> receptions,
      DateTime startDate,
      DateTime endDate) {
    // Calculate volumes by day of month
    return {};
  }

  List<Map<String, dynamic>> _calculateSupplierVolumes(
      List<MilkReceptionModel> receptions) {
    // Calculate volumes by supplier
    return [];
  }
}

/// Enum for grouping data in analytics
enum GroupBy {
  day,
  week,
  month,
  supplier,
  milkType,
  quality,
}

/// Class for representing a date range
class DateRange {

  const DateRange({required this.start, required this.end});

  /// Create a date range for today
  factory DateRange.today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end =
        start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return DateRange(start: start, end: end);
  }

  /// Create a date range for this week
  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final end =
        start.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
    return DateRange(start: start, end: end);
  }

  /// Create a date range for this month
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = (now.month < 12)
        ? DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1))
        : DateTime(now.year + 1, 1, 1).subtract(const Duration(seconds: 1));
    return DateRange(start: start, end: end);
  }

  /// Create a date range for the last N days
  factory DateRange.lastDays(int days) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = end.subtract(Duration(days: days));
    return DateRange(start: start, end: end);
  }
  final DateTime start;
  final DateTime end;
}

/// Custom exception for analytics operations
class AnalyticsException implements Exception {
  AnalyticsException(this.message);
  final String message;
  @override
  String toString() => 'AnalyticsException: $message';
}

/// Custom exception for report generation
class ReportGenerationException implements Exception {
  ReportGenerationException(this.message);
  final String message;
  @override
  String toString() => 'ReportGenerationException: $message';
}
