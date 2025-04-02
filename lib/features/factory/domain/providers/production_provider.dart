import 'package:riverpod/riverpod.dart';
import '../../data/models/production_order_model.dart';
import '../../data/repositories/production_repository.dart';

/// Provider for production orders and related CRUD operations.
///
/// This implementation removes the dependency on code generation by manually
/// implementing providers using Riverpod's StateNotifier and FutureProvider.

// StateNotifier that manages the list of production orders
class ProductionOrdersNotifier
    extends StateNotifier<AsyncValue<List<ProductionOrderModel>>> {
  ProductionOrdersNotifier({required this.productionRepository})
      : super(const AsyncValue.loading()) {
    loadProductionOrders();
  }

  final ProductionRepository productionRepository;

  Future<void> loadProductionOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await productionRepository.getProductionOrders();
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createProductionOrder(ProductionOrderModel order) async {
    try {
      await productionRepository.createProductionOrder(order);
      await loadProductionOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProductionOrder(ProductionOrderModel order) async {
    try {
      await productionRepository.updateProductionOrder(order);
      await loadProductionOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProductionOrder(String id) async {
    try {
      await productionRepository.deleteProductionOrder(id);
      await loadProductionOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProductionOrderStatus(String id, String status) async {
    try {
      await productionRepository.updateProductionOrderStatus(id, status);
      await loadProductionOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider for the production orders state notifier
final productionOrdersProvider = StateNotifierProvider<ProductionOrdersNotifier,
    AsyncValue<List<ProductionOrderModel>>>((ref) {
  final repository = ref.watch(productionRepositoryProvider);
  return ProductionOrdersNotifier(productionRepository: repository);
});

// Provider to get a single production order by ID
final productionOrderByIdProvider = FutureProvider.autoDispose
    .family<ProductionOrderModel, String>((ref, id) async {
  final repository = ref.watch(productionRepositoryProvider);
  return await repository.getProductionOrderById(id);
});
