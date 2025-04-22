import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/purchase_order_repository_impl.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../repositories/purchase_order_repository.dart';
import '../../data/models/purchase_order_model.dart';

final purchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  final supplierRepository = ref.read(supplierRepositoryProvider);
  final mockProvider = null; // Replace with actual mock provider if needed
  final dataSource = null; // Replace with actual data source if needed
  // Use the .fromMock factory for now, or adjust as needed for your app
  return PurchaseOrderRepositoryImpl.fromMock(mockProvider, supplierRepository);
});

final purchaseOrdersProvider =
    FutureProvider<List<PurchaseOrderModel>>((ref) async {
  final repository = ref.read(purchaseOrderRepositoryProvider);
  return repository.getAllPurchaseOrders();
});

final purchaseOrderByIdProvider =
    FutureProvider.family<PurchaseOrderModel?, String>((ref, id) async {
  final repository = ref.read(purchaseOrderRepositoryProvider);
  return repository.getPurchaseOrderById(id);
});
