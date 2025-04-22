import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_mock.dart';
import '../../../../core/firebase/firebase_module.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../repositories/inventory_repository.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../data/repositories/mock_inventory_repository.dart';

/// Set this flag to true to use mock data, false for real data
const bool useMockInventory = true;

/// Provider for inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  if (useMockInventory) {
    final mockDataService = ref.watch(mockDataServiceProvider);
    return MockInventoryRepository(mockDataService: mockDataService);
  } else {
    final firestoreInstance =
        useMockFirebase ? FirestoreMock() : FirebaseFirestore.instance;
    return InventoryRepositoryImpl(
      firestore: firestoreInstance,
    );
  }
});
