import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/data/models/location_model.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/domain/providers/inventory_repository_provider.dart'
    as inventory_provider;
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../entities/location_optimization_criteria.dart';
import '../providers/warehouse_location_repository_provider.dart';
import '../repositories/warehouse_location_repository.dart';
import '../services/location_optimization_service.dart';

/// Use case to optimize inventory item locations
class OptimizeItemLocationsUseCase {
  OptimizeItemLocationsUseCase({
    required this.inventoryRepository,
    required this.optimizationService,
    required this.locationRepository,
  });

  final InventoryRepository inventoryRepository;
  final LocationOptimizationService optimizationService;
  final WarehouseLocationRepository locationRepository;

  /// Execute the location optimization for a set of items
  /// Returns the number of items that were relocated
  Future<int> execute({
    List<String>? itemIds,
    String? warehouseId,
    String? categoryFilter,
    LocationOptimizationCriteria? criteria,
    bool applyChanges = false,
  }) async {
    // Get items to optimize (either specific items or filtered by category)
    final List<InventoryItem> items;
    if (itemIds != null && itemIds.isNotEmpty) {
      items = [];
      for (final id in itemIds) {
        final item = await inventoryRepository.getItem(id);
        if (item != null) items.add(item);
      }
    } else {
      // Get all items or filter by category
      items = await inventoryRepository.filterItems(
        category: categoryFilter,
      );
    }

    // Get available warehouse locations
    List<LocationModel> availableLocations;

    try {
      // Fetch real warehouse locations
      final warehouseLocations =
          await locationRepository.getLocationsByWarehouse(
        warehouseId ?? 'default_warehouse',
      );

      // Convert warehouse locations to inventory locations for the optimization service
      availableLocations = warehouseLocations
          .map((loc) => InventoryLocation(
                locationId: loc.id ?? loc.locationCode,
                locationName: loc.locationName,
                locationType: _convertLocationType(loc.locationType),
                temperatureCondition: loc.temperatureZone ?? 'ambient',
                storageCapacity: loc.maxVolume ?? 1000,
                currentUtilization: loc.currentVolume ?? 0,
                parentLocationId: loc.parentLocationId,
                isActive: loc.isActive,
              ))
          .toList();

      // If no locations found, use mock locations as fallback
      if (availableLocations.isEmpty) {
        print(
            'No warehouse locations found. Using mock locations as fallback.');
        availableLocations = _getMockLocations();
      }
    } catch (e) {
      // Fallback to mock locations if there's an error
      print(
          'Error fetching warehouse locations: $e. Using mock locations as fallback.');
      availableLocations = _getMockLocations();
    }

    // Get optimization recommendations
    final recommendations = await optimizationService.optimizeLocations(
      items: items,
      availableLocations: availableLocations,
      criteria: criteria,
    );

    // Count items that need relocating (current location != optimized location)
    int relocatedCount = 0;

    // Apply changes if requested
    if (applyChanges) {
      for (final item in items) {
        final recommendedLocation = recommendations[item.id];
        if (recommendedLocation != null &&
            recommendedLocation != item.location) {
          // Update the item's location
          final updatedItem = item.copyWith(location: recommendedLocation);
          await inventoryRepository.updateItem(updatedItem);
          relocatedCount++;
        }
      }
    } else {
      // Just count how many would be relocated without applying changes
      for (final item in items) {
        final recommendedLocation = recommendations[item.id];
        if (recommendedLocation != null &&
            recommendedLocation != item.location) {
          relocatedCount++;
        }
      }
    }

    return relocatedCount;
  }

  // Convert warehouse location type string to LocationType enum
  LocationType _convertLocationType(String locationType) {
    switch (locationType.toLowerCase()) {
      case 'coldstorage':
        return LocationType.coldStorage;
      case 'freezer':
        return LocationType.freezer;
      case 'production':
        return LocationType.productionArea;
      case 'quality':
        return LocationType.qualityControl;
      case 'dispatch':
        return LocationType.dispatchArea;
      case 'drystorage':
      default:
        return LocationType.dryStorage;
    }
  }

  // Mock locations for testing or fallback
  List<LocationModel> _getMockLocations() {
    return [
      const InventoryLocation(
        locationId: 'wh1/zone-a/aisle1/rack1',
        locationName: 'Zone A - Ambient Storage',
        locationType: LocationType.dryStorage,
        temperatureCondition: 'ambient',
        storageCapacity: 1000,
        currentUtilization: 500,
        isActive: true,
      ),
      const InventoryLocation(
        locationId: 'wh1/zone-b/aisle2/rack1',
        locationName: 'Zone B - Refrigerated',
        locationType: LocationType.coldStorage,
        temperatureCondition: 'refrigerated',
        storageCapacity: 800,
        currentUtilization: 400,
        isActive: true,
      ),
      const InventoryLocation(
        locationId: 'wh1/zone-c/aisle1/rack1',
        locationName: 'Zone C - Freezer',
        locationType: LocationType.freezer,
        temperatureCondition: 'frozen',
        storageCapacity: 500,
        currentUtilization: 200,
        isActive: true,
      ),
    ];
  }
}

/// Provider for OptimizeItemLocationsUseCase
final optimizeItemLocationsUseCaseProvider =
    Provider<OptimizeItemLocationsUseCase>((ref) {
  final inventoryRepository =
      ref.watch(inventory_provider.inventoryRepositoryProvider);
  final optimizationService = ref.watch(locationOptimizationServiceProvider);
  final locationRepository = ref.watch(warehouseLocationRepositoryProvider);

  return OptimizeItemLocationsUseCase(
    inventoryRepository: inventoryRepository,
    optimizationService: optimizationService,
    locationRepository: locationRepository,
  );
});
