import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importing Riverpod for Ref

import '../../../factory/data/models/material_requisition_item_model.dart'; // Use requisition item model
import '../../../factory/data/models/production_order_model.dart'; // Updated import path
import '../../../factory/domain/providers/production_provider.dart';
import '../../data/providers/material_requisition_provider.dart';
import '../providers/inventory_provider.dart';

/// Handles the specific integration between Inventory and Factory modules
class FactoryIntegration {
  FactoryIntegration(this._ref);
  final Ref _ref; // Updated to use Ref

  /// Checks material availability for a production order
  Future<Map<String, dynamic>> checkMaterialAvailability(
      String productionOrderId) async {
    final productionOrder =
        await _ref.read(productionOrderByIdProvider(productionOrderId).future);
    final inventoryState = _ref.read(inventoryProvider.notifier);

    final results = <String, dynamic>{};
    var allAvailable = true;

    // Check each required material
    if (productionOrder.requiredMaterials?.isNotEmpty ?? false) {
      for (final material in productionOrder.requiredMaterials!) {
        final available =
            await inventoryState.getAvailableStock(material.materialId);
        final isAvailable = available >= material.requiredQuantity;

        results[material.materialId] = {
          'required': material.requiredQuantity,
          'available': available,
          'isAvailable': isAvailable,
          'shortage': isAvailable ? 0 : material.requiredQuantity - available,
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
    };
  }

  /// Reserves materials for production
  Future<void> reserveMaterialsForProduction(String productionOrderId) async {
    final productionOrder =
        await _ref.read(productionOrderByIdProvider(productionOrderId).future);
    final inventoryState = _ref.read(inventoryProvider.notifier);

    if (productionOrder.requiredMaterials?.isNotEmpty ?? false) {
      for (final material in productionOrder.requiredMaterials!) {
        await inventoryState.reserveStock(
          itemId: material.materialId,
          quantity: material.requiredQuantity,
          reason: 'Production: $productionOrderId',
          referenceId: productionOrderId,
        );
      }
    }
  }

  /// Initiates a material requisition for a production order
  Future<String> createMaterialRequisition(String productionOrderId) async {
    final productionOrder =
        await _ref.read(productionOrderByIdProvider(productionOrderId).future);

    // Find best locations for picking materials
    final pickingLocations =
        await _fetchOptimalPickingLocations(productionOrder);

    // Convert required materials to requisition item models
    List<MaterialRequisitionItemModel> materials = [];
    if (productionOrder.requiredMaterials != null) {
      materials = productionOrder.requiredMaterials!
          .map((material) => MaterialRequisitionItemModel(
                materialId: material.materialId,
                quantity: material.requiredQuantity,
                unit: 'each',
              ))
          .toList();
    }

    // Create material requisition in the factory module
    final requisitionProvider = _ref.read(materialRequisitionProvider.notifier);
    final requisitionId = await requisitionProvider.createMaterialRequisition(
      productionOrderId: productionOrderId,
      scheduledDate: productionOrder.scheduledDate,
      materials: materials,
      pickingLocations: pickingLocations,
    );

    return requisitionId;
  }

  /// Calculates optimal locations for picking materials based on FEFO
  Future<Map<String, List<Map<String, dynamic>>>> _fetchOptimalPickingLocations(
      ProductionOrderModel order) async {
    final inventoryState = _ref.read(inventoryProvider.notifier);
    final result = <String, List<Map<String, dynamic>>>{};

    if (order.requiredMaterials?.isNotEmpty ?? false) {
      for (final material in order.requiredMaterials!) {
        final locations = await inventoryState.getOptimalPickingLocations(
          itemId: material.materialId,
          quantity: material.requiredQuantity,
          useFEFO: true, // First Expired, First Out for dairy
        );

        result[material.materialId] = locations;
      }
    }

    return result;
  }
}

/// Provider for factory integration
final factoryIntegrationProvider = Provider<FactoryIntegration>((ref) {
  return FactoryIntegration(ref);
});
