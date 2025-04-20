import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../datasources/purchase_order_remote_datasource.dart';
import '../models/purchase_order_model.dart' as models;

/// Implementation of [PurchaseOrderRepository] that works with Firestore
class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  /// Creates a new instance with the given data source
  PurchaseOrderRepositoryImpl(this._dataSource);
  final PurchaseOrderRemoteDataSource _dataSource;

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
      final statusStr = status?.toString().split('.').last;

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
        itemId: itemMap['itemId'] ?? '',
        itemName: itemMap['itemName'] ?? '',
        quantity: (itemMap['quantity'] ?? 0).toDouble(),
        unit: itemMap['unit'] ?? '',
        unitPrice: (itemMap['unitPrice'] ?? 0).toDouble(),
        totalPrice: (itemMap['totalPrice'] ?? 0).toDouble(),
        requiredByDate: itemMap['requiredByDate'] != null
            ? (itemMap['requiredByDate'] as DateTime)
            : DateTime.now(),
        notes: itemMap['notes'],
      );
    }).toList();

    // Create empty supporting documents list
    final supportingDocuments = <SupportingDocument>[];

    return PurchaseOrder(
      id: map['id'] ?? '',
      procurementPlanId: map['procurementPlanId'] ?? '',
      poNumber: map['poNumber'] ?? '',
      requestDate: map['requestDate'] as DateTime? ?? DateTime.now(),
      requestedBy: map['requestedBy'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      status: _mapStringToPurchaseOrderStatus(map['status'] ?? 'draft'),
      items: items,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      reasonForRequest: map['reasonForRequest'] ?? '',
      intendedUse: map['intendedUse'] ?? '',
      quantityJustification: map['quantityJustification'] ?? '',
      supportingDocuments: supportingDocuments,
      approvalDate: map['approvalDate'] as DateTime?,
      approvedBy: map['approvedBy'],
      deliveryDate: map['deliveryDate'] as DateTime?,
      completionDate: map['completionDate'] as DateTime?,
    );
  }

  // Helper method to convert a domain entity to a map
  Map<String, dynamic> _convertPurchaseOrderToMap(PurchaseOrder order) {
    // Convert items to maps
    final itemMaps = order.items.map((item) {
      return {
        'id': item.id,
        'itemId': item.itemId,
        'itemName': item.itemName,
        'quantity': item.quantity,
        'unit': item.unit,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
        'requiredByDate': item.requiredByDate,
        'notes': item.notes,
      };
    }).toList();

    return {
      'procurementPlanId': order.procurementPlanId,
      'poNumber': order.poNumber,
      'requestDate': order.requestDate,
      'requestedBy': order.requestedBy,
      'supplierId': order.supplierId,
      'supplierName': order.supplierName,
      'status': order.status.toString().split('.').last,
      'items': itemMaps,
      'totalAmount': order.totalAmount,
      'reasonForRequest': order.reasonForRequest,
      'intendedUse': order.intendedUse,
      'quantityJustification': order.quantityJustification,
      'supportingDocuments': order.supportingDocuments
          .map((doc) => {
                'id': doc.id,
                'name': doc.name,
                'type': doc.type,
                'url': doc.url,
                'uploadDate': doc.uploadDate,
              })
          .toList(),
      'approvalDate': order.approvalDate,
      'approvedBy': order.approvedBy,
      'deliveryDate': order.deliveryDate,
      'completionDate': order.completionDate,
    };
  }

  // Helper method to map string to PurchaseOrderStatus enum
  PurchaseOrderStatus _mapStringToPurchaseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return PurchaseOrderStatus.draft;
      case 'pending':
        return PurchaseOrderStatus.pending;
      case 'approved':
        return PurchaseOrderStatus.approved;
      case 'declined':
        return PurchaseOrderStatus.declined;
      case 'inprogress':
        return PurchaseOrderStatus.inProgress;
      case 'delivered':
        return PurchaseOrderStatus.delivered;
      case 'completed':
        return PurchaseOrderStatus.completed;
      case 'canceled':
        return PurchaseOrderStatus.canceled;
      default:
        return PurchaseOrderStatus.draft;
    }
  }
}
