import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/quality_parameters_repository.dart';
import '../../data/models/dairy_quality_parameters_model.dart';

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
