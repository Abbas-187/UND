import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase/firebase_mock.dart';
import '../core/firebase/firebase_module.dart';
import '../features/inventory/presentation/providers/inventory_provider.dart';
import '../features/milk_reception/domain/models/milk_reception_model.dart';
import '../features/milk_reception/domain/repositories/milk_reception_repository.dart';
import '../services/reception_inventory_service.dart';

/// Provider for ReceptionInventoryService
final receptionInventoryServiceProvider =
    Provider<ReceptionInventoryService>((ref) {
  final receptionRepository = ref.watch(milkReceptionRepositoryProvider);
  final inventoryRepository = ref.watch(inventoryRepositoryProvider);
  final firestoreInstance =
      useMockFirebase ? FirestoreMock() : FirebaseFirestore.instance;

  return ReceptionInventoryService(
    receptionRepository: receptionRepository,
    inventoryRepository: inventoryRepository,
    firestore: firestoreInstance,
  );
});

/// Provider for streaming completed milk receptions
final completedMilkReceptionsProvider =
    StreamProvider<List<MilkReceptionModel>>((ref) {
  final receptionInventoryService =
      ref.watch(receptionInventoryServiceProvider);
  return receptionInventoryService.completedReceptions;
});

/// Provider for tracking the inventory creation status for a milk reception
final inventoryCreationStatusProvider = StateNotifierProvider.family<
    InventoryCreationNotifier, AsyncValue<String?>, String>((ref, receptionId) {
  final receptionInventoryService =
      ref.watch(receptionInventoryServiceProvider);
  return InventoryCreationNotifier(receptionInventoryService, receptionId);
});

/// State notifier for tracking inventory creation status
class InventoryCreationNotifier extends StateNotifier<AsyncValue<String?>> {
  InventoryCreationNotifier(this._service, this._receptionId)
      : super(const AsyncValue.loading()) {
    _checkIfInventoryExists();
  }

  final ReceptionInventoryService _service;
  final String _receptionId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Checks if inventory already exists for this reception
  Future<void> _checkIfInventoryExists() async {
    try {
      // Query Firestore for existing inventory item with this reception ID
      final existingInventory = await _firestore
          .collection('inventory')
          .where('additionalAttributes.receptionId', isEqualTo: _receptionId)
          .limit(1)
          .get();

      if (existingInventory.docs.isNotEmpty) {
        // Inventory already exists
        state = AsyncValue.data(existingInventory.docs.first.id);
      } else {
        // No inventory exists yet
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Creates inventory from the milk reception
  Future<void> createInventory() async {
    state = const AsyncValue.loading();

    try {
      final inventoryId =
          await _service.createInventoryFromReception(_receptionId);
      state = AsyncValue.data(inventoryId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
