import '../../../../core/exceptions/result.dart';
import '../entities/supplier_contract.dart';

/// Repository interface for supplier contract operations
abstract class SupplierContractRepository {
  /// Get all supplier contracts with optional filtering
  Future<Result<List<SupplierContract>>> getSupplierContracts({
    String? supplierId,
    ContractStatus? status,
    DateTime? activeDate,
    String? contractType,
  });

  /// Get a supplier contract by ID
  Future<Result<SupplierContract>> getSupplierContractById(String id);

  /// Create a new supplier contract
  Future<Result<SupplierContract>> createSupplierContract(
      SupplierContract contract);

  /// Update an existing supplier contract
  Future<Result<SupplierContract>> updateSupplierContract(
      SupplierContract contract);

  /// Update supplier contract status
  Future<Result<SupplierContract>> updateSupplierContractStatus(
      String id, ContractStatus status);

  /// Delete a supplier contract
  Future<Result<void>> deleteSupplierContract(String id);

  /// Get active contracts for a supplier
  Future<Result<List<SupplierContract>>> getActiveContractsForSupplier(
      String supplierId);

  /// Get contracts expiring soon (within specified days)
  Future<Result<List<SupplierContract>>> getContractsExpiringSoon(
      int daysThreshold);
}
