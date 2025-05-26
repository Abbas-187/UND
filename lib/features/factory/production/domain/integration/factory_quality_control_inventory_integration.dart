import '../../../../inventory/data/models/quality_status.dart';
import '../../../../inventory/domain/usecases/update_inventory_quality_status_usecase.dart';
import '../models/quality_control_result_model.dart';

/// Maps factory QC result to inventory quality status
QualityStatus mapQcResultToInventoryStatus(QualityCheckResult result) {
  switch (result) {
    case QualityCheckResult.pass:
      return QualityStatus.good;
    case QualityCheckResult.conditional:
      return QualityStatus.warning;
    case QualityCheckResult.fail:
    default:
      return QualityStatus.rejected;
  }
}

/// Integration utility to update inventory after factory QC
class FactoryQualityControlInventoryIntegration {
  FactoryQualityControlInventoryIntegration(
      this.updateInventoryQualityStatusUseCase);
  final UpdateInventoryQualityStatusUseCase updateInventoryQualityStatusUseCase;

  /// Call this after a QC result is recorded
  Future<void> handleQcResult({
    required String inventoryItemId,
    String? batchLotNumber,
    required QualityControlResultModel qcResult,
    required String userId,
  }) async {
    final newStatus = mapQcResultToInventoryStatus(qcResult.result);
    await updateInventoryQualityStatusUseCase.execute(
      inventoryItemId: inventoryItemId,
      batchLotNumber: batchLotNumber,
      newQualityStatus: newStatus,
      reason: 'Factory QC: ${qcResult.checkpointName}',
      referenceDocumentId: qcResult.id,
      userId: userId,
    );
  }
}
