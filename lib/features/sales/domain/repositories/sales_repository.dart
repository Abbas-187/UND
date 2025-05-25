/// Repository interface for sales operations required by BOM integration
abstract class SalesRepository {
  /// Update product pricing based on BOM costs
  Future<void> updateProductPricing(Map<String, dynamic> pricingData);

  /// Get current product pricing
  Future<Map<String, dynamic>?> getProductPricing(String productId);

  /// Generate customer quotation
  Future<String> generateQuotation(Map<String, dynamic> quotationData);

  /// Get sales history for a product
  Future<List<Map<String, dynamic>>> getSalesHistory(String productId);

  /// Get customer discount information
  Future<double> getCustomerDiscount(String customerId);

  /// Update profit margins
  Future<void> updateProfitMargins(String productId, double margin);
}
