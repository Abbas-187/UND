import '../entities/supplier_contract.dart';

abstract class SupplierContractRepository {
  // Basic CRUD operations
  Future<SupplierContract> getContract(String id);
  Future<List<SupplierContract>> getAllContracts();
  Future<SupplierContract> addContract(SupplierContract contract);
  Future<SupplierContract> updateContract(SupplierContract contract);
  Future<void> deleteContract(String id);

  // Filtering and searching operations
  Future<List<SupplierContract>> getContractsBySupplier(String supplierId);
  Future<List<SupplierContract>> searchContracts(String query);
  Future<List<SupplierContract>> filterContracts({
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    List<String>? contractTypes,
  });

  // Document attachment operations
  Future<String> addAttachment(
      String contractId, String fileName, dynamic fileData);
  Future<bool> deleteAttachment(String contractId, String attachmentId);
  Future<List<Map<String, dynamic>>> getAttachments(String contractId);

  // Contract event operations
  Future<List<SupplierContract>> getUpcomingRenewals(int daysThreshold);
  Future<List<SupplierContract>> getExpiringContracts(int daysThreshold);

  // Real-time operations
  Stream<List<SupplierContract>> watchAllContracts();
  Stream<SupplierContract> watchContract(String id);
}
