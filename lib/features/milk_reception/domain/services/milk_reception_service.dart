import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/reception_inventory_service.dart';
import '../../../../services/reception_notification_service.dart';
import '../../../../utils/service_locator.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../quality/data/models/quality_test_result_model.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../models/milk_reception_model.dart';
import '../repositories/milk_reception_repository.dart';

/// Custom exception for business logic errors
class BusinessLogicException implements Exception {

  BusinessLogicException(this.message);
  final String message;

  @override
  String toString() => 'BusinessLogicException: $message';
}

/// Milk reception quality grade categories
enum MilkQualityGrade {
  /// Premium quality with bonus payment
  premium,

  /// Standard acceptable quality
  standard,

  /// Below standard quality with price deduction
  substandard,

  /// Unacceptable quality that should be rejected
  rejected
}

/// Service for handling milk reception business logic
class MilkReceptionService {
  MilkReceptionService({
    required MilkReceptionRepository receptionRepository,
    required InventoryRepository inventoryRepository,
    required SupplierRepository supplierRepository,
    required ReceptionNotificationService notificationService,
  })  : _receptionRepository = receptionRepository,
        _inventoryRepository = inventoryRepository,
        _supplierRepository = supplierRepository,
        _notificationService = notificationService;

  final MilkReceptionRepository _receptionRepository;
  final InventoryRepository _inventoryRepository;
  final SupplierRepository _supplierRepository;
  final ReceptionNotificationService _notificationService;

  /// Initiates a new milk reception from supplier
  ///
  /// Creates a new reception record in pending status
  /// Returns the ID of the created reception
  Future<String> initiateReception({
    required String supplierId,
    required String supplierName,
    required String vehiclePlate,
    required String driverName,
    required double quantityLiters,
    required MilkType milkType,
    required ContainerType containerType,
    required int containerCount,
    required String initialObservations,
    required String receivingEmployeeId,
    required double temperatureAtArrival,
    double? phValue,
    required String smell,
    required String appearance,
    required bool hasVisibleContamination,
    String? contaminationDescription,
    String? notes,
    List<String>? photoUrls,
    GeoPoint? geoLocation,
  }) async {
    try {
      // Create initial reception model
      final reception = MilkReceptionModel(
        id: '',
        timestamp: DateTime.now(),
        supplierId: supplierId,
        supplierName: supplierName,
        vehiclePlate: vehiclePlate,
        driverName: driverName,
        quantityLiters: quantityLiters,
        milkType: milkType,
        containerType: containerType,
        containerCount: containerCount,
        initialObservations: initialObservations,
        receptionStatus: ReceptionStatus.pendingTesting,
        receivingEmployeeId: receivingEmployeeId,
        temperatureAtArrival: temperatureAtArrival,
        phValue: phValue,
        smell: smell,
        appearance: appearance,
        hasVisibleContamination: hasVisibleContamination,
        contaminationDescription: contaminationDescription,
        notes: notes,
        photoUrls: photoUrls ?? [],
        geoLocation: geoLocation,
      );

      // Validate initial measurements
      final validationResult = validateInitialMeasurements(reception);
      if (!validationResult.isValid) {
        // If validation fails, create reception with rejected status
        final rejectedReception = reception.copyWith(
          receptionStatus: ReceptionStatus.rejected,
          notes:
              '${reception.notes ?? ''}\nAutomatically rejected: ${validationResult.rejectionReason}',
        );

        final receptionId =
            await _receptionRepository.addReception(rejectedReception);

        // Track supplier quality issue
        await _trackSupplierQualityIssue(
          supplierId: supplierId,
          issue:
              validationResult.rejectionReason ?? 'Failed initial validation',
          severity: 'High',
        );

        return receptionId;
      }

      // Add reception to database
      return await _receptionRepository.addReception(reception);
    } catch (e) {
      throw BusinessLogicException('Failed to initiate milk reception: $e');
    }
  }

