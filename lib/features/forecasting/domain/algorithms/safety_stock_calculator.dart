import 'dart:math' as math;

/// Class for calculating safety stock levels based on demand variability and service level
class SafetyStockCalculator {
  /// Map of service levels to corresponding z-scores
  /// These z-scores correspond to the standard normal distribution
  static final Map<double, double> _serviceLevelZScores = {
    0.50: 0.0, // 50% service level
    0.75: 0.67, // 75% service level
    0.80: 0.84, // 80% service level
    0.85: 1.04, // 85% service level
    0.90: 1.28, // 90% service level
    0.91: 1.34, // 91% service level
    0.92: 1.41, // 92% service level
    0.93: 1.48, // 93% service level
    0.94: 1.55, // 94% service level
    0.95: 1.64, // 95% service level
    0.96: 1.75, // 96% service level
    0.97: 1.88, // 97% service level
    0.98: 2.05, // 98% service level
    0.99: 2.33, // 99% service level
    0.995: 2.58, // 99.5% service level
    0.999: 3.09, // 99.9% service level
  };

  /// Calculates the safety stock level based on historical demand data
  ///
  /// [demandHistory] - List of historical demand values (daily, weekly, etc.)
  /// [serviceLevel] - Desired service level (between 0 and 1)
  /// [leadTimeInDays] - Average lead time for replenishment in days
  /// [leadTimeVariability] - Standard deviation of lead time (optional)
  ///
  /// Returns the calculated safety stock level
  double calculateSafetyStock({
    required List<double> demandHistory,
    required double serviceLevel,
    required double leadTimeInDays,
    double? leadTimeVariability,
  }) {
    if (demandHistory.isEmpty) {
      throw ArgumentError('Demand history cannot be empty');
    }

    if (serviceLevel < 0 || serviceLevel > 1) {
      throw ArgumentError('Service level must be between 0 and 1');
    }

    if (leadTimeInDays <= 0) {
      throw ArgumentError('Lead time must be positive');
    }

    // Calculate standard deviation of demand
    final demandStdDev = _calculateStandardDeviation(demandHistory);

    // Get Z-score for the service level
    final zScore = _getZScoreForServiceLevel(serviceLevel);

    // If lead time variability is not provided, use simplified formula
    if (leadTimeVariability == null || leadTimeVariability <= 0) {
      // Safety stock = Z × σ × √L
      // where Z is the z-score, σ is the standard deviation of demand, and L is the lead time
      return zScore * demandStdDev * math.sqrt(leadTimeInDays);
    } else {
      // Calculate average daily demand
      final avgDemand =
          demandHistory.reduce((a, b) => a + b) / demandHistory.length;

      // Use more complex formula that accounts for demand and lead time variability
      // Safety stock = Z × √(L × σ_d² + D² × σ_L²)
      // where D is average daily demand and σ_L is lead time standard deviation
      final variance = leadTimeInDays * math.pow(demandStdDev, 2) +
          math.pow(avgDemand, 2) * math.pow(leadTimeVariability, 2);

      return zScore * math.sqrt(variance);
    }
  }

  /// Gets the Z-score for a given service level
  /// Z-score is the number of standard deviations from the mean
  double _getZScoreForServiceLevel(double serviceLevel) {
    // Find closest service level in the map
    if (_serviceLevelZScores.containsKey(serviceLevel)) {
      return _serviceLevelZScores[serviceLevel]!;
    }

    // Find the closest match if exact value doesn't exist
    var closestServiceLevel = 0.9; // Default
    var minDifference = 1.0;

    for (final level in _serviceLevelZScores.keys) {
      final difference = (level - serviceLevel).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestServiceLevel = level;
      }
    }

    return _serviceLevelZScores[closestServiceLevel]!;
  }

  /// Calculates the standard deviation of a list of values
  double _calculateStandardDeviation(List<double> values) {
    if (values.length <= 1) {
      return 0.0;
    }

    // Calculate mean
    final mean = values.reduce((a, b) => a + b) / values.length;

    // Calculate sum of squared differences
    final sumSquaredDiffs = values.fold(0.0, (sum, value) {
      return sum + math.pow(value - mean, 2);
    });

    // Calculate variance (using n-1 for sample standard deviation)
    final variance = sumSquaredDiffs / (values.length - 1);

    // Return standard deviation
    return math.sqrt(variance);
  }

  /// Estimates the service level that would be achieved with a given safety stock
  double estimateServiceLevel({
    required double safetyStock,
    required List<double> demandHistory,
    required double leadTimeInDays,
    double? leadTimeVariability,
  }) {
    if (demandHistory.isEmpty) {
      throw ArgumentError('Demand history cannot be empty');
    }

    if (leadTimeInDays <= 0) {
      throw ArgumentError('Lead time must be positive');
    }

    if (safetyStock < 0) {
      throw ArgumentError('Safety stock cannot be negative');
    }

    // Calculate standard deviation of demand
    final demandStdDev = _calculateStandardDeviation(demandHistory);

    // Calculate average daily demand
    final avgDemand =
        demandHistory.reduce((a, b) => a + b) / demandHistory.length;

    // Calculate Z-score based on safety stock
    double zScore;
    if (leadTimeVariability == null || leadTimeVariability <= 0) {
      // Z = SS / (σ × √L)
      zScore = safetyStock / (demandStdDev * math.sqrt(leadTimeInDays));
    } else {
      // Z = SS / √(L × σ_d² + D² × σ_L²)
      final variance = leadTimeInDays * math.pow(demandStdDev, 2) +
          math.pow(avgDemand, 2) * math.pow(leadTimeVariability, 2);
      zScore = safetyStock / math.sqrt(variance);
    }

    // Find the closest Z-score in our map
    var closestServiceLevel = 0.9; // Default
    var minDifference = double.infinity;

    for (final entry in _serviceLevelZScores.entries) {
      final difference = (entry.value - zScore).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestServiceLevel = entry.key;
      }
    }

    return closestServiceLevel;
  }
}
