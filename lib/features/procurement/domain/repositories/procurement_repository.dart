/// Repository interface for procurement operations required by BOM integration
abstract class ProcurementRepository {
  /// Create a purchase request from BOM requirements
  Future<String> createPurchaseRequest(Map<String, dynamic> requestData);

  /// Get purchase requests by BOM reference
  Future<List<Map<String, dynamic>>> getPurchaseRequestsByBom(String bomId);

  /// Update purchase request status
  Future<void> updatePurchaseRequestStatus(String requestId, String status);

  /// Get supplier information
  Future<Map<String, dynamic>?> getSupplierInfo(String supplierCode);

  /// Get item pricing from suppliers
  Future<double> getItemPrice(String itemId, String supplierCode);

  /// Get supplier lead times
  Future<int> getSupplierLeadTime(String itemId, String supplierCode);
}
