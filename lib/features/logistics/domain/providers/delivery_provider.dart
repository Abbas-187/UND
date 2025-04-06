import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/delivery_model.dart';
import '../../data/repositories/delivery_repository.dart';

final deliveryByIdProvider =
    FutureProvider.family<DeliveryModel?, String>((ref, id) {
  final repository = ref.watch(deliveryRepositoryProvider);
  return repository.getDeliveryById(id);
});

final deliveryProvider =
    StateNotifierProvider<DeliveryNotifier, AsyncValue<List<DeliveryModel>>>(
        (ref) {
  final repository = ref.watch(deliveryRepositoryProvider);
  return DeliveryNotifier(repository);
});

class DeliveryNotifier extends StateNotifier<AsyncValue<List<DeliveryModel>>> {

  DeliveryNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadDeliveries();
  }
  final DeliveryRepository _repository;

  Future<void> _loadDeliveries() async {
    try {
      final deliveries = await _repository.getAllDeliveries();
      state = AsyncValue.data(deliveries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createDelivery(DeliveryModel delivery) async {
    try {
      await _repository.createDelivery(delivery);
      _loadDeliveries();
    } catch (e) {
      rethrow;
    }
  }
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository();
});
