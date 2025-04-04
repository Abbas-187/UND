import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/supplier_contract.dart';
import '../../domain/repositories/supplier_contract_repository.dart';

part 'supplier_contract_provider.g.dart';

// Repository provider
final supplierContractRepositoryProvider =
    Provider<SupplierContractRepository>((ref) {
  throw UnimplementedError('Repository implementation not provided');
});

// State providers
@riverpod
Stream<List<SupplierContract>> allContracts(AllContractsRef ref) {
  final repository = ref.watch(supplierContractRepositoryProvider);
  return repository.watchAllContracts();
}

@riverpod
Stream<SupplierContract> contract(ContractRef ref, String id) {
  final repository = ref.watch(supplierContractRepositoryProvider);
  return repository.watchContract(id);
}

@riverpod
Future<List<SupplierContract>> supplierContracts(
    SupplierContractsRef ref, String supplierId) {
  final repository = ref.watch(supplierContractRepositoryProvider);
  return repository.getContractsBySupplier(supplierId);
}

// Filter class
class ContractFilter {
  final String searchQuery;
  final bool? isActive;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final DateTime? endDateFrom;
  final DateTime? endDateTo;
  final List<String>? contractTypes;

  const ContractFilter({
    this.searchQuery = '',
    this.isActive,
    this.startDateFrom,
    this.startDateTo,
    this.endDateFrom,
    this.endDateTo,
    this.contractTypes,
  });

  ContractFilter copyWith({
    String? searchQuery,
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    List<String>? contractTypes,
  }) {
    return ContractFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      isActive: isActive,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      endDateFrom: endDateFrom ?? this.endDateFrom,
      endDateTo: endDateTo ?? this.endDateTo,
      contractTypes: contractTypes ?? this.contractTypes,
    );
  }
}

// Filter provider
@riverpod
class ContractFilterNotifier extends _$ContractFilterNotifier {
  @override
  ContractFilter build() {
    return const ContractFilter();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setActiveFilter(bool? isActive) {
    state = state.copyWith(isActive: isActive);
  }

  void setDateRanges({
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
  }) {
    state = state.copyWith(
      startDateFrom: startDateFrom,
      startDateTo: startDateTo,
      endDateFrom: endDateFrom,
      endDateTo: endDateTo,
    );
  }

  void setContractTypes(List<String>? types) {
    state = state.copyWith(contractTypes: types);
  }

  void resetFilters() {
    state = const ContractFilter();
  }
}

// Filtered contracts provider
@riverpod
Future<List<SupplierContract>> filteredContracts(
    FilteredContractsRef ref) async {
  final repository = ref.watch(supplierContractRepositoryProvider);
  final filter = ref.watch(contractFilterNotifierProvider);

  if (filter.searchQuery.isNotEmpty) {
    return repository.searchContracts(filter.searchQuery);
  } else {
    return repository.filterContracts(
      isActive: filter.isActive,
      startDateFrom: filter.startDateFrom,
      startDateTo: filter.startDateTo,
      endDateFrom: filter.endDateFrom,
      endDateTo: filter.endDateTo,
      contractTypes: filter.contractTypes,
    );
  }
}

// Contract notifications provider
@riverpod
Future<List<SupplierContract>> contractNotifications(
    ContractNotificationsRef ref) async {
  final repository = ref.watch(supplierContractRepositoryProvider);
  final expiringContracts = await repository.getExpiringContracts(30);
  final renewals = await repository.getUpcomingRenewals(30);

  // Combine and sort by urgency (closest to expiration/renewal first)
  final allNotifications = [...expiringContracts, ...renewals];
  allNotifications.sort((a, b) => a.endDate.compareTo(b.endDate));

  return allNotifications;
}

// Contract management functions
@riverpod
class ContractManager extends _$ContractManager {
  @override
  FutureOr<void> build() {
    // Empty initial build
  }

  Future<SupplierContract> addContract(SupplierContract contract) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(supplierContractRepositoryProvider);
      final result = await repository.addContract(contract);
      state = const AsyncData(null);
      return result;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<SupplierContract> updateContract(SupplierContract contract) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(supplierContractRepositoryProvider);
      final result = await repository.updateContract(contract);
      state = const AsyncData(null);
      return result;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> deleteContract(String id) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(supplierContractRepositoryProvider);
      await repository.deleteContract(id);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<String> addAttachment(
      String contractId, String fileName, dynamic fileData) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(supplierContractRepositoryProvider);
      final result =
          await repository.addAttachment(contractId, fileName, fileData);
      state = const AsyncData(null);
      return result;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<bool> deleteAttachment(String contractId, String attachmentId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(supplierContractRepositoryProvider);
      final result =
          await repository.deleteAttachment(contractId, attachmentId);
      state = const AsyncData(null);
      return result;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}
