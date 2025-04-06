import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../datasources/sales_data_source.dart';
import '../models/product_catalog_model.dart';

part 'product_catalog_repository.g.dart';

/// Repository for handling product catalog data operations
class ProductCatalogRepository {
  ProductCatalogRepository({
    SalesDataSource? dataSource,
  }) : _dataSource = dataSource ?? FirestoreSalesDataSource();
  final SalesDataSource _dataSource;

  /// Get a list of all products with optional filtering
  Future<List<ProductCatalogModel>> getProducts({
    bool? isActive,
    String? category,
    bool? isSeasonal,
  }) async {
    try {
      return await _dataSource.getProducts(
        isActive: isActive,
        category: category,
        isSeasonal: isSeasonal,
      );
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  /// Get a specific product by ID
  Future<ProductCatalogModel> getProductById(String id) async {
    try {
      return await _dataSource.getProductById(id);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  /// Get products by category
  Future<List<ProductCatalogModel>> getProductsByCategory(
      String category) async {
    try {
      return await _dataSource.getProducts(category: category);
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  /// Create a new product
  Future<String> createProduct(ProductCatalogModel product) async {
    try {
      return await _dataSource.createProduct(product);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update an existing product
  Future<void> updateProduct(ProductCatalogModel product) async {
    try {
      await _dataSource.updateProduct(product);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Update product active status
  Future<void> updateProductActiveStatus(
      String productId, bool isActive) async {
    try {
      await _dataSource.updateProductActiveStatus(productId, isActive);
    } catch (e) {
      throw Exception('Failed to update product status: $e');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _dataSource.deleteProduct(productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    try {
      return await _dataSource.getProductCategories();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// Search products by name or code
  Future<List<ProductCatalogModel>> searchProducts(String query) async {
    try {
      return await _dataSource.searchProducts(query);
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get seasonal products
  Future<List<ProductCatalogModel>> getSeasonalProducts() async {
    try {
      return await _dataSource.getProducts(isSeasonal: true);
    } catch (e) {
      throw Exception('Failed to get seasonal products: $e');
    }
  }

  /// Get products that need reordering
  Future<List<ProductCatalogModel>> getProductsNeedingReorder() async {
    try {
      return await _dataSource.getProductsNeedingReorder();
    } catch (e) {
      throw Exception('Failed to get products needing reorder: $e');
    }
  }

  /// Update product price tiers
  Future<void> updateProductPriceTiers(
      String productId, Map<String, double> priceTiers) async {
    try {
      await _dataSource.updateProductPriceTiers(productId, priceTiers);
    } catch (e) {
      throw Exception('Failed to update product price tiers: $e');
    }
  }
}

@riverpod
ProductCatalogRepository productCatalogRepository(
    ProductCatalogRepositoryRef ref) {
  return ProductCatalogRepository();
}
