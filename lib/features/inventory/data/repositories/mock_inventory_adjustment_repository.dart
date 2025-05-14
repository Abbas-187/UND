/*
import 'package:uuid/uuid.dart';

import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/repositories/inventory_adjustment_repository.dart';

class MockInventoryAdjustmentRepository
    implements InventoryAdjustmentRepository {
  final List<InventoryAdjustment> _adjustments = [
    InventoryAdjustment(
      id: '1',
      itemId: '101',
      itemName: 'Whole Milk (1L)',
      adjustmentType: AdjustmentType.stockCount,
      quantity: 15.0,
      previousQuantity: 32.0,
      adjustedQuantity: 47.0,
      reason: 'Stock count adjustment',
      performedBy: 'John Doe',
      performedAt: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Physical count showed more inventory than system',
      categoryId: '2',
      categoryName: 'Milk',
    ),
    InventoryAdjustment(
      id: '2',
      itemId: '102',
      itemName: 'Cheese (Block)',
      adjustmentType: AdjustmentType.damage,
      quantity: -5.0,
      previousQuantity: 20.0,
      adjustedQuantity: 15.0,
      reason: 'Damaged in storage',
      performedBy: 'Jane Smith',
      performedAt: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Temperature control failure in storage unit',
      categoryId: '3',
      categoryName: 'Cheese',
      approvalStatus: AdjustmentApprovalStatus.approved,
      approvedBy: 'Manager',
      approvedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryAdjustment(
      id: '3',
      itemId: '103',
      itemName: 'Yogurt (500g)',
      adjustmentType: AdjustmentType.expiry,
      quantity: -8.0,
      previousQuantity: 25.0,
      adjustedQuantity: 17.0,
      reason: 'Expired product',
      performedBy: 'Ahmed Khan',
      performedAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      categoryId: '4',
      categoryName: 'Yogurt',
    ),
    InventoryAdjustment(
      id: '4',
      itemId: '101',
      itemName: 'Whole Milk (1L)',
      adjustmentType: AdjustmentType.manual,
      quantity: -3.0,
      previousQuantity: 47.0,
      adjustedQuantity: 44.0,
      reason: 'Quality testing samples',
      performedBy: 'Maria Garcia',
      performedAt: DateTime.now().subtract(const Duration(hours: 12)),
      notes: 'Samples taken for quality assurance testing',
      categoryId: '2',
      categoryName: 'Milk',
      approvalStatus: AdjustmentApprovalStatus.pending,
    ),
    InventoryAdjustment(
      id: '5',
      itemId: '105',
      itemName: 'Butter (250g)',
      adjustmentType: AdjustmentType.return_to_supplier,
      quantity: -10.0,
      previousQuantity: 30.0,
      adjustedQuantity: 20.0,
      reason: 'Quality issues with batch',
      performedBy: 'Robert Johnson',
      performedAt: DateTime.now().subtract(const Duration(hours: 8)),
      notes: 'Returned to supplier due to inconsistent quality',
      documentReference: 'RET-2023-0042',
      categoryId: '1',
      categoryName: 'Dairy Products',
      approvalStatus: AdjustmentApprovalStatus.approved,
      approvedBy: 'Supply Chain Manager',
      approvedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    InventoryAdjustment(
      id: '6',
      itemId: '106',
      itemName: 'Milk Cartons (1L)',
      adjustmentType: AdjustmentType.system_correction,
      quantity: 50.0,
      previousQuantity: 150.0,
      adjustedQuantity: 200.0,
      reason: 'System data correction',
      performedBy: 'System Admin',
      performedAt: DateTime.now().subtract(const Duration(hours: 4)),
      notes: 'Correcting system count after inventory audit',
      categoryId: '5',
      categoryName: 'Packaging Materials',
      approvalStatus: AdjustmentApprovalStatus.approved,
      approvedBy: 'IT Manager',
      approvedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    InventoryAdjustment(
      id: '7',
      itemId: '107',
      itemName: 'Cream (500ml)',
      adjustmentType: AdjustmentType.loss,
      quantity: -2.0,
      previousQuantity: 18.0,
      adjustedQuantity: 16.0,
      reason: 'Spillage during transfer',
      performedBy: 'Warehouse Staff',
      performedAt: DateTime.now().subtract(const Duration(hours: 2)),
      categoryId: '1',
      categoryName: 'Dairy Products',
      approvalStatus: AdjustmentApprovalStatus.pending,
    ),
    InventoryAdjustment(
      id: '8',
      itemId: '108',
      itemName: 'Whey Protein',
      adjustmentType: AdjustmentType.transfer,
      quantity: -20.0,
      previousQuantity: 100.0,
      adjustedQuantity: 80.0,
      reason: 'Transfer to production',
      performedBy: 'Production Manager',
      performedAt: DateTime.now().subtract(const Duration(hours: 1)),
      notes: 'Transferred for cheese production batch #2023-45',
      documentReference: 'TRF-2023-0089',
      categoryId: '6',
      categoryName: 'Ingredients',
      approvalStatus: AdjustmentApprovalStatus.approved,
      approvedBy: 'Operations Director',
      approvedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<InventoryAdjustment>> getAdjustments({
    DateTime? startDate,
    DateTime? endDate,
    AdjustmentType? type,
    String? itemId,
    String? categoryId,
    AdjustmentApprovalStatus? status,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return _adjustments.where((adjustment) {
      bool matchesStartDate = startDate == null ||
          adjustment.performedAt.isAfter(startDate) ||
          adjustment.performedAt.isAtSameMomentAs(startDate);

      bool matchesEndDate = endDate == null ||
          adjustment.performedAt.isBefore(endDate) ||
          adjustment.performedAt.isAtSameMomentAs(endDate);

      bool matchesType = type == null || adjustment.adjustmentType == type;

      bool matchesItem = itemId == null || adjustment.itemId == itemId;

      bool matchesCategory =
          categoryId == null || adjustment.categoryId == categoryId;

      bool matchesStatus =
          status == null || adjustment.approvalStatus == status;

      return matchesStartDate &&
          matchesEndDate &&
          matchesType &&
          matchesItem &&
          matchesCategory &&
          matchesStatus;
    }).toList();
  }

  @override
  Future<InventoryAdjustment?> getAdjustment(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _adjustments.firstWhere((adjustment) => adjustment.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<InventoryAdjustment> createAdjustment(
      InventoryAdjustment adjustment) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final newId = adjustment.id.isEmpty ? const Uuid().v4() : adjustment.id;
    final now = DateTime.now();

    final newAdjustment = adjustment.copyWith(
      id: newId,
      performedAt: now,
    );

    _adjustments.add(newAdjustment);
    return newAdjustment;
  }

  @override
  Future<void> updateAdjustmentStatus(
    String id,
    AdjustmentApprovalStatus status,
    String approverName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _adjustments.indexWhere((adjustment) => adjustment.id == id);
    if (index == -1) {
      throw Exception('Adjustment not found: $id');
    }

    _adjustments[index] = _adjustments[index].copyWith(
      approvalStatus: status,
      approvedBy: approverName,
      approvedAt: DateTime.now(),
    );
  }

  @override
  Future<List<InventoryAdjustment>> getAdjustmentsForItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return _adjustments
        .where((adjustment) => adjustment.itemId == itemId)
        .toList();
  }

  @override
  Future<List<InventoryAdjustment>> getPendingAdjustments() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _adjustments
        .where((adjustment) =>
            adjustment.approvalStatus == AdjustmentApprovalStatus.pending)
        .toList();
  }

  @override
  Future<Map<AdjustmentType, int>> getAdjustmentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final filteredAdjustments = _adjustments.where((adjustment) {
      bool matchesStartDate = startDate == null ||
          adjustment.performedAt.isAfter(startDate) ||
          adjustment.performedAt.isAtSameMomentAs(startDate);

      bool matchesEndDate = endDate == null ||
          adjustment.performedAt.isBefore(endDate) ||
          adjustment.performedAt.isAtSameMomentAs(endDate);

      return matchesStartDate && matchesEndDate;
    }).toList();

    final stats = <AdjustmentType, int>{};

    for (final type in AdjustmentType.values) {
      stats[type] =
          filteredAdjustments.where((a) => a.adjustmentType == type).length;
    }

    return stats;
  }

  @override
  Future<Map<AdjustmentType, double>> getTotalQuantityByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredAdjustments = _adjustments.where((adjustment) {
      bool matchesStartDate = startDate == null ||
          adjustment.performedAt.isAfter(startDate) ||
          adjustment.performedAt.isAtSameMomentAs(startDate);

      bool matchesEndDate = endDate == null ||
          adjustment.performedAt.isBefore(endDate) ||
          adjustment.performedAt.isAtSameMomentAs(endDate);

      return matchesStartDate && matchesEndDate;
    }).toList();

    final quantities = <AdjustmentType, double>{};

    for (final type in AdjustmentType.values) {
      quantities[type] = filteredAdjustments
          .where((a) => a.adjustmentType == type)
          .fold(0.0, (sum, a) => sum + a.quantity.abs());
    }

    return quantities;
  }
}
*/
