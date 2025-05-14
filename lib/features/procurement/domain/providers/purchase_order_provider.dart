import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_module.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/repositories/purchase_order_repository_impl.dart';
import '../repositories/purchase_order_repository.dart';

final purchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  final firestore = ref.read(firestoreInterfaceProvider);
  final supplierRepository = ref.read(supplierRepositoryProvider);
  return PurchaseOrderRepositoryImpl(
      firestore as FirebaseFirestore, supplierRepository);
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
