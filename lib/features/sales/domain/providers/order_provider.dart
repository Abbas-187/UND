import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

part 'order_provider.g.dart';

// --- Provider for fetching filtered orders ---
@riverpod
Future<List<OrderModel>> filteredOrders(
  FilteredOrdersRef ref, {
  String? customerId,
  OrderStatus? status,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders(
    customerId: customerId,
    status: status,
    startDate: startDate,
    endDate: endDate,
  );
}

// --- Provider for a single order details ---
@riverpod
Future<OrderModel> orderDetails(OrderDetailsRef ref, String orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(orderId);
}

// --- StateNotifier for managing order actions ---
@riverpod
class OrderActions extends _$OrderActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> createOrder(OrderModel order) async {
    final repository = ref.read(orderRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.createOrder(order);
      ref.invalidate(filteredOrdersProvider); // Invalidate list
    });
  }

  Future<void> updateOrder(OrderModel order) async {
    final repository = ref.read(orderRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.updateOrder(order);
      ref.invalidate(filteredOrdersProvider);
      final orderId = order.toString().contains('id:')
          ? order.toString().split('id:')[1].split(',')[0].trim()
          : '';
      if (orderId.isNotEmpty) {
        ref.invalidate(orderDetailsProvider(orderId));
      }
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status,
      {String? userId, String? notes}) async {
    final repository = ref.read(orderRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.updateOrderStatus(orderId, status,
          userId: userId, notes: notes);
      ref.invalidate(filteredOrdersProvider);
      ref.invalidate(orderDetailsProvider(orderId));
    });
  }

  Future<void> deleteOrder(String orderId) async {
    final repository = ref.read(orderRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.deleteOrder(orderId);
      ref.invalidate(filteredOrdersProvider);
    });
  }
}
