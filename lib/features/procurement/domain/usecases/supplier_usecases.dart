import 'package:und_app/core/exceptions/app_exception.dart';
import 'package:und_app/features/procurement/domain/entities/supplier.dart';

// Repository interface
abstract class SupplierRepository {
  Future<List<Supplier>> getSuppliers({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
  });

  Future<Supplier> getSupplierById(String id);

  Future<Supplier> createSupplier(Supplier supplier);

  Future<Supplier> updateSupplier(Supplier supplier);

  Future<void> deleteSupplier(String id);
}

class GetSuppliersUseCase {
  final SupplierRepository repository;

  GetSuppliersUseCase(this.repository);

  Future<List<Supplier>> execute({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
  }) async {
    try {
      return await repository.getSuppliers(
        type: type,
        status: status,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw AppException('Failed to fetch suppliers', details: e.toString());
    }
  }
}

class GetSupplierByIdUseCase {
  final SupplierRepository repository;

  GetSupplierByIdUseCase(this.repository);

  Future<Supplier> execute(String id) async {
    try {
      return await repository.getSupplierById(id);
    } catch (e) {
      throw AppException('Failed to fetch supplier', details: e.toString());
    }
  }
}

class CreateSupplierUseCase {
  final SupplierRepository repository;

  CreateSupplierUseCase(this.repository);

  Future<Supplier> execute(Supplier supplier) async {
    try {
      return await repository.createSupplier(supplier);
    } catch (e) {
      throw AppException('Failed to create supplier', details: e.toString());
    }
  }
}

class UpdateSupplierUseCase {
  final SupplierRepository repository;

  UpdateSupplierUseCase(this.repository);

  Future<Supplier> execute(Supplier supplier) async {
    try {
      return await repository.updateSupplier(supplier);
    } catch (e) {
      throw AppException('Failed to update supplier', details: e.toString());
    }
  }
}

class DeleteSupplierUseCase {
  final SupplierRepository repository;

  DeleteSupplierUseCase(this.repository);

  Future<void> execute(String id) async {
    try {
      await repository.deleteSupplier(id);
    } catch (e) {
      throw AppException('Failed to delete supplier', details: e.toString());
    }
  }
}