  /// Validates initial measurements to determine if milk passes basic inspection
  ValidationResult validateInitialMeasurements(MilkReceptionModel reception) {
    // Initial rejection criteria

    // Temperature check (raw milk should be below 10°C)
    if (reception.milkType.toString().contains('raw') &&
        reception.temperatureAtArrival > 10.0) {
      // Send notification for temperature issue
      _notificationService.createQualityAlert(
        receptionId: reception.id,
        supplierId: reception.supplierId,
        supplierName: reception.supplierName,
        parameterName: 'Temperature',
        parameterValue: reception.temperatureAtArrival,
        thresholdValue: 10.0,
        exceedsThreshold: true,
        recommendedAction: 'Reject delivery due to high temperature',
        targetRoleId: 'factory',
      );

      return ValidationResult(
        isValid: false,
        rejectionReason:
            'Temperature too high: ${reception.temperatureAtArrival}°C (max 10°C)',
      );
    }

    // Visual inspection check
    if (reception.hasVisibleContamination) {
      // Send notification for contamination
      _notificationService.createQualityAlert(
        receptionId: reception.id,
        supplierId: reception.supplierId,
        supplierName: reception.supplierName,
        parameterName: 'Contamination',
        parameterValue: 1.0, // Binary flag
        thresholdValue: 0.0,
        exceedsThreshold: true,
        recommendedAction: 'Reject delivery due to visible contamination',
        targetRoleId: 'factory',
      );

      return ValidationResult(
        isValid: false,
        rejectionReason:
            'Visible contamination detected: ${reception.contaminationDescription}',
      );
    }

    // Smell check
    if (reception.smell.toLowerCase().contains('sour') ||
        reception.smell.toLowerCase().contains('off') ||
        reception.smell.toLowerCase().contains('bad')) {
      return ValidationResult(
        isValid: false,
        rejectionReason: 'Abnormal smell detected: ${reception.smell}',
      );
    }

    // Appearance check
    if (reception.appearance.toLowerCase().contains('abnormal') ||
        reception.appearance.toLowerCase().contains('contaminated') ||
        reception.appearance.toLowerCase().contains('discolored')) {
      return ValidationResult(
        isValid: false,
        rejectionReason: 'Abnormal appearance: ${reception.appearance}',
      );
    }

    // If pH value is provided, check if it's within acceptable range (6.6-6.8)
    if (reception.phValue != null &&
        (reception.phValue! < 6.6 || reception.phValue! > 6.8)) {
      // Send notification for pH issue
      _notificationService.createQualityAlert(
        receptionId: reception.id,
        supplierId: reception.supplierId,
        supplierName: reception.supplierName,
        parameterName: 'pH Level',
        parameterValue: reception.phValue!,
        thresholdValue: reception.phValue! < 6.6 ? 6.6 : 6.8,
        exceedsThreshold: reception.phValue! > 6.8,
        recommendedAction: 'Reject delivery due to pH outside acceptable range',
        targetRoleId: 'factory',
      );

      return ValidationResult(
        isValid: false,
        rejectionReason:
            'pH outside acceptable range: ${reception.phValue} (range: 6.6-6.8)',
      );
    }

    // All checks passed
    return ValidationResult(isValid: true);
  }

  /// Submits a reception for lab testing
  ///
  /// Updates the status and prepares for lab tests
  Future<void> submitForLabTesting(String receptionId) async {
    try {
      // Get current reception
      final reception =
          await _receptionRepository.getReceptionById(receptionId);

      // Validate current state
      if (reception.receptionStatus != ReceptionStatus.pendingTesting) {
        throw BusinessLogicException(
          'Cannot submit for lab testing: Reception is not in pending status',
        );
      }

      // Create test request or update status
      final updatedReception = reception.copyWith(
        notes:
            '${reception.notes ?? ''}\nSubmitted for lab testing on ${DateTime.now()}',
      );

      await _receptionRepository.updateReception(updatedReception);

      // Create pending test notification
      await _notificationService.createPendingTestNotification(
        receptionId: receptionId,
        supplierId: reception.supplierId,
        supplierName: reception.supplierName,
        sampleCode: 'RC-${reception.id.substring(0, 6)}',
        receptionTimestamp: reception.timestamp,
        testsRequired: [
          'Fat Content',
          'Protein Content',
          'Bacteria Count',
          'Antibiotics Test'
        ],
        dueBy: DateTime.now().add(const Duration(hours: 8)),
        targetRoleId: 'factory',
      );
    } catch (e) {
      if (e is BusinessLogicException) rethrow;
      throw BusinessLogicException('Failed to submit for lab testing: $e');
    }
  }

