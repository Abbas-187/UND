import 'package:flutter/foundation.dart';

/// Immutable class for supplier performance metrics
class SupplierPerformanceMetrics {
  /// Quality score of the supplier (0-5 scale)
  final double qualityScore;

  /// Delivery reliability score of the supplier (0-5 scale)
  final double deliveryScore;

  /// Price/value score of the supplier (0-5 scale)
  final double priceScore;

  /// Overall performance score of the supplier (0-5 scale)
  final double overallScore;

  /// Creates a new immutable [SupplierPerformanceMetrics] instance
  const SupplierPerformanceMetrics({
    required this.qualityScore,
    required this.deliveryScore,
    required this.priceScore,
    required this.overallScore,
  });

  /// Creates a copy of this [SupplierPerformanceMetrics] instance with the given fields replaced
  SupplierPerformanceMetrics copyWith({
    double? qualityScore,
    double? deliveryScore,
    double? priceScore,
    double? overallScore,
  }) {
    return SupplierPerformanceMetrics(
      qualityScore: qualityScore ?? this.qualityScore,
      deliveryScore: deliveryScore ?? this.deliveryScore,
      priceScore: priceScore ?? this.priceScore,
      overallScore: overallScore ?? this.overallScore,
    );
  }

  /// Converts this [SupplierPerformanceMetrics] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'quality_score': qualityScore,
      'delivery_score': deliveryScore,
      'price_score': priceScore,
      'overall_score': overallScore,
    };
  }

  /// Creates a [SupplierPerformanceMetrics] instance from a JSON map
  factory SupplierPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return SupplierPerformanceMetrics(
      qualityScore: (json['quality_score'] ?? 0.0).toDouble(),
      deliveryScore: (json['delivery_score'] ?? 0.0).toDouble(),
      priceScore: (json['price_score'] ?? 0.0).toDouble(),
      overallScore: (json['overall_score'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'SupplierPerformanceMetrics(qualityScore: $qualityScore, deliveryScore: $deliveryScore, priceScore: $priceScore, overallScore: $overallScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SupplierPerformanceMetrics &&
        other.qualityScore == qualityScore &&
        other.deliveryScore == deliveryScore &&
        other.priceScore == priceScore &&
        other.overallScore == overallScore;
  }

  @override
  int get hashCode {
    return Object.hash(
      qualityScore,
      deliveryScore,
      priceScore,
      overallScore,
    );
  }
}
