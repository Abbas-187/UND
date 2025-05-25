import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../entities/cost_layer.dart';
import '../../entities/inventory_item.dart';
import '../../repositories/inventory_repository.dart';
import '../../providers/inventory_repository_provider.dart' as repo_provider;
import '../../../data/models/inventory_movement_model.dart';
import '../../../data/models/inventory_movement_item_model.dart';
import '../process_inventory_movement_usecase.dart';

/// Data for material issuance to production
class MaterialIssuanceData {
  const MaterialIssuanceData({
    required this.inventoryItemId,
    required this.quantityToConsume,
    this.batchLotNumber,
    this.notes,
  });

  final String inventoryItemId;
  final double quantityToConsume;
  final String? batchLotNumber; // Optional specific batch requirement
  final String? notes;
}

/// Result of material issuance
class MaterialIssuanceResult {
  const MaterialIssuanceResult({
    required this.inventoryItemId,
    required this.quantityIssued,
    required this.actualCostIncurred,
    required this.batchesUsed,
    this.shortfall = 0.0,
  });

  final String inventoryItemId;
  final double quantityIssued;
  final double actualCostIncurred;
  final List<BatchUsageInfo> batchesUsed;
  final double
      shortfall; // Quantity that couldn't be issued due to insufficient stock
}

/// Information about batch usage during issuance
class BatchUsageInfo {
  const BatchUsageInfo({
    required this.batchLotNumber,
    required this.quantityUsed,
    required this.costPerUnit,
    required this.totalCost,
    this.expirationDate,
    this.productionDate,
  });

  final String batchLotNumber;
  final double quantityUsed;
  final double costPerUnit;
  final double totalCost;
  final DateTime? expirationDate;
  final DateTime? productionDate;
}