  /// Records quality test results for a reception
  ///
  /// Saves test results and links them to the reception
  Future<void> recordQualityResults(
      String receptionId, Map<String, dynamic> testResults) async {
    try {
      // Convert test results to parameters
      final parameters = _convertToTestParameters(testResults);

      // Create quality test record
      final testRecord = {
        'receptionId': receptionId,
        'testDate': Timestamp.now(),
        'testType': TestType.composition.toString(),
        'parameters': parameters.map((p) => p.toJson()).toList(),
        'testResultStatus': _determineOverallTestStatus(parameters).toString(),
      };

      // Get the milk reception
      final reception =
          await _receptionRepository.getReceptionById(receptionId);

      // Calculate quality grade
      final qualityGrade = calculateQualityGrade(parameters);

      // Update reception with test results and grade
      final updatedReception = reception.copyWith(
        notes: '''${reception.notes ?? ''}
Lab test results recorded on ${DateTime.now()}
Quality Grade: ${qualityGrade.name}''',
      );

      // Update reception
      await _receptionRepository.updateReception(updatedReception);

      // Send notifications based on test results
      _sendQualityResultNotifications(reception, parameters, qualityGrade);

      // Create a link between reception and quality test
      // This would depend on how your quality test repository is implemented
      // For now, we'll assume the quality test module will handle linking
    } catch (e) {
      throw BusinessLogicException('Failed to record quality results: $e');
    }
  }

  /// Send appropriate notifications based on quality test results
  Future<void> _sendQualityResultNotifications(MilkReceptionModel reception,
      List<TestParameter> parameters, MilkQualityGrade qualityGrade) async {
    // Check for issues in test parameters and send alerts
    for (final param in parameters) {
      if (param.status == TestResultStatus.fail) {
        await _notificationService.createQualityAlert(
          receptionId: reception.id,
          supplierId: reception.supplierId,
          supplierName: reception.supplierName,
          parameterName: param.parameterName,
          parameterValue: param.numericValue ?? 0.0,
          thresholdValue: param.maxThreshold ?? param.minThreshold ?? 0.0,
          exceedsThreshold: param.status == TestResultStatus.fail,
          recommendedAction: param.comments ?? 'Review test results',
          targetRoleId: 'factory',
        );
      }
    }

    // If quality is low or rejected, send additional notification
    if (qualityGrade == MilkQualityGrade.substandard ||
        qualityGrade == MilkQualityGrade.rejected) {
      final Map<String, dynamic> testResultsMap = {};
      for (final param in parameters) {
        testResultsMap[param.parameterName] = param.numericValue;
      }

      if (qualityGrade == MilkQualityGrade.rejected) {
        await _notificationService.createRejectionNotification(
          receptionId: reception.id,
          supplierId: reception.supplierId,
          supplierName: reception.supplierName,
          rejectionReason: 'Failed quality tests',
          quantityRejected: reception.quantityLiters,
          recommendedAction: 'Contact supplier about quality issues',
          targetRoleId: 'factory',
        );
      } else {
        // For substandard, just send a supplier performance alert
        await _notificationService.createSupplierPerformanceAlert(
          supplierId: reception.supplierId,
          supplierName: reception.supplierName,
          performanceData: testResultsMap,
          trendType: 'quality parameters',
          percentageChange: -15.0, // Estimate
          recommendedAction: 'Review supplier quality history',
          targetRoleId: 'factory',
        );
      }
    }
  }

