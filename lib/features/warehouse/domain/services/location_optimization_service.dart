import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/data/models/location_model.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../entities/location_optimization_criteria.dart';

/// Service that optimizes warehouse location assignments based on item characteristics
class LocationOptimizationService {
  LocationOptimizationService(this._ref);
  final Ref _ref;

  /// Calculate optimal locations for a set of inventory items
  /// Returns a Map with itemId as key and recommended locationId as value
  Future<Map<String, String>> optimizeLocations({
    required List<InventoryItem> items,
    required List<LocationModel> availableLocations,
    LocationOptimizationCriteria? criteria,
  }) async {
    // Use default criteria if none provided
    final optimizationCriteria = criteria ?? LocationOptimizationCriteria();

    // Result map: itemId -> recommended locationId
    final Map<String, String> recommendations = {};

    // Filter for active inventory locations only
    final validLocations =
        availableLocations.whereType<InventoryLocation>().toList();

    // Calculate location scores for each item
    for (final item in items) {
      final locationScores = <String, double>{};

      for (final location in validLocations) {
        // Skip inactive locations
        if (!location.isActive) continue;

        // Calculate location score based on multiple factors
        final score = _calculateLocationScore(
          item: item,
          location: location,
          criteria: optimizationCriteria,
        );

        locationScores[location.locationId] = score;
      }

      // Find location with best score
      if (locationScores.isNotEmpty) {
        final bestLocation = locationScores.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        recommendations[item.id] = bestLocation;
      }
    }

    return recommendations;
  }

  /// Calculate score for a specific item-location pair
  double _calculateLocationScore({
    required InventoryItem item,
    required InventoryLocation location,
    required LocationOptimizationCriteria criteria,
  }) {
    // Initialize base score
    double score = 0.0;

    // Get picking frequency from item usage history
    final pickingFrequency = _getPickingFrequencyScore(item.id);
    score += pickingFrequency * criteria.pickingFrequency;

    // Calculate turnover rate score
    final turnoverRate = _getTurnoverRateScore(item);
    score += turnoverRate * criteria.turnoverRate;

    // Calculate travel distance score
    final distanceScore = _getDistanceScore(item, location);
    score += distanceScore * criteria.travelDistance;

    // Calculate compatibility score
    final compatibilityScore = _getCompatibilityScore(item, location);
    score += compatibilityScore * criteria.itemCompatibility;

    return score;
  }

  /// Calculate picking frequency score (0-1) based on historical data
  double _getPickingFrequencyScore(String itemId) {
    // TODO: Implement real picking frequency calculation from transaction history
    // For now, return a random value between 0.0 and 1.0 for simulation
    return 0.7; // Placeholder
  }

  /// Calculate turnover rate score based on inventory movement
  double _getTurnoverRateScore(InventoryItem item) {
    // Use reorder point as a proxy for turnover (higher reorder point suggests higher turnover)
    // Normalize to a 0-1 scale
    final reorderValue = item.reorderPoint;

    // Simple normalization assuming max reorder point is around 1000
    // In a real implementation, this would use actual data ranges
    return (reorderValue / 1000).clamp(0.0, 1.0);
  }

  /// Calculate distance score (closer is better, so 1 - normalized distance)
  double _getDistanceScore(InventoryItem item, InventoryLocation location) {
    // For perishable items, score based on proximity to shipping area
    final isPerishable = item.expiryDate != null;

    // Parse location data to estimate distance
    // This is a simplification - real implementation would use actual warehouse layout
    final locationParts = location.locationId.split('/');

    // Assume closer to the start of the location code is closer to receiving/shipping
    // In real implementation, use actual distance measurements
    double rawDistance =
        locationParts.length > 1 ? locationParts[1].length / 10 : 0.5;

    // For perishable items, prioritize locations closer to shipping
    if (isPerishable) {
      rawDistance =
          rawDistance * 0.8; // Reduce distance score for perishable items
    }

    // Normalize and invert (closer is better)
    return (1.0 - rawDistance.clamp(0.0, 1.0));
  }

  /// Calculate compatibility score based on storage requirements
  double _getCompatibilityScore(
      InventoryItem item, InventoryLocation location) {
    // Check if item has temperature requirements
    final needsRefrigeration =
        item.additionalAttributes?['needsRefrigeration'] as bool? ?? false;
    final isFrozen = item.additionalAttributes?['isFrozen'] as bool? ?? false;

    // Check if location meets temperature requirements
    final isColdStorage = location.locationType == LocationType.coldStorage;
    final isFreezer = location.locationType == LocationType.freezer;

    // Score compatibility
    if (isFrozen && isFreezer) {
      return 1.0; // Perfect match for frozen items
    } else if (needsRefrigeration && isColdStorage) {
      return 1.0; // Perfect match for refrigerated items
    } else if (!needsRefrigeration &&
        !isFrozen &&
        location.locationType == LocationType.dryStorage) {
      return 1.0; // Perfect match for ambient items
    } else if (isFrozen && isColdStorage) {
      return 0.5; // Suboptimal but possible
    } else if (needsRefrigeration && isFreezer) {
      return 0.5; // Suboptimal but possible
    } else {
      return 0.0; // Incompatible
    }
  }
}

/// Provider for LocationOptimizationService
final locationOptimizationServiceProvider =
    Provider<LocationOptimizationService>((ref) {
  return LocationOptimizationService(ref);
});
