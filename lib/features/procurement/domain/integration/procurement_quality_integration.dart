import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/providers/quality_parameters_provider.dart';
import '../../../inventory/data/models/dairy_quality_parameters_model.dart';
import '../../data/models/supplier_quality_log_model.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/models/purchase_order_item_model.dart';
import '../providers/supplier_quality_provider.dart';

/// Integration service to connect procurement with quality control
class ProcurementQualityIntegration {
  ProcurementQualityIntegration(this._ref);
  final Ref _ref;

  /// Connects supplier quality logs with internal quality checks
  Future<Map<String, dynamic>> connectQualityLogs(String supplierId,
      {DateTime? startDate, DateTime? endDate}) async {
    final supplierQualityState = _ref.read(supplierQualityProvider.notifier);
    final qualityParametersState =
        _ref.read(qualityParametersProvider.notifier);

    // Set default date range if not provided
    startDate ??= DateTime.now().subtract(const Duration(days: 90));
    endDate ??= DateTime.now();

    // Get supplier quality logs
    final supplierLogs = await supplierQualityState.getSupplierQualityLogs(
      supplierId: supplierId,
      startDate: startDate,
      endDate: endDate,
    );

    // Get internal quality parameters for items from this supplier
    final internalChecks =
        await qualityParametersState.getQualityChecksBySupplier(
      supplierId: supplierId,
      startDate: startDate,
      endDate: endDate,
    );

    // Analyze correlation between supplier and internal quality
    final correlation = _analyzeQualityCorrelation(
      supplierLogs: supplierLogs,
      internalChecks: internalChecks,
    );

    return {
      'supplierId': supplierId,
      'supplierName':
          supplierLogs.isNotEmpty ? supplierLogs.first.supplierName : 'Unknown',
      'period': {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
      'supplierLogCount': supplierLogs.length,
      'internalCheckCount': internalChecks.length,
      'correlation': correlation,
      'qualitySummary': {
        'supplierPassRate': _calculatePassRate(supplierLogs),
        'internalPassRate': _calculateInternalPassRate(internalChecks),
        'fatContentDeviation': _calculateAverageDeviation(
          supplierLogs
              .map((log) => log.fatContent)
              .whereType<double>()
              .toList(),
          internalChecks
              .map((check) => check.fatContent)
              .whereType<double>()
              .toList(),
        ),
        'proteinContentDeviation': _calculateAverageDeviation(
          supplierLogs
              .map((log) => log.proteinContent)
              .whereType<double>()
              .toList(),
          internalChecks
              .map((check) => check.proteinContent)
              .whereType<double>()
              .toList(),
        ),
      },
    };
  }

  /// Calculates the pass rate for supplier quality logs
  double _calculatePassRate(List<SupplierQualityLog> logs) {
    if (logs.isEmpty) return 0.0;

    final passCount = logs
        .where((log) => log.inspectionResult == InspectionResult.pass)
        .length;

    return passCount / logs.length;
  }

  /// Calculates the pass rate for internal quality checks
  double _calculateInternalPassRate(List<DairyQualityParametersModel> checks) {
    if (checks.isEmpty) return 0.0;

    final passCount = checks
        .where((check) => check.status == 'pass' || check.status == 'accepted')
        .length;

    return passCount / checks.length;
  }

  /// Analyzes correlation between supplier and internal quality
  Map<String, dynamic> _analyzeQualityCorrelation({
    required List<SupplierQualityLog> supplierLogs,
    required List<DairyQualityParametersModel> internalChecks,
  }) {
    // This would be a more complex algorithm in a real implementation
    // Here we'll provide a simplified version

    // Match logs and checks by date/time proximity
    final matchedRecords = <Map<String, dynamic>>[];

    for (final log in supplierLogs) {
      // Find closest internal check by date
      final matchingChecks = internalChecks.where((check) {
        final difference =
            check.testDate!.difference(log.inspectionDate).inHours.abs();
        return difference <= 48; // Within 48 hours
      }).toList();

      if (matchingChecks.isNotEmpty) {
        matchingChecks.sort((a, b) => a.testDate!
            .difference(log.inspectionDate)
            .inHours
            .abs()
            .compareTo(
                b.testDate!.difference(log.inspectionDate).inHours.abs()));

        matchedRecords.add({
          'supplierLog': log,
          'internalCheck': matchingChecks.first,
          'timeDifference': matchingChecks.first.testDate!
              .difference(log.inspectionDate)
              .inHours,
        });
      }
    }

    // Calculate consistency score based on matched records
    final consistencyScore = matchedRecords.isNotEmpty
        ? matchedRecords
                .where((record) =>
                    (record['supplierLog'] as SupplierQualityLog)
                            .inspectionResult ==
                        InspectionResult.pass &&
                    (record['internalCheck'] as DairyQualityParametersModel)
                            .status ==
                        'pass')
                .length /
            matchedRecords.length
        : 0.0;

    return {
      'matchedRecordsCount': matchedRecords.length,
      'consistencyScore': consistencyScore,
      'averageTimeDifference': matchedRecords.isNotEmpty
          ? matchedRecords
                  .map((r) => (r['timeDifference'] as int).abs())
                  .reduce((a, b) => a + b) /
              matchedRecords.length
          : 0,
    };
  }

  /// Calculates the average deviation between two sets of measurements
  double _calculateAverageDeviation(
      List<double> supplierValues, List<double> internalValues) {
    if (supplierValues.isEmpty || internalValues.isEmpty) return 0.0;

    // This is a simplified calculation - in reality you'd need to match pairs of values
    final supplierAvg =
        supplierValues.reduce((a, b) => a + b) / supplierValues.length;
    final internalAvg =
        internalValues.reduce((a, b) => a + b) / internalValues.length;

    return (supplierAvg - internalAvg).abs();
  }

  /// Verifies material acceptance criteria during goods receipt
  Future<Map<String, dynamic>> verifyMaterialAcceptanceCriteria(
      String purchaseOrderId, String itemId) async {
    final supplierQualityState = _ref.read(supplierQualityProvider.notifier);
    final qualityParametersState =
        _ref.read(qualityParametersProvider.notifier);

    // Get purchase order item quality requirements
    final itemQualityRequirements =
        await supplierQualityState.getMaterialQualityRequirements(itemId);

    // Get actual quality parameters for the received item
    final receivedQualityParameters =
        await qualityParametersState.getQualityParameters(itemId);

    // Check if the item meets quality criteria
    final criteriaResults = <String, dynamic>{};
    var allCriteriaMet = true;

    for (final requirement in itemQualityRequirements.entries) {
      final parameterName = requirement.key;
      final acceptableRange = requirement.value;

      if (receivedQualityParameters.containsKey(parameterName)) {
        final actualValue = receivedQualityParameters[parameterName];
        final isWithinRange = _isValueWithinRange(actualValue, acceptableRange);

        criteriaResults[parameterName] = {
          'required': acceptableRange,
          'actual': actualValue,
          'passed': isWithinRange,
        };

        if (!isWithinRange) {
          allCriteriaMet = false;
        }
      }
    }

    return {
      'purchaseOrderId': purchaseOrderId,
      'itemId': itemId,
      'passedAllCriteria': allCriteriaMet,
      'criteriaResults': criteriaResults,
      'recommendedAction': allCriteriaMet ? 'accept' : 'reject',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Checks if a value is within an acceptable range
  bool _isValueWithinRange(dynamic value, dynamic range) {
    if (value == null || range == null) return false;

    if (value is num && range is Map<String, dynamic>) {
      final min = range['min'] as num?;
      final max = range['max'] as num?;

      if (min != null && max != null) {
        return value >= min && value <= max;
      } else if (min != null) {
        return value >= min;
      } else if (max != null) {
        return value <= max;
      }
    }

    return false;
  }

  /// Propagates quality alerts to relevant stakeholders
  Future<String> propagateQualityAlert({
    required String materialId,
    required String issueDescription,
    required String severity,
    String? purchaseOrderId,
    String? lotNumber,
  }) async {
    // In a real implementation, this would connect to a notification service
    // Here we just create the alert data structure

    final alertData = {
      'alertId': 'QA-${DateTime.now().millisecondsSinceEpoch}',
      'materialId': materialId,
      'issueDescription': issueDescription,
      'severity': severity,
      'purchaseOrderId': purchaseOrderId,
      'lotNumber': lotNumber,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'new',
      'affectedDepartments':
          _determineAffectedDepartments(severity, materialId),
    };

    // Return the alert ID (in a real implementation, this would also send the alert)
    return alertData['alertId'] as String;
  }

  /// Determines which departments should be notified based on severity and material
  List<String> _determineAffectedDepartments(
      String severity, String materialId) {
    final departments = <String>['quality'];

    if (severity == 'high' || severity == 'critical') {
      departments.addAll(['production', 'management']);
    }

    departments.add('procurement');

    return departments;
  }

  /// Generates sampling requirements for quality inspection
  Future<Map<String, dynamic>> generateSamplingRequirements(
      String purchaseOrderId) async {
    final supplierQualityState = _ref.read(supplierQualityProvider.notifier);

    // Get purchase order items
    final poItems =
        await supplierQualityState.getPurchaseOrderItems(purchaseOrderId);

    // Generate sampling plan for each item
    final samplingPlans = <Map<String, dynamic>>[];

    for (final item in poItems) {
      final samplingPlan = await _createSamplingPlan(
        materialId: item.materialId,
        quantity: item.quantity,
        uom: item.unit,
      );

      samplingPlans.add({
        'materialId': item.materialId,
        'materialName': item.materialName,
        'samplingPlan': samplingPlan,
      });
    }

    return {
      'purchaseOrderId': purchaseOrderId,
      'generatedAt': DateTime.now().toIso8601String(),
      'samplingPlans': samplingPlans,
    };
  }

  /// Creates a sampling plan based on material and quantity
  Future<Map<String, dynamic>> _createSamplingPlan({
    required String materialId,
    required double quantity,
    required String uom,
  }) async {
    // In a real implementation, this would use statistical methods to determine
    // appropriate sample sizes. Here we use simplified logic.

    // Calculate sample size based on quantity (simplified)
    final sampleSize = _calculateSampleSize(quantity);

    // Determine sampling method based on material type
    final samplingMethod = await _determineSamplingMethod(materialId);

    return {
      'sampleSize': sampleSize,
      'sampleUnit': uom,
      'samplingMethod': samplingMethod,
      'requiredTests': await _getRequiredTestsForMaterial(materialId),
      'handlingInstructions':
          'Store samples at appropriate temperature and deliver to lab within 4 hours',
    };
  }

  /// Calculates appropriate sample size based on quantity
  double _calculateSampleSize(double quantity) {
    // Simplified sample size calculation
    if (quantity <= 100) {
      return quantity * 0.1; // 10% for small quantities
    } else if (quantity <= 1000) {
      return 10 +
          (quantity - 100) * 0.05; // 10 + 5% of remainder for medium quantities
    } else {
      return 55 +
          (quantity - 1000) * 0.02; // 55 + 2% of remainder for large quantities
    }
  }

  /// Determines the appropriate sampling method for a material
  Future<String> _determineSamplingMethod(String materialId) async {
    // In a real implementation, this would look up the material characteristics
    // For now, we'll return a simple result
    return 'systematic';
  }

  /// Gets the required tests for a specific material
  Future<List<String>> _getRequiredTestsForMaterial(String materialId) async {
    // In a real implementation, this would look up required tests from a database
    // For now, we'll return a simple list
    return ['visual_inspection', 'composition_analysis', 'contamination_check'];
  }
}

/// Provider for procurement-quality integration
final procurementQualityIntegrationProvider =
    Provider<ProcurementQualityIntegration>((ref) {
  return ProcurementQualityIntegration(ref);
});
