// This file now exports the domain entity to avoid duplicate class definitions
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/time_series_point.dart';

export '../../domain/entities/time_series_point.dart';

/// Converts a Firestore timestamp to a TimeSeriesPoint
TimeSeriesPoint timeSeriesPointFromFirestore(Map<String, dynamic> json) {
  return TimeSeriesPoint(
    timestamp: json['timestamp'] is Timestamp
        ? (json['timestamp'] as Timestamp).toDate()
        : DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    value: (json['value'] as num).toDouble(),
  );
}

/// Converts a TimeSeriesPoint to Firestore format
Map<String, dynamic> timeSeriesPointToFirestore(TimeSeriesPoint point) {
  return {
    'timestamp': Timestamp.fromDate(point.timestamp),
    'value': point.value,
  };
}
