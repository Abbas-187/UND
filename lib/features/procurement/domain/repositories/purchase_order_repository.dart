import '../entities/purchase_order.dart';
import '../../../../core/exceptions/result.dart';
import '../../data/models/purchase_order_model.dart';

/// Repository interface for purchase order operations
abstract class PurchaseOrderRepository {
  /// Get all purchase orders with optional filtering
  Future<Result<List<PurchaseOrder>>> getPurchaseOrders({
    String? supplierId,
    dynamic status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  });

  /// Get a purchase order by ID
  Future<Result<PurchaseOrder>> getPurchaseOrderByIdResult(String id);

  /// Create a new purchase order
  Future<Result<PurchaseOrder>> createPurchaseOrder(PurchaseOrder order);

  /// Update an existing purchase order
  Future<Result<PurchaseOrder>> updatePurchaseOrder(PurchaseOrder order);

  /// Update purchase order status
  Future<Result<PurchaseOrder>> updatePurchaseOrderStatus(
      String id, dynamic status);

  /// Delete a purchase order
  Future<Result<void>> deletePurchaseOrder(String id);

  Future<List<PurchaseOrderModel>> getAllPurchaseOrders();

  Future<PurchaseOrderModel?> getPurchaseOrderById(String id);
}
