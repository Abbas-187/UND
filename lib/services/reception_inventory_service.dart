import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/core.dart';
import '../features/inventory/data/models/inventory_item_model.dart';
import '../features/inventory/domain/entities/inventory_item.dart';
import '../features/inventory/domain/repositories/inventory_repository.dart';
import '../features/milk_reception/domain/models/milk_reception_model.dart';
import '../features/milk_reception/domain/repositories/milk_reception_repository.dart';

/// Custom exception for business logic errors
class BusinessLogicException implements Exception {
  BusinessLogicException(this.message);
  final String message;

  @override
  String toString() => 'BusinessLogicException: $message';
}

/// Service for integrating milk reception with inventory management
class ReceptionInventoryService {
  /// Constructor with dependency injection
  ReceptionInventoryService({
    required MilkReceptionRepository receptionRepository,
    required InventoryRepository inventoryRepository,
    required dynamic firestore,
  })  : _receptionRepository = receptionRepository,
        _inventoryRepository = inventoryRepository,
        _firestore = firestore;

  final MilkReceptionRepository _receptionRepository;
  final InventoryRepository _inventoryRepository;
  final dynamic _firestore;

  /// Get the properly typed Firestore instance
  dynamic get firestore => _firestore;

  /// Stream of completed milk receptions
  Stream<List<MilkReceptionModel>> get completedReceptions {
    if (useMockFirebase) {
      return (firestore as FirestoreInterface)
          .collection('milk_receptions')
          .where('receptionStatus',
              isEqualTo: ReceptionStatus.accepted.toString())
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                if (data is Map<String, dynamic>) {
                  return MilkReceptionModel.fromJson(data);
                }
                throw Exception('Unexpected data type in document');
              }).toList());
    } else {
      return (firestore as FirebaseFirestore)
          .collection('milk_receptions')
          .where('receptionStatus',
              isEqualTo: ReceptionStatus.accepted.toString())
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MilkReceptionModel.fromJson(doc.data()))
              .toList());
    }
  }

  /// Creates inventory from a completed milk reception
  Future<String> createInventoryFromReception(String receptionId) async {
    try {
      // Get the reception details
      final reception =
          await _receptionRepository.getReceptionById(receptionId);

      // Verify that reception is accepted
      if (reception.receptionStatus != ReceptionStatus.accepted) {
        throw BusinessLogicException(
            'Cannot create inventory from reception that is not accepted');
      }

      // Allocate storage location
      final location = await allocateStorageLocation(
          reception.milkType, reception.quantityLiters);

      // Generate lot number
      final lotNumber = generateLotNumber(receptionId, reception.supplierId);

      // Calculate expiration date (3 days for raw milk, 14 days for pasteurized)
      final expirationDays =
          reception.milkType.toString().contains('raw') ? 3 : 14;
      final expiryDate = DateTime.now().add(Duration(days: expirationDays));

      // Create inventory item
      final itemName = _getMilkTypeName(reception.milkType);
      final category = 'Raw Materials';

      // Create batch information
      final batchInfo = BatchInformation(
        batchId: lotNumber,
        productionDate: reception.timestamp,
        sourceId: receptionId,
        sourceDetails: {
          'supplierId': reception.supplierId,
          'supplierName': reception.supplierName,
          'milkType': reception.milkType.toString(),
          'temperatureAtArrival': reception.temperatureAtArrival,
          'vehiclePlate': reception.vehiclePlate,
          'driverName': reception.driverName,
        },
        isApproved: true,
        approvalDate: DateTime.now(),
        notes: 'Created from milk reception #$receptionId',
      );

      // Create quality parameters
      Map<String, QualityParameterMeasurement> qualityParams = {
        'temperature': QualityParameterMeasurement(
          parameterName: 'Temperature',
          value: reception.temperatureAtArrival,
          unit: '°C',
          timestamp: DateTime.now(),
          status: _getTemperatureQualityStatus(
              reception.temperatureAtArrival, reception.milkType),
        ),
      };

      // Add pH if available
      if (reception.phValue != null) {
        qualityParams['ph'] = QualityParameterMeasurement(
          parameterName: 'pH',
          value: reception.phValue!,
          unit: 'pH',
          timestamp: DateTime.now(),
          status: _getPHQualityStatus(reception.phValue!),
        );
      }

      // Create inventory item
      final inventoryItem = InventoryItemModel(
        id: '', // Will be generated by the repository
        name: itemName,
        category: category,
        unit: 'liters',
        quantity: reception.quantityLiters,
        minimumQuantity: 100, // Default values, can be configured
        reorderPoint: 300, // Default values, can be configured
        location: location,
        lastUpdated: DateTime.now(),
        batchNumber: lotNumber,
        expiryDate: expiryDate,
        additionalAttributes: {
          'receptionId': receptionId,
          'supplierId': reception.supplierId,
          'milkType': reception.milkType.toString(),
          'quality': _determineQualityGrade(reception).toString(),
        },
        temperatureHistory: [
          TemperatureReading(
            timestamp: reception.timestamp,
            temperature: reception.temperatureAtArrival,
            recordedBy: 'system',
            deviceId: 'reception_system',
            location: 'milk_reception_area',
            isCompliant: reception.temperatureAtArrival <= 8.0,
            notes: 'Initial temperature at reception',
          ),
        ],
        currentTemperature: reception.temperatureAtArrival,
        qualityParameters: qualityParams,
        batchInformation: batchInfo,
        storageCondition: 'refrigerated',
        searchTerms: [
          'milk',
          itemName.toLowerCase(),
          reception.supplierName.toLowerCase(),
          lotNumber.toLowerCase(),
        ],
        overallQualityStatus: _determineOverallQualityStatus(reception),
      );

      // Add to inventory
      final addedItem =
          await _inventoryRepository.addItem(inventoryItem.toDomain());

      // Record temperature measurement
      await recordTemperatureMeasurement(
          addedItem.id, reception.temperatureAtArrival);

      // Update available inventory
      await updateAvailableInventory(addedItem);

      return addedItem.id;
    } catch (e) {
      if (e is BusinessLogicException) rethrow;
      throw BusinessLogicException(
          'Failed to create inventory from reception: $e');
    }
  }

  /// Allocates an appropriate storage location based on milk type and quantity
  Future<String> allocateStorageLocation(
      MilkType milkType, double quantity) async {
    try {
      // Query available storage locations
      final locationQuery = await (firestore as FirebaseFirestore)
          .collection('storage_locations')
          .where('storageType', isEqualTo: 'Milk')
          .where('milkType', isEqualTo: milkType.toString())
          .where('availableCapacity', isGreaterThanOrEqualTo: quantity)
          .orderBy('availableCapacity')
          .limit(1)
          .get();

      // If no suitable location found, throw exception
      if (locationQuery.docs.isEmpty) {
        throw BusinessLogicException(
            'No suitable storage location found for ${milkType.toString()} milk of quantity $quantity liters');
      }

      // Return the allocated location
      final locationDoc = locationQuery.docs.first;
      final locationId = locationDoc.id;
      final locationName = locationDoc.data()['name'] as String;

      // Update available capacity in the storage location
      await (firestore as FirebaseFirestore)
          .collection('storage_locations')
          .doc(locationId)
          .update({
        'availableCapacity': FieldValue.increment(-quantity),
        'lastUpdated': DateTime.now(),
      });

      return locationName;
    } catch (e) {
      if (e is BusinessLogicException) rethrow;
      throw BusinessLogicException('Failed to allocate storage location: $e');
    }
  }

  /// Generates a lot number for the inventory entry
  String generateLotNumber(String receptionId, String supplierId) {
    final timestamp = DateTime.now();
    final dateCode =
        '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final shortReceptionId = receptionId.substring(0, 4).toUpperCase();
    final shortSupplierId = supplierId.substring(0, 3).toUpperCase();

    return 'M$dateCode-$shortSupplierId-$shortReceptionId';
  }

  /// Updates available inventory after adding a new item
  Future<void> updateAvailableInventory(InventoryItem inventoryItem) async {
    try {
      // Fire an event to notify of new inventory
      final updateEvent = {
        'eventType': 'inventoryAdded',
        'inventoryId': inventoryItem.id,
        'itemName': inventoryItem.name,
        'quantity': inventoryItem.quantity,
        'category': inventoryItem.category,
        'location': inventoryItem.location,
        'batchNumber': inventoryItem.batchNumber,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await (firestore as FirebaseFirestore)
          .collection('inventory_events')
          .add(updateEvent);

      // Check if low inventory alert needs to be triggered
      if (await _shouldTriggerLowInventoryAlert(inventoryItem.name)) {
        await _triggerLowInventoryAlert(inventoryItem.name);
      }

      // Update inventory analytics
      await _updateInventoryAnalytics(
        category: inventoryItem.category,
        quantity: inventoryItem.quantity,
      );
    } catch (e) {
      throw BusinessLogicException('Failed to update available inventory: $e');
    }
  }

  /// Records a temperature measurement for an inventory item
  Future<void> recordTemperatureMeasurement(
      String inventoryId, double temperature) async {
    try {
      final item = await _inventoryRepository.getItem(inventoryId);

      if (item == null) {
        throw BusinessLogicException('Inventory item not found');
      }

      // Create the measurement record
      final measurementData = {
        'inventoryId': inventoryId,
        'temperature': temperature,
        'timestamp': FieldValue.serverTimestamp(),
        'recordedBy': 'system',
        'measurementType': 'automatic',
      };

      // Add to temperature_measurements collection
      await (firestore as FirebaseFirestore)
          .collection('temperature_measurements')
          .add(measurementData);

      // Add to temperature_history subcollection of the inventory item
      await (firestore as FirebaseFirestore)
          .collection('inventory')
          .doc(inventoryId)
          .collection('temperature_history')
          .add(measurementData);

      // Check if temperature is out of acceptable range
      if (_isTemperatureOutOfRange(temperature, item.name)) {
        await _triggerTemperatureAlert(inventoryId, item.name, temperature);
      }
    } catch (e) {
      throw BusinessLogicException(
          'Failed to record temperature measurement: $e');
    }
  }

  /// Checks if inventory levels are low for a specific item type
  Future<bool> _shouldTriggerLowInventoryAlert(String itemName) async {
    try {
      // Query total available quantity for this item type
      final snapshot = await (firestore as FirebaseFirestore)
          .collection('inventory')
          .where('name', isEqualTo: itemName)
          .get();

      double totalQuantity = 0.0;
      for (final doc in snapshot.docs) {
        totalQuantity += (doc.data()['quantity'] as num).toDouble();
      }

      // Get threshold for this item type
      final thresholdDoc = await (firestore as FirebaseFirestore)
          .collection('inventory_thresholds')
          .where('itemName', isEqualTo: itemName)
          .get();

      if (thresholdDoc.docs.isEmpty) return false;

      final lowThreshold =
          (thresholdDoc.docs.first.data()['lowThreshold'] as num).toDouble();

      return totalQuantity < lowThreshold;
    } catch (e) {
      return false; // If error, don't trigger alert
    }
  }

  /// Triggers a low inventory alert
  Future<void> _triggerLowInventoryAlert(String itemName) async {
    try {
      final alertData = {
        'alertType': 'lowInventory',
        'itemName': itemName,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'message': 'Low inventory level for $itemName',
        'severity': 'medium',
      };

      await (firestore as FirebaseFirestore)
          .collection('alerts')
          .add(alertData);
    } catch (e) {
      // Log error but don't throw
      print('Failed to trigger low inventory alert: $e');
    }
  }

  /// Updates inventory analytics after adding inventory
  Future<void> _updateInventoryAnalytics(
      {required String category, required double quantity}) async {
    try {
      // Update daily inventory additions
      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final analyticsRef = (firestore as FirebaseFirestore)
          .collection('inventory_analytics')
          .doc('daily_additions')
          .collection(dateString)
          .doc(category);

      await (firestore as FirebaseFirestore)
          .runTransaction((transaction) async {
        final docSnapshot = await transaction.get(analyticsRef);

        if (docSnapshot.exists) {
          transaction.update(analyticsRef, {
            'totalQuantity': FieldValue.increment(quantity),
            'numberOfAdditions': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(analyticsRef, {
            'category': category,
            'totalQuantity': quantity,
            'numberOfAdditions': 1,
            'date': dateString,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      // Log error but don't throw
      print('Failed to update inventory analytics: $e');
    }
  }

  /// Checks if a temperature is out of acceptable range
  bool _isTemperatureOutOfRange(double temperature, String itemName) {
    // For milk, standard refrigeration temperature is 2-4°C
    final minTemp = 2.0;
    final maxTemp = 4.0;

    return temperature < minTemp || temperature > maxTemp;
  }

  /// Triggers a temperature alert
  Future<void> _triggerTemperatureAlert(
      String inventoryId, String itemName, double temperature) async {
    try {
      final alertData = {
        'alertType': 'temperatureOutOfRange',
        'inventoryId': inventoryId,
        'itemName': itemName,
        'temperature': temperature,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'message': 'Temperature out of range for $itemName: $temperature°C',
        'severity': 'high',
      };

      await (firestore as FirebaseFirestore)
          .collection('alerts')
          .add(alertData);
    } catch (e) {
      // Log error but don't throw
      print('Failed to trigger temperature alert: $e');
    }
  }

  /// Helper method to get a formatted name from milk type
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

  /// Helper method to determine quality grade from reception data
  QualityStatus _determineQualityGrade(MilkReceptionModel reception) {
    // If there's any visible contamination, it's rejected quality
    if (reception.hasVisibleContamination) {
      return QualityStatus.rejected;
    }

    // Check temperature for raw milk
    if (reception.milkType.toString().contains('raw')) {
      if (reception.temperatureAtArrival > 10.0) {
        return QualityStatus.warning;
      }
    }

    // Check pH if available
    if (reception.phValue != null) {
      if (reception.phValue! < 6.6 || reception.phValue! > 6.8) {
        return QualityStatus.warning;
      }
    }

    // Check smell and appearance
    if (reception.smell.toLowerCase().contains('off') ||
        reception.appearance.toLowerCase().contains('abnormal')) {
      return QualityStatus.warning;
    }

    // Default to good if no issues detected
    return QualityStatus.good;
  }

  /// Helper method to determine temperature quality status
  QualityStatus _getTemperatureQualityStatus(
      double temperature, MilkType milkType) {
    // For raw milk
    if (milkType.toString().contains('raw')) {
      if (temperature <= 4.0) return QualityStatus.excellent;
      if (temperature <= 6.0) return QualityStatus.good;
      if (temperature <= 8.0) return QualityStatus.acceptable;
      if (temperature <= 10.0) return QualityStatus.warning;
      return QualityStatus.critical;
    }
    // For pasteurized milk
    else {
      if (temperature <= 4.0) return QualityStatus.excellent;
      if (temperature <= 6.0) return QualityStatus.good;
      if (temperature <= 7.0) return QualityStatus.acceptable;
      return QualityStatus.warning;
    }
  }

  /// Helper method to determine pH quality status
  QualityStatus _getPHQualityStatus(double ph) {
    if (ph >= 6.6 && ph <= 6.8) return QualityStatus.excellent;
    if (ph >= 6.5 && ph <= 6.9) return QualityStatus.good;
    if (ph >= 6.4 && ph <= 7.0) return QualityStatus.acceptable;
    if (ph >= 6.3 && ph <= 7.1) return QualityStatus.warning;
    return QualityStatus.critical;
  }

  /// Helper method to determine overall quality status
  QualityStatus _determineOverallQualityStatus(MilkReceptionModel reception) {
    // If there's any visible contamination, it's rejected
    if (reception.hasVisibleContamination) {
      return QualityStatus.rejected;
    }

    int warningCount = 0;

    // Check temperature
    if (reception.milkType.toString().contains('raw') &&
        reception.temperatureAtArrival > 8.0) {
      warningCount++;
    }

    // Check pH if available
    if (reception.phValue != null &&
        (reception.phValue! < 6.5 || reception.phValue! > 6.9)) {
      warningCount++;
    }

    // Check smell and appearance
    if (reception.smell.toLowerCase().contains('off') ||
        reception.appearance.toLowerCase().contains('abnormal')) {
      warningCount++;
    }

    // Determine overall quality
    if (warningCount == 0) return QualityStatus.excellent;
    if (warningCount == 1) return QualityStatus.good;
    if (warningCount == 2) return QualityStatus.acceptable;
    return QualityStatus.warning;
  }
}
