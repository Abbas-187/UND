import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../inventory/data/providers/mock_inventory_provider.dart';
import '../models/purchase_order_model.dart';
import '../models/supplier_model.dart';
import '../models/vendor_evaluation_model.dart';
import 'dart:math';

/// Provides mock procurement data that integrates with inventory
class MockProcurementProvider {
  MockProcurementProvider({
    required this.mockDataService,
    required this.mockInventoryProvider,
  });

  final MockDataService mockDataService;
  final MockInventoryProvider mockInventoryProvider;

  // In-memory storage for mock data
  final Map<String, PurchaseOrderModel> _purchaseOrders = {};
  final Map<String, SupplierModel> _suppliers = {};
  final Map<String, VendorEvaluationModel> _vendorEvaluations = {};
  final Map<String, Map<String, dynamic>> _procurementPlans = {};
  final Map<String, Map<String, dynamic>> _supplierContracts = {};
  final Map<String, Map<String, dynamic>> _qualityLogs = {};
  final Map<String, Map<String, dynamic>> _performanceMetrics = {};

  // Initialize with sample data
  void initializeMockData() {
    // Load mock data from mockDataService or create sample data
    _loadMockSuppliers();
    _loadMockPurchaseOrders();
    _loadMockVendorEvaluations();
    _loadMockProcurementPlans();
    _loadMockSupplierContracts();
    _loadMockQualityLogs();
    _loadMockPerformanceMetrics();
  }

  /// Get procurement needs from inventory
  List<Map<String, dynamic>> getProcurementNeeds() {
    return mockDataService.getProcurementNeeds();
  }

  /// Get inventory items below reorder point
  List<Map<String, dynamic>> getItemsBelowReorderPoint() {
    final items = mockInventoryProvider.getItemsNeedingReorder();
    final result = <Map<String, dynamic>>[];

    for (final item in items) {
      result.add({
        'itemId': item.id,
        'name': item.name,
        'category': item.category,
        'currentQuantity': item.quantity,
        'reorderPoint': item.reorderPoint,
        'minimumQuantity': item.minimumQuantity,
        'unit': item.unit,
        'recommendedOrderQuantity': _calculateRecommendedOrderQuantity(
            item.id, item.reorderPoint, item.quantity),
      });
    }

    return result;
  }

  /// Generate purchase order from inventory needs
  PurchaseOrderModel generatePurchaseOrderFromInventory(
      String supplierId, String supplierName) {
    final itemsToOrder = _getItemsForSupplier(supplierId);

    if (itemsToOrder.isEmpty) {
      throw Exception('No items to order from this supplier');
    }

    final poNumber =
        'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final now = DateTime.now();

    return PurchaseOrderModel(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      procurementPlanId: 'plan-auto-generated',
      poNumber: poNumber,
      requestDate: now,
      requestedBy: 'System',
      supplierId: supplierId,
      supplierName: supplierName,
      status: 'draft',
      items: itemsToOrder,
      totalAmount: _calculateTotalAmount(itemsToOrder),
      reasonForRequest: 'Auto-generated from inventory levels',
      intendedUse: 'Replenish inventory',
      quantityJustification: 'Based on inventory reorder points',
      supportingDocuments: [],
      expectedDeliveryDate: now.add(const Duration(days: 7)),
    );
  }

  /// Forecast procurement needs
  List<Map<String, dynamic>> forecastProcurementNeeds(int daysAhead) {
    // Get current inventory items
    final items = mockInventoryProvider.getAllItems();
    final result = <Map<String, dynamic>>[];

    for (final item in items) {
      // Get forecasted usage over period (could be replaced with real forecast data)
      final dailyUsage = _estimateDailyUsage(item.id);
      final forecastedUsage = dailyUsage * daysAhead;

      // Calculate projected inventory
      final projectedInventory = item.quantity - forecastedUsage;

      // If projected to go below reorder point
      if (projectedInventory <= item.reorderPoint) {
        final daysTillReorder = dailyUsage > 0
            ? ((item.quantity - item.reorderPoint) / dailyUsage).ceil()
            : daysAhead;

        result.add({
          'itemId': item.id,
          'name': item.name,
          'currentQuantity': item.quantity,
          'forecastedUsage': forecastedUsage,
          'projectedInventory': projectedInventory > 0 ? projectedInventory : 0,
          'needsReorder': true,
          'daysTillReorder': daysTillReorder,
          'recommendedOrderQuantity': _calculateRecommendedOrderQuantity(
              item.id,
              item.reorderPoint,
              projectedInventory > 0 ? projectedInventory : 0),
        });
      }
    }

    return result;
  }