  /// Determines milk quality grade based on test results
  MilkQualityGrade calculateQualityGrade(List<TestParameter> testResults) {
    // Extract key parameters
    double? fatContent;
    double? proteinContent;
    double? totalSolids;
    double? somaticCellCount;
    bool antibioticsPresent = false;

    for (final param in testResults) {
      switch (param.parameterName.toLowerCase()) {
        case 'fat':
        case 'fat content':
        case 'butterfat':
          fatContent = param.numericValue;
          break;
        case 'protein':
        case 'protein content':
          proteinContent = param.numericValue;
          break;
        case 'total solids':
        case 'solids':
          totalSolids = param.numericValue;
          break;
        case 'somatic cell count':
        case 'scc':
          somaticCellCount = param.numericValue;
          break;
        case 'antibiotics':
        case 'antibiotic residue':
          antibioticsPresent = param.status == TestResultStatus.fail;
          break;
      }
    }

    // Automatic rejection for antibiotic presence
    if (antibioticsPresent) {
      return MilkQualityGrade.rejected;
    }

    // Determine grade based on key parameters
    // Premium grade criteria
    if (fatContent != null &&
        fatContent >= 3.8 &&
        proteinContent != null &&
        proteinContent >= 3.2 &&
        totalSolids != null &&
        totalSolids >= 12.5 &&
        somaticCellCount != null &&
        somaticCellCount < 200000) {
      return MilkQualityGrade.premium;
    }

    // Standard grade criteria
    if (fatContent != null &&
        fatContent >= 3.5 &&
        proteinContent != null &&
        proteinContent >= 3.0 &&
        somaticCellCount != null &&
        somaticCellCount < 400000) {
      return MilkQualityGrade.standard;
    }

    // Substandard criteria
    if (fatContent != null &&
        fatContent >= 3.0 &&
        somaticCellCount != null &&
        somaticCellCount < 750000) {
      return MilkQualityGrade.substandard;
    }

    // Default to rejected if doesn't meet minimum criteria
    return MilkQualityGrade.rejected;
  }

  /// Finalizes the reception process
  ///
  /// Completes the process with final decision
  Future<void> finalizeReception({
    required String receptionId,
    required bool accepted,
    String? notes,
  }) async {
    try {
      // Get current reception
      final reception =
          await _receptionRepository.getReceptionById(receptionId);

      // Validate that reception is not already finalized
      if (reception.receptionStatus == ReceptionStatus.accepted ||
          reception.receptionStatus == ReceptionStatus.rejected) {
        throw BusinessLogicException('Reception has already been finalized');
      }

      final newStatus =
          accepted ? ReceptionStatus.accepted : ReceptionStatus.rejected;
      final updateNotes = '''${reception.notes ?? ''}
Reception ${accepted ? 'accepted' : 'rejected'} on ${DateTime.now()}
${notes ?? ''}''';

      // Update reception with final status
      final updatedReception = reception.copyWith(
        receptionStatus: newStatus,
        notes: updateNotes,
      );

      await _receptionRepository.updateReception(updatedReception);

      // If accepted, add to inventory
      if (accepted) {
        await _addToInventory(reception);

        // Send completion notification
        await _notificationService.createCompletionNotification(
          receptionId: receptionId,
          supplierId: reception.supplierId,
          supplierName: reception.supplierName,
          quantityAccepted: reception.quantityLiters,
          qualityGrade:
              'Standard', // This should come from quality test results
          targetRoleId: 'factory',
        );
      } else {
        // Send rejection notification
        await _notificationService.createRejectionNotification(
          receptionId: receptionId,
          supplierId: reception.supplierId,
          supplierName: reception.supplierName,
          rejectionReason: notes ?? 'Failed quality checks',
          quantityRejected: reception.quantityLiters,
          targetRoleId: 'factory',
        );
      }

      // Update supplier metrics
      await _updateSupplierMetrics(
        supplierId: reception.supplierId,
        accepted: accepted,
        qualityGrade: calculateQualityGrade(
            []), // This would need the actual test results
        quantityLiters: reception.quantityLiters,
      );
    } catch (e) {
      if (e is BusinessLogicException) rethrow;
      throw BusinessLogicException('Failed to finalize reception: $e');
    }
  }

