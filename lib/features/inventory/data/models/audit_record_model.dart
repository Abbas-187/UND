import 'package:meta/meta.dart';

@immutable
class AuditRecord {
  factory AuditRecord.fromJson(Map<String, dynamic> json) {
    return AuditRecord(
      recordId: json['recordId'] as String,
      movementId: json['movementId'] as String,
      movementType: json['movementType'] as String,
      employeeId: json['employeeId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: Map<String, dynamic>.from(json['details'] as Map),
    );
  }

  const AuditRecord({
    required this.recordId,
    required this.movementId,
    required this.movementType,
    required this.employeeId,
    required this.timestamp,
    required this.details,
  });

  final String recordId;
  final String movementId;
  final String movementType;
  final String employeeId;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  Map<String, dynamic> toJson() => {
        'recordId': recordId,
        'movementId': movementId,
        'movementType': movementType,
        'employeeId': employeeId,
        'timestamp': timestamp.toIso8601String(),
        'details': details,
      };
}
