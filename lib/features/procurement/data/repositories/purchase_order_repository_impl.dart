import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../datasources/purchase_order_remote_datasource.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../models/purchase_order_model.dart' as models;

/// Implementation of [PurchaseOrderRepository] that works with Firestore
class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  final PurchaseOrderRemoteDataSource _dataSource;

  /// Creates a new instance with the given data source
  PurchaseOrderRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<PurchaseOrder>>> getPurchaseOrders({
    String? supplierId,
    dynamic status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    try {
      // Convert enum to string for the data source
      final statusStr =
          status != null ? status.toString().split('.').last : null;

      final orderMaps = await _dataSource.getPurchaseOrders(
        supplierId: supplierId,
        status: statusStr,
        fromDate: fromDate,
        toDate: toDate,
        searchQuery: searchQuery,
      );

      // Convert raw data to domain entities
      // This would normally use a model class like in the supplier repository
      // For brevity, we're using a simplified approach here
      final purchaseOrders = _convertMapsToPurchaseOrders(orderMaps);

      return Result.success(purchaseOrders);
    } on PurchaseOrderDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to get purchase orders', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<models.PurchaseOrderModel?> getPurchaseOrderById(String id) async {
    try {
      // For now, return null
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Result<PurchaseOrder>> getPurchaseOrderByIdResult(String id) async {
    try {
      final orderMap = await _dataSource.getPurchaseOrderById(id);
      final purchaseOrder = _convertMapToPurchaseOrder(orderMap);
      return Result.success(purchaseOrder);
    } on PurchaseOrderDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure('Purchase order not found with ID: $id'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to get purchase order with ID: $id',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<PurchaseOrder>> createPurchaseOrder(PurchaseOrder order) async {
    try {
      // Convert domain entity to data map
      final orderMap = _convertPurchaseOrderToMap(order);

      // Pass to data source
      final createdOrderMap = await _dataSource.createPurchaseOrder(orderMap);

      // Convert back to domain entity
      final createdOrder = _convertMapToPurchaseOrder(createdOrderMap);

      return Result.success(createdOrder);
    } on PurchaseOrderDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to create purchase order', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<PurchaseOrder>> updatePurchaseOrder(PurchaseOrder order) async {
    try {
      // Validate ID
      if (order.id.isEmpty) {
        return Result.failure(
          ValidationFailure('Purchase order ID is required for update'),
        );
      }

      // Convert domain entity to data map
      final orderMap = _convertPurchaseOrderToMap(order);

      // Pass to data source
      final updatedOrderMap =
          await _dataSource.updatePurchaseOrder(order.id, orderMap);

      // Convert back to domain entity
      final updatedOrder = _convertMapToPurchaseOrder(updatedOrderMap);

      return Result.success(updatedOrder);
    } on PurchaseOrderDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure('Purchase order not found with ID: ${order.id}'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to update purchase order', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<PurchaseOrder>> updatePurchaseOrderStatus(
      String id, dynamic status) async {
    try {
      // Convert enum to string for the data source
      final statusStr = status.toString().split('.').last;

      // Pass to data source
      final updatedOrderMap =
          await _dataSource.updatePurchaseOrderStatus(id, statusStr);

      // Convert back to domain entity
      final updatedOrder = _convertMapToPurchaseOrder(updatedOrderMap);

      return Result.success(updatedOrder);
    } on PurchaseOrderDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure('Purchase order not found with ID: $id'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to update purchase order status',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deletePurchaseOrder(String id) async {
    try {
      await _dataSource.deletePurchaseOrder(id);
      return Result.success(null);
    } on PurchaseOrderDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to delete purchase order', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<List<models.PurchaseOrderModel>> getAllPurchaseOrders() async {
    try {
      // For now, just return an empty list
      return [];
    } catch (e) {
      return [];
    }
  }

  // Helper method to convert a list of maps to domain entities
  List<PurchaseOrder> _convertMapsToPurchaseOrders(
      List<Map<String, dynamic>> maps) {
    return maps.map((map) => _convertMapToPurchaseOrder(map)).toList();
  }

  // Helper method to convert a map to a domain entity
  PurchaseOrder _convertMapToPurchaseOrder(Map<String, dynamic> map) {
    // In a real implementation, you would use a model class like SupplierModel
    // For this example, we'll directly convert the map to a domain entity

    // Convert item maps to domain entities
    final itemMaps =
        (map['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final items = itemMaps.map((itemMap) {
      return PurchaseOrderItem(
        id: itemMap['id'] ?? '',
        productId: itemMap['productId'] ?? '',
        productName: itemMap['productName'] ?? '',
        quantity: (itemMap['quantity'] ?? 0).toDouble(),
        unit: itemMap['unit'] ?? '',
        unitPrice: (itemMap['unitPrice'] ?? 0).toDouble(),
        totalPrice: (itemMap['totalPrice'] ?? 0).toDouble(),
        expectedDeliveryDate: itemMap['expectedDeliveryDate'] != null
            ? (itemMap['expectedDeliveryDate'] as DateTime)
            : null,
        notes: itemMap['notes'],
      );
    }).toList();

    return PurchaseOrder(
      id: map['id'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      orderDate: map['orderDate'] as DateTime? ?? DateTime.now(),
      approvalDate: map['approvalDate'] as DateTime?,
      expectedDeliveryDate:
          map['expectedDeliveryDate'] as DateTime? ?? DateTime.now(),
      status: _mapStringToPurchaseOrderStatus(map['status'] ?? 'draft'),
      items: items,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentTerms: map['paymentTerms'],
      shippingTerms: map['shippingTerms'],
      notes: map['notes'],
      approvedBy: map['approvedBy'],
      createdAt: map['createdAt'] as DateTime? ?? DateTime.now(),
      updatedAt: map['updatedAt'] as DateTime?,
    );
  }

  // Helper method to convert a domain entity to a map
  Map<String, dynamic> _convertPurchaseOrderToMap(PurchaseOrder order) {
    // Convert items to maps
    final itemMaps = order.items.map((item) {
      return {
        'id': item.id,
        'productId': item.productId,
        'productName': item.productName,
        'quantity': item.quantity,
        'unit': item.unit,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
        'expectedDeliveryDate': item.expectedDeliveryDate,
        'notes': item.notes,
      };
    }).toList();

    return {
      'orderNumber': order.orderNumber,
      'supplierId': order.supplierId,
      'supplierName': order.supplierName,
      'orderDate': order.orderDate,
      'approvalDate': order.approvalDate,
      'expectedDeliveryDate': order.expectedDeliveryDate,
      'status': order.status.toString().split('.').last,
      'items': itemMaps,
      'totalAmount': order.totalAmount,
      'paymentTerms': order.paymentTerms,
      'shippingTerms': order.shippingTerms,
      'notes': order.notes,
      'approvedBy': order.approvedBy,
    };
  }

  // Helper method to map string to PurchaseOrderStatus enum
  PurchaseOrderStatus _mapStringToPurchaseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return PurchaseOrderStatus.draft;
      case 'submitted':
        return PurchaseOrderStatus.submitted;
      case 'approved':
        return PurchaseOrderStatus.approved;
      case 'rejected':
        return PurchaseOrderStatus.rejected;
      case 'partiallyreceived':
        return PurchaseOrderStatus.partiallyReceived;
      case 'received':
        return PurchaseOrderStatus.received;
      case 'cancelled':
        return PurchaseOrderStatus.cancelled;
      case 'closed':
        return PurchaseOrderStatus.closed;
      default:
        return PurchaseOrderStatus.draft;
    }
  }
}
