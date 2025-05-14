import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/order_entity.dart';
import '../../models/order_model.dart';

/// Remote datasource for order management
abstract class OrderRemoteDataSource {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity> getOrderById(String id);
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<OrderEntity> updateOrder(OrderEntity order);
  Future<OrderEntity> cancelOrder(String id);
  Future<OrderEntity> handleProcurementComplete(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {

  OrderRemoteDataSourceImpl({required this.client, required this.baseUrl});
  final http.Client client;
  final String baseUrl;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final uri = Uri.parse(baseUrl);
    final response =
        await client.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final list = json.decode(response.body) as List<dynamic>;
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    }
    throw Exception('Failed to fetch orders: ${response.statusCode}');
  }

  @override
  Future<OrderEntity> getOrderById(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    final response =
        await client.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return OrderModel.fromJson(data).toEntity();
    }
    throw Exception('Failed to fetch order $id: ${response.statusCode}');
  }

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    final uri = Uri.parse(baseUrl);
    final model = OrderModel.fromEntity(order);
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return OrderModel.fromJson(data).toEntity();
    }
    throw Exception('Failed to create order: ${response.statusCode}');
  }

  @override
  Future<OrderEntity> updateOrder(OrderEntity order) async {
    final uri = Uri.parse('$baseUrl/${order.id}');
    final model = OrderModel.fromEntity(order);
    final response = await client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model.toJson()),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return OrderModel.fromJson(data).toEntity();
    }
    throw Exception(
        'Failed to update order ${order.id}: ${response.statusCode}');
  }

  @override
  Future<OrderEntity> cancelOrder(String id) async {
    final uri = Uri.parse('$baseUrl/$id/cancel');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return OrderModel.fromJson(data).toEntity();
    }
    throw Exception('Failed to cancel order $id: ${response.statusCode}');
  }

  @override
  Future<OrderEntity> handleProcurementComplete(String id) async {
    final uri = Uri.parse('$baseUrl/$id/procurement-complete');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return OrderModel.fromJson(data).toEntity();
    }
    throw Exception(
        'Failed to complete procurement for order $id: ${response.statusCode}');
  }
}
