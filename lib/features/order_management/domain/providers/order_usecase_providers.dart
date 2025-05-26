import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/inventory_data_layer_providers.dart';
import '../../data/providers/order_data_layer_providers.dart';
import '../usecases/cancel_order_usecase.dart';
// Use-cases
import '../usecases/create_order_usecase.dart';
import '../usecases/fulfill_order_usecase.dart';
import '../usecases/get_order_by_id_usecase.dart';
import '../usecases/get_orders_usecase.dart';
import '../usecases/handle_procurement_complete_usecase.dart';
import '../usecases/update_order_usecase.dart';

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return CreateOrderUseCase(orderRepo, inventoryRepo);
});

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return GetOrdersUseCase(repo);
});

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return GetOrderByIdUseCase(repo);
});

final updateOrderUseCaseProvider = Provider<UpdateOrderUseCase>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return UpdateOrderUseCase(repo);
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return CancelOrderUseCase(orderRepo, inventoryRepo);
});

final handleProcurementCompleteUseCaseProvider =
    Provider<HandleProcurementCompleteUseCase>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return HandleProcurementCompleteUseCase(repo);
});

final fulfillOrderUseCaseProvider = Provider<FulfillOrderUseCase>((ref) {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return FulfillOrderUseCase(orderRepo, inventoryRepo);
});
