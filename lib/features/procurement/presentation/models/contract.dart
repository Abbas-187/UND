import 'package:flutter/foundation.dart';

@immutable
class Contract {

  const Contract({
    required this.id,
    required this.title,
    required this.value,
    required this.startDate,
    required this.endDate,
  });
  final String id;
  final String title;
  final double value;
  final DateTime startDate;
  final DateTime endDate;
}
