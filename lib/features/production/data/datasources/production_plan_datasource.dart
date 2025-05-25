import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/production_plan_model.dart';

class ProductionPlanDataSource {
  Future<ProductionPlan> fetchProductionPlan(String planId) async {
    // Simulate fetching from a database or API
    await Future.delayed(const Duration(seconds: 1));
    return ProductionPlan(
      id: planId,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      items: [
        ProductionPlanItem(
          productId: 'P001',
          productName: 'Milk 1L',
          requiredQuantity: 100,
          availableStock: 20,
          productionQuantity: 80,
          deadline: DateTime.now().add(const Duration(days: 3)),
        ),
      ],
      status: 'draft',
    );
  }

  Future<void> updateProductionPlan(ProductionPlan plan) async {
    // Simulate updating the plan in a database or API
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> submitProductionPlan(String planId) async {
    // Simulate submitting the plan
    await Future.delayed(const Duration(seconds: 1));
  }
}

final productionPlanDataSourceProvider =
    Provider<ProductionPlanDataSource>((ref) {
  return ProductionPlanDataSource();
});
