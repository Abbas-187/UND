import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/repositories/bom_repository.dart';
import '../datasources/bom_firestore_datasource.dart';
import '../models/bom_item_model.dart';
import '../models/bom_model.dart';

/// Implementation of BomRepository using Firebase Firestore
class BomRepositoryImpl implements BomRepository {
  BomRepositoryImpl(FirebaseFirestore firestore)
      : _datasource = BomFirestoreDatasource(firestore);

  final BomFirestoreDatasource _datasource;

  @override
  Future<List<BillOfMaterials>> getAllBoms() async {
    try {
      final models = await _datasource.getAllBoms();
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get all BOMs: $e');
    }
  }

  @override
  Future<BillOfMaterials?> getBomById(String id) async {
    try {
      final model = await _datasource.getBomById(id);
      return model?.toDomain();
    } catch (e) {
      throw Exception('Failed to get BOM by ID: $e');
    }
  }

  @override
  Future<List<BillOfMaterials>> getBomsByProductId(String productId) async {
    try {
      final models = await _datasource.getBomsByProductId(productId);
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get BOMs by product ID: $e');
    }
  }

  @override
  Future<List<BillOfMaterials>> getBomsByType(BomType type) async {
    try {
      final models = await _datasource.getBomsByType(type.name);
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get BOMs by type: $e');
    }
  }

  @override
  Future<List<BillOfMaterials>> getBomsByStatus(BomStatus status) async {
    try {
      final models = await _datasource.getBomsByStatus(status.name);
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get BOMs by status: $e');
    }
  }

  @override
  Future<String> createBom(BillOfMaterials bom) async {
    try {
      final model = BomModel.fromDomain(bom);
      return await _datasource.createBom(model);
    } catch (e) {
      throw Exception('Failed to create BOM: $e');
    }
  }

  @override
  Future<void> updateBom(BillOfMaterials bom) async {
    try {
      final model = BomModel.fromDomain(bom);
      await _datasource.updateBom(bom.id, model);
    } catch (e) {
      throw Exception('Failed to update BOM: $e');
    }
  }

  @override
  Future<void> deleteBom(String id) async {
    try {
      await _datasource.deleteBom(id);
    } catch (e) {
      throw Exception('Failed to delete BOM: $e');
    }
  }

  @override
  Future<void> approveBom(String id, String approvedBy) async {
    try {
      await _datasource.updateBomStatus(id, BomStatus.approved.name,
          approvedBy: approvedBy);
    } catch (e) {
      throw Exception('Failed to approve BOM: $e');
    }
  }

  @override
  Future<void> activateBom(String id) async {
    try {
      await _datasource.updateBomStatus(id, BomStatus.active.name);
    } catch (e) {
      throw Exception('Failed to activate BOM: $e');
    }
  }

  @override
  Future<void> deactivateBom(String id) async {
    try {
      await _datasource.updateBomStatus(id, BomStatus.inactive.name);
    } catch (e) {
      throw Exception('Failed to deactivate BOM: $e');
    }
  }

  @override
  Future<List<BomItem>> getBomItems(String bomId) async {
    try {
      final models = await _datasource.getBomItems(bomId);
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get BOM items: $e');
    }
  }

  @override
  Future<BomItem?> getBomItem(String bomId, String itemId) async {
    try {
      final model = await _datasource.getBomItem(bomId, itemId);
      return model?.toDomain();
    } catch (e) {
      throw Exception('Failed to get BOM item: $e');
    }
  }

  @override
  Future<void> addBomItem(String bomId, BomItem item) async {
    try {
      final model = BomItemModel.fromDomain(item);
      await _datasource.addBomItem(model);
    } catch (e) {
      throw Exception('Failed to add BOM item: $e');
    }
  }

  @override
  Future<void> updateBomItem(String bomId, BomItem item) async {
    try {
      final model = BomItemModel.fromDomain(item);
      await _datasource.updateBomItem(item.id, model);
    } catch (e) {
      throw Exception('Failed to update BOM item: $e');
    }
  }

  @override
  Future<void> removeBomItem(String bomId, String itemId) async {
    try {
      await _datasource.deleteBomItemsByBomAndItem(bomId, itemId);
    } catch (e) {
      throw Exception('Failed to remove BOM item: $e');
    }
  }

  @override
  Future<void> reorderBomItems(String bomId, List<String> itemIds) async {
    try {
      await _datasource.reorderBomItems(bomId, itemIds);
    } catch (e) {
      throw Exception('Failed to reorder BOM items: $e');
    }
  }

