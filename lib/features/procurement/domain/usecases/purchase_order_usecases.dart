import '../../../../core/exceptions/app_exception.dart';
import '../entities/purchase_order.dart';
import '../repositories/purchase_order_repository.dart';

class GetPurchaseOrdersUseCase {
  GetPurchaseOrdersUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<List<PurchaseOrder>> execute({
    String? supplierId,
    dynamic status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    final result = await repository.getPurchaseOrders(
      supplierId: supplierId,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
      searchQuery: searchQuery,
    );
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw result.failure!;
    }
  }
}

class GetPurchaseOrderByIdUseCase {
  GetPurchaseOrderByIdUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(String id) async {
    final result = await repository.getPurchaseOrderByIdResult(id);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw result.failure!;
    }
  }
}

class CreatePurchaseOrderUseCase {
  CreatePurchaseOrderUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    if (order.items.isEmpty) {
      throw AppException(
          message: 'Purchase order must contain at least one item');
    }
    double calculatedTotal = 0;
    for (var item in order.items) {
      calculatedTotal += item.totalPrice;
    }
    if ((calculatedTotal - order.totalAmount).abs() > 0.01) {
      throw AppException(
          message: 'Order total amount does not match sum of items');
    }
    final result = await repository.createPurchaseOrder(order);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw result.failure!;
    }
  }
}

class UpdatePurchaseOrderUseCase {
  UpdatePurchaseOrderUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(PurchaseOrder order) async {
    final result = await repository.updatePurchaseOrder(order);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw result.failure!;
    }
  }
}

class UpdatePurchaseOrderStatusUseCase {
  UpdatePurchaseOrderStatusUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<PurchaseOrder> execute(String id, dynamic status) async {
    // Get current order to validate status transition
    final currentResult = await repository.getPurchaseOrderByIdResult(id);
    if (!currentResult.isSuccess) {
      throw currentResult.failure!;
    }
    final currentOrder = currentResult.data!;
    // Business logic for status transitions
    if (!_isValidStatusTransition(currentOrder.status, status)) {
      throw AppException(
        message:
            'Invalid status transition from \\${currentOrder.status} to \\$status',
      );
    }
    final result = await repository.updatePurchaseOrderStatus(id, status);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw result.failure!;
    }
  }

  bool _isValidStatusTransition(dynamic currentStatus, dynamic newStatus) {
    // Implement business rules for valid status transitions
    // (You may want to cast to PurchaseOrderStatus if needed)
    return true; // For now, always allow
  }
}

class DeletePurchaseOrderUseCase {
  DeletePurchaseOrderUseCase(this.repository);
  final PurchaseOrderRepository repository;

  Future<void> execute(String id) async {
    final result = await repository.deletePurchaseOrder(id);
    if (!result.isSuccess) {
      throw result.failure!;
    }
  }
}
