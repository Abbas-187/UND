import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_mapper.dart';
import '../../data/models/order_model.dart';
import '../../domain/providers/order_usecase_providers.dart';

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
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>(
  (ref) => OrderNotifier(ref),
);
