import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/order_audit_trail_data_layer_providers.dart';
import '../usecases/get_order_audit_trail_usecase.dart';
import '../usecases/log_order_cancellation_usecase.dart';
import '../usecases/log_order_creation_usecase.dart';
import '../usecases/log_order_items_change_usecase.dart';
import '../usecases/log_order_status_change_usecase.dart';
import '../usecases/log_order_update_usecase.dart';

final getOrderAuditTrailUseCaseProvider =
    Provider<GetOrderAuditTrailUseCase>((ref) {
  final repo = ref.watch(orderAuditTrailRepositoryProvider);
  return GetOrderAuditTrailUseCase(repo);
});

final logOrderCreationUseCaseProvider =
    Provider<LogOrderCreationUseCase>((ref) {
  final repo = ref.watch(orderAuditTrailRepositoryProvider);
  return LogOrderCreationUseCase(repo);
});

final logOrderStatusChangeUseCaseProvider =
    Provider<LogOrderStatusChangeUseCase>((ref) {
  final repo = ref.watch(orderAuditTrailRepositoryProvider);
  return LogOrderStatusChangeUseCase(repo);
});

final logOrderUpdateUseCaseProvider = Provider<LogOrderUpdateUseCase>((ref) {
  final repo = ref.watch(orderAuditTrailRepositoryProvider);
  return LogOrderUpdateUseCase(repo);
});

final logOrderCancellationUseCaseProvider =
    Provider<LogOrderCancellationUseCase>((ref) {
  final repo = ref.watch(orderAuditTrailRepositoryProvider);
  return LogOrderCancellationUseCase(repo);
});

final logOrderItemsChangeUseCaseProvider =
    Provider<LogOrderItemsChangeUseCase>((ref) {
  final repo = ref.watch(orderAuditTrailRepositoryProvider);
  return LogOrderItemsChangeUseCase(repo);
});
