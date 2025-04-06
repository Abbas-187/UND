import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/purchase_order_model.dart' as model;
import '../../data/repositories/purchase_order_repository.dart';
import '../../domain/entities/purchase_order.dart' as entity;

part 'purchase_order_provider.g.dart';

// Repository provider
final purchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  return PurchaseOrderRepository();
});

// Filter/Sort class for Purchase Orders
class PurchaseOrderFilter {

  const PurchaseOrderFilter({
    this.searchQuery,
    this.status,
    this.supplierId,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.paymentStatus,
    this.sortField,
    this.sortAscending = true,
  });
  final String? searchQuery;
  final entity.PurchaseOrderStatus? status;
  final String? supplierId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final model.PaymentStatus? paymentStatus;
  final String? sortField;
  final bool sortAscending;

  PurchaseOrderFilter copyWith({
    String? searchQuery,
    entity.PurchaseOrderStatus? status,
    String? supplierId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    model.PaymentStatus? paymentStatus,
    String? sortField,
    bool? sortAscending,
  }) {
    return PurchaseOrderFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      supplierId: supplierId ?? this.supplierId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

// Purchase order filter state provider
final poFilterProvider = StateProvider<PurchaseOrderFilter>((ref) {
  return const PurchaseOrderFilter();
});

@riverpod
class PurchaseOrderListProvider extends _$PurchaseOrderListProvider {
  @override
  Future<List<entity.PurchaseOrder>> build() async {
    final filter = ref.watch(poFilterProvider);
    final models = await _getFilteredPurchaseOrders(filter);
    return models.map((model) => model.toEntity()).toList();
  }

  Future<List<model.PurchaseOrderModel>> _getFilteredPurchaseOrders(
      PurchaseOrderFilter filter) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);

    // Start with all purchase orders
    List<model.PurchaseOrderModel> purchaseOrders = [];

    // Apply filters based on available filter options
    if (filter.status != null) {
      final snapshot = await repository
          .getPurchaseOrdersByStatus(filter.status.toString().split('.').last)
          .first;
      purchaseOrders = snapshot.docs
          .map((doc) => model.PurchaseOrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } else if (filter.supplierId != null) {
      final snapshot = await repository
          .getPurchaseOrdersBySupplier(filter.supplierId!)
          .first;
      purchaseOrders = snapshot.docs
          .map((doc) => model.PurchaseOrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } else if (filter.startDate != null && filter.endDate != null) {
      final snapshot = await repository
          .getPurchaseOrdersByDateRange(filter.startDate!, filter.endDate!)
          .first;
      purchaseOrders = snapshot.docs
          .map((doc) => model.PurchaseOrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } else {
      final snapshot = await repository.getAllPurchaseOrders().first;
      purchaseOrders = snapshot.docs
          .map((doc) => model.PurchaseOrderModel.fromMap(doc.data(), doc.id))
          .toList();
    }

    // Apply additional filters
    purchaseOrders = purchaseOrders.where((po) {
      bool match = true;

      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        match = match &&
            (po.orderNumber.contains(filter.searchQuery!) ||
                po.supplierName.contains(filter.searchQuery!));
      }

      if (filter.minAmount != null) {
        match = match && po.totalAmount >= filter.minAmount!;
      }

      if (filter.maxAmount != null) {
        match = match && po.totalAmount <= filter.maxAmount!;
      }

      if (filter.paymentStatus != null) {
        match = match && po.status == filter.paymentStatus.toString();
      }

      return match;
    }).toList();

    // Sort the results
    if (filter.sortField != null) {
      purchaseOrders.sort((a, b) {
        dynamic valueA;
        dynamic valueB;

        switch (filter.sortField) {
          case 'orderNumber':
            valueA = a.orderNumber;
            valueB = b.orderNumber;
            break;
          case 'supplierName':
            valueA = a.supplierName;
            valueB = b.supplierName;
            break;
          case 'createdAt':
            valueA = a.createdAt;
            valueB = b.createdAt;
            break;
          case 'expectedDeliveryDate':
            valueA = a.expectedDeliveryDate;
            valueB = b.expectedDeliveryDate;
            break;
          case 'totalAmount':
            valueA = a.totalAmount;
            valueB = b.totalAmount;
            break;
          default:
            valueA = a.createdAt;
            valueB = b.createdAt;
        }

        int comparison = Comparable.compare(valueA, valueB);
        return filter.sortAscending ? comparison : -comparison;
      });
    }

    return purchaseOrders;
  }

  // CRUD operations
  Future<void> createPurchaseOrder(Map<String, dynamic> poData) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.createPurchaseOrder(poData);
    ref.invalidateSelf();
  }

  Future<void> updatePurchaseOrder(
      String poId, Map<String, dynamic> poData) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.updatePurchaseOrder(poId, poData);
    ref.invalidateSelf();
  }

