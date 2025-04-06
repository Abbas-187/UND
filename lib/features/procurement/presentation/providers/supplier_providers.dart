import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/usecases/supplier_usecases.dart';

part 'supplier_providers.g.dart';

// States

/// Represents the state of a supplier list
@immutable
class SuppliersState {

  const SuppliersState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.suppliers = const [],
    this.hasMore = true,
    this.selectedType,
    this.selectedStatus,
    this.searchQuery,
  });
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<Supplier> suppliers;
  final bool hasMore;
  final SupplierType? selectedType;
  final SupplierStatus? selectedStatus;
  final String? searchQuery;

  SuppliersState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<Supplier>? suppliers,
    bool? hasMore,
    SupplierType? selectedType,
    SupplierStatus? selectedStatus,
    String? searchQuery,
    bool clearError = false,
    bool clearSelectedType = false,
    bool clearSelectedStatus = false,
    bool clearSearchQuery = false,
  }) {
    return SuppliersState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      suppliers: suppliers ?? this.suppliers,
      hasMore: hasMore ?? this.hasMore,
      selectedType:
          clearSelectedType ? null : (selectedType ?? this.selectedType),
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

/// Represents the state of a supplier detail
@immutable
class SupplierDetailState {

  const SupplierDetailState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.supplier,
  });
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final Supplier? supplier;

  SupplierDetailState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    Supplier? supplier,
    bool clearError = false,
    bool clearSupplier = false,
  }) {
    return SupplierDetailState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      supplier: clearSupplier ? null : (supplier ?? this.supplier),
    );
  }
}

// Providers

/// Provider for the GetSuppliersUseCase
@riverpod
GetSuppliersUseCase getSuppliersUseCase(GetSuppliersUseCaseRef ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return GetSuppliersUseCase(repository);
}

/// Provider for the GetSupplierByIdUseCase
@riverpod
GetSupplierByIdUseCase getSupplierByIdUseCase(GetSupplierByIdUseCaseRef ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return GetSupplierByIdUseCase(repository);
}

/// Provider for the CreateSupplierUseCase
@riverpod
CreateSupplierUseCase createSupplierUseCase(CreateSupplierUseCaseRef ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return CreateSupplierUseCase(repository);
}

/// Provider for the UpdateSupplierUseCase
@riverpod
UpdateSupplierUseCase updateSupplierUseCase(UpdateSupplierUseCaseRef ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return UpdateSupplierUseCase(repository);
}

/// Provider for the DeleteSupplierUseCase
@riverpod
DeleteSupplierUseCase deleteSupplierUseCase(DeleteSupplierUseCaseRef ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return DeleteSupplierUseCase(repository);
}

/// Provider for supplier repository (to be implemented in the data layer)
@riverpod
SupplierRepository supplierRepository(SupplierRepositoryRef ref) {
  throw UnimplementedError(
      'You need to override this provider in the data layer');
}

/// Notifier for suppliers list
@riverpod
class SuppliersNotifier extends _$SuppliersNotifier {
  static const int _pageSize = 20;

  @override
  SuppliersState build() {
    return const SuppliersState();
  }

