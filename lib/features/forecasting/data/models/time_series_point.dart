import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSeriesPoint {
  TimeSeriesPoint({
    required this.timestamp,
    required this.value,
  });

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      value: json['value'].toDouble(),
    );
  }
  final DateTime timestamp;
  final double value;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'value': value,
    };
  }
}