  Future<void> deletePurchaseOrder(String poId) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.deletePurchaseOrder(poId);
    ref.invalidateSelf();
  }

  // Workflow state management
  Future<void> updatePurchaseOrderStatus(
      String poId, entity.PurchaseOrderStatus status) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.transitionPurchaseOrderStatus(
        poId, status.toString().split('.').last);

    // Track history
    await repository.trackPurchaseOrderHistory(
        poId,
        "Status changed to ${status.toString().split('.').last}",
        'currentUserId' // This should come from authentication
        );

    ref.invalidateSelf();
  }

  // Approval workflow methods
  Future<void> requestApproval(String poId) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.requestPurchaseOrderApproval(poId);
    ref.invalidateSelf();
  }

  Future<void> approvePurchaseOrder(String poId) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.approvePurchaseOrder(poId);

    // Update inventory after approval
    await _updateInventoryOnApproval(poId);

    ref.invalidateSelf();
  }

  Future<void> rejectPurchaseOrder(String poId) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.rejectPurchaseOrder(poId);
    ref.invalidateSelf();
  }

  // Inventory system integration
  Future<void> _updateInventoryOnApproval(String poId) async {
    // This would integrate with your inventory system
    // It would typically:
    // 1. Get the PO details
    // 2. Create expected inventory items
    // 3. Update inventory levels or create pending receipts

    final repository = ref.read(purchaseOrderRepositoryProvider);
    final poDoc = await repository.getPurchaseOrder(poId);
    final po = model.PurchaseOrderModel.fromMap(poDoc.data()!, poDoc.id);

    // Here you would call the inventory system to update it
    // For example:
    // final inventoryRepo = ref.read(inventoryRepositoryProvider);
    // for (var item in po.items) {
    //   await inventoryRepo.createPendingReceipt(item);
    // }
  }

  Future<void> registerDelivery(String poId, DateTime deliveryDate) async {
    final repository = ref.read(purchaseOrderRepositoryProvider);
    await repository.updatePurchaseOrder(
        poId, {'actualDeliveryDate': deliveryDate, 'status': 'completed'});

    // Update inventory with actual received items
    // This would be implemented in coordination with your inventory system

    ref.invalidateSelf();
  }
}

// Single purchase order provider
final purchaseOrderProvider =
    FutureProvider.family<entity.PurchaseOrder, String>((ref, poId) async {
  final repository = ref.read(purchaseOrderRepositoryProvider);
  final poDoc = await repository.getPurchaseOrder(poId);
  final poModel = model.PurchaseOrderModel.fromMap(poDoc.data()!, poDoc.id);
  return poModel.toEntity();
});

// Purchase order items provider
final purchaseOrderItemsProvider =
    StreamProvider.family<List<model.PurchaseOrderItemModel>, String>(
        (ref, poId) {
  final repository = ref.read(purchaseOrderRepositoryProvider);
  return repository.getAllPurchaseOrderItems(poId).map((snapshot) => snapshot
      .docs
      .map((doc) => model.PurchaseOrderItemModel.fromMap(doc.data()))
      .toList());
});

// Purchase order history provider
final purchaseOrderHistoryProvider =
    StreamProvider.family<List<dynamic>, String>((ref, poId) {
  // This would need to be implemented in the repository
  // For now, returning an empty list
  return Stream.value([]);
});
