import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/order_entity.dart';

abstract class OrderLocalDataSource {
  Future<void> cacheOrders(List<OrderEntity> orders);
  Future<List<OrderEntity>> getCachedOrders();
  Future<void> cacheOrder(OrderEntity order);
  Future<OrderEntity?> getCachedOrderById(String orderId);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  OrderLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  static const _ordersKey = 'cached_orders';

  @override
  Future<void> cacheOrders(List<OrderEntity> orders) async {
    final jsonList = orders
        .map((o) => json.encode({
              'id': o.id,
              'orderNumber': o.orderNumber,
              'orderDate': o.orderDate.toIso8601String(),
              'customerId': o.customerId,
              'customerName': o.customerName,
              'billingAddress': o.billingAddress,
              'shippingAddress': o.shippingAddress,
              'status': o.status,
              'items': o.items,
              'subtotal': o.subtotal,
              'taxAmount': o.taxAmount,
              'shippingCost': o.shippingCost,
              'totalAmount': o.totalAmount,
              'notes': o.notes,
              'createdByUserId': o.createdByUserId,
              'requiredDeliveryDate': o.requiredDeliveryDate?.toIso8601String(),
              'actualShipmentDate': o.actualShipmentDate?.toIso8601String(),
              'actualDeliveryDate': o.actualDeliveryDate?.toIso8601String(),
              'shippingMethod': o.shippingMethod,
              'trackingNumber': o.trackingNumber,
              'paymentMethod': o.paymentMethod,
              'paymentStatus': o.paymentStatus,
              'statusHistory': o.statusHistory,
            }))
        .toList();
    await sharedPreferences.setStringList(_ordersKey, jsonList);
  }

  @override
  Future<List<OrderEntity>> getCachedOrders() async {
    final list = sharedPreferences.getStringList(_ordersKey);
    if (list == null) return [];
    return list.map((str) {
      final map = json.decode(str) as Map<String, dynamic>;
      return OrderEntity(
        id: map['id'] as String,
        orderNumber: map['orderNumber'] as String,
        orderDate: DateTime.parse(map['orderDate'] as String),
        customerId: map['customerId'] as String,
        customerName: map['customerName'] as String,
        billingAddress: map['billingAddress'],
        shippingAddress: map['shippingAddress'],
        status: map['status'],
        items: List<dynamic>.from(map['items'] as List),
        subtotal: (map['subtotal'] as num).toDouble(),
        taxAmount: (map['taxAmount'] as num).toDouble(),
        shippingCost: (map['shippingCost'] as num).toDouble(),
        totalAmount: (map['totalAmount'] as num).toDouble(),
        notes: map['notes'],
        createdByUserId: map['createdByUserId'],
        requiredDeliveryDate: map['requiredDeliveryDate'] != null
            ? DateTime.tryParse(map['requiredDeliveryDate'])
            : null,
        actualShipmentDate: map['actualShipmentDate'] != null
            ? DateTime.tryParse(map['actualShipmentDate'])
            : null,
        actualDeliveryDate: map['actualDeliveryDate'] != null
            ? DateTime.tryParse(map['actualDeliveryDate'])
            : null,
        shippingMethod: map['shippingMethod'],
        trackingNumber: map['trackingNumber'],
        paymentMethod: map['paymentMethod'],
        paymentStatus: map['paymentStatus'],
        statusHistory: map['statusHistory'],
      );
    }).toList();
  }

  @override
  Future<void> cacheOrder(OrderEntity order) async {
    final orders = await getCachedOrders();
    final updated = orders.where((o) => o.id != order.id).toList();
    updated.add(order);
    await cacheOrders(updated);
  }

  @override
  Future<OrderEntity?> getCachedOrderById(String orderId) async {
    final orders = await getCachedOrders();
    for (final o in orders) {
      if (o.id == orderId) return o;
    }
    return null;
  }
}
