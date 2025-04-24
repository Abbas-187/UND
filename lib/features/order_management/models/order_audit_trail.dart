// OrderAuditTrail model for Order Management Module
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

@immutable
class OrderAuditTrail {
  final String id;
  final String orderId;
  final String action;
  final String userId;
  final DateTime timestamp;
  final String? justification;

  const OrderAuditTrail({
    required this.id,
    required this.orderId,
    required this.action,
    required this.userId,
    required this.timestamp,
    this.justification,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderAuditTrail &&
        other.id == id &&
        other.orderId == orderId &&
        other.action == action &&
        other.userId == userId &&
        other.timestamp == timestamp &&
        other.justification == justification;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        orderId,
        action,
        userId,
        timestamp,
        justification,
      ]);

  // Creates a copy with modified fields
  OrderAuditTrail copyWith({
    String? id,
    String? orderId,
    String? action,
    String? userId,
    DateTime? timestamp,
    String? justification,
  }) {
    return OrderAuditTrail(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      action: action ?? this.action,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      justification: justification ?? this.justification,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'action': action,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'justification': justification,
    };
  }

  factory OrderAuditTrail.fromJson(Map<String, dynamic> json) {
    return OrderAuditTrail(
      id: json['id'],
      orderId: json['orderId'],
      action: json['action'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      justification: json['justification'],
    );
  }
}
