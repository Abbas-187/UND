import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_mapper.dart';
import '../../data/models/order_model.dart';
import '../../domain/providers/order_usecase_providers.dart';
import '../../domain/entities/order_audit_trail_entity.dart';
import '../../data/providers/order_data_layer_providers.dart';
import '../../data/providers/order_audit_trail_data_layer_providers.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/order_status_automation_service.dart';
import '../../domain/providers/order_audit_trail_usecase_providers.dart';

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  OrderNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchOrders();
  }
  final Ref ref;

  Future<void> fetchOrders() async {
    try {
      state = const AsyncValue.loading();
      final usecase = ref.read(getOrdersUseCaseProvider);
      final entities = await usecase.execute();
      final orders = entities.map((e) => OrderMapper.fromEntity(e)).toList();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      state = const AsyncValue.loading();
      final usecase = ref.read(createOrderUseCaseProvider);
      final entity = OrderMapper.toEntity(order);
      final created = await usecase.execute(entity);
      final createdOrder = OrderMapper.fromEntity(created);
      final current = state.value ?? [];
      state = AsyncValue.data([...current, createdOrder]);
      return createdOrder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<OrderModel> updateOrder(OrderModel order) async {
    final usecase = ref.read(updateOrderUseCaseProvider);
    final entity = OrderMapper.toEntity(order);
    final updated = await usecase.execute(entity);
    final updatedOrder = OrderMapper.fromEntity(updated);
    final current = state.value ?? [];
    final idx = current.indexWhere((o) => o.id == updatedOrder.id);
    if (idx >= 0) {
      final newList = [...current];
      newList[idx] = updatedOrder;
      state = AsyncValue.data(newList);
    }
    return updatedOrder;
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      state = const AsyncValue.loading();
      final usecase = ref.read(cancelOrderUseCaseProvider);
      await usecase.execute(orderId);
      await fetchOrders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<OrderModel> fulfillOrder(OrderModel order) async {
    final usecase = ref.read(fulfillOrderUseCaseProvider);
    final entity = OrderMapper.toEntity(order);
    final fulfilled = await usecase.execute(entity);
    final fulfilledOrder = OrderMapper.fromEntity(fulfilled);
    final current = state.value ?? [];
    final idx = current.indexWhere((o) => o.id == fulfilledOrder.id);
    if (idx >= 0) {
      final newList = [...current];
      newList[idx] = fulfilledOrder;
      state = AsyncValue.data(newList);
    }
    // Integrate status automation
    final statusAutomationService = OrderStatusAutomationService(
      orderRepository: ref.read(orderRepositoryProvider),
      auditTrailService: ref.read(orderAuditTrailServiceProvider),
      notificationService: ref.read(notificationServiceProvider),
    );
    await statusAutomationService.automateStatusTransition(fulfilled);
    return fulfilledOrder;
  }

  Future<OrderModel> fulfillOrderItem(
      OrderModel order, Map<String, dynamic> item, double quantity) async {
    final usecase = ref.read(updateOrderUseCaseProvider);
    final entity = OrderMapper.toEntity(order);
    final fulfillmentUpdates = [
      {
        'productId': item['productId'],
        'fulfilledQuantity': (item['fulfilledQuantity'] ?? 0) + quantity,
        'backorderedQuantity':
            (item['backorderedQuantity'] ?? item['quantity']) - quantity,
        'fulfillmentStatus':
            ((item['backorderedQuantity'] ?? item['quantity']) - quantity) > 0
                ? 'backordered'
                : 'fulfilled',
      }
    ];
    final updated =
        await usecase.partialFulfillment(entity, fulfillmentUpdates);
    final updatedOrder = OrderMapper.fromEntity(updated);
    final current = state.value ?? [];
    final idx = current.indexWhere((o) => o.id == updatedOrder.id);
    if (idx >= 0) {
      final newList = [...current];
      newList[idx] = updatedOrder;
      state = AsyncValue.data(newList);
    }
    // Integrate status automation
    final statusAutomationService = OrderStatusAutomationService(
      orderRepository: ref.read(orderRepositoryProvider),
      auditTrailService: ref.read(orderAuditTrailServiceProvider),
      notificationService: ref.read(notificationServiceProvider),
    );
    await statusAutomationService.automateStatusTransition(updated);
    return updatedOrder;
  }

  Future<void> requestProcurement(OrderModel order, Map<String, dynamic> item,
      double quantity, String? notes) async {
    await Future.delayed(const Duration(seconds: 1));
    // Log audit trail
    final logUsecase = ref.read(logOrderItemsChangeUseCaseProvider);
    final entry = OrderAuditTrailEntity(
      id: '',
      orderId: order.id,
      action: 'Procurement Requested',
      userId: 'system',
      timestamp: DateTime.now(),
      before: null,
      after: {
        'productId': item['productId'],
        'quantity': quantity,
        'notes': notes,
      },
      justification: notes,
    );
    await logUsecase.execute(entry);
    // Notify procurement team
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.notifyProcurement(
        orderId: order.id,
        productId: item['productId'],
        quantity: quantity,
        notes: notes,
        location: order.shippingAddress?.toString() ?? '',
      );
    } catch (e) {
      // Optionally log or handle notification error
    }
  }

  Future<void> resolveBackorder(
      OrderModel order, Map<String, dynamic> item, String note) async {
    await Future.delayed(const Duration(seconds: 1));
    // Log audit trail
    final logUsecase = ref.read(logOrderItemsChangeUseCaseProvider);
    final entry = OrderAuditTrailEntity(
      id: '',
      orderId: order.id,
      action: 'Backorder Resolved',
      userId: 'system',
      timestamp: DateTime.now(),
      before: null,
      after: {
        'productId': item['productId'],
        'note': note,
      },
      justification: note,
    );
    await logUsecase.execute(entry);
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>(
  (ref) => OrderNotifier(ref),
);
