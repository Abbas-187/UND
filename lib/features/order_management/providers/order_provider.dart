import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/user_role.dart';
import '../services/order_service.dart';
import '../integrations/customer_profile_integration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/config/api_config.dart';

// Provider for the OrderService
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Provider for the CustomerProfileIntegrationService
final customerProfileServiceProvider =
    Provider<CustomerProfileIntegrationService>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return CustomerProfileIntegrationService(orderService: orderService);
});

// Provider for managing orders
class OrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderService _orderService;
  final CustomerProfileIntegrationService _customerProfileService;

  OrderNotifier(this._orderService, this._customerProfileService)
      : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders(
      {String? userId, String? location, RoleType? role}) async {
    try {
      state = const AsyncValue.loading();
      final orders = await _orderService.fetchOrders(
        userId: userId,
        location: location,
        role: role,
      );
      state = AsyncValue.data(orders);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      // Enhance order with customer information
      final enhancedOrder =
          await _customerProfileService.enrichOrderWithCustomerData(order);

      // Create the order
      final createdOrder = await _orderService.createOrder(enhancedOrder);

      // Update the state with the new order
      state.whenData((orders) {
        state = AsyncValue.data([...orders, createdOrder]);
      });

      return createdOrder;
    } catch (e) {
      // Forward the error
      rethrow;
    }
  }

  Future<Order> updateOrder(Order order) async {
    try {
      final updatedOrder = await _orderService.updateOrder(order);

      // Update the state with the updated order
      state.whenData((orders) {
        final index = orders.indexWhere((o) => o.id == updatedOrder.id);
        if (index >= 0) {
          final updatedOrders = [...orders];
          updatedOrders[index] = updatedOrder;
          state = AsyncValue.data(updatedOrders);
        }
      });

      return updatedOrder;
    } catch (e) {
      // Forward the error
      rethrow;
    }
  }

  Future<Order> cancelOrder(
      String orderId, String reason, String cancelledBy) async {
    try {
      final cancelledOrder = await _orderService.cancelOrder(
        orderId,
        reason,
        cancelledBy,
      );

      // Update the state with the cancelled order
      state.whenData((orders) {
        final index = orders.indexWhere((o) => o.id == cancelledOrder.id);
        if (index >= 0) {
          final updatedOrders = [...orders];
          updatedOrders[index] = cancelledOrder;
          state = AsyncValue.data(updatedOrders);
        }
      });

      return cancelledOrder;
    } catch (e) {
      // Forward the error
      rethrow;
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      // First check if the order is already in the state
      Order? order;
      state.whenData((orders) {
        order = orders.firstWhere(
          (order) => order.id == orderId,
          orElse: () => null as Order, // This will be null if not found
        );
      });

      // If found in state, return it
      if (order != null) return order;

      // If not in state, fetch all orders and try again
      await fetchOrders();

      // Check again after fetching
      state.whenData((orders) {
        order = orders.firstWhere(
          (order) => order.id == orderId,
          orElse: () => null as Order, // This will be null if not found
        );
      });

      return order;
    } catch (e) {
      // Forward the error
      rethrow;
    }
  }
}

// Provider for the OrderNotifier
final orderProviderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<Order>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final customerProfileService = ref.watch(customerProfileServiceProvider);
  return OrderNotifier(orderService, customerProfileService);
});
