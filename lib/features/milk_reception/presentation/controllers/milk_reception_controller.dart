import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../../../features/procurement/domain/repositories/purchase_order_repository.dart';
import '../../../../features/suppliers/domain/repositories/supplier_repository.dart';
import '../../../../services/reception_notification_service.dart';
import '../../domain/models/milk_reception_model.dart';
import '../../domain/repositories/milk_reception_repository.dart';
import '../../domain/services/milk_reception_service.dart';

/// Provider for the milk reception controller
final milkReceptionControllerProvider = StateNotifierProvider.family<
    MilkReceptionController, MilkReceptionState, String?>((ref, receptionId) {
  final receptionRepository = ref.watch(milkReceptionRepositoryProvider);
  final milkReceptionService = ref.watch(milkReceptionServiceProvider);

  return MilkReceptionController(
    receptionService: milkReceptionService,
    receptionRepository: receptionRepository,
    receptionId: receptionId,
  );
});

/// Provider for the milk reception service
final milkReceptionServiceProvider = Provider<MilkReceptionService>((ref) {
  final receptionRepository = ref.watch(milkReceptionRepositoryProvider);
  final inventoryRepository =
      ref.watch(milkReceptionInventoryRepositoryProvider);
  final supplierRepository = ref.watch(milkReceptionSupplierRepositoryProvider);
  final notificationService = ref.watch(receptionNotificationServiceProvider);
  return MilkReceptionService(
    receptionRepository: receptionRepository,
    inventoryRepository: inventoryRepository,
    supplierRepository: supplierRepository,
    notificationService: notificationService,
    purchaseOrderRepository:
        ref.watch(milkReceptionPurchaseOrderRepositoryProvider),
  );
});

/// Provider for inventory repository
final milkReceptionInventoryRepositoryProvider =
    Provider<InventoryRepository>((ref) {
  // Implementation would depend on your actual repository setup
  throw UnimplementedError('This provider should be implemented in your app');
});

/// Provider for supplier repository
final milkReceptionSupplierRepositoryProvider =
    Provider<SupplierRepository>((ref) {
  // Implementation would depend on your actual repository setup
  throw UnimplementedError('This provider should be implemented in your app');
});

/// Provider for purchase order repository
final milkReceptionPurchaseOrderRepositoryProvider =
    Provider<PurchaseOrderRepository>((ref) {
  // Implementation would depend on your actual repository setup
  throw UnimplementedError('This provider should be implemented in your app');
});

/// Provider for notification service
final receptionNotificationServiceProvider =
    Provider<ReceptionNotificationService>((ref) {
  // Implementation would depend on your actual notification service setup
  throw UnimplementedError('This provider should be implemented in your app');
});

/// Enum representing the steps in the milk reception workflow
enum MilkReceptionStep {
  /// Step 1: Supplier Information
  supplierInfo,

  /// Step 2: Initial Inspection
  initialInspection,

  /// Step 3: Quality Inspection
  qualityInspection,

  /// Step 4: Sample Collection
  sampleCollection,

  /// Step 5: Lab Results
  labResults,

  /// Step 6: Delivery Authorization
  deliveryAuthorization,
}

/// Enum representing validation status
enum ValidationStatus {
  /// Field has not been validated yet
  notValidated,

  /// Field is valid
  valid,

  /// Field is invalid
  invalid,
}

/// Model representing the state of the milk reception process
class MilkReceptionState {
  MilkReceptionState({
    required this.receptionModel,
    this.currentStep = MilkReceptionStep.supplierInfo,
    this.isLoading = false,
    this.errorMessage,
    this.stepValidity = const {},
    this.fieldValidation = const {},
    this.hasUnsavedChanges = false,
  });

  /// The milk reception data model
  final MilkReceptionModel receptionModel;

  /// Current step in the reception workflow
  final MilkReceptionStep currentStep;

  /// Loading state indicator
  final bool isLoading;

  /// Error message if there's an error
  final String? errorMessage;

  /// Map tracking validity of each step
  final Map<MilkReceptionStep, bool> stepValidity;

  /// Map tracking validation status of individual fields
  final Map<String, ValidationStatus> fieldValidation;

  /// Indicates if there are unsaved changes
  final bool hasUnsavedChanges;

