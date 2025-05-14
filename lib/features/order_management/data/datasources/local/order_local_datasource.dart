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
              'customerName': o.customerName,
              'date': o.date.toIso8601String(),
              'items': o.items,
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
        customerName: map['customerName'] as String,
        date: DateTime.parse(map['date'] as String),
        items: List<dynamic>.from(map['items'] as List),
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
