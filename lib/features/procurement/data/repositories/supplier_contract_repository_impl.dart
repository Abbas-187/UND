import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../../domain/entities/supplier_contract.dart';
import '../../domain/repositories/supplier_contract_repository.dart';
import '../datasources/supplier_contract_remote_datasource.dart';

/// Implementation of [SupplierContractRepository] that works with Firestore
class SupplierContractRepositoryImpl implements SupplierContractRepository {

  /// Creates a new instance with the given data source
  SupplierContractRepositoryImpl(this._dataSource);
  final SupplierContractRemoteDataSource _dataSource;

  @override
  Future<Result<List<SupplierContract>>> getSupplierContracts({
    String? supplierId,
    ContractStatus? status,
    DateTime? activeDate,
    String? contractType,
  }) async {
    try {
      // Convert enum to string for the data source
      final statusStr =
          status?.toString().split('.').last;

      final contractMaps = await _dataSource.getSupplierContracts(
        supplierId: supplierId,
        status: statusStr,
        activeDate: activeDate,
        contractType: contractType,
      );

      // Convert the raw data maps to domain entities
      final contracts = _convertMapsToContracts(contractMaps);

      return Result.success(contracts);
    } on SupplierContractDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to get supplier contracts',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<SupplierContract>> getSupplierContractById(String id) async {
    try {
      final contractMap = await _dataSource.getSupplierContractById(id);
      final contract = _convertMapToContract(contractMap);
      return Result.success(contract);
    } on SupplierContractDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure('Supplier contract not found with ID: $id'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to get supplier contract with ID: $id',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<SupplierContract>> createSupplierContract(
      SupplierContract contract) async {
    try {
      // Convert domain entity to data map
      final contractMap = _convertContractToMap(contract);

      // Pass to data source
      final createdContractMap =
          await _dataSource.createSupplierContract(contractMap);

      // Convert back to domain entity
      final createdContract = _convertMapToContract(createdContractMap);

      return Result.success(createdContract);
    } on SupplierContractDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to create supplier contract',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<SupplierContract>> updateSupplierContract(
      SupplierContract contract) async {
    try {
      // Validate ID
      if (contract.id.isEmpty) {
        return Result.failure(
          ValidationFailure('Supplier contract ID is required for update'),
        );
      }

      // Convert domain entity to data map
      final contractMap = _convertContractToMap(contract);

      // Pass to data source
      final updatedContractMap =
          await _dataSource.updateSupplierContract(contract.id, contractMap);

      // Convert back to domain entity
      final updatedContract = _convertMapToContract(updatedContractMap);

      return Result.success(updatedContract);
    } on SupplierContractDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure(
              'Supplier contract not found with ID: ${contract.id}'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to update supplier contract',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<SupplierContract>> updateSupplierContractStatus(
      String id, ContractStatus status) async {
    try {
      // Convert enum to string for the data source
      final statusStr = status.toString().split('.').last;

      // Pass to data source
      final updatedContractMap =
          await _dataSource.updateSupplierContractStatus(id, statusStr);

      // Convert back to domain entity
      final updatedContract = _convertMapToContract(updatedContractMap);

      return Result.success(updatedContract);
    } on SupplierContractDataSourceException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          NotFoundFailure('Supplier contract not found with ID: $id'),
        );
      }
      return Result.failure(
        ServerFailure('Failed to update supplier contract status',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteSupplierContract(String id) async {
    try {
      await _dataSource.deleteSupplierContract(id);
      return Result.success(null);
    } on SupplierContractDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to delete supplier contract',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<SupplierContract>>> getActiveContractsForSupplier(
      String supplierId) async {
    try {
      final contractMaps =
          await _dataSource.getActiveContractsForSupplier(supplierId);
      final contracts = _convertMapsToContracts(contractMaps);
      return Result.success(contracts);
    } on SupplierContractDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to get active contracts for supplier',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<List<SupplierContract>>> getContractsExpiringSoon(
      int daysThreshold) async {
    try {
      final contractMaps =
          await _dataSource.getContractsExpiringSoon(daysThreshold);
      final contracts = _convertMapsToContracts(contractMaps);
      return Result.success(contracts);
    } on SupplierContractDataSourceException catch (e) {
      return Result.failure(
        ServerFailure('Failed to get contracts expiring soon',
            details: e.toString()),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('An unexpected error occurred', details: e.toString()),
      );
    }
  }

  // Helper method to convert a list of maps to domain entities
  List<SupplierContract> _convertMapsToContracts(
      List<Map<String, dynamic>> maps) {
    return maps.map((map) => _convertMapToContract(map)).toList();
  }

  // Helper method to convert a map to a domain entity
  SupplierContract _convertMapToContract(Map<String, dynamic> map) {
    return SupplierContract(
      id: map['id'] ?? '',
      contractNumber: map['contractNumber'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      startDate: map['startDate'] as DateTime? ?? DateTime.now(),
      endDate: map['endDate'] as DateTime? ??
          DateTime.now().add(const Duration(days: 365)),
      status: _mapStringToContractStatus(map['status'] ?? 'draft'),
      contractType: map['contractType'] ?? '',
      terms: map['terms'],
      value: map['value'] != null ? (map['value'] as num).toDouble() : null,
      paymentTerms: map['paymentTerms'],
      deliveryTerms: map['deliveryTerms'],
      qualityRequirements: map['qualityRequirements'],
      attachments: map['attachments'] != null
          ? (map['attachments'] as List).cast<String>()
          : null,
      signedBy: map['signedBy'],
      signedDate: map['signedDate'] as DateTime?,
      createdAt: map['createdAt'] as DateTime? ?? DateTime.now(),
      updatedAt: map['updatedAt'] as DateTime?,
    );
  }

  // Helper method to convert a domain entity to a map
  Map<String, dynamic> _convertContractToMap(SupplierContract contract) {
    return {
      'contractNumber': contract.contractNumber,
      'supplierId': contract.supplierId,
      'supplierName': contract.supplierName,
      'startDate': contract.startDate,
      'endDate': contract.endDate,
      'status': contract.status.toString().split('.').last,
      'contractType': contract.contractType,
      'terms': contract.terms,
      'value': contract.value,
      'paymentTerms': contract.paymentTerms,
      'deliveryTerms': contract.deliveryTerms,
      'qualityRequirements': contract.qualityRequirements,
      'attachments': contract.attachments,
      'signedBy': contract.signedBy,
      'signedDate': contract.signedDate,
    };
  }

  // Helper method to map string to ContractStatus enum
  ContractStatus _mapStringToContractStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return ContractStatus.draft;
      case 'active':
        return ContractStatus.active;
      case 'expired':
        return ContractStatus.expired;
      case 'terminated':
        return ContractStatus.terminated;
      case 'onhold':
        return ContractStatus.onHold;
      case 'pendingrenewal':
        return ContractStatus.pendingRenewal;
      case 'renewed':
        return ContractStatus.renewed;
      default:
        return ContractStatus.draft;
    }
  }
}
