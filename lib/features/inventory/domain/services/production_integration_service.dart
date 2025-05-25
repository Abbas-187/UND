import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../factory/data/models/production_order_model.dart';
import '../../../factory/domain/providers/production_provider.dart';
import '../usecases/production/issue_materials_to_production_usecase.dart';
import '../usecases/production/receive_finished_goods_usecase.dart';
import '../repositories/inventory_repository.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;

/// Complete production integration result
class ProductionIntegrationResult {
  const ProductionIntegrationResult({
    required this.success,
    required this.productionOrderId,
    this.materialIssuanceResult,
    this.finishedGoodsResult,
    this.totalMaterialCost = 0.0,
    this.totalFinishedGoodsValue = 0.0,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool success;
  final String productionOrderId;
  final ProductionMaterialIssuanceResult? materialIssuanceResult;
  final FinishedGoodsReceiptResult? finishedGoodsResult;
  final double totalMaterialCost;
  final double totalFinishedGoodsValue;
  final List<String> errors;
  final List<String> warnings;

  double get netProductionValue => totalFinishedGoodsValue - totalMaterialCost;
}

/// Production status for inventory integration
enum ProductionStatus {
  planned,
  materialsIssued,
  inProgress,
  completed,
  cancelled,
}

/// Service for comprehensive production-inventory integration
class ProductionIntegrationService {
  const ProductionIntegrationService(
    this._repository,
    this._issueMaterialsUseCase,
    this._receiveFinishedGoodsUseCase,
    this._ref,
  );

  final InventoryRepository _repository;
  final IssueMaterialsToProductionUseCase _issueMaterialsUseCase;
  final ReceiveFinishedGoodsUseCase _receiveFinishedGoodsUseCase;
  final Ref _ref;

  /// Handle production start - issue materials to production
  Future<ProductionIntegrationResult> handleProductionStart({
    required String productionOrderId,
    required String issuedBy,
    String warehouseId = 'MAIN',
    bool allowPartialIssuance = false,
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Get production order details
      final productionOrder = await _ref.read(
        productionOrderByIdProvider(productionOrderId).future,
      );

      // Validate production order
      if (productionOrder.status != 'planned' &&
          productionOrder.status != 'approved') {
        errors.add(
            'Production order must be in planned or approved status to start');
        return ProductionIntegrationResult(
          success: false,
          productionOrderId: productionOrderId,
          errors: errors,
        );
      }

      // Check if materials are already issued
      final existingIssuance =
          await _checkExistingMaterialIssuance(productionOrderId);
      if (existingIssuance) {
        warnings.add(
            'Materials may have already been issued for this production order');
      }

      // Prepare material issuance data
      final materialsToIssue =
          await _prepareMaterialIssuanceData(productionOrder);

      if (materialsToIssue.isEmpty) {
        warnings.add('No materials required for this production order');
        return ProductionIntegrationResult(
          success: true,
          productionOrderId: productionOrderId,
          warnings: warnings,
        );
      }

      // Issue materials to production
      final materialResult = await _issueMaterialsUseCase.execute(
        productionOrderId: productionOrderId,
        materialsToIssue: materialsToIssue,
        issuedBy: issuedBy,
        warehouseId: warehouseId,
        allowPartialIssuance: allowPartialIssuance,
        notes: notes,
      );

      errors.addAll(materialResult.errors);
      warnings.addAll(materialResult.warnings);

      return ProductionIntegrationResult(
        success: materialResult.success,
        productionOrderId: productionOrderId,
        materialIssuanceResult: materialResult,
        totalMaterialCost: materialResult.totalCost,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Error handling production start: $e');
      return ProductionIntegrationResult(
        success: false,
        productionOrderId: productionOrderId,
        errors: errors,
        warnings: warnings,
      );
    }
  }

  /// Handle production completion - receive finished goods
  Future<ProductionIntegrationResult> handleProductionCompletion({
    required String productionOrderId,
    required double quantityProduced,
    required String receivedBy,
    String warehouseId = 'MAIN',
    double? laborCost,
    double? overheadCost,
    String? qualityStatus,
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Get production order details
      final productionOrder = await _ref.read(
        productionOrderByIdProvider(productionOrderId).future,
      );

      // Validate production order
      if (productionOrder.status != 'in_progress' &&
          productionOrder.status != 'inProgress') {
        errors.add('Production order must be in progress to complete');
        return ProductionIntegrationResult(
          success: false,
          productionOrderId: productionOrderId,
          errors: errors,
        );
      }

      // Check if finished goods are already received
      final existingReceipt =
          await _checkExistingFinishedGoodsReceipt(productionOrderId);
      if (existingReceipt) {
        warnings.add(
            'Finished goods may have already been received for this production order');
      }

      // Calculate material costs from issuance
      final materialCost = await _calculateMaterialCosts(productionOrderId);

      // Calculate finished goods cost
      final finishedGoodsCost =
          ReceiveFinishedGoodsUseCase.calculateFinishedGoodsCost(
        totalMaterialCost: materialCost,
        laborCost: laborCost ?? 0.0,
        overheadCost: overheadCost ?? 0.0,
        quantityProduced: quantityProduced,
      );

      // Generate batch number
      final batchNumber = _generateBatchNumber(productionOrder);

      // Calculate expiry date if applicable
      final expiryDate = await _calculateExpiryDate(
        productionOrder.productId,
        DateTime.now(),
      );

      // Prepare finished goods receipt data
      final finishedGoodsData = FinishedGoodsReceiptData(
        finishedGoodInventoryItemId: productionOrder.productId,
        quantityProduced: quantityProduced,
        newBatchLotNumber: batchNumber,
        finishedGoodProductionDate: DateTime.now(),
        finishedGoodExpirationDate: expiryDate,
        costOfFinishedGood: finishedGoodsCost,
        qualityStatus: qualityStatus ?? 'PENDING_QC',
        notes: notes,
      );

      // Receive finished goods
      final finishedGoodsResult = await _receiveFinishedGoodsUseCase.execute(
        productionOrderId: productionOrderId,
        finishedGoodsData: finishedGoodsData,
        receivedBy: receivedBy,
        warehouseId: warehouseId,
        notes: notes,
      );

      errors.addAll(finishedGoodsResult.errors);
      warnings.addAll(finishedGoodsResult.warnings);

      return ProductionIntegrationResult(
        success: finishedGoodsResult.success,
        productionOrderId: productionOrderId,
        finishedGoodsResult: finishedGoodsResult,
        totalMaterialCost: materialCost,
        totalFinishedGoodsValue: finishedGoodsResult.totalValue,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Error handling production completion: $e');
      return ProductionIntegrationResult(
        success: false,
        productionOrderId: productionOrderId,
        errors: errors,
        warnings: warnings,
      );
    }
  }

  /// Handle complete production cycle (start to finish)
  Future<ProductionIntegrationResult> handleCompleteProductionCycle({
    required String productionOrderId,
    required double quantityProduced,
    required String operatorId,
    String warehouseId = 'MAIN',
    bool allowPartialIssuance = false,
    double? laborCost,
    double? overheadCost,
    String? qualityStatus,
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Step 1: Issue materials
      final startResult = await handleProductionStart(
        productionOrderId: productionOrderId,
        issuedBy: operatorId,
        warehouseId: warehouseId,
        allowPartialIssuance: allowPartialIssuance,
        notes: notes,
      );

      if (!startResult.success) {
        return startResult;
      }

      errors.addAll(startResult.errors);
      warnings.addAll(startResult.warnings);

      // Step 2: Complete production and receive finished goods
      final completionResult = await handleProductionCompletion(
        productionOrderId: productionOrderId,
        quantityProduced: quantityProduced,
        receivedBy: operatorId,
        warehouseId: warehouseId,
        laborCost: laborCost,
        overheadCost: overheadCost,
        qualityStatus: qualityStatus,
        notes: notes,
      );

      errors.addAll(completionResult.errors);
      warnings.addAll(completionResult.warnings);

      return ProductionIntegrationResult(
        success: completionResult.success,
        productionOrderId: productionOrderId,
        materialIssuanceResult: startResult.materialIssuanceResult,
        finishedGoodsResult: completionResult.finishedGoodsResult,
        totalMaterialCost: startResult.totalMaterialCost,
        totalFinishedGoodsValue: completionResult.totalFinishedGoodsValue,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Error handling complete production cycle: $e');
      return ProductionIntegrationResult(
        success: false,
        productionOrderId: productionOrderId,
        errors: errors,
        warnings: warnings,
      );
    }
  }

  /// Check material availability for production order
  Future<Map<String, dynamic>> checkMaterialAvailability({
    required String productionOrderId,
    String warehouseId = 'MAIN',
  }) async {
    try {
      final productionOrder = await _ref.read(
        productionOrderByIdProvider(productionOrderId).future,
      );

      final results = <String, dynamic>{};
      bool allAvailable = true;

      if (productionOrder.requiredMaterials?.isNotEmpty ?? false) {
        for (final material in productionOrder.requiredMaterials!) {
          final inventoryItem =
              await _repository.getInventoryItem(material.materialId);
          if (inventoryItem == null) {
            results[material.materialId] = {
              'required': material.requiredQuantity,
              'available': 0.0,
              'isAvailable': false,
              'shortage': material.requiredQuantity,
              'error': 'Item not found in inventory',
            };
            allAvailable = false;
            continue;
          }

          final available = inventoryItem.quantity;
          final isAvailable = available >= material.requiredQuantity;

          results[material.materialId] = {
            'itemName': inventoryItem.name,
            'required': material.requiredQuantity,
            'available': available,
            'isAvailable': isAvailable,
            'shortage':
                isAvailable ? 0.0 : material.requiredQuantity - available,
          };

          if (!isAvailable) {
            allAvailable = false;
          }
        }
      }

      return {
        'productionOrderId': productionOrderId,
        'allMaterialsAvailable': allAvailable,
        'materials': results,
        'checkedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'productionOrderId': productionOrderId,
        'allMaterialsAvailable': false,
        'materials': {},
        'error': 'Error checking material availability: $e',
        'checkedAt': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Prepare material issuance data from production order
  Future<List<MaterialIssuanceData>> _prepareMaterialIssuanceData(
    ProductionOrderModel productionOrder,
  ) async {
    final materialsToIssue = <MaterialIssuanceData>[];

    if (productionOrder.requiredMaterials?.isNotEmpty ?? false) {
      for (final material in productionOrder.requiredMaterials!) {
        materialsToIssue.add(MaterialIssuanceData(
          inventoryItemId: material.materialId,
          quantityToConsume: material.requiredQuantity,
          notes:
              'Material for production order: ${productionOrder.orderNumber}',
        ));
      }
    }

    return materialsToIssue;
  }

  /// Check if materials have already been issued
  Future<bool> _checkExistingMaterialIssuance(String productionOrderId) async {
    try {
      // This would check for existing inventory movements
      // For now, return false (no existing issuance)
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if finished goods have already been received
  Future<bool> _checkExistingFinishedGoodsReceipt(
      String productionOrderId) async {
    try {
      // This would check for existing inventory movements
      // For now, return false (no existing receipt)
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Calculate total material costs from issuance
  Future<double> _calculateMaterialCosts(String productionOrderId) async {
    try {
      // This would query inventory movements for material costs
      // For now, return a placeholder value
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Generate batch number for finished goods
  String _generateBatchNumber(ProductionOrderModel productionOrder) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'FG-$dateStr-$timeStr-${productionOrder.orderNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}';
  }

  /// Calculate expiry date for finished goods
  Future<DateTime?> _calculateExpiryDate(
      String productId, DateTime productionDate) async {
    try {
      final inventoryItem = await _repository.getInventoryItem(productId);
      if (inventoryItem?.additionalAttributes?['shelfLifeDays'] != null) {
        final shelfLifeDays =
            inventoryItem!.additionalAttributes!['shelfLifeDays'] as int;
        return ReceiveFinishedGoodsUseCase.calculateExpiryDate(
          productionDate: productionDate,
          shelfLifeDays: shelfLifeDays,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Provider for ProductionIntegrationService
final productionIntegrationServiceProvider =
    Provider<ProductionIntegrationService>((ref) {
  return ProductionIntegrationService(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ref.watch(issueMaterialsToProductionUseCaseProvider),
    ref.watch(receiveFinishedGoodsUseCaseProvider),
    ref,
  );
});
