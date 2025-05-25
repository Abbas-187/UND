import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/process_inventory_movement_usecase.dart';

/// Provider for the inventory repository (implementation is provided elsewhere)
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  throw UnimplementedError(
      'Repository must be overridden with a real implementation');
});

/// Provider for the inventory movement processor use case
final inventoryMovementProcessorProvider =
    Provider<ProcessInventoryMovementUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return ProcessInventoryMovementUseCase(repository);
});

/// Provider for warehouses (to be populated by the app)
final warehousesProvider = FutureProvider((ref) async {
  // This would be populated with real warehouse data from the repository
  // For now, we return some sample data
  return [
    Warehouse(id: 'warehouse1', name: 'Main Warehouse'),
    Warehouse(id: 'warehouse2', name: 'Production Warehouse'),
    Warehouse(id: 'warehouse3', name: 'Distribution Center'),
  ];
});

/// Simple warehouse model for the UI
class Warehouse {
  Warehouse({required this.id, required this.name});
  final String id;
  final String name;
}

/// Provider for inventory movement state
final inventoryMovementProvider =
    StateNotifierProvider<InventoryMovementNotifier, InventoryMovementState>(
        (ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  final processor = ref.watch(inventoryMovementProcessorProvider);
  return InventoryMovementNotifier(repository, processor);
});

/// State class for inventory movement
class InventoryMovementState {
  InventoryMovementState({
    this.isLoading = false,
    this.isSaving = false,
    this.isFormPopulated = false,
    this.currentMovement,
    List<InventoryMovementItemModel>? items,
    this.errorMessage,
  }) : items = items ?? [];
  final bool isLoading;
  final bool isSaving;
  final bool isFormPopulated;
  final InventoryMovementModel? currentMovement;
  final List<InventoryMovementItemModel> items;
  final String? errorMessage;

  InventoryMovementState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isFormPopulated,
    InventoryMovementModel? currentMovement,
    List<InventoryMovementItemModel>? items,
    String? errorMessage,
  }) {
    return InventoryMovementState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isFormPopulated: isFormPopulated ?? this.isFormPopulated,
      currentMovement: currentMovement ?? this.currentMovement,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier class for inventory movement
class InventoryMovementNotifier extends StateNotifier<InventoryMovementState> {
  InventoryMovementNotifier(this._repository, this._processor)
      : super(InventoryMovementState());
  final InventoryRepository _repository;
  final ProcessInventoryMovementUseCase _processor;

  /// Load an existing movement
  Future<void> loadMovement(String movementId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final movement = await _repository.getMovement(movementId);
      if (movement != null) {
        state = state.copyWith(
          isLoading: false,
          currentMovement: movement,
          items: [...movement.items],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Movement not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load movement: $e',
      );
    }
  }

  /// Mark the form as populated (used when editing)
  void setFormPopulated(bool populated) {
    state = state.copyWith(isFormPopulated: populated);
  }

  /// Add an item to the movement
  void addItem(InventoryMovementItemModel item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  /// Update an item in the movement
  void updateItem(int index, InventoryMovementItemModel updatedItem) {
    final newItems = [...state.items];
    newItems[index] = updatedItem;
    state = state.copyWith(items: newItems);
  }

  /// Remove an item from the movement
  void removeItem(int index) {
    final newItems = [...state.items];
    newItems.removeAt(index);
    state = state.copyWith(items: newItems);
  }

  /// Save the movement (create or update)
  Future<MovementProcessingResult> saveMovement({
    String? id,
    required String documentNumber,
    required DateTime movementDate,
    required InventoryMovementType movementType,
    required String warehouseId,
    String? referenceNumber,
    String? reasonNotes,
    required String initiatingEmployeeId,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      // Create the movement model
      final movement = InventoryMovementModel(
        id: id,
        documentNumber: documentNumber,
        movementDate: movementDate,
        movementType: movementType,
        warehouseId: warehouseId,
        referenceNumber: referenceNumber,
        reasonNotes: reasonNotes,
        items: state.items,
        status: InventoryMovementStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        initiatingEmployeeId: initiatingEmployeeId,
      );

      // Process the movement using the use case
      final result = await _processor.execute(
        movement: movement,
        validateBatchTracking: true,
      );

      state = state.copyWith(isSaving: false);

      return result;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save movement: $e',
      );

      return MovementProcessingResult(
        success: false,
        movementId: null,
        errors: ['Failed to save movement: $e'],
      );
    }
  }

  /// Delete a movement
  Future<bool> deleteMovement(String movementId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _repository.deleteMovement(movementId);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete movement: $e',
      );
      return false;
    }
  }
}
