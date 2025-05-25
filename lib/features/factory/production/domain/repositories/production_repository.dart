/// Repository interface for production operations required by BOM integration
abstract class ProductionRepository {
  /// Create a production order from BOM
  Future<String> createProductionOrder(Map<String, dynamic> orderData);

  /// Get production orders by BOM reference
  Future<List<Map<String, dynamic>>> getProductionOrdersByBom(String bomId);

  /// Update production order status
  Future<void> updateProductionOrderStatus(String orderId, String status);

  /// Record material consumption
  Future<void> recordMaterialConsumption(Map<String, dynamic> consumptionData);

  /// Get production capacity information
  Future<Map<String, dynamic>> getProductionCapacity(String workCenter);

  /// Get production schedule
  Future<List<Map<String, dynamic>>> getProductionSchedule(
      DateTime startDate, DateTime endDate);
}
