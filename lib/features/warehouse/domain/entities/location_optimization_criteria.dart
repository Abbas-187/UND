class LocationOptimizationCriteria {
  /// Create a default criteria with equal weights
  factory LocationOptimizationCriteria.equal() {
    return const LocationOptimizationCriteria(
      pickingFrequency: 0.25,
      turnoverRate: 0.25,
      travelDistance: 0.25,
      itemCompatibility: 0.25,
    );
  }

  /// Create a criteria optimized for high-frequency picking
  factory LocationOptimizationCriteria.pickingFocus() {
    return const LocationOptimizationCriteria(
      pickingFrequency: 0.6,
      turnoverRate: 0.2,
      travelDistance: 0.15,
      itemCompatibility: 0.05,
    );
  }

  /// Create a criteria optimized for FEFO/expiration handling
  factory LocationOptimizationCriteria.expirationFocus() {
    return const LocationOptimizationCriteria(
      pickingFrequency: 0.2,
      turnoverRate: 0.5,
      travelDistance: 0.2,
      itemCompatibility: 0.1,
    );
  }

  /// Create a criteria optimized for temperature-sensitive items
  factory LocationOptimizationCriteria.temperatureFocus() {
    return const LocationOptimizationCriteria(
      pickingFrequency: 0.2,
      turnoverRate: 0.2,
      travelDistance: 0.1,
      itemCompatibility: 0.5,
    );
  }
  const LocationOptimizationCriteria({
    this.pickingFrequency = 0.4,
    this.turnoverRate = 0.3,
    this.travelDistance = 0.2,
    this.itemCompatibility = 0.1,
  });

  /// Weighting for picking frequency (how often an item is picked)
  final double pickingFrequency;

  /// Weighting for turnover rate (how fast inventory rotates)
  final double turnoverRate;

  /// Weighting for travel distance (from receiving/shipping areas)
  final double travelDistance;

  /// Weighting for item compatibility (temperature, handling requirements)
  final double itemCompatibility;

  /// Total of all weights should be 1.0
  double get totalWeight =>
      pickingFrequency + turnoverRate + travelDistance + itemCompatibility;
}
