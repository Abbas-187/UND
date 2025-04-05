import 'package:flutter/foundation.dart';

@immutable
class Order {
  final String id;
  final DateTime date;
  final double amount;
  final String status;

  const Order({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
  });
}
