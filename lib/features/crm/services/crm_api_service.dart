import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/customer.dart';
import '../models/interaction_log.dart';
import '../models/order.dart';

class CrmApiService {

  CrmApiService({
    required this.customers,
    required this.interactions,
    required this.orders,
  });
  final List<Customer> customers;
  final List<InteractionLog> interactions;
  final List<Order> orders;

  Router get router {
    final router = Router();

    // Get all customers
    router.get('/crm/customers', (Request req) {
      return Response.ok(jsonEncode(customers.map((c) => c.toJson()).toList()),
          headers: {'Content-Type': 'application/json'});
    });

    // Get a customer by ID
    router.get('/crm/customers/<id>', (Request req, String id) {
      final customer = customers.firstWhere((c) => c.id == id,
          orElse: () => throw StateError('Customer not found'));
      return Response.ok(jsonEncode(customer.toJson()),
          headers: {'Content-Type': 'application/json'});
    });

    // Get interactions for a customer
    router.get('/crm/customers/<id>/interactions', (Request req, String id) {
      final logs = interactions
          .where((log) => log.customerId == id)
          .map((l) => l.toJson())
          .toList();
      return Response.ok(jsonEncode(logs),
          headers: {'Content-Type': 'application/json'});
    });

    // Get orders for a customer
    router.get('/crm/customers/<id>/orders', (Request req, String id) {
      final customerOrders = orders
          .where((o) => o.customerId == id)
          .map((o) => o.toJson())
          .toList();
      return Response.ok(jsonEncode(customerOrders),
          headers: {'Content-Type': 'application/json'});
    });

    // Add more endpoints as needed (e.g., POST, PUT, DELETE)

    return router;
  }
}
