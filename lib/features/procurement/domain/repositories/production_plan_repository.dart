/// Repository interface for production plan operations.
abstract class ProductionPlanRepository {
  /// Retrieves a production plan by its ID.
  ///
  /// [id] - ID of the production plan
  /// Returns the production plan or null if not found
  Future<ProductionPlan?> getProductionPlanById(String id);

  /// Retrieves all active production plans.
  ///
  /// Returns a list of active production plans
  Future<List<ProductionPlan>> getActiveProductionPlans();
}

/// Simple model for production plan.
class ProductionPlan {

  const ProductionPlan({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.items,
  });
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<ProductionPlanItem> items;
}

/// Simple model for production plan item.
class ProductionPlanItem {

  const ProductionPlanItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.requiredMaterials,
  });
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final List<ProductionMaterial> requiredMaterials;
}

/// Simple model for production material.
class ProductionMaterial {

  const ProductionMaterial({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });
  final String itemId;
  final String itemName;
  final double quantity;
  final String unit;
}
