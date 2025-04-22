import 'package:uuid/uuid.dart';
import '../../domain/entities/procurement_plan.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/production_plan_repository.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../domain/validation/procurement_plan_validator.dart';

/// Service responsible for generating procurement plans based on production needs.
class ProcurementPlanGenerator {
  final ProductionPlanRepository _productionPlanRepository;
  final InventoryRepository _inventoryRepository;
  final SupplierRepository _supplierRepository;
  final ProcurementPlanValidator _validator;
  final Uuid _uuid = const Uuid();

  ProcurementPlanGenerator({
    required ProductionPlanRepository productionPlanRepository,
    required InventoryRepository inventoryRepository,
    required SupplierRepository supplierRepository,
    required ProcurementPlanValidator validator,
  })  : _productionPlanRepository = productionPlanRepository,
        _inventoryRepository = inventoryRepository,
        _supplierRepository = supplierRepository,
        _validator = validator;

  /// Generates a procurement plan based on the provided production plan IDs.
  ///
  /// [productionPlanIds] - List of production plan IDs to consider
  /// [createdBy] - User ID of the person creating the plan
  /// [planName] - Name for the procurement plan
  /// [budgetLimit] - Optional budget limit for the plan
  /// [notes] - Optional notes for the plan
  Future<ProcurementPlan> generateProcurementPlan({
    required List<String> productionPlanIds,
    required String createdBy,
    required String planName,
    double? budgetLimit,
    String? notes,
  }) async {
    // 1. Fetch production plans
    final productionPlans = await _fetchProductionPlans(productionPlanIds);

    // 2. Aggregate required materials
    final requiredMaterials = _aggregateRequiredMaterials(productionPlans);

    // 3. Check inventory for each material
    final toProcure = await _calculateToProcure(requiredMaterials);

    // 4. Select suppliers for each item
    final procurementItems = await _createProcurementItems(toProcure);

    // 5. Calculate total estimated cost
    final totalCost = _calculateTotalCost(procurementItems);

    // 6. Create the procurement plan
    final plan = ProcurementPlan(
      id: _uuid.v4(),
      name: planName,
      creationDate: DateTime.now(),
      createdBy: createdBy,
      status: ProcurementPlanStatus.draft,
      items: procurementItems,
      estimatedTotalCost: totalCost,
      notes: notes,
      budgetLimit: budgetLimit,
    );

    // 7. Validate the plan
    final validationResult = await _validator.validate(plan);
    if (!validationResult.isValid) {
      throw Exception(
          'Procurement plan validation failed: ${validationResult.errors.join(', ')}');
    }

    return plan;
  }

  Future<List<dynamic>> _fetchProductionPlans(
      List<String> productionPlanIds) async {
    // Fetch all production plans
    final List<dynamic> plans = [];
    for (final id in productionPlanIds) {
      final plan = await _productionPlanRepository.getProductionPlanById(id);
      if (plan != null) {
        plans.add(plan);
      }
    }
    return plans;
  }

  Map<String, double> _aggregateRequiredMaterials(
      List<dynamic> productionPlans) {
    // Aggregate required materials across all production plans
    final Map<String, double> requiredMaterials = {};

    for (final plan in productionPlans) {
      final items = plan.items;
      for (final item in items) {
        final materials = item.requiredMaterials;
        for (final material in materials) {
          final itemId = material.itemId;
          final requiredQuantity = material.quantity * item.quantity;

          if (requiredMaterials.containsKey(itemId)) {
            requiredMaterials[itemId] =
                (requiredMaterials[itemId] ?? 0) + requiredQuantity;
          } else {
            requiredMaterials[itemId] = requiredQuantity;
          }
        }
      }
    }

    return requiredMaterials;
  }

  Future<Map<String, Map<String, dynamic>>> _calculateToProcure(
      Map<String, double> requiredMaterials) async {
    // Check inventory levels and calculate what needs to be procured
    final Map<String, Map<String, dynamic>> toProcure = {};

    for (final entry in requiredMaterials.entries) {
      final itemId = entry.key;
      final requiredQuantity = entry.value;

      // Get current inventory level
      final inventoryLevel =
          await _inventoryRepository.getItemInventoryLevel(itemId);

      // Calculate how much to procure
      final quantityToProcure = requiredQuantity - inventoryLevel;

      // Only include items that need to be procured
      if (quantityToProcure > 0) {
        // Get item details
        final item = await _inventoryRepository.getItemById(itemId);

        toProcure[itemId] = {
          'itemId': itemId,
          'itemName': item.name,
          'quantity': quantityToProcure,
          'unit': item.unit,
          'inventoryLevel': inventoryLevel,
        };
      }
    }

    return toProcure;
  }

  Future<List<ProcurementPlanItem>> _createProcurementItems(
      Map<String, Map<String, dynamic>> toProcure) async {
    // Select suppliers and create procurement items
    final List<ProcurementPlanItem> items = [];

    for (final entry in toProcure.entries) {
      final itemData = entry.value;

      // TODO: Implement preferred supplier selection using SupplierRepository methods
      final supplier = (await _supplierRepository.getAllSuppliers()).first;
      // TODO: Implement supplier item price retrieval using SupplierRepository methods
      final unitPrice = 0.0;

      final item = ProcurementPlanItem(
        id: _uuid.v4(),
        itemId: itemData['itemId'],
        itemName: itemData['itemName'],
        quantity: itemData['quantity'],
        unit: itemData['unit'],
        preferredSupplierId: supplier.id,
        preferredSupplierName: supplier.name,
        estimatedUnitCost: unitPrice,
        estimatedTotalCost: unitPrice * itemData['quantity'],
        requiredByDate: DateTime.now()
            .add(const Duration(days: 14)), // Default to 2 weeks lead time
        urgency: ProcurementItemUrgency.medium, // Default urgency
        inventoryLevel: itemData['inventoryLevel'],
      );

      items.add(item);
    }

    return items;
  }

  double _calculateTotalCost(List<ProcurementPlanItem> items) {
    // Calculate total estimated cost
    return items.fold(0, (sum, item) => sum + item.estimatedTotalCost);
  }
}
