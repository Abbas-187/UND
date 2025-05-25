import '../entities/bill_of_materials.dart';
import '../entities/bom_item.dart';

/// Repository interface for BOM operations
abstract class BomRepository {
  // BOM CRUD operations
  Future<List<BillOfMaterials>> getAllBoms();
  Future<BillOfMaterials?> getBomById(String id);
  Future<List<BillOfMaterials>> getBomsByProductId(String productId);
  Future<List<BillOfMaterials>> getBomsByType(BomType type);
  Future<List<BillOfMaterials>> getBomsByStatus(BomStatus status);
  Future<String> createBom(BillOfMaterials bom);
  Future<void> updateBom(BillOfMaterials bom);
  Future<void> deleteBom(String id);
  Future<void> approveBom(String id, String approvedBy);
  Future<void> activateBom(String id);
  Future<void> deactivateBom(String id);

  // BOM Item operations
  Future<List<BomItem>> getBomItems(String bomId);
  Future<BomItem?> getBomItem(String bomId, String itemId);
  Future<void> addBomItem(String bomId, BomItem item);
  Future<void> updateBomItem(String bomId, BomItem item);
  Future<void> removeBomItem(String bomId, String itemId);
  Future<void> reorderBomItems(String bomId, List<String> itemIds);

  // BOM versioning
  Future<List<BillOfMaterials>> getBomVersions(String productId);
  Future<String> createBomVersion(String baseBomId, String newVersion);
  Future<BillOfMaterials?> getActiveBomForProduct(String productId);

  // BOM costing
  Future<Map<String, double>> calculateBomCost(String bomId, double batchSize);
  Future<void> updateBomCosts(String bomId);
  Future<Map<String, dynamic>> getBomCostBreakdown(String bomId);

  // BOM validation
  Future<List<String>> validateBom(String bomId);
  Future<bool> checkBomIntegrity(String bomId);
  Future<List<String>> findCircularReferences(String bomId);

  // BOM explosion (multi-level)
  Future<List<BomItem>> explodeBom(String bomId, {int maxLevels = 10});
  Future<Map<String, double>> calculateNetRequirements(
    String bomId,
    double quantity,
    Map<String, double> currentInventory,
  );

  // BOM comparison
  Future<Map<String, dynamic>> compareBoms(String bomId1, String bomId2);
  Future<List<Map<String, dynamic>>> getBomChangeHistory(String bomId);

  // BOM templates and standards
  Future<List<BillOfMaterials>> getBomTemplates();
  Future<String> createBomFromTemplate(String templateId, String productId);
  Future<void> saveBomAsTemplate(String bomId, String templateName);

  // Integration operations
  Future<void> saveMrpResults(Map<String, dynamic> mrpData);
  Future<Map<String, dynamic>?> getMrpResults(String bomId);
  Future<List<Map<String, dynamic>>> getBomUsageAnalytics(String bomId);

  // Bulk operations
  Future<void> bulkUpdateBomItems(String bomId, List<BomItem> items);
  Future<void> importBomFromCsv(String bomId, String csvData);
  Future<String> exportBomToCsv(String bomId);

  // Search and filtering
  Future<List<BillOfMaterials>> searchBoms(String query);
  Future<List<BillOfMaterials>> filterBoms({
    BomType? type,
    BomStatus? status,
    String? productCode,
    DateTime? createdAfter,
    DateTime? createdBefore,
  });

  // Streams for real-time updates
  Stream<List<BillOfMaterials>> watchAllBoms();
  Stream<BillOfMaterials> watchBom(String id);
  Stream<List<BomItem>> watchBomItems(String bomId);
}
