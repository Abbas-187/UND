import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_audit_trail_mapper.dart';
import '../../data/models/order_audit_trail_model.dart';
import '../../domain/providers/order_audit_trail_usecase_providers.dart';

class OrderAuditTrailNotifier
    extends StateNotifier<AsyncValue<List<OrderAuditTrailModel>>> {
  OrderAuditTrailNotifier(this.ref) : super(const AsyncValue.loading());
  final Ref ref;

  Future<void> fetch(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final usecase = ref.read(getOrderAuditTrailUseCaseProvider);
      final entities = await usecase.execute(orderId);
      final list =
          entities.map((e) => OrderAuditTrailMapper.fromEntity(e)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> log(OrderAuditTrailModel entry) async {
    try {
      final usecase = ref.read(logOrderCreationUseCaseProvider);
      final logged =
          await usecase.execute(OrderAuditTrailMapper.toEntity(entry));
      state.whenData((list) {
        state = AsyncValue.data(
            [...list, OrderAuditTrailMapper.fromEntity(logged)]);
      });
    } catch (e) {
      rethrow;
    }
  }
}

final orderAuditTrailProvider = StateNotifierProvider<OrderAuditTrailNotifier,
    AsyncValue<List<OrderAuditTrailModel>>>(
  (ref) => OrderAuditTrailNotifier(ref),
);
