/// A data point in a time series.
class TimeSeriesPoint {

  /// Create a TimeSeriesPoint from a map.
  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      value: (json['value'] as num).toDouble(),
    );
  }
  /// Creates a new [TimeSeriesPoint].
  TimeSeriesPoint({
    required this.timestamp,
    required this.value,
  });

  /// The timestamp for this data point.
  final DateTime timestamp;

  /// The value at this timestamp.
  final double value;

  /// Convert to a map representation.
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'value': value,
    };
  }

  @override
  String toString() =>
      'TimeSeriesPoint(${timestamp.toIso8601String()}, $value)';
}