  @override
  Future<List<BillOfMaterials>> getBomVersions(String productId) async {
    try {
      final models = await _datasource.getBomVersions(productId);
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get BOM versions: $e');
    }
  }

  @override
  Future<String> createBomVersion(String baseBomId, String newVersion) async {
    try {
      final baseBom = await getBomById(baseBomId);
      if (baseBom == null) throw Exception('Base BOM not found');

      final newBom = baseBom.copyWith(
        id: '', // Will be generated by Firestore
        version: newVersion,
        status: BomStatus.draft,
        approvedBy: null,
        approvedAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createBom(newBom);
    } catch (e) {
      throw Exception('Failed to create BOM version: $e');
    }
  }

  @override
  Future<BillOfMaterials?> getActiveBomForProduct(String productId) async {
    try {
      final model = await _datasource.getActiveBomForProduct(productId);
      return model?.toDomain();
    } catch (e) {
      throw Exception('Failed to get active BOM for product: $e');
    }
  }

  @override
  Future<Map<String, double>> calculateBomCost(
      String bomId, double batchSize) async {
    try {
      final bom = await getBomById(bomId);
      if (bom == null) throw Exception('BOM not found');

      final materialCost = bom.calculateMaterialCost(batchSize);
      final totalCost = bom.calculateTotalBomCost(batchSize);

      return {
        'materialCost': materialCost,
        'laborCost': bom.laborCost * (batchSize / bom.baseQuantity),
        'overheadCost': bom.overheadCost * (batchSize / bom.baseQuantity),
        'setupCost': bom.setupCost,
        'totalCost': totalCost,
      };
    } catch (e) {
      throw Exception('Failed to calculate BOM cost: $e');
    }
  }

  @override
  Future<void> updateBomCosts(String bomId) async {
    try {
      final bom = await getBomById(bomId);
      if (bom == null) throw Exception('BOM not found');

      final totalCost = bom.calculateTotalBomCost(bom.baseQuantity);

      final updatedBom = bom.copyWith(
        totalCost: totalCost,
        updatedAt: DateTime.now(),
      );

      await updateBom(updatedBom);
    } catch (e) {
      throw Exception('Failed to update BOM costs: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBomCostBreakdown(String bomId) async {
    try {
      final bom = await getBomById(bomId);
      if (bom == null) throw Exception('BOM not found');

      final itemCosts = <Map<String, dynamic>>[];
      for (final item in bom.items) {
        itemCosts.add({
          'itemCode': item.itemCode,
          'itemName': item.itemName,
          'quantity': item.quantity,
          'costPerUnit': item.costPerUnit,
          'totalCost': item.calculateTotalCost(bom.baseQuantity),
        });
      }

      return {
        'bomId': bomId,
        'bomCode': bom.bomCode,
        'baseQuantity': bom.baseQuantity,
        'itemCosts': itemCosts,
        'laborCost': bom.laborCost,
        'overheadCost': bom.overheadCost,
        'setupCost': bom.setupCost,
        'totalCost': bom.totalCost,
      };
    } catch (e) {
      throw Exception('Failed to get BOM cost breakdown: $e');
    }
  }

  @override
  Future<List<String>> validateBom(String bomId) async {
    final errors = <String>[];
    try {
      final bom = await getBomById(bomId);
      if (bom == null) {
        errors.add('BOM not found');
        return errors;
      }

      if (bom.items.isEmpty) {
        errors.add('BOM has no items');
      }

      // Validate BOM items
      for (final item in bom.items) {
        if (item.quantity <= 0) {
          errors.add('Item ${item.itemCode} has invalid quantity');
        }
        if (item.costPerUnit < 0) {
          errors.add('Item ${item.itemCode} has negative cost');
        }
      }

      // Check for duplicate items
      final itemCodes = bom.items.map((item) => item.itemCode).toList();
      final uniqueItemCodes = itemCodes.toSet();
      if (itemCodes.length != uniqueItemCodes.length) {
        errors.add('BOM contains duplicate items');
      }

      return errors;
    } catch (e) {
      errors.add('Validation failed: $e');
      return errors;
    }
  }

  @override
  Future<bool> checkBomIntegrity(String bomId) async {
    final errors = await validateBom(bomId);
    return errors.isEmpty;
  }

  @override
  Future<List<String>> findCircularReferences(String bomId) async {
    // Simplified implementation - would need more complex logic for real circular reference detection
    return [];
  }

  @override
  Future<List<BomItem>> explodeBom(String bomId, {int maxLevels = 10}) async {
    // Simplified implementation - would need recursive explosion logic
    return await getBomItems(bomId);
  }

  @override
  Future<Map<String, double>> calculateNetRequirements(
    String bomId,
    double quantity,
    Map<String, double> currentInventory,
  ) async {
    final netRequirements = <String, double>{};
    final items = await getBomItems(bomId);

    for (final item in items) {
      final required = item.calculateActualQuantity(quantity);
      final available = currentInventory[item.itemId] ?? 0.0;
      final net = required - available;

      if (net > 0) {
        netRequirements[item.itemId] = net;
      }
    }

    return netRequirements;
  }

  @override
  Future<Map<String, dynamic>> compareBoms(String bomId1, String bomId2) async {
    try {
      final bom1 = await getBomById(bomId1);
      final bom2 = await getBomById(bomId2);

      if (bom1 == null || bom2 == null) {
        throw Exception('One or both BOMs not found');
      }

      return {
        'bom1': {
          'code': bom1.bomCode,
          'itemCount': bom1.items.length,
          'totalCost': bom1.totalCost
        },
        'bom2': {
          'code': bom2.bomCode,
          'itemCount': bom2.items.length,
          'totalCost': bom2.totalCost
        },
        'costDifference': bom2.totalCost - bom1.totalCost,
        'itemCountDifference': bom2.items.length - bom1.items.length,
      };
    } catch (e) {
      throw Exception('Failed to compare BOMs: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBomChangeHistory(String bomId) async {
    // Simplified implementation - would need audit trail functionality
    return [];
  }

  @override
  Future<List<BillOfMaterials>> getBomTemplates() async {
    try {
      final models = await _datasource.getBomTemplates();
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get BOM templates: $e');
    }
  }

  @override
  Future<String> createBomFromTemplate(
      String templateId, String productId) async {
    // Simplified implementation
    throw UnimplementedError('Create BOM from template not implemented yet');
  }

  @override
  Future<void> saveBomAsTemplate(String bomId, String templateName) async {
    // Simplified implementation
    throw UnimplementedError('Save BOM as template not implemented yet');
  }

  @override
  Future<void> saveMrpResults(Map<String, dynamic> mrpData) async {
    try {
      await _datasource.saveMrpResults(mrpData);
    } catch (e) {
      throw Exception('Failed to save MRP results: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getMrpResults(String bomId) async {
    try {
      return await _datasource.getMrpResults(bomId);
    } catch (e) {
      throw Exception('Failed to get MRP results: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBomUsageAnalytics(String bomId) async {
    // Simplified implementation
    return [];
  }

  @override
  Future<void> bulkUpdateBomItems(String bomId, List<BomItem> items) async {
    try {
      final models =
          items.map((item) => BomItemModel.fromDomain(item)).toList();
      await _datasource.bulkUpdateBomItems(models);
    } catch (e) {
      throw Exception('Failed to bulk update BOM items: $e');
    }
  }

  @override
  Future<void> importBomFromCsv(String bomId, String csvData) async {
    // Simplified implementation
    throw UnimplementedError('Import BOM from CSV not implemented yet');
  }

  @override
  Future<String> exportBomToCsv(String bomId) async {
    // Simplified implementation
    throw UnimplementedError('Export BOM to CSV not implemented yet');
  }

  @override
  Future<List<BillOfMaterials>> searchBoms(String query) async {
    try {
      final models = await _datasource.searchBoms(query);
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to search BOMs: $e');
    }
  }

  @override
  Future<List<BillOfMaterials>> filterBoms({
    BomType? type,
    BomStatus? status,
    String? productCode,
    DateTime? createdAfter,
    DateTime? createdBefore,
  }) async {
    try {
      final models = await _datasource.filterBoms(
        type: type?.name,
        status: status?.name,
        productCode: productCode,
        createdAfter: createdAfter,
        createdBefore: createdBefore,
      );
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to filter BOMs: $e');
    }
  }

  @override
  Stream<List<BillOfMaterials>> watchAllBoms() {
    return _datasource.watchAllBoms().map(
          (models) => models.map((model) => model.toDomain()).toList(),
        );
  }

  @override
  Stream<BillOfMaterials> watchBom(String id) {
    return _datasource.watchBom(id).map((model) => model.toDomain());
  }

  @override
  Stream<List<BomItem>> watchBomItems(String bomId) {
    return _datasource.watchBomItems(bomId).map(
          (models) => models.map((model) => model.toDomain()).toList(),
        );
  }
}
