import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/supplier_model_new.dart';

/// Implementation of [SupplierRepository] that works with Firestore
class SupplierRepositoryImpl implements SupplierRepository {
  /// Creates a new instance with the given data source
  SupplierRepositoryImpl(this._dataSource);
  final SupplierRemoteDataSource _dataSource;

  @override
  Future<List<Supplier>> getSuppliers() async {
    try {
      // Call the data source method with no filters
      final supplierMaps = await _dataSource.getSuppliers();

      // Convert the raw data maps to domain entities
      final suppliers = supplierMaps
          .map((map) =>
              SupplierModel.fromMap(map, map['id'] as String).toEntity())
          .toList();

      return suppliers;
    } catch (e) {
      throw ServerFailure('Failed to get suppliers', details: e.toString());
    }
  }

  /// Extended version of getSuppliers that supports filtering
  Future<Result<List<Supplier>>> getSuppliersWithFilters({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
  }) async {
    try {
      // Convert enums to strings for the data source
      final typeStr = type?.toString().split('.').last;
      final statusStr = status?.toString().split('.').last;

      final supplierMaps = await _dataSource.getSuppliers(
        type: typeStr,
        status: statusStr,
        searchQuery: searchQuery,
      );

      // Convert the raw data maps to domain entities
      final suppliers = supplierMaps
          .map((map) =>
              SupplierModel.fromMap(map, map['id'] as String).toEntity())
          .toList();

      return Result.success(suppliers);
    } on SupplierDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to get suppliers', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Supplier?> getSupplierById(String id) async {
    try {
      final supplierMap = await _dataSource.getSupplierById(id);
      final supplier = SupplierModel.fromMap(supplierMap, id).toEntity();
      return supplier;
    } on SupplierDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return null;
      }
      throw ServerFailure('Failed to get supplier with ID: $id',
          details: e.toString());
    } catch (e) {
      throw UnknownFailure('An unexpected error occurred',
          details: e.toString());
    }
  }

  @override
  Future<Result<Supplier>> createSupplier(Supplier supplier) async {
    try {
      // Convert domain entity to data model
      final supplierModel = SupplierModel.fromEntity(supplier);

      // Pass to data source
      final createdSupplierMap =
          await _dataSource.createSupplier(supplierModel.toMap());

      // Convert back to domain entity
      final createdSupplier = SupplierModel.fromMap(
              createdSupplierMap, createdSupplierMap['id'] as String)
          .toEntity();

      return Result.success(createdSupplier);
    } on SupplierDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to create supplier', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<Supplier>> updateSupplier(Supplier supplier) async {
    try {
      // Validate ID
      if (supplier.id.isEmpty) {
        return Result.failure(
          ValidationFailure('Supplier ID is required for update'),
        );
      }

      // Convert domain entity to data model
      final supplierModel = SupplierModel.fromEntity(supplier);

      // Pass to data source
      final updatedSupplierMap =
          await _dataSource.updateSupplier(supplier.id, supplierModel.toMap());

      // Convert back to domain entity
      final updatedSupplier =
          SupplierModel.fromMap(updatedSupplierMap, supplier.id).toEntity();

      return Result.success(updatedSupplier);
    } on SupplierDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure('Supplier not found with ID: ${supplier.id}'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to update supplier', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteSupplier(String id) async {
    try {
      await _dataSource.deleteSupplier(id);
      return Result.success(null);
    } on SupplierDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to delete supplier', details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<List<Supplier>> getActiveSuppliers() async {
    try {
      final supplierMaps = await _dataSource.getSuppliers(
        status: 'active',
      );

      // Convert the raw data maps to domain entities
      final suppliers = supplierMaps
          .map((map) =>
              SupplierModel.fromMap(map, map['id'] as String).toEntity())
          .toList();

      return suppliers;
    } catch (e) {
      throw ServerFailure('Failed to get active suppliers',
          details: e.toString());
    }
  }

  @override
  Future<Supplier> getPreferredSupplierForItem(String itemId) async {
    try {
      // Implementation note: This would typically involve a query to get the preferred
      // supplier for a specific item. Since we don't have a direct method in the data source,
      // we need to implement a custom query here or extend the data source.

      // For now, we'll implement a simple version that returns the first active supplier
      // In a real application, this would query a relationship collection or use a more complex query
      final supplierMaps = await _dataSource.getSuppliers(status: 'active');

      if (supplierMaps.isEmpty) {
        throw ServerFailure('No preferred supplier found for item: $itemId');
      }

      // Assume the first active supplier is the preferred one (this is a simplified approach)
      return SupplierModel.fromMap(
              supplierMaps.first, supplierMaps.first['id'] as String)
          .toEntity();
    } catch (e) {
      throw ServerFailure('Failed to get preferred supplier for item: $itemId',
          details: e.toString());
    }
  }

  @override
  Future<double> getSupplierItemPrice(String supplierId, String itemId) async {
    try {
      // Implementation note: This would typically involve a query to the pricing collection
      // Since we don't have a direct method in the data source, we'll simulate it here

      // In a real application, you would query a pricing collection or item-supplier relationship
      // For now, returning a dummy value (this should be replaced with actual implementation)
      return 100.0; // Placeholder price
    } catch (e) {
      throw ServerFailure(
          'Failed to get price for item: $itemId from supplier: $supplierId',
          details: e.toString());
    }
  }

  @override
  Future<List<Supplier>> getSuppliersForItem(String itemId) async {
    try {
      // Implementation note: This would typically involve a query to find all suppliers
      // that can provide a specific item.

      // For now, returning all active suppliers as a placeholder implementation
      final supplierMaps = await _dataSource.getSuppliers(status: 'active');

      return supplierMaps
          .map((map) =>
              SupplierModel.fromMap(map, map['id'] as String).toEntity())
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get suppliers for item: $itemId',
          details: e.toString());
    }
  }
}