  /// Create a copy of this state with specified changes
  MilkReceptionState copyWith({
    MilkReceptionModel? receptionModel,
    MilkReceptionStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    Map<MilkReceptionStep, bool>? stepValidity,
    Map<String, ValidationStatus>? fieldValidation,
    bool? hasUnsavedChanges,
  }) {
    return MilkReceptionState(
      receptionModel: receptionModel ?? this.receptionModel,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      stepValidity: stepValidity ?? this.stepValidity,
      fieldValidation: fieldValidation ?? this.fieldValidation,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// Controller for managing milk reception process
class MilkReceptionController extends StateNotifier<MilkReceptionState> {
  MilkReceptionController({
    required this.receptionService,
    required this.receptionRepository,
    String? receptionId,
  }) : super(MilkReceptionState(
          receptionModel: MilkReceptionModel.empty(),
        )) {
    _logger = Logger('MilkReceptionController');
    if (receptionId != null) {
      _loadExistingReception(receptionId);
    }
  }

  /// Service for handling milk reception business logic
  final MilkReceptionService receptionService;

  /// Repository for milk reception data persistence
  final MilkReceptionRepository receptionRepository;

  /// Logger for debugging and audit
  late final Logger _logger;

  /// Loads an existing milk reception by ID
  Future<void> _loadExistingReception(String receptionId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final reception = await receptionRepository.getReceptionById(receptionId);
      state = state.copyWith(
        receptionModel: reception,
        isLoading: false,
        hasUnsavedChanges: false,
      );
    } catch (e, stackTrace) {
      _logger.severe('Failed to load reception: $e', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load reception: $e',
      );
    }
  }

  /// Move to the next step in the reception process
  void goToNextStep() {
    final currentStepIndex =
        MilkReceptionStep.values.indexOf(state.currentStep);
    if (currentStepIndex < MilkReceptionStep.values.length - 1) {
      final nextStep = MilkReceptionStep.values[currentStepIndex + 1];
      state = state.copyWith(currentStep: nextStep);
    }
  }

  /// Move to the previous step in the reception process
  void goToPreviousStep() {
    final currentStepIndex =
        MilkReceptionStep.values.indexOf(state.currentStep);
    if (currentStepIndex > 0) {
      final previousStep = MilkReceptionStep.values[currentStepIndex - 1];
      state = state.copyWith(currentStep: previousStep);
    }
  }

  /// Create a new reception in the repository
  Future<String> createReception() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final receptionId =
          await receptionRepository.createReception(state.receptionModel);
      state = state.copyWith(
        receptionModel: state.receptionModel.copyWith(id: receptionId),
        isLoading: false,
        hasUnsavedChanges: false,
      );
      return receptionId;
    } catch (e, stackTrace) {
      _logger.severe('Failed to create reception: $e', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create reception: $e',
      );
      rethrow;
    }
  }

  /// Update an existing reception in the repository
  Future<void> updateReception() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await receptionRepository.updateReception(state.receptionModel);
      state = state.copyWith(
        isLoading: false,
        hasUnsavedChanges: false,
      );
    } catch (e, stackTrace) {
      _logger.severe('Failed to update reception: $e', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update reception: $e',
      );
      rethrow;
    }
  }

  /// Update the status of a reception
  Future<void> updateReceptionStatus(ReceptionStatus status) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await receptionRepository.updateReceptionStatus(
          state.receptionModel.id, status);
      state = state.copyWith(
        receptionModel: state.receptionModel.copyWith(receptionStatus: status),
        isLoading: false,
        hasUnsavedChanges: false,
      );
    } catch (e, stackTrace) {
      _logger.severe('Failed to update reception status: $e', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update reception status: $e',
      );
      rethrow;
    }
  }

  /// Finalize a reception - either accept or reject it
  Future<bool> finalizeReception({
    required bool isAccepted,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedModel = state.receptionModel.copyWith(
        receptionStatus:
            isAccepted ? ReceptionStatus.accepted : ReceptionStatus.rejected,
        notes: notes,
      );

      await receptionRepository.updateReception(updatedModel);

      state = state.copyWith(
        receptionModel: updatedModel,
        isLoading: false,
        hasUnsavedChanges: false,
      );

      // Notify relevant services about the finalization
      await receptionService.handleReceptionFinalization(
          updatedModel, isAccepted);

      return true;
    } catch (e, stackTrace) {
      _logger.severe('Failed to finalize reception: $e', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to finalize reception: $e',
      );
      return false;
    }
  }
}