  // Helper methods

  // Calculate the recommended order quantity based on inventory levels
  double _calculateRecommendedOrderQuantity(
      String itemId, double reorderPoint, double currentQuantity) {
    // Get the item's average daily usage
    final dailyUsage = _estimateDailyUsage(itemId);

    // Calculate days of supply we want (30 days is default)
    const targetDaysOfSupply = 30.0;

    // Calculate order quantity (target - current + buffer)
    final orderQuantity = (dailyUsage * targetDaysOfSupply) -
        currentQuantity +
        (reorderPoint * 0.5);

    // Return rounded up to nearest 5
    return (orderQuantity / 5).ceil() * 5.0;
  }

  // Estimate daily usage based on inventory history
  double _estimateDailyUsage(String itemId) {
    // In a real system, this would use actual historical data
    // Here we'll simulate usage at 2-5% of current inventory per day
    final item = mockInventoryProvider.getItemById(itemId);
    if (item == null) return 0.0;

    // Generate a consistent pseudo-random value between 2-5% for this item
    final seed = itemId.hashCode;
    final usageRate = 0.02 + ((seed % 30) / 1000); // Between 2% and 5%

    return item.quantity * usageRate;
  }

  // Get items that need to be ordered from a specific supplier
  List<PurchaseOrderItemModel> _getItemsForSupplier(String supplierId) {
    // In a real system, we would filter based on supplier-item mapping
    // Here we'll simulate based on the supplier ID (e.g., odd/even items)
    final items = mockInventoryProvider.getItemsNeedingReorder();
    final result = <PurchaseOrderItemModel>[];

    for (final item in items) {
      // Simple logic: even supplier ID gets even item IDs, odd gets odd
      final supplierLastDigit =
          int.tryParse(supplierId.substring(supplierId.length - 1)) ?? 0;
      final itemLastDigit =
          int.tryParse(item.id.substring(item.id.length - 1)) ?? 0;

      if (supplierLastDigit % 2 == itemLastDigit % 2) {
        final quantity = _calculateRecommendedOrderQuantity(
            item.id, item.reorderPoint, item.quantity);

        result.add(
          PurchaseOrderItemModel(
            id: 'poi-${DateTime.now().millisecondsSinceEpoch}-${result.length}',
            itemId: item.id,
            itemName: item.name,
            quantity: quantity,
            unit: item.unit,
            unitPrice: item.cost ?? 1.0,
            totalPrice: (item.cost ?? 1.0) * quantity,
            requiredByDate: DateTime.now().add(const Duration(days: 7)),
            notes: 'Auto-generated from inventory',
          ),
        );
      }
    }

    return result;
  }

