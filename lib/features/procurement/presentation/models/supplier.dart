import 'package:flutter/foundation.dart';

import 'contract.dart';
import 'order.dart';
import 'quality_log.dart';

class SupplierMetrics {

  const SupplierMetrics({
    required this.onTimeDeliveryRate,
    required this.qualityScore,
    required this.responseTime,
  });
  final double onTimeDeliveryRate;
  final int qualityScore;
  final int responseTime;
}

@immutable
class Supplier {

  const Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.website,
    required this.metrics,
    required this.orders,
    required this.contracts,
    required this.qualityLogs,
  });
  final String id;
  final String name;
  final String category;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String website;
  final SupplierMetrics metrics;
  final List<Order> orders;
  final List<Contract> contracts;
  final List<QualityLog> qualityLogs;
}
