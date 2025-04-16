import '../entities/inventory_adjustment.dart';

/// Repository interface for inventory adjustment management
abstract class InventoryAdjustmentRepository {
  /// Gets all inventory adjustments
  Future<List<InventoryAdjustment>> getAdjustments({
    DateTime? startDate,
    DateTime? endDate,
    AdjustmentType? type,
    String? itemId,
    String? categoryId,
    AdjustmentApprovalStatus? status,
  });

  /// Gets an inventory adjustment by ID
  Future<InventoryAdjustment?> getAdjustment(String id);

  /// Creates a new inventory adjustment
  Future<InventoryAdjustment> createAdjustment(InventoryAdjustment adjustment);

  /// Updates an existing inventory adjustment's approval status
  Future<void> updateAdjustmentStatus(
    String id,
    AdjustmentApprovalStatus status,
    String approverName,
  );

  /// Gets adjustments for a specific inventory item
  Future<List<InventoryAdjustment>> getAdjustmentsForItem(String itemId);

  /// Gets pending adjustments requiring approval
  Future<List<InventoryAdjustment>> getPendingAdjustments();

  /// Gets adjustment statistics
  Future<Map<AdjustmentType, int>> getAdjustmentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets total quantity adjusted by type
  Future<Map<AdjustmentType, double>> getTotalQuantityByType({
    DateTime? startDate,
    DateTime? endDate,
  });
}