  /// Fetch suppliers with optional filters
  Future<void> fetchSuppliers({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
    bool refresh = false,
  }) async {
    // If refreshing, reset state but keep filters
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        suppliers: const [],
        hasMore: true,
        clearError: true,
        selectedType: type ?? state.selectedType,
        selectedStatus: status ?? state.selectedStatus,
        searchQuery: searchQuery ?? state.searchQuery,
      );
    } else if (state.isLoading) {
      // Don't do anything if already loading
      return;
    } else {
      // Otherwise just set loading
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        selectedType: type ?? state.selectedType,
        selectedStatus: status ?? state.selectedStatus,
        searchQuery: searchQuery ?? state.searchQuery,
      );
    }

    try {
      final getSuppliersUseCase = ref.read(getSuppliersUseCaseProvider);
      final suppliers = await getSuppliersUseCase.execute(
        type: state.selectedType,
        status: state.selectedStatus,
        searchQuery: state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        suppliers: suppliers,
        hasMore: suppliers.length >= _pageSize, // Simple pagination logic
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to fetch suppliers',
      );
    }
  }

  /// Load more suppliers for pagination
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final getSuppliersUseCase = ref.read(getSuppliersUseCaseProvider);
      final currentSuppliers = state.suppliers;

      // In a real implementation, you would pass offset/limit or cursor
      // For now we're just simulating pagination
      final moreSuppliers = await getSuppliersUseCase.execute(
        type: state.selectedType,
        status: state.selectedStatus,
        searchQuery: state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        suppliers: [...currentSuppliers, ...moreSuppliers],
        hasMore: moreSuppliers.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to load more suppliers',
      );
    }
  }

  /// Update the filter for supplier type
  void updateTypeFilter(SupplierType? type) {
    if (type == state.selectedType) {
      // Toggle off if already selected
      state = state.copyWith(clearSelectedType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
    fetchSuppliers(refresh: true);
  }

  /// Update the filter for supplier status
  void updateStatusFilter(SupplierStatus? status) {
    if (status == state.selectedStatus) {
      // Toggle off if already selected
      state = state.copyWith(clearSelectedStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
    fetchSuppliers(refresh: true);
  }

  /// Update the search query
  void updateSearchQuery(String query) {
    if (query.isEmpty) {
      state = state.copyWith(clearSearchQuery: true);
    } else {
      state = state.copyWith(searchQuery: query);
    }
    fetchSuppliers(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      clearSelectedType: true,
      clearSelectedStatus: true,
      clearSearchQuery: true,
    );
    fetchSuppliers(refresh: true);
  }
}

/// Notifier for supplier details
@riverpod
class SupplierDetailNotifier extends _$SupplierDetailNotifier {
  @override
  SupplierDetailState build(String supplierId) {
    // Load supplier when the provider is first created
    _loadSupplier(supplierId);
    return const SupplierDetailState(isLoading: true);
  }

  Future<void> _loadSupplier(String supplierId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final getSupplierByIdUseCase = ref.read(getSupplierByIdUseCaseProvider);
      final supplier = await getSupplierByIdUseCase.execute(supplierId);
      state = state.copyWith(isLoading: false, supplier: supplier);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e is AppException ? e.message : 'Failed to load supplier',
      );
    }
  }

  /// Refresh the supplier details
  Future<void> refreshSupplier() async {
    await _loadSupplier(supplierId);
  }

  /// Create a new supplier
  Future<Result<Supplier>> createSupplier(Supplier supplier) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final createSupplierUseCase = ref.read(createSupplierUseCaseProvider);
      final createdSupplier = await createSupplierUseCase.execute(supplier);
      state = state.copyWith(isLoading: false, supplier: createdSupplier);

      // Refresh the suppliers list
      ref
          .read(suppliersNotifierProvider.notifier)
          .fetchSuppliers(refresh: true);

      return Result.success(createdSupplier);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to create supplier',
      );
      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to create supplier'));
    }
  }

  /// Update an existing supplier
  Future<Result<Supplier>> updateSupplier(Supplier supplier) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updateSupplierUseCase = ref.read(updateSupplierUseCaseProvider);
      final updatedSupplier = await updateSupplierUseCase.execute(supplier);
      state = state.copyWith(isLoading: false, supplier: updatedSupplier);

      // Refresh the suppliers list
      ref
          .read(suppliersNotifierProvider.notifier)
          .fetchSuppliers(refresh: true);

      return Result.success(updatedSupplier);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to update supplier',
      );
      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to update supplier'));
    }
  }

  /// Delete a supplier
  Future<Result<void>> deleteSupplier() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final deleteSupplierUseCase = ref.read(deleteSupplierUseCaseProvider);
      await deleteSupplierUseCase.execute(supplierId);
      state = state.copyWith(isLoading: false, clearSupplier: true);

      // Refresh the suppliers list
      ref
          .read(suppliersNotifierProvider.notifier)
          .fetchSuppliers(refresh: true);

      return Result.success(null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to delete supplier',
      );
      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to delete supplier'));
    }
  }
}
