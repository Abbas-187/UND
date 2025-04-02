import '../entities/supplier.dart';

abstract class SupplierRepository {
  // Basic CRUD operations
  Future<Supplier> getSupplier(String id);
  Future<List<Supplier>> getAllSuppliers();
  Future<Supplier> addSupplier(Supplier supplier);
  Future<Supplier> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String id);

  // Filtering and searching operations
  Future<List<Supplier>> getSuppliersByCategory(String category);
  Future<List<Supplier>> searchSuppliers(String query);
  Future<List<Supplier>> filterSuppliers({
    bool? isActive,
    double? minRating,
    List<String>? categories,
  });

  // Statistics and analytics
  Future<Map<String, int>> getSuppliersCountByCategory();
  Future<List<Supplier>> getTopRatedSuppliers(int limit);
  Future<List<Supplier>> getRecentlyUpdatedSuppliers(int limit);

  // Real-time operations
  Stream<List<Supplier>> watchAllSuppliers();
  Stream<Supplier> watchSupplier(String id);
}
