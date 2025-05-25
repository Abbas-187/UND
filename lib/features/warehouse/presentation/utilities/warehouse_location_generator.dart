import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/warehouse_location_model.dart';
import '../../domain/providers/warehouse_location_repository_provider.dart';
import '../../domain/repositories/warehouse_location_repository.dart';

/// Utility for creating test warehouse locations
class WarehouseLocationGenerator {
  WarehouseLocationGenerator(this._repository);
  final WarehouseLocationRepository _repository;

  /// Create sample warehouse locations for testing
  Future<List<String>> createSampleLocations() async {
    final List<String> createdLocationIds = [];

    // Define temperature zones
    const zones = [
      {
        'name': 'Ambient',
        'minTemp': 15.0,
        'maxTemp': 25.0,
        'requiresHumidity': false
      },
      {
        'name': 'Cold',
        'minTemp': 2.0,
        'maxTemp': 6.0,
        'requiresHumidity': true
      },
      {
        'name': 'Freezer',
        'minTemp': -22.0,
        'maxTemp': -18.0,
        'requiresHumidity': false
      },
      {
        'name': 'Production',
        'minTemp': 10.0,
        'maxTemp': 20.0,
        'requiresHumidity': true
      },
    ];

    // Define warehouses
    const warehouses = [
      {'id': 'wh1', 'name': 'Main Warehouse'},
      {'id': 'wh2', 'name': 'Distribution Center'},
    ];

    for (final warehouse in warehouses) {
      final warehouseId = warehouse['id'] as String;

      // Create locations for each zone
      for (var zoneIndex = 0; zoneIndex < zones.length; zoneIndex++) {
        final zone = zones[zoneIndex];
        final zoneName = zone['name'] as String;
        final zoneCode = zoneName.substring(0, 1).toLowerCase();

        // Create a few aisles per zone
        for (var aisle = 1; aisle <= 3; aisle++) {
          // Create racks in each aisle
          for (var rack = 1; rack <= 4; rack++) {
            // Create levels in each rack
            for (var level = 1; level <= 3; level++) {
              // Create bins in each level
              for (var bin = 1; bin <= 4; bin++) {
                // Generate location code and name
                final locationCode =
                    '$warehouseId/$zoneCode$zoneIndex/a$aisle/r$rack/l$level/b$bin';
                final locationName =
                    '${warehouse['name']} - ${zone['name']} Zone - A$aisle-R$rack-L$level-B$bin';

                // Create location model
                final location = WarehouseLocationModel(
                  warehouseId: warehouseId,
                  locationCode: locationCode,
                  locationName: locationName,
                  locationType: _getLocationType(zoneName),
                  zone: '$zoneCode$zoneIndex',
                  aisle: 'a$aisle',
                  rack: 'r$rack',
                  level: 'l$level',
                  bin: 'b$bin',
                  maxWeight: 500.0,
                  maxVolume: 1000.0,
                  currentWeight: 0.0,
                  currentVolume: 0.0,
                  currentItemCount: 0,
                  temperatureZone: zoneName,
                  minTemperature: zone['minTemp'] as double,
                  maxTemperature: zone['maxTemp'] as double,
                  requiresHumidityControl: zone['requiresHumidity'] as bool,
                  minHumidity: zone['requiresHumidity'] as bool ? 40.0 : null,
                  maxHumidity: zone['requiresHumidity'] as bool ? 60.0 : null,
                  isActive: true,
                  createdAt: DateTime.now(),
                );

                try {
                  final id = await _repository.createLocation(location);
                  createdLocationIds.add(id);
                } catch (e) {
                  print('Error creating location $locationCode: $e');
                }
              }
            }
          }
        }
      }
    }

    return createdLocationIds;
  }

  String _getLocationType(String zoneName) {
    switch (zoneName.toLowerCase()) {
      case 'ambient':
        return 'dryStorage';
      case 'cold':
        return 'coldStorage';
      case 'freezer':
        return 'freezer';
      case 'production':
        return 'productionArea';
      default:
        return 'dryStorage';
    }
  }
}

/// Provider for the warehouse location generator
final warehouseLocationGeneratorProvider =
    Provider<WarehouseLocationGenerator>((ref) {
  final repository = ref.watch(warehouseLocationRepositoryProvider);
  return WarehouseLocationGenerator(repository);
});
