import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_mock.dart';
import '../../../../core/firebase/firebase_module.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../repositories/inventory_repository.dart';

/// Provider for inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final firestoreInstance =
      useMockFirebase ? FirestoreMock() : FirebaseFirestore.instance;

  return InventoryRepositoryImpl(
    firestore: firestoreInstance,
  );
});
