import '../../../../core/exceptions/app_exception.dart';
import '../entities/supplier.dart';
import '../entities/supplier_enums.dart';

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
  GetSuppliersUseCase(this.repository);
  final SupplierRepository repository;

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
      throw AppException(
          message: 'Failed to fetch suppliers', details: e.toString());
    }
  }
}

class GetSupplierByIdUseCase {
  GetSupplierByIdUseCase(this.repository);
  final SupplierRepository repository;

  Future<Supplier> execute(String id) async {
    try {
      return await repository.getSupplierById(id);
    } catch (e) {
      throw AppException(
          message: 'Failed to fetch supplier', details: e.toString());
    }
  }
}

class CreateSupplierUseCase {
  CreateSupplierUseCase(this.repository);
  final SupplierRepository repository;

  Future<Supplier> execute(Supplier supplier) async {
    try {
      return await repository.createSupplier(supplier);
    } catch (e) {
      throw AppException(
          message: 'Failed to create supplier', details: e.toString());
    }
  }
}

class UpdateSupplierUseCase {
  UpdateSupplierUseCase(this.repository);
  final SupplierRepository repository;

  Future<Supplier> execute(Supplier supplier) async {
    try {
      return await repository.updateSupplier(supplier);
    } catch (e) {
      throw AppException(
          message: 'Failed to update supplier', details: e.toString());
    }
  }
}

class DeleteSupplierUseCase {
  DeleteSupplierUseCase(this.repository);
  final SupplierRepository repository;

  Future<void> execute(String id) async {
    try {
      await repository.deleteSupplier(id);
    } catch (e) {
      throw AppException(
          message: 'Failed to delete supplier', details: e.toString());
    }
  }
}
