import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/inventory_item.dart';
import '../../models/inventory_model.dart';

/// Exceptions thrown by inventory datasource
class InventoryException implements Exception {
  InventoryException(this.message);
  final String message;
  @override
  String toString() => 'InventoryException: $message';
}

/// Remote datasource for inventory operations
abstract class InventoryRemoteDataSource {
  Future<InventoryItem> fetchInventory(String productId);
  Future<void> reserve(String productId, double quantity);
  Future<void> release(String productId, double quantity);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {

  InventoryRemoteDataSourceImpl({required this.client, required this.baseUrl});
  final http.Client client;
  final String baseUrl;

  @override
  Future<InventoryItem> fetchInventory(String productId) async {
    final uri = Uri.parse('$baseUrl/$productId');
    final response =
        await client.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return InventoryModel.fromJson(jsonMap).toEntity();
    }
    throw InventoryException(
        'Failed to fetch inventory: ${response.statusCode}');
  }

  @override
  Future<void> reserve(String productId, double quantity) async {
    final uri = Uri.parse('$baseUrl/$productId/reserve');
    final body = json.encode({'quantity': quantity});
    final response = await client.post(uri,
        headers: {'Content-Type': 'application/json'}, body: body);
    if (response.statusCode != 200) {
      throw InventoryException(
          'Failed to reserve inventory: ${response.statusCode}');
    }
  }

  @override
  Future<void> release(String productId, double quantity) async {
    final uri = Uri.parse('$baseUrl/$productId/release');
    final body = json.encode({'quantity': quantity});
    final response = await client.post(uri,
        headers: {'Content-Type': 'application/json'}, body: body);
    if (response.statusCode != 200) {
      throw InventoryException(
          'Failed to release inventory: ${response.statusCode}');
    }
  }
}
