import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/logging/logging_service.dart';
import '../../domain/repositories/supplier_lead_time_repository.dart';

/// Implementation of SupplierLeadTimeRepository using Firebase Firestore
class SupplierLeadTimeRepositoryImpl implements SupplierLeadTimeRepository {
  SupplierLeadTimeRepositoryImpl({
    LoggingService? loggingService,
    FirebaseFirestore? firestore,
  })  : _loggingService = loggingService ??
            LoggingService(Logger(printer: PrettyPrinter()), AppConfig()),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LoggingService _loggingService;

  CollectionReference<Map<String, dynamic>> get _leadTimeCollection =>
      _firestore.collection('supplier_lead_times');

  @override
  Future<Map<String, double>> getLeadTimeInfo({
    required String supplierId,
    required String itemId,
  }) async {
    try {
      // Query for the specific supplier-item combination
      final query = await _leadTimeCollection
          .where('supplierId', isEqualTo: supplierId)
          .where('itemId', isEqualTo: itemId)
          .get();

      if (query.docs.isEmpty) {
        // If no specific data is found, fall back to default
        return getDefaultLeadTimeInfo(itemId: itemId);
      }

      // Found specific supplier-item lead time data
      final data = query.docs.first.data();

      return {
        'averageLeadTimeDays': (data['averageLeadTimeDays'] as num).toDouble(),
        'leadTimeVariability':
            (data['leadTimeVariability'] as num?)?.toDouble() ?? 1.0,
        'maxLeadTimeDays': (data['maxLeadTimeDays'] as num?)?.toDouble() ??
            ((data['averageLeadTimeDays'] as num).toDouble() *
                1.5), // Default to 150% of average
      };
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get lead time info for supplier $supplierId and item $itemId',
          e,
          stackTrace);

      // Return default values if there's an error
      return {
        'averageLeadTimeDays': 7.0, // Default one week
        'leadTimeVariability': 2.0,
        'maxLeadTimeDays': 14.0, // Default two weeks
      };
    }
  }

  @override
  Future<Map<String, double>> getDefaultLeadTimeInfo({
    required String itemId,
  }) async {
    try {
      // Query to find any lead time data for this item across all suppliers
      final query =
          await _leadTimeCollection.where('itemId', isEqualTo: itemId).get();

      if (query.docs.isEmpty) {
        // No data at all, return conservative defaults
        return {
          'averageLeadTimeDays': 7.0, // Default one week
          'leadTimeVariability': 2.0,
          'maxLeadTimeDays': 14.0, // Default two weeks
        };
      }

      // Calculate average of all lead times for this item
      double totalLeadTime = 0.0;
      double maxLeadTime = 0.0;
      List<double> allLeadTimes = [];

      for (final doc in query.docs) {
        final data = doc.data();
        final leadTime = (data['averageLeadTimeDays'] as num).toDouble();
        totalLeadTime += leadTime;
        maxLeadTime = leadTime > maxLeadTime ? leadTime : maxLeadTime;
        allLeadTimes.add(leadTime);
      }

      final averageLeadTime = totalLeadTime / query.docs.length;

      // Calculate variability as standard deviation
      double sumSquaredDiff = 0.0;
      for (final leadTime in allLeadTimes) {
        sumSquaredDiff +=
            (leadTime - averageLeadTime) * (leadTime - averageLeadTime);
      }
      final variability = allLeadTimes.length > 1
          ? sqrt(sumSquaredDiff / (allLeadTimes.length - 1))
          : 1.0; // Default if only one data point

      return {
        'averageLeadTimeDays': averageLeadTime,
        'leadTimeVariability': variability,
        'maxLeadTimeDays': maxLeadTime,
      };
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get default lead time info for item $itemId',
          e,
          stackTrace);

      // Return default values if there's an error
      return {
        'averageLeadTimeDays': 7.0, // Default one week
        'leadTimeVariability': 2.0,
        'maxLeadTimeDays': 14.0, // Default two weeks
      };
    }
  }

  @override
  Future<void> recordActualLeadTime({
    required String supplierId,
    required String itemId,
    required double actualLeadTimeDays,
    String? purchaseOrderId,
  }) async {
    try {
      // First, check if we have an existing record to update
      final query = await _leadTimeCollection
          .where('supplierId', isEqualTo: supplierId)
          .where('itemId', isEqualTo: itemId)
          .get();

      if (query.docs.isEmpty) {
        // Create new lead time record
        await _leadTimeCollection.add({
          'supplierId': supplierId,
          'itemId': itemId,
          'averageLeadTimeDays': actualLeadTimeDays,
          'leadTimeVariability': 0.0, // Will be updated as more data comes in
          'maxLeadTimeDays': actualLeadTimeDays,
          'dataPoints': 1,
          'lastUpdated': FieldValue.serverTimestamp(),
          'historicalLeadTimes': [
            {
              'leadTimeDays': actualLeadTimeDays,
              'purchaseOrderId': purchaseOrderId,
              'recordedDate': FieldValue.serverTimestamp(),
            }
          ],
        });
      } else {
        // Update existing record
        final docRef = query.docs.first.reference;
        final data = query.docs.first.data();

        final int dataPoints = (data['dataPoints'] as num? ?? 0).toInt() + 1;
        final double currentAverage =
            (data['averageLeadTimeDays'] as num? ?? 0).toDouble();

        // Calculate new average using the formula:
        // newAvg = oldAvg + (newValue - oldAvg) / newCount
        final double newAverage = currentAverage +
            ((actualLeadTimeDays - currentAverage) / dataPoints);

        // Get current history for variance calculation
        List<Map<String, dynamic>> historicalLeadTimes =
            List<Map<String, dynamic>>.from(data['historicalLeadTimes'] ?? []);

        // Add new lead time to history
        historicalLeadTimes.add({
          'leadTimeDays': actualLeadTimeDays,
          'purchaseOrderId': purchaseOrderId,
          'recordedDate': FieldValue.serverTimestamp(),
        });

        // Calculate new max
        final double currentMax =
            (data['maxLeadTimeDays'] as num? ?? 0).toDouble();
        final double newMax =
            actualLeadTimeDays > currentMax ? actualLeadTimeDays : currentMax;

        // Calculate new variance and standard deviation
        double sumSquaredDiff = 0;
        for (var item in historicalLeadTimes) {
          double leadTime = (item['leadTimeDays'] as num).toDouble();
          sumSquaredDiff += (leadTime - newAverage) * (leadTime - newAverage);
        }

        final double newVariability = historicalLeadTimes.length > 1
            ? sqrt(sumSquaredDiff / (historicalLeadTimes.length - 1))
            : 0.0;

        // Update the document
        await docRef.update({
          'averageLeadTimeDays': newAverage,
          'leadTimeVariability': newVariability,
          'maxLeadTimeDays': newMax,
          'dataPoints': dataPoints,
          'lastUpdated': FieldValue.serverTimestamp(),
          'historicalLeadTimes': historicalLeadTimes,
        });
      }
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to record actual lead time for supplier $supplierId and item $itemId',
          e,
          stackTrace);
      rethrow;
    }
  }
}
