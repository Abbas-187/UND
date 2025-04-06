import '../../../../core/exceptions/result.dart';
import '../entities/supplier.dart';

/// Repository interface for supplier operations
abstract class SupplierRepository {
  /// Get all suppliers with optional filtering
  Future<Result<List<Supplier>>> getSuppliers({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
  });

  /// Get a supplier by ID
  Future<Result<Supplier>> getSupplierById(String id);

  /// Create a new supplier
  Future<Result<Supplier>> createSupplier(Supplier supplier);

  /// Update an existing supplier
  Future<Result<Supplier>> updateSupplier(Supplier supplier);

  /// Delete a supplier
  Future<Result<void>> deleteSupplier(String id);
}
