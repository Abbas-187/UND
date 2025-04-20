import '../entities/inventory_adjustment.dart';

abstract class InventoryAdjustmentRepository {
  Future<List<InventoryAdjustment>> getAdjustments({
    DateTime? startDate,
    DateTime? endDate,
    AdjustmentType? type,
    String? itemId,
    String? categoryId,
    AdjustmentApprovalStatus? status,
  });

  Future<InventoryAdjustment?> getAdjustment(String id);

  Future<InventoryAdjustment> createAdjustment(InventoryAdjustment adjustment);

  Future<List<InventoryAdjustment>> getAdjustmentsForItem(String itemId);

  Future<List<InventoryAdjustment>> getPendingAdjustments();

  Future<Map<AdjustmentType, int>> getAdjustmentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Map<AdjustmentType, double>> getTotalQuantityByType({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> updateAdjustmentStatus(
      String id, AdjustmentApprovalStatus status, String approverName);
}
