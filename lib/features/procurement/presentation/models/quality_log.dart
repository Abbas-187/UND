import 'package:flutter/foundation.dart';

@immutable
class QualityLog {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String issueType;
  final int severity;

  const QualityLog({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.issueType,
    required this.severity,
  });
}
