import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/supplier_model_new.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';

/// Implementation of [SupplierRepository] that works with Firestore
class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource _dataSource;

  /// Creates a new instance with the given data source
  SupplierRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Supplier>>> getSuppliers({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
  }) async {
    try {
      // Convert enums to strings for the data source
      final typeStr = type != null ? type.toString().split('.').last : null;
      final statusStr =
          status != null ? status.toString().split('.').last : null;

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
  Future<Result<Supplier>> getSupplierById(String id) async {
    try {
      final supplierMap = await _dataSource.getSupplierById(id);
      final supplier = SupplierModel.fromMap(supplierMap, id).toEntity();
      return Result.success(supplier);
    } on SupplierDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure('Supplier not found with ID: $id'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to get supplier with ID: $id',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
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
}