  // Calculate total order amount
  double _calculateTotalAmount(List<PurchaseOrderItemModel> items) {
    double total = 0.0;
    for (final item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  // CRUD Operations for Purchase Orders

  /// Get all purchase orders
  List<PurchaseOrderModel> getAllPurchaseOrders() {
    return _purchaseOrders.values.toList();
  }

  /// Get purchase order by ID
  PurchaseOrderModel? getPurchaseOrderById(String id) {
    return _purchaseOrders[id];
  }

  /// Create a new purchase order
  PurchaseOrderModel createPurchaseOrder(PurchaseOrderModel order) {
    final id = order.id ?? 'order-${DateTime.now().millisecondsSinceEpoch}';
    final newOrder = order.id == null ? order : order; // Copy with ID if needed
    _purchaseOrders[id] = newOrder;
    return newOrder;
  }

  /// Update an existing purchase order
  PurchaseOrderModel updatePurchaseOrder(PurchaseOrderModel order) {
    if (order.id == null || !_purchaseOrders.containsKey(order.id)) {
      throw Exception('Purchase order not found');
    }
    _purchaseOrders[order.id!] = order;
    return order;
  }

  /// Delete a purchase order
  void deletePurchaseOrder(String id) {
    _purchaseOrders.remove(id);
  }

  // CRUD Operations for Suppliers

  /// Get all suppliers
  List<SupplierModel> getAllSuppliers() {
    return _suppliers.values.toList();
  }

  /// Get supplier by ID
  SupplierModel? getSupplierById(String id) {
    return _suppliers[id];
  }

  /// Create a new supplier
  SupplierModel createSupplier(SupplierModel supplier) {
    final id =
        supplier.id ?? 'supplier-${DateTime.now().millisecondsSinceEpoch}';
    final newSupplier = supplier; // Copy with ID if needed
    _suppliers[id] = newSupplier;
    return newSupplier;
  }

  /// Update an existing supplier
  SupplierModel updateSupplier(SupplierModel supplier) {
    if (supplier.id == null || !_suppliers.containsKey(supplier.id)) {
      throw Exception('Supplier not found');
    }
    _suppliers[supplier.id!] = supplier;
    return supplier;
  }

  /// Delete a supplier
  void deleteSupplier(String id) {
    _suppliers.remove(id);
  }

  // CRUD Operations for Vendor Evaluations

  /// Get all vendor evaluations
  List<VendorEvaluationModel> getAllVendorEvaluations() {
    return _vendorEvaluations.values.toList();
  }

  /// Get vendor evaluations for a specific supplier
  List<VendorEvaluationModel> getVendorEvaluationsForSupplier(
      String supplierId) {
    return _vendorEvaluations.values
        .where((eval) => eval.vendorId == supplierId)
        .toList();
  }

  /// Get vendor evaluation by ID
  VendorEvaluationModel? getVendorEvaluationById(String id) {
    return _vendorEvaluations[id];
  }

  /// Create a new vendor evaluation
  VendorEvaluationModel createVendorEvaluation(
      VendorEvaluationModel evaluation) {
    final id = evaluation.id ?? 'eval-${DateTime.now().millisecondsSinceEpoch}';
    final newEvaluation = VendorEvaluationModel(
      id: id,
      vendorId: evaluation.vendorId,
      vendorName: evaluation.vendorName,
      evaluationDate: evaluation.evaluationDate,
      evaluator: evaluation.evaluator,
      qualityScore: evaluation.qualityScore,
      deliveryScore: evaluation.deliveryScore,
      priceScore: evaluation.priceScore,
      serviceScore: evaluation.serviceScore,
      overallScore: evaluation.overallScore,
      status: evaluation.status,
      comments: evaluation.comments,
      strengths: evaluation.strengths,
      weaknesses: evaluation.weaknesses,
      recommendations: evaluation.recommendations,
    );
    _vendorEvaluations[id] = newEvaluation;
    return newEvaluation;
  }

  /// Update an existing vendor evaluation
  VendorEvaluationModel updateVendorEvaluation(
      VendorEvaluationModel evaluation) {
    if (evaluation.id == null ||
        !_vendorEvaluations.containsKey(evaluation.id)) {
      throw Exception('Vendor evaluation not found');
    }
    _vendorEvaluations[evaluation.id!] = evaluation;
    return evaluation;
  }

  /// Delete a vendor evaluation
  void deleteVendorEvaluation(String id) {
    _vendorEvaluations.remove(id);
  }

  // CRUD Operations for Procurement Plans

  /// Get all procurement plans
  List<Map<String, dynamic>> getAllProcurementPlans() {
    return _procurementPlans.values.toList();
  }

  /// Get procurement plan by ID
  Map<String, dynamic>? getProcurementPlanById(String id) {
    return _procurementPlans[id];
  }

  /// Create a new procurement plan
  Map<String, dynamic> createProcurementPlan(Map<String, dynamic> plan) {
    final id = plan['id'] ?? 'plan-${DateTime.now().millisecondsSinceEpoch}';
    final newPlan = {...plan, 'id': id};
    _procurementPlans[id] = newPlan;
    return newPlan;
  }

  /// Update an existing procurement plan
  Map<String, dynamic> updateProcurementPlan(Map<String, dynamic> plan) {
    final id = plan['id'];
    if (id == null || !_procurementPlans.containsKey(id)) {
      throw Exception('Procurement plan not found');
    }
    _procurementPlans[id] = plan;
    return plan;
  }

  /// Delete a procurement plan
  void deleteProcurementPlan(String id) {
    _procurementPlans.remove(id);
  }

  // CRUD Operations for Supplier Contracts

  /// Get all supplier contracts
  List<Map<String, dynamic>> getAllSupplierContracts() {
    return _supplierContracts.values.toList();
  }

  /// Get contracts for a specific supplier
  List<Map<String, dynamic>> getContractsForSupplier(String supplierId) {
    return _supplierContracts.values
        .where((contract) => contract['supplierId'] == supplierId)
        .toList();
  }

  /// Get supplier contract by ID
  Map<String, dynamic>? getSupplierContractById(String id) {
    return _supplierContracts[id];
  }

  /// Create a new supplier contract
  Map<String, dynamic> createSupplierContract(Map<String, dynamic> contract) {
    final id =
        contract['id'] ?? 'contract-${DateTime.now().millisecondsSinceEpoch}';
    final newContract = {...contract, 'id': id};
    _supplierContracts[id] = newContract;
    return newContract;
  }

  /// Update an existing supplier contract
  Map<String, dynamic> updateSupplierContract(Map<String, dynamic> contract) {
    final id = contract['id'];
    if (id == null || !_supplierContracts.containsKey(id)) {
      throw Exception('Supplier contract not found');
    }
    _supplierContracts[id] = contract;
    return contract;
  }

  /// Delete a supplier contract
  void deleteSupplierContract(String id) {
    _supplierContracts.remove(id);
  }

  // CRUD Operations for Supplier Quality Logs

  /// Get all quality logs
  List<Map<String, dynamic>> getAllQualityLogs() {
    return _qualityLogs.values.toList();
  }

  /// Get quality logs for a specific supplier
  List<Map<String, dynamic>> getQualityLogsForSupplier(String supplierId) {
    return _qualityLogs.values
        .where((log) => log['supplierId'] == supplierId)
        .toList();
  }

  /// Get quality log by ID
  Map<String, dynamic>? getQualityLogById(String id) {
    return _qualityLogs[id];
  }

  /// Create a new quality log
  Map<String, dynamic> createQualityLog(Map<String, dynamic> log) {
    final id =
        log['id'] ?? 'qualitylog-${DateTime.now().millisecondsSinceEpoch}';
    final newLog = {...log, 'id': id};
    _qualityLogs[id] = newLog;
    return newLog;
  }

  /// Update an existing quality log
  Map<String, dynamic> updateQualityLog(Map<String, dynamic> log) {
    final id = log['id'];
    if (id == null || !_qualityLogs.containsKey(id)) {
      throw Exception('Quality log not found');
    }
    _qualityLogs[id] = log;
    return log;
  }

  /// Delete a quality log
  void deleteQualityLog(String id) {
    _qualityLogs.remove(id);
  }

  // CRUD Operations for Supplier Performance Metrics

  /// Get all performance metrics
  List<Map<String, dynamic>> getAllPerformanceMetrics() {
    return _performanceMetrics.values.toList();
  }

  /// Get performance metrics for a specific supplier
  List<Map<String, dynamic>> getPerformanceMetricsForSupplier(
      String supplierId) {
    return _performanceMetrics.values
        .where((metrics) => metrics['supplierId'] == supplierId)
        .toList();
  }

  /// Get performance metrics by ID
  Map<String, dynamic>? getPerformanceMetricsById(String id) {
    return _performanceMetrics[id];
  }

  /// Create new performance metrics
  Map<String, dynamic> createPerformanceMetrics(Map<String, dynamic> metrics) {
    final id =
        metrics['id'] ?? 'metrics-${DateTime.now().millisecondsSinceEpoch}';
    final newMetrics = {...metrics, 'id': id};
    _performanceMetrics[id] = newMetrics;
    return newMetrics;
  }

  /// Update existing performance metrics
  Map<String, dynamic> updatePerformanceMetrics(Map<String, dynamic> metrics) {
    final id = metrics['id'];
    if (id == null || !_performanceMetrics.containsKey(id)) {
      throw Exception('Performance metrics not found');
    }
    _performanceMetrics[id] = metrics;
    return metrics;
  }

  /// Delete performance metrics
  void deletePerformanceMetrics(String id) {
    _performanceMetrics.remove(id);
  }

  // Mock data initialization methods

  void _loadMockSuppliers() {
    // Load suppliers from mockDataService or create sample data
    final mockSuppliers = mockDataService.getMockSuppliers();
    for (final supplier in mockSuppliers) {
      if (supplier['id'] != null) {
        final id = supplier['id'] as String;
        _suppliers[id] = SupplierModel.fromMap(supplier, id);
      }
    }
  }

  void _loadMockPurchaseOrders() {
    // Create some sample purchase orders
    final mockPOs = mockDataService.getMockPurchaseOrders();
    for (final po in mockPOs) {
      if (po['id'] != null) {
        final id = po['id'] as String;
        _purchaseOrders[id] = PurchaseOrderModel.fromMap(po, id);
      }
    }
  }

  void _loadMockVendorEvaluations() {
    // Create sample vendor evaluations
    for (final supplier in _suppliers.values) {
      if (supplier.id != null) {
        final id =
            'eval-${supplier.id}-${DateTime.now().millisecondsSinceEpoch}';
        final random = Random(supplier.id.hashCode);

        _vendorEvaluations[id] = VendorEvaluationModel(
          id: id,
          vendorId: supplier.id!,
          vendorName: supplier.name,
          evaluationDate:
              DateTime.now().subtract(Duration(days: random.nextInt(30))),
          evaluator: 'Mock Evaluator',
          qualityScore: 70.0 + random.nextDouble() * 30.0,
          deliveryScore: 70.0 + random.nextDouble() * 30.0,
          priceScore: 70.0 + random.nextDouble() * 30.0,
          serviceScore: 70.0 + random.nextDouble() * 30.0,
          overallScore: 70.0 + random.nextDouble() * 30.0,
          status: 'completed',
          comments: 'Mock evaluation comments',
          strengths: 'Good quality products',
          weaknesses: 'Occasionally late deliveries',
          recommendations: 'Recommended for continued business',
        );
      }
    }
  }

  void _loadMockProcurementPlans() {
    // Load or create sample procurement plans
    final mockPlans = mockDataService.getMockProcurementPlans();
    for (final plan in mockPlans) {
      if (plan['id'] != null) {
        _procurementPlans[plan['id'] as String] = plan;
      }
    }
  }

  void _loadMockSupplierContracts() {
    // Load or create sample supplier contracts
    final mockContracts = mockDataService.getMockSupplierContracts();
    for (final contract in mockContracts) {
      if (contract['id'] != null) {
        _supplierContracts[contract['id'] as String] = contract;
      }
    }
  }

  void _loadMockQualityLogs() {
    // Load or create sample quality logs
    final mockLogs = mockDataService.getMockQualityLogs();
    for (final log in mockLogs) {
      if (log['id'] != null) {
        _qualityLogs[log['id'] as String] = log;
      }
    }
  }

  void _loadMockPerformanceMetrics() {
    // Load or create sample performance metrics
    final mockMetrics = mockDataService.getMockPerformanceMetrics();
    for (final metric in mockMetrics) {
      if (metric['id'] != null) {
        _performanceMetrics[metric['id'] as String] = metric;
      }
    }
  }
}

/// Provider for mock procurement
final mockProcurementProvider = Provider<MockProcurementProvider>((ref) {
  final mockDataService = ref.read(mockDataServiceProvider);
  final inventoryProvider = ref.read(mockInventoryProvider);

  final provider = MockProcurementProvider(
    mockDataService: mockDataService,
    mockInventoryProvider: inventoryProvider,
  );

  // Initialize mock data
  provider.initializeMockData();

  return provider;
});
