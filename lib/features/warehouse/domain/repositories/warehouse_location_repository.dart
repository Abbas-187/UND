import '../../data/models/warehouse_location_model.dart';

/// Repository interface for accessing warehouse location data
abstract class WarehouseLocationRepository {
  /// Get all warehouse locations
  Future<List<WarehouseLocationModel>> getAllLocations();

  /// Get locations for a specific warehouse
  Future<List<WarehouseLocationModel>> getLocationsByWarehouse(
      String warehouseId);

  /// Get a specific location by ID
  Future<WarehouseLocationModel?> getLocationById(String locationId);

  /// Get locations by type (e.g., coldStorage, freezer)
  Future<List<WarehouseLocationModel>> getLocationsByType(String locationType);

  /// Get locations by zone
  Future<List<WarehouseLocationModel>> getLocationsByZone(String zone);

  /// Create a new warehouse location
  Future<String> createLocation(WarehouseLocationModel location);

  /// Update an existing location
  Future<void> updateLocation(WarehouseLocationModel location);

  /// Delete a location
  Future<void> deleteLocation(String locationId);

  /// Get locations suitable for a particular inventory item
  /// based on temperature requirements, item type, etc.
  Future<List<WarehouseLocationModel>> getSuitableLocationsForItem({
    required Map<String, dynamic> itemRequirements,
    String? warehouseId,
  });

  /// Calculate distance between two locations (for optimization)
  double calculateDistance(String locationId1, String locationId2);
}
