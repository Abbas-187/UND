import '../entities/cost_layer.dart';
import '../repositories/inventory_repository.dart';

/// Model for the inventory valuation report
class InventoryValuationReport {

  const InventoryValuationReport({
    required this.reportDate,
    required this.entries,
    required this.totalValue,
    required this.costingMethod,
    this.warehouseId,
    this.warehouseName,
  });
  final DateTime reportDate;
  final List<InventoryValuationEntry> entries;
  final double totalValue;
  final CostingMethod costingMethod;
  final String? warehouseId;
  final String? warehouseName;
}

/// Model for an entry in the inventory valuation report
class InventoryValuationEntry {

  const InventoryValuationEntry({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    this.category,
    required this.totalQuantity,
    required this.totalValue,
    required this.averageCost,
    this.costLayerBreakdown,
    this.costingMethod,
  });
  final String itemId;
  final String itemCode;
  final String itemName;
  final String? category;
  final double totalQuantity;
  final double totalValue;
  final double averageCost;
  final List<CostLayerValuationEntry>? costLayerBreakdown;
  final CostingMethod? costingMethod;
}

/// Model for a cost layer entry in the inventory valuation report
class CostLayerValuationEntry {

  const CostLayerValuationEntry({
    required this.id,
    required this.itemId,
    required this.batchLotNumber,
    required this.movementDate,
    required this.quantity,
    required this.costPerUnit,
    required this.totalValue,
    this.productionDate,
    this.expirationDate,
  });
  final String id;
  final String itemId;
  final String batchLotNumber;
  final DateTime movementDate;
  final double quantity;
  final double costPerUnit;
  final double totalValue;
  final DateTime? productionDate;
  final DateTime? expirationDate;
}

/// UseCase for generating inventory valuation reports using different costing methods
class GenerateInventoryValuationReportUseCase {

  const GenerateInventoryValuationReportUseCase(this._repository);
  final InventoryRepository _repository;

  /// Generate an inventory valuation report
  ///
  /// Parameters:
  /// - warehouseId: Optional ID of warehouse to filter by
  /// - costingMethod: Costing method to use (FIFO, LIFO, WAC)
  /// - includeLayerBreakdown: Whether to include cost layer details
  /// - asOfDate: Date to generate the report for (defaults to now)
  ///
  /// Returns a valuation report with total values and item details
  Future<InventoryValuationReport> execute({
    String? warehouseId,
    CostingMethod costingMethod = CostingMethod.fifo,
    bool includeLayerBreakdown = true,
    DateTime? asOfDate,
  }) async {
    // Use current date if none provided
    final reportDate = asOfDate ?? DateTime.now();

    // Get warehouse name if warehouseId is provided
    String? warehouseName;
    if (warehouseId != null) {
      final warehouse = await _repository.getWarehouse(warehouseId);
      warehouseName = warehouse?.name;
    }

    // Get inventory items to value
    final items = warehouseId != null
        ? await _repository.getInventoryItems(warehouseId)
        : await _repository.getItems();

    if (items.isEmpty) {
      return InventoryValuationReport(
        reportDate: reportDate,
        entries: [],
        totalValue: 0,
        costingMethod: costingMethod,
        warehouseId: warehouseId,
        warehouseName: warehouseName,
      );
    }

    // Generate valuation entries for each item
    final entries = <InventoryValuationEntry>[];
    double totalReportValue = 0;

    for (final item in items) {
      // Get cost layers for the item based on the costing method
      final costLayers = await _repository.getAvailableCostLayers(
        item.id,
        warehouseId,
        costingMethod,
      );

      // Skip items with no cost layers or quantity
      if (costLayers.isEmpty || item.quantity <= 0) continue;

      // Calculate total value and average cost
      double totalItemValue = 0;
      double totalQuantity = 0;

      for (final layer in costLayers) {
        totalItemValue += layer.remainingQuantity * layer.costAtTransaction;
        totalQuantity += layer.remainingQuantity;
      }

      // Skip items with no quantity
      if (totalQuantity <= 0) continue;

      final averageCost = totalItemValue / totalQuantity;

      // Build cost layer breakdown if requested
      List<CostLayerValuationEntry>? costLayerBreakdown;
      if (includeLayerBreakdown) {
        costLayerBreakdown = costLayers.map((layer) {
          return CostLayerValuationEntry(
            id: layer.id,
            itemId: layer.itemId,
            batchLotNumber: layer.batchLotNumber,
            movementDate: layer.movementDate,
            quantity: layer.remainingQuantity,
            costPerUnit: layer.costAtTransaction,
            totalValue: layer.remainingQuantity * layer.costAtTransaction,
            productionDate: layer.productionDate,
            expirationDate: layer.expirationDate,
          );
        }).toList();
      }

      // Create the entry
      final entry = InventoryValuationEntry(
        itemId: item.id,
        itemCode: item.itemCode,
        itemName: item.name,
        category: item.category,
        totalQuantity: totalQuantity,
        totalValue: totalItemValue,
        averageCost: averageCost,
        costLayerBreakdown: costLayerBreakdown,
        costingMethod: costingMethod,
      );

      entries.add(entry);
      totalReportValue += totalItemValue;
    }

    // Sort entries by item code
    entries.sort((a, b) => a.itemCode.compareTo(b.itemCode));

    // Create and return the report
    return InventoryValuationReport(
      reportDate: reportDate,
      entries: entries,
      totalValue: totalReportValue,
      costingMethod: costingMethod,
      warehouseId: warehouseId,
      warehouseName: warehouseName,
    );
  }
}
