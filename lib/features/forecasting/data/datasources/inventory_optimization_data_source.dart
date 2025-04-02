import '../models/inventory_optimization_model.dart';

/// Mock data source for inventory optimizations (using in-memory data)
class InventoryOptimizationDataSource {
  InventoryOptimizationDataSource();

  final List<InventoryOptimizationModel> _optimizations =
      []; // In-memory storage

  /// Creates a new inventory optimization
  Future<String> createInventoryOptimization(
      InventoryOptimizationModel optimization) async {
    _optimizations.add(optimization);
    return optimization.id ?? 'mock_id_${_optimizations.length}'; // Mock ID
  }

  /// Updates an existing inventory optimization
  Future<void> updateInventoryOptimization(
      InventoryOptimizationModel optimization) async {
    final index = _optimizations.indexWhere((opt) => opt.id == optimization.id);
    if (index != -1) {
      _optimizations[index] = optimization;
    } else {
      throw Exception('Inventory optimization not found');
    }
  }

  /// Gets an inventory optimization by ID
  Future<InventoryOptimizationModel> getInventoryOptimizationById(
      String id) async {
    final optimization = _optimizations.firstWhere((opt) => opt.id == id,
        orElse: () => throw Exception('Inventory optimization not found'));
    return optimization;
  }

  /// Gets all inventory optimizations
  Future<List<InventoryOptimizationModel>> getInventoryOptimizations() async {
    return _optimizations;
  }

  /// Deletes an inventory optimization
  Future<void> deleteInventoryOptimization(String id) async {
    _optimizations.removeWhere((opt) => opt.id == id);
  }

  /// Calculates optimal inventory levels (mock implementation)
  Future<Map<String, OptimizationResultModel>> calculateOptimalInventoryLevels({
    required List<String> productIds,
    String? categoryId,
    String? warehouseId,
    Map<String, dynamic>? parameters,
  }) async {
    // Mock implementation - returns empty map
    return {};
  }
}
