import '../../../order_management/data/models/customer_model.dart';
import '../models/product_catalog_model.dart';

abstract class SalesDataSource {
  Future<List<CustomerModel>> getCustomers(
      {String? status, String? customerType});
  Future<CustomerModel> getCustomerById(String id);
  Future<String> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
  Future<List<CustomerModel>> searchCustomers(String query);
  Future<List<ProductCatalogModel>> getProducts(
      {bool? isActive, String? category, bool? isSeasonal});
  Future<ProductCatalogModel> getProductById(String id);
  Future<String> createProduct(ProductCatalogModel product);
  Future<void> updateProduct(ProductCatalogModel product);
  Future<void> updateProductActiveStatus(String productId, bool isActive);
  Future<void> deleteProduct(String productId);
  Future<List<String>> getProductCategories();
  Future<List<ProductCatalogModel>> searchProducts(String query);
  Future<List<ProductCatalogModel>> getProductsNeedingReorder();
  Future<void> updateProductPriceTiers(
      String productId, Map<String, double> priceTiers);
}

class FirestoreSalesDataSource implements SalesDataSource {
  @override
  Future<List<CustomerModel>> getCustomers(
      {String? status, String? customerType}) async {
    // TODO: Implement Firestore logic
    return [];
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    // TODO: Implement Firestore logic
    throw UnimplementedError();
  }

  @override
  Future<String> createCustomer(CustomerModel customer) async {
    // TODO: Implement Firestore logic
    throw UnimplementedError();
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    // TODO: Implement Firestore logic
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    // TODO: Implement Firestore logic
    throw UnimplementedError();
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    // TODO: Implement Firestore logic
    return [];
  }

  @override
  Future<List<ProductCatalogModel>> getProducts(
      {bool? isActive, String? category, bool? isSeasonal}) async {
    throw UnimplementedError();
  }

  @override
  Future<ProductCatalogModel> getProductById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<String> createProduct(ProductCatalogModel product) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProduct(ProductCatalogModel product) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProductActiveStatus(
      String productId, bool isActive) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProduct(String productId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getProductCategories() async {
    throw UnimplementedError();
  }

  @override
  Future<List<ProductCatalogModel>> searchProducts(String query) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ProductCatalogModel>> getProductsNeedingReorder() async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProductPriceTiers(
      String productId, Map<String, double> priceTiers) async {
    throw UnimplementedError();
  }
}
