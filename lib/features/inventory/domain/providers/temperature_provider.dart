import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/temperature_log_model.dart';
import '../../data/models/temperature_settings_model.dart';
import '../../data/repositories/temperature_monitoring_repository.dart';

part 'temperature_provider.g.dart';

@riverpod
class TemperatureLogs extends _$TemperatureLogs {
  @override
  Stream<List<TemperatureLogModel>> build(String locationId) {
    final repository = ref.watch(temperatureMonitoringRepositoryProvider);
    return Stream.fromFuture(
        repository.getTemperatureLogsByLocation(locationId));
  }

  Future<String> recordTemperature({
    required String locationId,
    required String sensorId,
    required double temperature,
    String? notes,
  }) async {
    final repository = ref.read(temperatureMonitoringRepositoryProvider);

    final log = TemperatureLogModel(
      locationId: locationId,
      locationName: 'Location Name', // Should be fetched from a repository
      timestamp: DateTime.now(),
      temperatureValue: temperature,
      complianceStatus: TemperatureComplianceStatus.notApplicable,
      deviceId: sensorId,
      notes: notes,
      createdBy: 'system',
      createdAt: DateTime.now(),
    );
    return repository.createTemperatureLog(log);
  }
}

@riverpod
class TemperatureSettings extends _$TemperatureSettings {
  @override
  Future<TemperatureSettingsModel> build(String locationId) async {
    final repository = ref.watch(temperatureMonitoringRepositoryProvider);
    final settings =
        await repository.getTemperatureSettingsForLocation(locationId);
    if (settings == null) {
      throw Exception(
          'Temperature settings not found for location: $locationId');
    }
    return settings;
  }
}

@riverpod
class TemperatureAlerts extends _$TemperatureAlerts {
  @override
  Stream<List<Map<String, dynamic>>> build({bool onlyUnresolved = true}) {
    final repository = ref.watch(temperatureMonitoringRepositoryProvider);
    // Repository doesn't have stream-based alerts, so we'll convert
    return Stream.fromFuture(repository.getTemperatureAlerts().then((alerts) {
      // Convert to Map<String, dynamic> format
      return alerts
          .map((alert) => {
                'id': alert.id,
                'locationId': alert.locationId,
                'sensorId': alert.deviceId,
                'temperature': alert.temperatureValue,
                'timestamp': alert.timestamp,
                'isResolved': !(alert.additionalData?['isAlert'] ??
                    true), // Invert isAlert
                'notes': alert.notes,
              })
          .toList();
    }));
  }

  Future<void> resolveAlert(String alertId, String resolution) async {
    // Implementation depends on repository capabilities
    // For now, update the alert with notes about resolution
    final repository = ref.read(temperatureMonitoringRepositoryProvider);
    // Repository doesn't have direct resolveAlert method
    // This would need to be implemented in the repository
    // For now, we'll just print a message
    print('Alert $alertId resolved with: $resolution');
  }
}