/// Complete result of production material issuance
class ProductionMaterialIssuanceResult {
  const ProductionMaterialIssuanceResult({
    required this.success,
    required this.productionOrderId,
    required this.movementId,
    required this.materialResults,
    required this.totalCost,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool success;
  final String productionOrderId;
  final String? movementId;
  final List<MaterialIssuanceResult> materialResults;
  final double totalCost;
  final List<String> errors;
  final List<String> warnings;
}

/// Use case for issuing materials to production with FIFO/FEFO logic
class IssueMaterialsToProductionUseCase {
  const IssueMaterialsToProductionUseCase(
    this._repository,
    this._processMovementUseCase,
  );

  final InventoryRepository _repository;
  final ProcessInventoryMovementUseCase _processMovementUseCase;

  /// Issue materials to production
  Future<ProductionMaterialIssuanceResult> execute({
    required String productionOrderId,
    required List<MaterialIssuanceData> materialsToIssue,
    required String issuedBy,
    String warehouseId = 'MAIN',
    CostingMethod costingMethod = CostingMethod.fifo,
    bool allowPartialIssuance = false,
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];
    final materialResults = <MaterialIssuanceResult>[];
    double totalCost = 0.0;

    try {
      // Validate production order exists
      // Note: This would typically validate against production order repository
      if (productionOrderId.isEmpty) {
        errors.add('Production order ID is required');
        return ProductionMaterialIssuanceResult(
          success: false,
          productionOrderId: productionOrderId,
          movementId: null,
          materialResults: [],
          totalCost: 0.0,
          errors: errors,
        );
      }

      // Process each material
      for (final materialData in materialsToIssue) {
        try {
          final result = await _issueMaterial(
            materialData: materialData,
            warehouseId: warehouseId,
            costingMethod: costingMethod,
            allowPartialIssuance: allowPartialIssuance,
          );

          materialResults.add(result);
          totalCost += result.actualCostIncurred;

          if (result.shortfall > 0) {
            warnings.add(
              'Partial issuance for ${materialData.inventoryItemId}: '
              'requested ${materialData.quantityToConsume}, '
              'issued ${result.quantityIssued}, '
              'shortfall ${result.shortfall}',
            );
          }
        } catch (e) {
          errors.add(
              'Error issuing material ${materialData.inventoryItemId}: $e');
          if (!allowPartialIssuance) {
            return ProductionMaterialIssuanceResult(
              success: false,
              productionOrderId: productionOrderId,
              movementId: null,
              materialResults: materialResults,
              totalCost: totalCost,
              errors: errors,
              warnings: warnings,
            );
          }
        }
      }

      // Create inventory movement if any materials were issued
      String? movementId;
      if (materialResults.any((r) => r.quantityIssued > 0)) {
        movementId = await _createInventoryMovement(
          productionOrderId: productionOrderId,
          materialResults: materialResults,
          warehouseId: warehouseId,
          issuedBy: issuedBy,
          notes: notes,
        );
      }

      final success = errors.isEmpty && materialResults.isNotEmpty;

      return ProductionMaterialIssuanceResult(
        success: success,
        productionOrderId: productionOrderId,
        movementId: movementId,
        materialResults: materialResults,
        totalCost: totalCost,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Unexpected error during material issuance: $e');
      return ProductionMaterialIssuanceResult(
        success: false,
        productionOrderId: productionOrderId,
        movementId: null,
        materialResults: materialResults,
        totalCost: totalCost,
        errors: errors,
        warnings: warnings,
      );
    }
  }

  /// Issue a single material using FIFO/FEFO logic
  Future<MaterialIssuanceResult> _issueMaterial({
    required MaterialIssuanceData materialData,
    required String warehouseId,
    required CostingMethod costingMethod,
    required bool allowPartialIssuance,
  }) async {
    final inventoryItem =
        await _repository.getInventoryItem(materialData.inventoryItemId);
    if (inventoryItem == null) {
      throw Exception(
          'Inventory item not found: ${materialData.inventoryItemId}');
    }

    // Get available cost layers
    final costLayers = await _repository.getAvailableCostLayers(
      materialData.inventoryItemId,
      warehouseId,
      costingMethod,
    );

    if (costLayers.isEmpty) {
      throw Exception('No available stock for item: ${inventoryItem.name}');
    }

    // Filter by specific batch if required
    final availableLayers = materialData.batchLotNumber != null
        ? costLayers
            .where(
                (layer) => layer.batchLotNumber == materialData.batchLotNumber)
            .toList()
        : costLayers;

    if (availableLayers.isEmpty) {
      throw Exception(
        'No available stock for item: ${inventoryItem.name}'
        '${materialData.batchLotNumber != null ? ' in batch ${materialData.batchLotNumber}' : ''}',
      );
    }

    // Sort layers based on costing method and expiry (FEFO for perishables)
    _sortCostLayers(
        availableLayers, costingMethod, inventoryItem.expiryDate != null);

    // Calculate total available quantity
    final totalAvailable = availableLayers.fold<double>(
      0.0,
      (sum, layer) => sum + layer.remainingQuantity,
    );

    final requestedQuantity = materialData.quantityToConsume;
    final quantityToIssue = totalAvailable >= requestedQuantity
        ? requestedQuantity
        : (allowPartialIssuance ? totalAvailable : 0.0);

    if (quantityToIssue == 0.0) {
      throw Exception(
        'Insufficient stock for item: ${inventoryItem.name}. '
        'Available: $totalAvailable, Required: $requestedQuantity',
      );
    }

    // Issue from cost layers
    final batchesUsed = <BatchUsageInfo>[];
    double remainingToIssue = quantityToIssue;
    double totalCost = 0.0;

    for (final layer in availableLayers) {
      if (remainingToIssue <= 0) break;

      final quantityFromLayer = remainingToIssue > layer.remainingQuantity
          ? layer.remainingQuantity
          : remainingToIssue;

      final costFromLayer = quantityFromLayer * layer.costAtTransaction;
      totalCost += costFromLayer;

      batchesUsed.add(BatchUsageInfo(
        batchLotNumber: layer.batchLotNumber,
        quantityUsed: quantityFromLayer,
        costPerUnit: layer.costAtTransaction,
        totalCost: costFromLayer,
        expirationDate: layer.expirationDate,
        productionDate: layer.productionDate,
      ));

      // Update layer remaining quantity
      final updatedLayer = layer.copyWith(
        remainingQuantity: layer.remainingQuantity - quantityFromLayer,
      );
      await _repository.saveCostLayer(updatedLayer);

      // Record consumption
      final consumption = CostLayerConsumption(
        id: 'consumption_${DateTime.now().millisecondsSinceEpoch}_${layer.id}',
        costLayerId: layer.id,
        itemId: materialData.inventoryItemId,
        warehouseId: warehouseId,
        movementId: '', // Will be updated when movement is created
        movementDate: DateTime.now(),
        quantity: quantityFromLayer,
        cost: costFromLayer,
        createdAt: DateTime.now(),
      );
      await _repository.saveCostLayerConsumption(consumption);

      remainingToIssue -= quantityFromLayer;
    }

    // Update inventory quantity
    await _repository.updateInventoryQuantity(
      materialData.inventoryItemId,
      warehouseId,
      -quantityToIssue,
    );

    return MaterialIssuanceResult(
      inventoryItemId: materialData.inventoryItemId,
      quantityIssued: quantityToIssue,
      actualCostIncurred: totalCost,
      batchesUsed: batchesUsed,
      shortfall: requestedQuantity - quantityToIssue,
    );
  }

  /// Sort cost layers based on costing method and FEFO for perishables
  void _sortCostLayers(
    List<CostLayer> layers,
    CostingMethod costingMethod,
    bool isPerishable,
  ) {
    if (isPerishable) {
      // FEFO (First Expired, First Out) for perishable items
      layers.sort((a, b) {
        // Items without expiry date go last
        if (a.expirationDate == null && b.expirationDate == null) {
          return costingMethod == CostingMethod.fifo
              ? a.movementDate.compareTo(b.movementDate)
              : b.movementDate.compareTo(a.movementDate);
        }
        if (a.expirationDate == null) return 1;
        if (b.expirationDate == null) return -1;
        return a.expirationDate!.compareTo(b.expirationDate!);
      });
    } else {
      // Standard FIFO/LIFO for non-perishable items
      if (costingMethod == CostingMethod.fifo) {
        layers.sort((a, b) => a.movementDate.compareTo(b.movementDate));
      } else {
        layers.sort((a, b) => b.movementDate.compareTo(a.movementDate));
      }
    }
  }

  /// Create inventory movement for the issuance
  Future<String> _createInventoryMovement({
    required String productionOrderId,
    required List<MaterialIssuanceResult> materialResults,
    required String warehouseId,
    required String issuedBy,
    String? notes,
  }) async {
    final movementId = const Uuid().v4();
    final now = DateTime.now();

    // Create movement items
    final items = <InventoryMovementItemModel>[];

    for (final result in materialResults) {
      if (result.quantityIssued <= 0) continue;

      final inventoryItem =
          await _repository.getInventoryItem(result.inventoryItemId);
      if (inventoryItem == null) continue;

      // Create items for each batch used
      for (final batchUsage in result.batchesUsed) {
        final item = InventoryMovementItemModel(
          id: const Uuid().v4(),
          itemId: result.inventoryItemId,
          itemCode: inventoryItem.sapCode,
          itemName: inventoryItem.name,
          quantity: -batchUsage.quantityUsed, // Negative for outbound
          uom: inventoryItem.unit,
          batchLotNumber: batchUsage.batchLotNumber,
          expirationDate: batchUsage.expirationDate,
          productionDate: batchUsage.productionDate,
          costAtTransaction: batchUsage.costPerUnit,
          notes: notes,
        );

        items.add(item);
      }
    }

    // Create the movement
    final movement = InventoryMovementModel(
      id: movementId,
      documentNumber: 'PI-${now.millisecondsSinceEpoch}',
      movementType: InventoryMovementType.productionConsumption,
      warehouseId: warehouseId,
      movementDate: now,
      items: items,
      createdAt: now,
      updatedAt: now,
      initiatingEmployeeId: issuedBy,
      reasonNotes:
          notes ?? 'Material issuance for production order: $productionOrderId',
      referenceType: 'PRODUCTION_ORDER',
      referenceNumber: productionOrderId,
      referenceDocuments: ['PRODUCTION_ORDER:$productionOrderId'],
      status: InventoryMovementStatus.completed,
      approvedById: issuedBy,
      approvedAt: now,
    );

    // Process the movement
    final result = await _processMovementUseCase.execute(
      movement: movement,
      validateBatchTracking: true,
      costingMethod: CostingMethod.fifo,
    );

    if (!result.success) {
      throw Exception(
          'Failed to process inventory movement: ${result.errors.join(', ')}');
    }

    return movementId;
  }
}

/// Provider for IssueMaterialsToProductionUseCase
final issueMaterialsToProductionUseCaseProvider =
    Provider<IssueMaterialsToProductionUseCase>((ref) {
  return IssueMaterialsToProductionUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ProcessInventoryMovementUseCase(
      ref.watch(repo_provider.inventoryRepositoryProvider),
    ),
  );
});
