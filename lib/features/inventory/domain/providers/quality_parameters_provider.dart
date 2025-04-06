import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/dairy_quality_parameters_model.dart';
import '../../data/repositories/quality_parameters_repository.dart';

part 'quality_parameters_provider.g.dart';

@riverpod
class ItemQualityParameters extends _$ItemQualityParameters {
  @override
  Stream<List<DairyQualityParametersModel>> build(String inventoryItemId) {
    final repository = ref.watch(qualityParametersRepositoryProvider);
    return repository.getQualityParametersForItem(inventoryItemId);
  }

  Future<String> saveQualityParameters(
      DairyQualityParametersModel parameters) async {
    final repository = ref.read(qualityParametersRepositoryProvider);
    return repository.saveQualityParameters(parameters);
  }

  Future<void> approveQualityParameters(String parametersId) async {
    final repository = ref.read(qualityParametersRepositoryProvider);
    return repository.approveQualityParameters(parametersId);
  }

  Future<void> rejectQualityParameters(
      String parametersId, String rejectionReason) async {
    final repository = ref.read(qualityParametersRepositoryProvider);
    return repository.rejectQualityParameters(parametersId, rejectionReason);
  }
}

@riverpod
class BatchQualityParameters extends _$BatchQualityParameters {
  @override
  Stream<List<DairyQualityParametersModel>> build(String batchNumber) {
    final repository = ref.watch(qualityParametersRepositoryProvider);
    return repository.getQualityParametersForBatch(batchNumber);
  }
}

@riverpod
class PendingQualityTests extends _$PendingQualityTests {
  @override
  Stream<List<DairyQualityParametersModel>> build() {
    final repository = ref.watch(qualityParametersRepositoryProvider);
    return repository.getPendingQualityTests();
  }
}

/// Provider for quality parameters state
final qualityParametersProvider =
    StateNotifierProvider<QualityParametersNotifier, QualityParametersState>(
        (ref) {
  return QualityParametersNotifier();
});

/// State for quality parameters
class QualityParametersState {

  QualityParametersState({
    this.parameters = const [],
    this.isLoading = false,
    this.error,
  });
  final List<DairyQualityParametersModel> parameters;
  final bool isLoading;
  final String? error;

  QualityParametersState copyWith({
    List<DairyQualityParametersModel>? parameters,
    bool? isLoading,
    String? error,
  }) {
    return QualityParametersState(
      parameters: parameters ?? this.parameters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for quality parameters
class QualityParametersNotifier extends StateNotifier<QualityParametersState> {
  QualityParametersNotifier() : super(QualityParametersState());

  /// Gets quality checks by supplier
  Future<List<DairyQualityParametersModel>> getQualityChecksBySupplier({
    required String supplierId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // This would fetch from a repository in a real implementation
    // Mock implementation for now
    return [];
  }

  /// Gets quality parameters for an item
  Future<Map<String, dynamic>> getQualityParameters(String itemId) async {
    // This would fetch from a repository in a real implementation
    // Mock implementation for now
    return {
      'fatContent': 3.8,
      'proteinContent': 3.2,
      'bacterialCount': 80000,
    };
  }
}
