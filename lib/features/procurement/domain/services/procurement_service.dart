import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/services/supplier_integration_service.dart';
import '../../../inventory/domain/usecases/process_goods_receipt_usecase.dart';
import '../../../inventory/domain/usecases/process_return_to_supplier_usecase.dart';
import '../../data/models/purchase_order_model.dart';
import '../entities/purchase_order.dart' as entity;
import '../integration/procurement_inventory_integration.dart';
import '../repositories/purchase_order_repository.dart';
import '../usecases/purchase_order_usecases.dart';

/// Comprehensive procurement service that handles the full procurement lifecycle
/// with deep inventory integration
class ProcurementService {
  const ProcurementService(this._ref);

  final Ref _ref;

  /// Create a purchase order from reorder recommendations
  Future<PurchaseOrderModel> createPurchaseOrderFromRecommendations({
    required List<ReorderRecommendation> recommendations,
    required String requestedBy,
    String? reasonForRequest,
  }) async {
    if (recommendations.isEmpty) {
      throw Exception('No recommendations provided');
    }

    // Group recommendations by supplier
    final supplierGroups = <String, List<ReorderRecommendation>>{};
    for (final rec in recommendations) {
      final supplierId = rec.recommendedSupplier.supplierId;
      supplierGroups.putIfAbsent(supplierId, () => []).add(rec);
    }

    if (supplierGroups.length > 1) {
      throw Exception('All recommendations must be for the same supplier');
    }

    final supplier = recommendations.first.recommendedSupplier;
    final items = recommendations
        .map((rec) => entity.PurchaseOrderItem(
              id: 'item-${DateTime.now().millisecondsSinceEpoch}-${rec.itemId}',
              itemId: rec.itemId,
              itemName: rec.itemName,
              quantity: rec.recommendedQuantity,
              unit: 'PCS', // Default unit, should be retrieved from item master
              unitPrice: rec.recommendedSupplier.unitPrice ?? 0,
              totalPrice: rec.recommendedQuantity *
                  (rec.recommendedSupplier.unitPrice ?? 0),
              requiredByDate: rec.estimatedDeliveryDate,
              notes: rec.reason,
            ))
        .toList();

    final totalAmount =
        items.fold<double>(0, (sum, item) => sum + item.totalPrice);

    final purchaseOrder = entity.PurchaseOrder(
      id: 'po-${DateTime.now().millisecondsSinceEpoch}',
      procurementPlanId: 'auto-generated',
      poNumber: 'PO-${DateTime.now().millisecondsSinceEpoch}',
      requestDate: DateTime.now(),
      requestedBy: requestedBy,
      supplierId: supplier.supplierId,
      supplierName: supplier.supplierName,
      status: entity.PurchaseOrderStatus.draft,
      items: items,
      totalAmount: totalAmount,
      reasonForRequest: reasonForRequest ??
          'Auto-generated from inventory reorder recommendations',
      intendedUse: 'Inventory replenishment',
      quantityJustification: 'Based on reorder points and supplier lead times',
      supportingDocuments: [],
    );

    final createUseCase = _ref.read(createPurchaseOrderUseCaseProvider);
    final createdOrder = await createUseCase.execute(purchaseOrder);

    // Convert entity back to model for return
    return PurchaseOrderModel.fromEntity(createdOrder);
  }

  /// Process goods receipt for a purchase order
  Future<GoodsReceiptResult> receiveGoods({
    required String purchaseOrderId,
    required String receivedBy,
    required Map<String, double> receivedQuantities,
    Map<String, String>? batchNumbers,
    Map<String, DateTime>? expirationDates,
    String? deliveryNoteReference,
    String? notes,
  }) async {
    final integration = ProcurementInventoryIntegration(_ref);

    return await integration.processGoodsReceipt(
      purchaseOrderId: purchaseOrderId,
      receivedBy: receivedBy,
      receivedQuantities: receivedQuantities,
      batchNumbers: batchNumbers,
      expirationDates: expirationDates,
      deliveryNoteReference: deliveryNoteReference,
      notes: notes,
    );
  }

  /// Process return to supplier
  Future<ReturnToSupplierResult> returnToSupplier({
    required String returnId,
    required String supplierId,
    required String supplierName,
    required String returnedBy,
    required Map<String, double> returnedQuantities,
    required Map<String, String> returnReasons,
    Map<String, String>? batchNumbers,
    String? originalPoNumber,
    String? notes,
  }) async {
    final integration = ProcurementInventoryIntegration(_ref);

    return await integration.processReturnToSupplier(
      returnId: returnId,
      supplierId: supplierId,
      supplierName: supplierName,
      returnedBy: returnedBy,
      returnedQuantities: returnedQuantities,
      returnReasons: returnReasons,
      batchNumbers: batchNumbers,
      originalPoNumber: originalPoNumber,
      notes: notes,
    );
  }

  /// Get reorder recommendations for procurement planning
  Future<List<ReorderRecommendation>> getReorderRecommendations({
    String? warehouseId,
    List<String>? itemIds,
    String? supplierId,
  }) async {
    final integration = ProcurementInventoryIntegration(_ref);
    final recommendations = await integration.getReorderRecommendations(
      warehouseId: warehouseId,
      itemIds: itemIds,
    );

    // Filter by supplier if specified
    if (supplierId != null) {
      return recommendations
          .where(
            (rec) => rec.recommendedSupplier.supplierId == supplierId,
          )
          .toList();
    }

    return recommendations;
  }

