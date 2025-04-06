import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/temperature_log_model.dart';
import '../models/temperature_settings_model.dart';

part 'temperature_monitoring_repository.g.dart';

class TemperatureMonitoringRepository {
  TemperatureMonitoringRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _temperatureLogsCollection =>
      _firestore.collection('temperature_logs');

  CollectionReference<Map<String, dynamic>>
      get _temperatureSettingsCollection =>
          _firestore.collection('temperature_settings');

  // Get all temperature logs
  Future<List<TemperatureLogModel>> getTemperatureLogs() async {
    final querySnapshot = await _temperatureLogsCollection
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TemperatureLogModel.fromJson(data);
    }).toList();
  }

  final FirebaseFirestore _firestore;
  // Get temperature logs by location
  Future<List<TemperatureLogModel>> getTemperatureLogsByLocation(
      String locationId) async {
    final querySnapshot = await _temperatureLogsCollection
        .where('locationId', isEqualTo: locationId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TemperatureLogModel.fromJson(data);
    }).toList();
  }

  // Create temperature log
  Future<String> createTemperatureLog(TemperatureLogModel log) async {
    final docRef = await _temperatureLogsCollection.add(log.toJson());

    // Check for temperature alerts
    TemperatureSettingsModel? settings =
        await getTemperatureSettingsForLocation(log.locationId);

    if (settings != null &&
        settings.alertsEnabled &&
        (log.temperatureValue < settings.minTemperature ||
            log.temperatureValue > settings.maxTemperature)) {
      // Create alert by updating the log
      await _temperatureLogsCollection.doc(docRef.id).update({'isAlert': true});

      // Handle alert notification logic here
      // This could involve sending notifications, emails, etc.
    }

    return docRef.id;
  }

  // Get temperature logs by date range
  Future<List<TemperatureLogModel>> getTemperatureLogsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final querySnapshot = await _temperatureLogsCollection
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TemperatureLogModel.fromJson(data);
    }).toList();
  }

  // Get temperature alerts
  Future<List<TemperatureLogModel>> getTemperatureAlerts() async {
    final querySnapshot = await _temperatureLogsCollection
        .where('isAlert', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TemperatureLogModel.fromJson(data);
    }).toList();
  }

  // Get temperature settings for a location
  Future<TemperatureSettingsModel?> getTemperatureSettingsForLocation(
      String locationId) async {
    try {
      final querySnapshot = await _temperatureSettingsCollection
          .where('locationId', isEqualTo: locationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return TemperatureSettingsModel.fromJson(data);
    } catch (e) {
      // Log error: Error getting temperature settings: $e
      return null;
    }
  }

  // Create or update temperature settings
  Future<String> createOrUpdateTemperatureSettings(
      TemperatureSettingsModel settings) async {
    if (settings.id != null) {
      // Update existing settings
      await _temperatureSettingsCollection
          .doc(settings.id)
          .update(settings.toJson());
      return settings.id!;
    } else {
      // Check if settings already exist for this location
      final querySnapshot = await _temperatureSettingsCollection
          .where('locationId', isEqualTo: settings.locationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing settings
        final docId = querySnapshot.docs.first.id;
        await _temperatureSettingsCollection
            .doc(docId)
            .update(settings.toJson());
        return docId;
      } else {
        // Create new settings
        final docRef =
            await _temperatureSettingsCollection.add(settings.toJson());
        return docRef.id;
      }
    }
  }
}

// Provider for temperature monitoring repository
@riverpod
TemperatureMonitoringRepository temperatureMonitoringRepository(
    TemperatureMonitoringRepositoryRef ref) {
  return TemperatureMonitoringRepository();
}
