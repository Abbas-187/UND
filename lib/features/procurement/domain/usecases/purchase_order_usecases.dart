import '../../../../core/exceptions/app_exception.dart';
import '../entities/purchase_order.dart';

// Repository interface
abstract class PurchaseOrderRepository {
  Future<List<PurchaseOrder>> getPurchaseOrders({
    String? supplierId,
    PurchaseOrderStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  });

  Future<PurchaseOrder> getPurchaseOrderById(String id);

  Future<PurchaseOrder> createPurchaseOrder(PurchaseOrder order);

  Future<PurchaseOrder> updatePurchaseOrder(PurchaseOrder order);

  Future<PurchaseOrder> updatePurchaseOrderStatus(
      String id, PurchaseOrderStatus status);

  Future<void> deleteOrder(String id);
}

class GetPurchaseOrdersUseCase {
  GetPurchaseOrdersUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<List<PurchaseOrder>> execute({
    String? supplierId,
    PurchaseOrderStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    try {
      return await repository.getPurchaseOrders(
        supplierId: supplierId,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw AppException(
          message: 'Failed to fetch purchase orders', details: e.toString());
    }
  }
}

class GetPurchaseOrderByIdUseCase {
  GetPurchaseOrderByIdUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(String id) async {
    try {
      return await repository.getPurchaseOrderById(id);
    } catch (e) {
      throw AppException(
          message: 'Failed to fetch purchase order', details: e.toString());
    }
  }
}

class CreatePurchaseOrderUseCase {
  CreatePurchaseOrderUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    try {
      // Validate order items
      if (order.items.isEmpty) {
        throw AppException(
            message: 'Purchase order must contain at least one item');
      }

      // Validate order total
      double calculatedTotal = 0;
      for (var item in order.items) {
        calculatedTotal += item.totalPrice;
      }

      if ((calculatedTotal - order.totalAmount).abs() > 0.01) {
        throw AppException(
            message: 'Order total amount does not match sum of items');
      }

      return await repository.createPurchaseOrder(order);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
          message: 'Failed to create purchase order', details: e.toString());
    }
  }
}

class UpdatePurchaseOrderUseCase {
  UpdatePurchaseOrderUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    try {
      return await repository.updatePurchaseOrder(order);
    } catch (e) {
      throw AppException(
          message: 'Failed to update purchase order', details: e.toString());
    }
  }
}

class UpdatePurchaseOrderStatusUseCase {
  UpdatePurchaseOrderStatusUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(String id, PurchaseOrderStatus status) async {
    try {
      // Get current order to validate status transition
      final currentOrder = await repository.getPurchaseOrderById(id);

      // Business logic for status transitions
      if (!_isValidStatusTransition(currentOrder.status, status)) {
        throw AppException(
            message:
                'Invalid status transition from ${currentOrder.status} to $status');
      }

      return await repository.updatePurchaseOrderStatus(id, status);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
          message: 'Failed to update purchase order status',
          details: e.toString());
    }
  }

  bool _isValidStatusTransition(
      PurchaseOrderStatus currentStatus, PurchaseOrderStatus newStatus) {
    // Implement business rules for valid status transitions
    switch (currentStatus) {
      case PurchaseOrderStatus.draft:
        return newStatus == PurchaseOrderStatus.pending ||
            newStatus == PurchaseOrderStatus.canceled;

      case PurchaseOrderStatus.pending:
        return newStatus == PurchaseOrderStatus.approved ||
            newStatus == PurchaseOrderStatus.declined ||
            newStatus == PurchaseOrderStatus.canceled;

      case PurchaseOrderStatus.approved:
        return newStatus == PurchaseOrderStatus.inProgress ||
            newStatus == PurchaseOrderStatus.delivered ||
            newStatus == PurchaseOrderStatus.canceled;

      case PurchaseOrderStatus.inProgress:
        return newStatus == PurchaseOrderStatus.delivered ||
            newStatus == PurchaseOrderStatus.canceled;

      case PurchaseOrderStatus.delivered:
        return newStatus == PurchaseOrderStatus.completed;

      case PurchaseOrderStatus.declined:
      case PurchaseOrderStatus.canceled:
      case PurchaseOrderStatus.completed:
        return false; // Terminal states

      default:
        return false;
    }
  }
}

class DeletePurchaseOrderUseCase {
  DeletePurchaseOrderUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<void> execute(String id) async {
    try {
      // Delete the purchase order
      await repository.deleteOrder(id);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
          message: 'Failed to delete purchase order', details: e.toString());
    }
  }
}