  /// Calculates payment amount based on quantity and quality
  Future<double> calculatePayment(String receptionId) async {
    try {
      // Get the reception
      final reception =
          await _receptionRepository.getReceptionById(receptionId);

      // Verify reception is accepted
      if (reception.receptionStatus != ReceptionStatus.accepted) {
        throw BusinessLogicException(
            'Cannot calculate payment: Reception not accepted');
      }

      // Get current milk prices (in a real implementation, these would come from a price configuration)
      final pricePerLiter = _getMilkBasePrice(reception.milkType);

      // Get quality test results to determine quality grade
      // For this example, we'll assume a default grade
      final qualityGrade = MilkQualityGrade.standard;

      // Apply quality adjustments
      final adjustedPrice =
          _applyQualityAdjustment(pricePerLiter, qualityGrade);

      // Calculate total payment
      final totalPayment = reception.quantityLiters * adjustedPrice;

      return totalPayment;
    } catch (e) {
      if (e is BusinessLogicException) rethrow;
      throw BusinessLogicException('Failed to calculate payment: $e');
    }
  }

  // Helper methods

  /// Converts test result map to TestParameter objects
  List<TestParameter> _convertToTestParameters(
      Map<String, dynamic> testResults) {
    final parameters = <TestParameter>[];

    testResults.forEach((paramName, value) {
      // Skip non-test parameters
      if (paramName == 'testDate' || paramName == 'testType') return;

      if (value is Map<String, dynamic>) {
        // Handle complex parameter structure
        final numValue =
            value['value'] is num ? (value['value'] as num).toDouble() : null;
        final strValue =
            value['value'] is String ? value['value'] as String : null;
        final unit = value['unit'] as String? ?? '';
        final min =
            value['min'] is num ? (value['min'] as num).toDouble() : null;
        final max =
            value['max'] is num ? (value['max'] as num).toDouble() : null;
        final target =
            value['target'] is num ? (value['target'] as num).toDouble() : null;

        // Determine status
        TestResultStatus status = TestResultStatus.pending;
        if (numValue != null && min != null && max != null) {
          if (numValue < min || numValue > max) {
            status = TestResultStatus.fail;
          } else {
            status = TestResultStatus.pass;
          }
        } else if (value['status'] != null) {
          // Try to parse status from the input
          status = TestResultStatus.values.firstWhere(
            (s) => s
                .toString()
                .toLowerCase()
                .contains(value['status'].toString().toLowerCase()),
            orElse: () => TestResultStatus.pending,
          );
        }

        parameters.add(TestParameter(
          parameterName: paramName,
          numericValue: numValue,
          stringValue: strValue,
          unit: unit,
          minThreshold: min,
          maxThreshold: max,
          targetValue: target,
          status: status,
          comments: value['comments'] as String?,
        ));
      } else if (value is num) {
        // Handle simple numeric values
        parameters.add(TestParameter(
          parameterName: paramName,
          numericValue: value.toDouble(),
          unit: '', // Default unit
          status: TestResultStatus.pending, // Default status
        ));
      } else if (value is String) {
        // Handle simple string values
        parameters.add(TestParameter(
          parameterName: paramName,
          stringValue: value,
          unit: '', // Default unit
          status: TestResultStatus.pending, // Default status
        ));
      }
    });

    return parameters;
  }

  /// Determines overall test status based on individual parameters
  TestResultStatus _determineOverallTestStatus(List<TestParameter> parameters) {
    // If any critical parameter fails, the entire test fails
    for (final param in parameters) {
      // Consider certain parameters as critical
      final isCriticalParameter = [
        'antibiotics',
        'somatic cell count',
        'bacteria',
        'inhibitors',
      ].any((term) => param.parameterName.toLowerCase().contains(term));

      if (isCriticalParameter && param.status == TestResultStatus.fail) {
        return TestResultStatus.fail;
      }
    }

    // Count failures and warnings
    int failures = 0;
    int warnings = 0;

    for (final param in parameters) {
      if (param.status == TestResultStatus.fail) {
        failures++;
      } else if (param.status == TestResultStatus.warning) {
        warnings++;
      }
    }

    // Define thresholds for overall status
    if (failures > 0) {
      return TestResultStatus.fail;
    } else if (warnings > 2) {
      // More than 2 warnings is a failure
      return TestResultStatus.fail;
    } else if (warnings > 0) {
      // Any warnings result in warning status
      return TestResultStatus.warning;
    }

    return TestResultStatus.pass;
  }

