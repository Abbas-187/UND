import 'package:und_app/core/exceptions/app_exception.dart';
import 'package:und_app/features/procurement/domain/entities/purchase_order.dart';

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
  final PurchaseOrderRepository repository;

  GetPurchaseOrdersUseCase(this.repository);

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
      throw AppException('Failed to fetch purchase orders',
          details: e.toString());
    }
  }
}

class GetPurchaseOrderByIdUseCase {
  final PurchaseOrderRepository repository;

  GetPurchaseOrderByIdUseCase(this.repository);

  Future<PurchaseOrder> execute(String id) async {
    try {
      return await repository.getPurchaseOrderById(id);
    } catch (e) {
      throw AppException('Failed to fetch purchase order',
          details: e.toString());
    }
  }
}

class CreatePurchaseOrderUseCase {
  final PurchaseOrderRepository repository;

  CreatePurchaseOrderUseCase(this.repository);

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    try {
      // Validate order items
      if (order.items.isEmpty) {
        throw AppException('Purchase order must contain at least one item');
      }

      // Validate order total
      double calculatedTotal = 0;
      for (var item in order.items) {
        calculatedTotal += item.totalPrice;
      }

      if ((calculatedTotal - order.totalAmount).abs() > 0.01) {
        throw AppException('Order total amount does not match sum of items');
      }

      return await repository.createPurchaseOrder(order);
    } catch (e) {
      if (e is AppException) {
        throw e;
      }
      throw AppException('Failed to create purchase order',
          details: e.toString());
    }
  }
}

class UpdatePurchaseOrderUseCase {
  final PurchaseOrderRepository repository;

  UpdatePurchaseOrderUseCase(this.repository);

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    try {
      return await repository.updatePurchaseOrder(order);
    } catch (e) {
      throw AppException('Failed to update purchase order',
          details: e.toString());
    }
  }
}

class UpdatePurchaseOrderStatusUseCase {
  final PurchaseOrderRepository repository;

  UpdatePurchaseOrderStatusUseCase(this.repository);

  Future<PurchaseOrder> execute(String id, PurchaseOrderStatus status) async {
    try {
      // Get current order to validate status transition
      final currentOrder = await repository.getPurchaseOrderById(id);

      // Business logic for status transitions
      if (!_isValidStatusTransition(currentOrder.status, status)) {
        throw AppException(
            'Invalid status transition from ${currentOrder.status} to $status');
      }

      return await repository.updatePurchaseOrderStatus(id, status);
    } catch (e) {
      if (e is AppException) {
        throw e;
      }
      throw AppException('Failed to update purchase order status',
          details: e.toString());
    }
  }

  bool _isValidStatusTransition(
      PurchaseOrderStatus currentStatus, PurchaseOrderStatus newStatus) {
    // Implement business rules for valid status transitions
    switch (currentStatus) {
      case PurchaseOrderStatus.draft:
        return newStatus == PurchaseOrderStatus.submitted ||
            newStatus == PurchaseOrderStatus.cancelled;

      case PurchaseOrderStatus.submitted:
        return newStatus == PurchaseOrderStatus.approved ||
            newStatus == PurchaseOrderStatus.rejected ||
            newStatus == PurchaseOrderStatus.cancelled;

      case PurchaseOrderStatus.approved:
        return newStatus == PurchaseOrderStatus.partiallyReceived ||
            newStatus == PurchaseOrderStatus.received ||
            newStatus == PurchaseOrderStatus.cancelled;

      case PurchaseOrderStatus.partiallyReceived:
        return newStatus == PurchaseOrderStatus.received ||
            newStatus == PurchaseOrderStatus.cancelled;

      case PurchaseOrderStatus.received:
        return newStatus == PurchaseOrderStatus.closed;

      case PurchaseOrderStatus.rejected:
      case PurchaseOrderStatus.cancelled:
      case PurchaseOrderStatus.closed:
        return false; // Terminal states

      default:
        return false;
    }
  }
}

class DeletePurchaseOrderUseCase {
  final PurchaseOrderRepository repository;

  DeletePurchaseOrderUseCase(this.repository);

  Future<void> execute(String id) async {
    try {
      // Delete the purchase order
      await repository.deleteOrder(id);
    } catch (e) {
      if (e is AppException) {
        throw e;
      }
      throw AppException('Failed to delete purchase order',
          details: e.toString());
    }
  }
}