  /// Generate procurement plan based on inventory needs
  Future<Map<String, dynamic>> generateProcurementPlan({
    int planningHorizonDays = 90,
    String? warehouseId,
    List<String>? categoryIds,
  }) async {
    final recommendations = await getReorderRecommendations(
      warehouseId: warehouseId,
    );

    // Group by supplier and urgency
    final supplierGroups = <String, List<ReorderRecommendation>>{};
    final urgencyGroups = <String, List<ReorderRecommendation>>{
      'CRITICAL': [],
      'HIGH': [],
      'NORMAL': [],
      'LOW': [],
    };

    for (final rec in recommendations) {
      final supplierId = rec.recommendedSupplier.supplierId;
      supplierGroups.putIfAbsent(supplierId, () => []).add(rec);
      urgencyGroups[rec.urgencyLevel]?.add(rec);
    }

    // Calculate totals
    final totalEstimatedCost = recommendations.fold<double>(
      0,
      (sum, rec) => sum + rec.estimatedCost,
    );

    final totalItems = recommendations.length;

    // Generate supplier summaries
    final supplierSummaries = supplierGroups.entries.map((entry) {
      final supplierId = entry.key;
      final supplierRecs = entry.value;
      final supplier = supplierRecs.first.recommendedSupplier;

      return {
        'supplierId': supplierId,
        'supplierName': supplier.supplierName,
        'itemCount': supplierRecs.length,
        'totalEstimatedCost': supplierRecs.fold<double>(
          0,
          (sum, rec) => sum + rec.estimatedCost,
        ),
        'averageLeadTime': supplier.leadTimeDays,
        'recommendations': supplierRecs
            .map((rec) => {
                  'itemId': rec.itemId,
                  'itemName': rec.itemName,
                  'currentQuantity': rec.currentQuantity,
                  'recommendedQuantity': rec.recommendedQuantity,
                  'urgencyLevel': rec.urgencyLevel,
                  'estimatedCost': rec.estimatedCost,
                  'estimatedDeliveryDate':
                      rec.estimatedDeliveryDate.toIso8601String(),
                  'reason': rec.reason,
                })
            .toList(),
      };
    }).toList();

    return {
      'planGeneratedAt': DateTime.now().toIso8601String(),
      'planningHorizonDays': planningHorizonDays,
      'warehouseId': warehouseId,
      'summary': {
        'totalItems': totalItems,
        'totalEstimatedCost': totalEstimatedCost,
        'supplierCount': supplierGroups.length,
        'urgencyBreakdown': {
          'critical': urgencyGroups['CRITICAL']!.length,
          'high': urgencyGroups['HIGH']!.length,
          'normal': urgencyGroups['NORMAL']!.length,
          'low': urgencyGroups['LOW']!.length,
        },
      },
      'supplierSummaries': supplierSummaries,
      'urgencyGroups': urgencyGroups.map((key, value) => MapEntry(
            key.toLowerCase(),
            value
                .map((rec) => {
                      'itemId': rec.itemId,
                      'itemName': rec.itemName,
                      'supplierName': rec.recommendedSupplier.supplierName,
                      'estimatedDeliveryDate':
                          rec.estimatedDeliveryDate.toIso8601String(),
                      'estimatedCost': rec.estimatedCost,
                    })
                .toList(),
          )),
    };
  }

  /// Update supplier information for better procurement planning
  Future<void> updateSupplierInfo(
      String itemId, List<SupplierInfo> suppliers) async {
    final supplierService = _ref.read(supplierIntegrationServiceProvider);
    await supplierService.updateSupplierInfo(itemId, suppliers);
  }

  /// Get supplier performance metrics
  Future<Map<String, dynamic>> getSupplierPerformanceMetrics(
      String supplierId) async {
    final purchaseOrderRepository = _ref.read(purchaseOrderRepositoryProvider);

    // Get all purchase orders for this supplier
    final orders = await purchaseOrderRepository.getPurchaseOrders(
      supplierId: supplierId,
    );

    if (orders.isFailure) {
      throw Exception('Failed to retrieve purchase orders: ${orders.failure}');
    }

    final supplierOrders = orders.data!;

    if (supplierOrders.isEmpty) {
      return {
        'supplierId': supplierId,
        'totalOrders': 0,
        'message': 'No orders found for this supplier',
      };
    }

    // Calculate metrics
    final totalOrders = supplierOrders.length;
    final completedOrders = supplierOrders
        .where(
          (order) => order.status == entity.PurchaseOrderStatus.completed,
        )
        .length;

    final totalValue = supplierOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    final averageOrderValue = totalValue / totalOrders;

    // Calculate delivery performance (simplified)
    // Note: Using deliveryDate as the actual delivery date
    final onTimeDeliveries = supplierOrders.where((order) {
      return order.deliveryDate != null &&
          order.deliveryDate!.isBefore(
              DateTime.now().add(const Duration(days: 30))); // Simplified check
    }).length;

    final deliveryPerformance =
        totalOrders > 0 ? onTimeDeliveries / totalOrders : 0.0;

    return {
      'supplierId': supplierId,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'completionRate': totalOrders > 0 ? completedOrders / totalOrders : 0.0,
      'totalValue': totalValue,
      'averageOrderValue': averageOrderValue,
      'deliveryPerformance': deliveryPerformance,
      'lastOrderDate': supplierOrders.isNotEmpty
          ? supplierOrders
              .map((o) => o.requestDate)
              .reduce(
                (a, b) => a.isAfter(b) ? a : b,
              )
              .toIso8601String()
          : null,
    };
  }
}

/// Provider for ProcurementService
final procurementServiceProvider = Provider<ProcurementService>((ref) {
  return ProcurementService(ref);
});

/// Provider for CreatePurchaseOrderUseCase
final createPurchaseOrderUseCaseProvider =
    Provider<CreatePurchaseOrderUseCase>((ref) {
  return CreatePurchaseOrderUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

/// Provider for PurchaseOrderRepository
final purchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  throw UnimplementedError('PurchaseOrderRepository provider not implemented');
});