  /// Adds accepted milk to inventory
  Future<void> _addToInventory(MilkReceptionModel reception) async {
    try {
      // Try to use the reception inventory service if available
      try {
        final receptionInventoryService =
            ServiceLocator.instance.get<ReceptionInventoryService>();

        // Create inventory entry
        await receptionInventoryService
            .createInventoryFromReception(reception.id);
        return;
      } catch (e) {
        // If service locator fails, continue with basic implementation
        print(
            'ReceptionInventoryService not available, using basic implementation: $e');
      }

      // Basic implementation - store simple data in inventory collection
      final inventoryData = {
        'name': _getMilkTypeName(reception.milkType),
        'description':
            'Received from ${reception.supplierName} on ${reception.timestamp}',
        'category': 'Raw Materials',
        'quantity': reception.quantityLiters,
        'unit': 'liters',
        'location': 'Raw Milk Storage',
        'supplier': reception.supplierId,
        'batch': 'MR-${reception.id}',
        'receptionId': reception.id,
        'expiryDate': DateTime.now().add(Duration(
            days: reception.milkType.toString().contains('raw') ? 3 : 14)),
        'dateAdded': reception.timestamp,
      };

      // Add directly to Firestore if repository interface doesn't match
      await FirebaseFirestore.instance
          .collection('inventory')
          .add(inventoryData);
    } catch (e) {
      throw BusinessLogicException('Failed to add milk to inventory: $e');
    }
  }

  /// Updates supplier quality metrics
  Future<void> _updateSupplierMetrics({
    required String supplierId,
    required bool accepted,
    required MilkQualityGrade qualityGrade,
    required double quantityLiters,
  }) async {
    try {
      // Get supplier document reference
      final supplierRef =
          FirebaseFirestore.instance.collection('suppliers').doc(supplierId);

      // Get current supplier data
      final supplierDoc = await supplierRef.get();
      if (!supplierDoc.exists) {
        throw BusinessLogicException('Supplier not found');
      }

      final supplierData = supplierDoc.data()!;

      // Update metrics
      await supplierRef.update({
        'totalDeliveries': (supplierData['totalDeliveries'] as int?) ?? 0 + 1,
        'acceptedDeliveries': accepted
            ? ((supplierData['acceptedDeliveries'] as int?) ?? 0) + 1
            : (supplierData['acceptedDeliveries'] as int?) ?? 0,
        'rejectedDeliveries': !accepted
            ? ((supplierData['rejectedDeliveries'] as int?) ?? 0) + 1
            : (supplierData['rejectedDeliveries'] as int?) ?? 0,
        'totalVolume':
            ((supplierData['totalVolume'] as num?) ?? 0.0) + quantityLiters,
        'lastDeliveryDate': DateTime.now(),
        'lastQualityGrade': qualityGrade.toString(),
      });
    } catch (e) {
      // Log error but don't throw
      print('Failed to update supplier metrics: $e');
    }
  }

  /// Tracks a quality issue with a supplier
  Future<void> _trackSupplierQualityIssue({
    required String supplierId,
    required String issue,
    required String severity,
  }) async {
    try {
      // Create quality issue record
      final qualityIssue = {
        'supplierId': supplierId,
        'issueDate': DateTime.now(),
        'description': issue,
        'severity': severity,
        'status': 'Open',
        'resolutionNotes': '',
      };

      // Add directly to quality issues collection
      await FirebaseFirestore.instance
          .collection('quality_issues')
          .add(qualityIssue);

      // Also update the supplier document
      await _updateSupplierQualityIssues(supplierId, qualityIssue);
    } catch (e) {
      // Log error but don't throw
      print('Failed to track supplier quality issue: $e');
    }
  }

