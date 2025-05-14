import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// Customer model representing a customer in the CRM system
@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String address,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> tags,
  }) = _Customer;

  const Customer._();

  /// Creates a Customer from JSON map
  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

extension CustomerDummy on Customer {
  static Customer dummy() {
    return Customer(
      id: 'dummy',
      name: 'Dummy Customer',
      email: 'dummy@example.com',
      phone: '000-000-0000',
      address: '123 Dummy St',
      createdAt: DateTime(2000, 1, 1),
      updatedAt: null,
      tags: const [],
    );
  }
}
