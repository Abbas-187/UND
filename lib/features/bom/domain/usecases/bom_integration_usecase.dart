import '../../../factory/production/domain/repositories/production_repository.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../procurement/domain/repositories/procurement_repository.dart';
import '../../../sales/domain/repositories/sales_repository.dart';
import '../entities/bom_item.dart';
import '../repositories/bom_repository.dart';

/// Result class for BOM integration operations
class BomIntegrationResult {
  const BomIntegrationResult({
    required this.success,
    this.bomId,
    this.errors = const [],
    this.warnings = const [],
    this.suggestions = const [],
  });

  final bool success;
  final String? bomId;
  final List<String> errors;
  final List<String> warnings;
  final List<String> suggestions;
}

/// Comprehensive use case for BOM integration with all modules
class BomIntegrationUseCase {
  const BomIntegrationUseCase({
    required this.bomRepository,
    required this.inventoryRepository,
    required this.procurementRepository,
    required this.productionRepository,
    required this.salesRepository,
  });

  final BomRepository bomRepository;
  final InventoryRepository inventoryRepository;
  final ProcurementRepository procurementRepository;
  final ProductionRepository productionRepository;
  final SalesRepository salesRepository;

  /// Validate BOM against inventory availability
  Future<BomIntegrationResult> validateBomInventoryAvailability({
    required String bomId,
    required double batchSize,
    String? warehouseId,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];
    final suggestions = <String>[];

    try {
      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        return BomIntegrationResult(
          success: false,
          errors: ['BOM not found: $bomId'],
        );
      }

      // Check inventory availability for each BOM item
      for (final bomItem in bom.items.where((item) => item.isActive)) {
        final requiredQuantity = bomItem.calculateActualQuantity(batchSize);

        // Get current inventory level
        final inventoryItem = await inventoryRepository.getItem(bomItem.itemId);
        if (inventoryItem == null) {
          errors.add('Inventory item not found: ${bomItem.itemCode}');
          continue;
        }

        // Check availability
        if (inventoryItem.quantity < requiredQuantity) {
          final shortage = requiredQuantity - inventoryItem.quantity;
          errors.add('Insufficient inventory for ${bomItem.itemCode}: '
              'Required: $requiredQuantity ${bomItem.unit}, '
              'Available: ${inventoryItem.quantity} ${inventoryItem.unit}, '
              'Shortage: $shortage ${bomItem.unit}');

          // Suggest procurement
          suggestions.add(
              'Create purchase order for ${bomItem.itemCode}: $shortage ${bomItem.unit}');
        }

        // Check expiry dates for perishable items
        if (inventoryItem.expiryDate != null) {
          final daysToExpiry =
              inventoryItem.expiryDate!.difference(DateTime.now()).inDays;
          if (daysToExpiry < 7) {
            warnings
                .add('Item ${bomItem.itemCode} expires in $daysToExpiry days');
          }
        }

        // Check reorder points
        if (inventoryItem.quantity <= inventoryItem.reorderPoint) {
          warnings.add('Item ${bomItem.itemCode} is below reorder point');
        }
      }

      return BomIntegrationResult(
        success: errors.isEmpty,
        bomId: bomId,
        errors: errors,
        warnings: warnings,
        suggestions: suggestions,
      );
    } catch (e) {
      return BomIntegrationResult(
        success: false,
        errors: ['Error validating BOM inventory: ${e.toString()}'],
      );
    }
  }

  /// Create procurement requests based on BOM requirements
  Future<BomIntegrationResult> createProcurementFromBom({
    required String bomId,
    required double batchSize,
    String? requestedBy,
    DateTime? requiredDate,
  }) async {
    final errors = <String>[];
    final suggestions = <String>[];

    try {
      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        return BomIntegrationResult(
          success: false,
          errors: ['BOM not found: $bomId'],
        );
      }

      // Group items by supplier
      final Map<String, List<BomItem>> itemsBySupplier = {};

      for (final bomItem in bom.items.where((item) => item.isActive)) {
        final supplier = bomItem.supplierCode ?? 'Unknown';
        itemsBySupplier.putIfAbsent(supplier, () => []).add(bomItem);
      }

      // Create purchase requests for each supplier
      for (final entry in itemsBySupplier.entries) {
        final supplierCode = entry.key;
        final items = entry.value;

        final purchaseRequestItems = items.map((bomItem) {
          final requiredQuantity = bomItem.calculateActualQuantity(batchSize);
          return {
            'itemId': bomItem.itemId,
            'itemCode': bomItem.itemCode,
            'itemName': bomItem.itemName,
            'quantity': requiredQuantity,
            'unit': bomItem.unit,
            'estimatedCost': bomItem.costPerUnit * requiredQuantity,
            'bomReference': bomId,
          };
        }).toList();

        // Create purchase request
        await procurementRepository.createPurchaseRequest({
          'supplierCode': supplierCode,
          'items': purchaseRequestItems,
          'requestedBy': requestedBy,
          'requiredDate': requiredDate?.toIso8601String(),
          'bomReference': bomId,
          'batchSize': batchSize,
          'priority': 'Normal',
          'notes': 'Auto-generated from BOM: ${bom.bomCode}',
        });

        suggestions.add(
            'Created purchase request for supplier $supplierCode with ${items.length} items');
      }

      return BomIntegrationResult(
        success: true,
        bomId: bomId,
        suggestions: suggestions,
      );
    } catch (e) {
      return BomIntegrationResult(
        success: false,
        errors: ['Error creating procurement from BOM: ${e.toString()}'],
      );
    }
  }

  /// Create production order from BOM
  Future<BomIntegrationResult> createProductionOrderFromBom({
    required String bomId,
    required double batchSize,
    String? plannedBy,
    DateTime? scheduledDate,
    String? workCenter,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        return BomIntegrationResult(
          success: false,
          errors: ['BOM not found: $bomId'],
        );
      }

      // Validate BOM is approved for production
      if (!bom.isValidForProduction) {
        errors.add('BOM is not approved for production');
        return BomIntegrationResult(success: false, errors: errors);
      }

      // Check inventory availability first
      final inventoryValidation = await validateBomInventoryAvailability(
        bomId: bomId,
        batchSize: batchSize,
      );

      if (!inventoryValidation.success) {
        errors.addAll(inventoryValidation.errors);
        warnings.addAll(inventoryValidation.warnings);
      }

      // Create production order
      final productionOrder = {
        'bomId': bomId,
        'bomCode': bom.bomCode,
        'productId': bom.productId,
        'productCode': bom.productCode,
        'productName': bom.productName,
        'plannedQuantity': batchSize,
        'unit': bom.baseUnit,
        'expectedYield': bom.calculateExpectedYield(batchSize),
        'estimatedCost': bom.calculateTotalBomCost(batchSize),
        'plannedBy': plannedBy,
        'scheduledDate': scheduledDate?.toIso8601String(),
        'workCenter': workCenter,
        'status': 'Planned',
        'bomItems': bom.items
            .where((item) => item.isActive)
            .map((item) => {
                  'itemId': item.itemId,
                  'itemCode': item.itemCode,
                  'itemName': item.itemName,
                  'requiredQuantity': item.calculateActualQuantity(batchSize),
                  'unit': item.unit,
                  'sequenceNumber': item.sequenceNumber,
                  'consumptionType': item.consumptionType.toString(),
                })
            .toList(),
        'productionInstructions': bom.productionInstructions,
        'qualityRequirements': bom.qualityRequirements,
      };

      await productionRepository.createProductionOrder(productionOrder);

      return BomIntegrationResult(
        success: errors.isEmpty,
        bomId: bomId,
        errors: errors,
        warnings: warnings,
        suggestions: ['Production order created successfully'],
      );
    } catch (e) {
      return BomIntegrationResult(
        success: false,
        errors: ['Error creating production order: ${e.toString()}'],
      );
    }
  }

  /// Calculate BOM cost and update pricing
  Future<BomIntegrationResult> updateProductPricingFromBom({
    required String bomId,
    double profitMargin = 0.25, // 25% default margin
  }) async {
    final errors = <String>[];
    final suggestions = <String>[];

    try {
      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        return BomIntegrationResult(
          success: false,
          errors: ['BOM not found: $bomId'],
        );
      }

      // Calculate total BOM cost
      final totalCost = bom.calculateTotalBomCost(bom.baseQuantity);
      final costPerUnit = totalCost / bom.baseQuantity;

      // Calculate suggested selling price
      final suggestedPrice = costPerUnit * (1 + profitMargin);

      // Update product pricing in sales module
      await salesRepository.updateProductPricing({
        'productId': bom.productId,
        'productCode': bom.productCode,
        'costPerUnit': costPerUnit,
        'suggestedPrice': suggestedPrice,
        'profitMargin': profitMargin,
        'bomReference': bomId,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      suggestions.add('Updated pricing for ${bom.productCode}: '
          'Cost: \$${costPerUnit.toStringAsFixed(2)}, '
          'Suggested Price: \$${suggestedPrice.toStringAsFixed(2)}');

      return BomIntegrationResult(
        success: true,
        bomId: bomId,
        suggestions: suggestions,
      );
    } catch (e) {
      return BomIntegrationResult(
        success: false,
        errors: ['Error updating product pricing: ${e.toString()}'],
      );
    }
  }

  /// Generate material requirements planning (MRP) from BOM
  Future<BomIntegrationResult> generateMrpFromBom({
    required String bomId,
    required List<Map<String, dynamic>> demandForecast,
    int planningHorizonDays = 90,
  }) async {
    final errors = <String>[];
    final suggestions = <String>[];

    try {
      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        return BomIntegrationResult(
          success: false,
          errors: ['BOM not found: $bomId'],
        );
      }

      // Calculate total demand for planning horizon
      double totalDemand = 0.0;
      for (final forecast in demandForecast) {
        totalDemand += (forecast['quantity'] as num).toDouble();
      }

      // Calculate material requirements
      final materialRequirements = <String, double>{};

      for (final bomItem in bom.items.where((item) => item.isActive)) {
        final totalRequired = bomItem.calculateActualQuantity(totalDemand);
        materialRequirements[bomItem.itemId] = totalRequired;
      }

      // Check current inventory and calculate net requirements
      final netRequirements = <String, Map<String, dynamic>>{};

      for (final entry in materialRequirements.entries) {
        final itemId = entry.key;
        final grossRequirement = entry.value;

        final inventoryItem = await inventoryRepository.getItem(itemId);
        final currentStock = inventoryItem?.quantity ?? 0.0;
        final netRequirement = grossRequirement - currentStock;

        if (netRequirement > 0) {
          netRequirements[itemId] = {
            'itemId': itemId,
            'itemCode': inventoryItem?.name ?? 'Unknown',
            'grossRequirement': grossRequirement,
            'currentStock': currentStock,
            'netRequirement': netRequirement,
            'unit': inventoryItem?.unit ?? 'units',
          };
        }
      }

      // Save MRP results
      await bomRepository.saveMrpResults({
        'bomId': bomId,
        'planningHorizon': planningHorizonDays,
        'totalDemand': totalDemand,
        'materialRequirements': materialRequirements,
        'netRequirements': netRequirements,
        'generatedAt': DateTime.now().toIso8601String(),
      });

      suggestions.add(
          'Generated MRP for ${netRequirements.length} items requiring procurement');

      return BomIntegrationResult(
        success: true,
        bomId: bomId,
        suggestions: suggestions,
      );
    } catch (e) {
      return BomIntegrationResult(
        success: false,
        errors: ['Error generating MRP: ${e.toString()}'],
      );
    }
  }

  /// Validate BOM against quality requirements
  Future<BomIntegrationResult> validateBomQuality({
    required String bomId,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        return BomIntegrationResult(
          success: false,
          errors: ['BOM not found: $bomId'],
        );
      }

      // Check if BOM has quality requirements
      if (bom.qualityRequirements == null || bom.qualityRequirements!.isEmpty) {
        warnings.add('No quality requirements defined for BOM');
      }

      // Validate each item against quality parameters
      for (final bomItem in bom.items.where((item) => item.isActive)) {
        if (bomItem.qualityParameters != null) {
          // Check if quality parameters are properly defined
          final qualityParams = bomItem.qualityParameters!;

          if (!qualityParams.containsKey('specifications')) {
            warnings
                .add('No quality specifications for item: ${bomItem.itemCode}');
          }

          if (!qualityParams.containsKey('testMethods')) {
            warnings
                .add('No test methods defined for item: ${bomItem.itemCode}');
          }
        }
      }

      return BomIntegrationResult(
        success: errors.isEmpty,
        bomId: bomId,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return BomIntegrationResult(
        success: false,
        errors: ['Error validating BOM quality: ${e.toString()}'],
      );
    }
  }
}