  /// Updates supplier quality issues
  Future<void> _updateSupplierQualityIssues(
      String supplierId, Map<String, dynamic> issue) async {
    try {
      // Get supplier document reference
      final supplierRef =
          FirebaseFirestore.instance.collection('suppliers').doc(supplierId);

      // Update quality issues using array union to add to the array
      await supplierRef.update({
        'qualityIssues': FieldValue.arrayUnion([issue]),
      });
    } catch (e) {
      // Log error but don't throw
      print('Failed to update supplier quality issues: $e');
    }
  }

  /// Gets base price for milk type
  double _getMilkBasePrice(MilkType milkType) {
    // In a real implementation, these prices would come from a configuration or database
    switch (milkType) {
      case MilkType.rawCow:
        return 0.50; // $0.50 per liter
      case MilkType.rawGoat:
        return 0.85; // $0.85 per liter
      case MilkType.rawSheep:
        return 0.95; // $0.95 per liter
      default:
        return 0.50; // Default price
    }
  }

  /// Applies quality adjustments to base price
  double _applyQualityAdjustment(
      double basePrice, MilkQualityGrade qualityGrade) {
    switch (qualityGrade) {
      case MilkQualityGrade.premium:
        return basePrice * 1.15; // 15% premium
      case MilkQualityGrade.standard:
        return basePrice; // No adjustment
      case MilkQualityGrade.substandard:
        return basePrice * 0.85; // 15% reduction
      case MilkQualityGrade.rejected:
        return 0.0; // No payment for rejected milk
    }
  }

  // Helper methods to handle milk types and naming

  /// Gets a formatted display name from a milk type
  String _getMilkTypeName(MilkType milkType) {
    switch (milkType) {
      case MilkType.rawCow:
        return 'Raw Cow Milk';
      case MilkType.rawGoat:
        return 'Raw Goat Milk';
      case MilkType.rawSheep:
        return 'Raw Sheep Milk';
      case MilkType.pasteurizedCow:
        return 'Pasteurized Cow Milk';
      case MilkType.pasteurizedGoat:
        return 'Pasteurized Goat Milk';
      case MilkType.pasteurizedSheep:
        return 'Pasteurized Sheep Milk';
      default:
        return 'Other Milk';
    }
  }

  /// Handle finalization of a milk reception (accept or reject)
  Future<void> handleReceptionFinalization(
    MilkReceptionModel reception,
    bool isAccepted,
  ) async {
    // If accepted, add to inventory
    if (isAccepted) {
      // Use _addToInventory method which already exists in this class
      await _addToInventory(reception);

      // Update supplier metrics using existing method
      await _updateSupplierMetrics(
        supplierId: reception.supplierId,
        accepted: isAccepted,
        qualityGrade: MilkQualityGrade.standard, // Default grade
        quantityLiters: reception.quantityLiters,
      );
    } else {
      // If rejected, track quality issue
      await _trackSupplierQualityIssue(
        supplierId: reception.supplierId,
        issue: 'Reception rejected',
        severity: 'Medium',
      );
    }

    // Send notification using existing notification methods
    if (isAccepted) {
      await _notificationService.createCompletionNotification(
        receptionId: reception.id,
        supplierId: reception.supplierId,
        supplierName: reception.supplierName,
        quantityAccepted: reception.quantityLiters,
        qualityGrade: 'Standard',
        targetRoleId: 'factory',
      );
    } else {
      await _notificationService.createRejectionNotification(
        receptionId: reception.id,
        supplierId: reception.supplierId,
        supplierName: reception.supplierName,
        rejectionReason: reception.notes ?? 'Quality issues',
        quantityRejected: reception.quantityLiters,
        targetRoleId: 'factory',
      );
    }
  }
}

/// Result of milk reception validation
class ValidationResult {
  ValidationResult({
    required this.isValid,
    this.rejectionReason,
  });

  final bool isValid;
  final String? rejectionReason;
}
