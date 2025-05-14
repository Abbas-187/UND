import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Represents an order in the CRM system
@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required String customerId,
    required DateTime date,
    required double totalAmount,
    required String status,
  }) = _Order;

  const Order._();

  /// Creates an Order from JSON map
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
