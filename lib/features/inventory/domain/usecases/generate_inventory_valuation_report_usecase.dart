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

/// Model for comparative inventory valuation report
class ComparativeInventoryValuationReport {
  const ComparativeInventoryValuationReport({
    required this.reportDate,
    required this.entries,
    required this.fifoTotalValue,
    required this.lifoTotalValue,
    required this.wacTotalValue,
    this.warehouseId,
    this.warehouseName,
  });
  final DateTime reportDate;
  final List<ComparativeValuationEntry> entries;
  final double fifoTotalValue;
  final double lifoTotalValue;
  final double wacTotalValue;
  final String? warehouseId;
  final String? warehouseName;
}

/// Model for an entry in the comparative inventory valuation report
class ComparativeValuationEntry {
  const ComparativeValuationEntry({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    this.category,
    required this.quantity,
    required this.fifoValue,
    required this.lifoValue,
    required this.wacValue,
    this.costLayers,
  });
  final String itemId;
  final String itemCode;
  final String itemName;
  final String? category;
  final double quantity;
  final double fifoValue;
  final double lifoValue;
  final double wacValue;
  final List<CostLayerValuationEntry>? costLayers;

  /// Get the value difference between FIFO and LIFO
  double get fifoLifoDifference => fifoValue - lifoValue;

  /// Get the value difference between FIFO and WAC
  double get fifoWacDifference => fifoValue - wacValue;

  /// Get the value difference between LIFO and WAC
  double get lifoWacDifference => lifoValue - wacValue;
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
        warehouseId ?? '',
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
        itemCode: item.sapCode,
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

// Extension to the GenerateInventoryValuationReportUseCase class
extension ComparativeValuationExtension
    on GenerateInventoryValuationReportUseCase {
  /// Generate a comparative inventory valuation report showing FIFO, LIFO, and WAC values
  ///
  /// Parameters:
  /// - warehouseId: Optional ID of warehouse to filter by
  /// - includeLayerBreakdown: Whether to include cost layer details
  /// - asOfDate: Date to generate the report for (defaults to now)
  ///
  /// Returns a comparative report with values using all costing methods
  Future<ComparativeInventoryValuationReport> generateComparativeReport({
    String? warehouseId,
    bool includeLayerBreakdown = true,
    DateTime? asOfDate,
  }) async {
    // Generate separate reports for each costing method
    final fifoReport = await execute(
      warehouseId: warehouseId,
      costingMethod: CostingMethod.fifo,
      includeLayerBreakdown: includeLayerBreakdown,
      asOfDate: asOfDate,
    );

    final lifoReport = await execute(
      warehouseId: warehouseId,
      costingMethod: CostingMethod.lifo,
      includeLayerBreakdown: false,
      asOfDate: asOfDate,
    );

    final wacReport = await execute(
      warehouseId: warehouseId,
      costingMethod: CostingMethod.wac,
      includeLayerBreakdown: false,
      asOfDate: asOfDate,
    );

    // Combine the reports into a comparative report
    final comparativeEntries = <ComparativeValuationEntry>[];
    final allItemIds = <String>{};

    // Collect all item IDs from the three reports
    for (final entry in fifoReport.entries) {
      allItemIds.add(entry.itemId);
    }
    for (final entry in lifoReport.entries) {
      allItemIds.add(entry.itemId);
    }
    for (final entry in wacReport.entries) {
      allItemIds.add(entry.itemId);
    }

    // Create comparative entries
    for (final itemId in allItemIds) {
      final fifoEntry = fifoReport.entries.firstWhere(
        (e) => e.itemId == itemId,
        orElse: () => InventoryValuationEntry(
          itemId: itemId,
          itemCode: '',
          itemName: '',
          totalQuantity: 0,
          totalValue: 0,
          averageCost: 0,
        ),
      );

      final lifoEntry = lifoReport.entries.firstWhere(
        (e) => e.itemId == itemId,
        orElse: () => InventoryValuationEntry(
          itemId: itemId,
          itemCode: fifoEntry.itemCode,
          itemName: fifoEntry.itemName,
          category: fifoEntry.category,
          totalQuantity: fifoEntry.totalQuantity,
          totalValue: 0,
          averageCost: 0,
        ),
      );

      final wacEntry = wacReport.entries.firstWhere(
        (e) => e.itemId == itemId,
        orElse: () => InventoryValuationEntry(
          itemId: itemId,
          itemCode: fifoEntry.itemCode,
          itemName: fifoEntry.itemName,
          category: fifoEntry.category,
          totalQuantity: fifoEntry.totalQuantity,
          totalValue: 0,
          averageCost: 0,
        ),
      );

      comparativeEntries.add(ComparativeValuationEntry(
        itemId: itemId,
        itemCode: fifoEntry.itemCode.isEmpty
            ? lifoEntry.itemCode
            : fifoEntry.itemCode,
        itemName: fifoEntry.itemName.isEmpty
            ? lifoEntry.itemName
            : fifoEntry.itemName,
        category: fifoEntry.category,
        quantity: fifoEntry.totalQuantity,
        fifoValue: fifoEntry.totalValue,
        lifoValue: lifoEntry.totalValue,
        wacValue: wacEntry.totalValue,
        costLayers: fifoEntry.costLayerBreakdown,
      ));
    }

    // Sort entries by item code
    comparativeEntries.sort((a, b) => a.itemCode.compareTo(b.itemCode));

    return ComparativeInventoryValuationReport(
      reportDate: fifoReport.reportDate,
      entries: comparativeEntries,
      fifoTotalValue: fifoReport.totalValue,
      lifoTotalValue: lifoReport.totalValue,
      wacTotalValue: wacReport.totalValue,
      warehouseId: warehouseId,
      warehouseName: fifoReport.warehouseName,
    );
  }
}
