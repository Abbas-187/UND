import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/purchase_order_model.dart';
import '../repositories/purchase_order_repository.dart';
import '../../data/repositories/purchase_order_repository_impl.dart';
import '../../data/datasources/purchase_order_remote_datasource.dart';

final purchaseOrderDataSourceProvider =
    Provider<PurchaseOrderRemoteDataSource>((ref) {
  return PurchaseOrderRemoteDataSource();
});

final purchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  final dataSource = ref.read(purchaseOrderDataSourceProvider);
  return PurchaseOrderRepositoryImpl(dataSource);
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
