import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../order_management/data/models/order_model.dart';

/// Repository for managing sales data
class SalesRepository {
  SalesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String _collection = 'sales_orders';

  /// Get all sales orders with optional filters
  Future<List<OrderModel>> getSalesOrders({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? productId,
    String? orderStatus,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Apply filters if provided
      if (startDate != null) {
        query = query.where('orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('orderDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }
      if (orderStatus != null) {
        query = query.where('status', isEqualTo: orderStatus);
      }

      final snapshot = await query.get();
      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromJson({...data, 'id': doc.id});
      }).toList();

      // If productId filter is provided, filter orders that contain the product
      if (productId != null) {
        return orders.where((order) {
          return order.items.any((item) => item.productId == productId);
        }).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to get sales orders: $e');
    }
  }

  /// Get a specific sales order by ID
  Future<OrderModel> getSalesOrderById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(id).get();

      if (!docSnapshot.exists) {
        throw Exception('Sales order not found');
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      return OrderModel.fromJson({...data, 'id': docSnapshot.id});
    } catch (e) {
      throw Exception('Failed to get sales order: $e');
    }
  }

  /// Get aggregated sales data for analytics
  Future<Map<String, dynamic>> getSalesAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
    String? productId,
  }) async {
    try {
      // Get orders for the specified period
      final orders = await getSalesOrders(
        startDate: startDate,
        endDate: endDate,
        customerId: customerId,
        productId: productId,
      );

      // Calculate total sales
      double totalSales = 0;
      int orderCount = orders.length;

      // Maps for breakdowns
      Map<String, double> salesByProduct = {};
      Map<String, double> salesByCategory = {};
      Map<String, double> salesByCustomer = {};

      // Process orders
      for (final order in orders) {
        totalSales += order.totalAmount;

        // Add customer sales
        salesByCustomer.update(
          order.customerName,
          (value) => value + order.totalAmount,
          ifAbsent: () => order.totalAmount,
        );

        // Process items
        for (final item in order.items) {
          // Add product sales
          salesByProduct.update(
            item.productName,
            (value) => value + item.totalAmount,
            ifAbsent: () => item.totalAmount,
          );

          // Add category sales if available
          if (item.category != null) {
            salesByCategory.update(
              item.category!,
              (value) => value + item.totalAmount,
              ifAbsent: () => item.totalAmount,
            );
          }
        }
      }

      // Calculate average order value
      double averageOrderValue = orderCount > 0 ? totalSales / orderCount : 0;

      // Return analytics data
      return {
        'totalSales': totalSales,
        'orderCount': orderCount,
        'averageOrderValue': averageOrderValue,
        'salesByProduct': salesByProduct,
        'salesByCategory': salesByCategory,
        'salesByCustomer': salesByCustomer,
      };
    } catch (e) {
      throw Exception('Failed to get sales analytics: $e');
    }
  }
}

/// Provider for the sales repository
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository();
});
