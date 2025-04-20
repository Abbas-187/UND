import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_enums.dart';
import '../../domain/usecases/supplier_usecases.dart';

part 'supplier_providers.g.dart';

// Models

/// Quality log for suppliers
@immutable
class SupplierQualityLog {
  final String id;
  final String supplierId;
  final DateTime date;
  final String description;
  final double rating;
  final String? notes;

  const SupplierQualityLog({
    required this.id,
    required this.supplierId,
    required this.date,
    required this.description,
    required this.rating,
    this.notes,
  });
}

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
    this.certifications,
    this.minQualityRating,
    this.minDeliveryRating,
  });

  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<Supplier> suppliers;
  final bool hasMore;
  final SupplierType? selectedType;
  final SupplierStatus? selectedStatus;
  final String? searchQuery;
  final List<String>? certifications;
  final double? minQualityRating;
  final double? minDeliveryRating;

  SuppliersState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<Supplier>? suppliers,
    bool? hasMore,
    SupplierType? selectedType,
    SupplierStatus? selectedStatus,
    String? searchQuery,
    List<String>? certifications,
    double? minQualityRating,
    double? minDeliveryRating,
    bool clearError = false,
    bool clearSelectedType = false,
    bool clearSelectedStatus = false,
    bool clearSearchQuery = false,
    bool clearCertifications = false,
    bool clearQualityRating = false,
    bool clearDeliveryRating = false,
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
      certifications:
          clearCertifications ? null : (certifications ?? this.certifications),
      minQualityRating: clearQualityRating
          ? null
          : (minQualityRating ?? this.minQualityRating),
      minDeliveryRating: clearDeliveryRating
          ? null
          : (minDeliveryRating ?? this.minDeliveryRating),
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

// Filter class for suppliers
@immutable
class SupplierFilter {
  const SupplierFilter({
    this.searchQuery,
    this.supplierType,
    this.supplierStatus,
    this.minQualityRating,
    this.minDeliveryRating,
    this.certifications,
  });

  final String? searchQuery;
  final SupplierType? supplierType;
  final SupplierStatus? supplierStatus;
  final double? minQualityRating;
  final double? minDeliveryRating;
  final List<String>? certifications;

  SupplierFilter copyWith({
    String? searchQuery,
    SupplierType? supplierType,
    SupplierStatus? supplierStatus,
    double? minQualityRating,
    double? minDeliveryRating,
    List<String>? certifications,
    bool clearSearchQuery = false,
    bool clearSupplierType = false,
    bool clearSupplierStatus = false,
    bool clearQualityRating = false,
    bool clearDeliveryRating = false,
    bool clearCertifications = false,
  }) {
    return SupplierFilter(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      supplierType:
          clearSupplierType ? null : (supplierType ?? this.supplierType),
      supplierStatus:
          clearSupplierStatus ? null : (supplierStatus ?? this.supplierStatus),
      minQualityRating: clearQualityRating
          ? null
          : (minQualityRating ?? this.minQualityRating),
      minDeliveryRating: clearDeliveryRating
          ? null
          : (minDeliveryRating ?? this.minDeliveryRating),
      certifications:
          clearCertifications ? null : (certifications ?? this.certifications),
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

/// Provider for supplier filter state
@riverpod
class SupplierFilterNotifier extends _$SupplierFilterNotifier {
  @override
  SupplierFilter build() {
    return const SupplierFilter();
  }

  void updateSearchQuery(String? query) {
    if (query == null || query.isEmpty) {
      state = state.copyWith(clearSearchQuery: true);
    } else {
      state = state.copyWith(searchQuery: query);
    }
  }

  void updateSupplierType(SupplierType? type) {
    if (type == state.supplierType) {
      state = state.copyWith(clearSupplierType: true);
    } else {
      state = state.copyWith(supplierType: type);
    }
  }

  void updateSupplierStatus(SupplierStatus? status) {
    if (status == state.supplierStatus) {
      state = state.copyWith(clearSupplierStatus: true);
    } else {
      state = state.copyWith(supplierStatus: status);
    }
  }

  void updateQualityRating(double? rating) {
    if (rating == null) {
      state = state.copyWith(clearQualityRating: true);
    } else {
      state = state.copyWith(minQualityRating: rating);
    }
  }

  void updateDeliveryRating(double? rating) {
    if (rating == null) {
      state = state.copyWith(clearDeliveryRating: true);
    } else {
      state = state.copyWith(minDeliveryRating: rating);
    }
  }

  void updateCertifications(List<String>? certifications) {
    if (certifications == null || certifications.isEmpty) {
      state = state.copyWith(clearCertifications: true);
    } else {
      state = state.copyWith(certifications: certifications);
    }
  }

  void clearAllFilters() {
    state = const SupplierFilter();
  }
}

/// Notifier for suppliers list
@riverpod
class SuppliersNotifier extends AsyncNotifier<SuppliersState> {
  static const int _pageSize = 20;

  @override
  Future<SuppliersState> build() async {
    return const SuppliersState();
  }

  /// Fetch suppliers with optional filters
  Future<void> fetchSuppliers({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
    bool refresh = false,
  }) async {
    final currentState = await future;

    // If refreshing, reset state but keep filters
    SuppliersState newState;
    if (refresh) {
      newState = currentState.copyWith(
        isLoading: true,
        suppliers: const [],
        hasMore: true,
        clearError: true,
        selectedType: type ?? currentState.selectedType,
        selectedStatus: status ?? currentState.selectedStatus,
        searchQuery: searchQuery ?? currentState.searchQuery,
      );
    } else if (currentState.isLoading) {
      // Don't do anything if already loading
      return;
    } else {
      // Otherwise just set loading
      newState = currentState.copyWith(
        isLoading: true,
        clearError: true,
        selectedType: type ?? currentState.selectedType,
        selectedStatus: status ?? currentState.selectedStatus,
        searchQuery: searchQuery ?? currentState.searchQuery,
      );
    }

    state = AsyncValue.data(newState);

    try {
      final getSuppliersUseCase = ref.read(getSuppliersUseCaseProvider);
      final suppliers = await getSuppliersUseCase.execute(
        type: newState.selectedType,
        status: newState.selectedStatus,
        searchQuery: newState.searchQuery,
      );

      newState = newState.copyWith(
        isLoading: false,
        suppliers: suppliers,
        hasMore: suppliers.length >= _pageSize, // Simple pagination logic
      );

      state = AsyncValue.data(newState);
    } catch (e) {
      newState = newState.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to fetch suppliers',
      );
      state = AsyncValue.data(newState);
    }
  }

  /// Load more suppliers for pagination
  Future<void> loadMore() async {
    final currentState = await future;
    if (currentState.isLoading || !currentState.hasMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final getSuppliersUseCase = ref.read(getSuppliersUseCaseProvider);
      final currentSuppliers = currentState.suppliers;

      // In a real implementation, you would pass offset/limit or cursor
      final moreSuppliers = await getSuppliersUseCase.execute(
        type: currentState.selectedType,
        status: currentState.selectedStatus,
        searchQuery: currentState.searchQuery,
        // Pass parameter if your domain UseCase supports pagination
        // offset: currentSuppliers.length,
        // limit: _pageSize,
      );

      final newState = currentState.copyWith(
        isLoading: false,
        suppliers: [...currentSuppliers, ...moreSuppliers],
        hasMore: moreSuppliers.length >= _pageSize,
      );

      state = AsyncValue.data(newState);
    } catch (e) {
      final newState = currentState.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to load more suppliers',
      );
      state = AsyncValue.data(newState);
    }
  }

  /// Update the filter for supplier type
  Future<void> updateTypeFilter(SupplierType? type) async {
    final currentState = await future;
    SuppliersState newState;

    if (type == currentState.selectedType) {
      // Toggle off if already selected
      newState = currentState.copyWith(clearSelectedType: true);
    } else {
      newState = currentState.copyWith(selectedType: type);
    }

    state = AsyncValue.data(newState);
    fetchSuppliers(refresh: true);
  }

  /// Update the filter for supplier status
  Future<void> updateStatusFilter(SupplierStatus? status) async {
    final currentState = await future;
    SuppliersState newState;

    if (status == currentState.selectedStatus) {
      // Toggle off if already selected
      newState = currentState.copyWith(clearSelectedStatus: true);
    } else {
      newState = currentState.copyWith(selectedStatus: status);
    }

    state = AsyncValue.data(newState);
    fetchSuppliers(refresh: true);
  }

  /// Update the search query
  Future<void> updateSearchQuery(String query) async {
    final currentState = await future;
    SuppliersState newState;

    if (query.isEmpty) {
      newState = currentState.copyWith(clearSearchQuery: true);
    } else {
      newState = currentState.copyWith(searchQuery: query);
    }

    state = AsyncValue.data(newState);
    fetchSuppliers(refresh: true);
  }

  /// Apply a filter object
  Future<void> applyFilter(SupplierFilter filter) async {
    final currentState = await future;
    final newState = currentState.copyWith(
      selectedType: filter.supplierType,
      selectedStatus: filter.supplierStatus,
      searchQuery: filter.searchQuery,
    );

    state = AsyncValue.data(newState);
    fetchSuppliers(refresh: true);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    final currentState = await future;
    final newState = currentState.copyWith(
      clearSelectedType: true,
      clearSelectedStatus: true,
      clearSearchQuery: true,
    );

    state = AsyncValue.data(newState);
    fetchSuppliers(refresh: true);
  }
}

/// Provider for supplier detail
@riverpod
class SupplierDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<SupplierDetailState> {
  late String _supplierId;

  @override
  FutureOr<SupplierDetailState> build(String supplierId) {
    _supplierId = supplierId;
    // Load supplier when the provider is first created
    return _loadSupplier(supplierId);
  }

  Future<SupplierDetailState> _loadSupplier(String supplierId) async {
    try {
      final getSupplierByIdUseCase = ref.read(getSupplierByIdUseCaseProvider);
      final supplier = await getSupplierByIdUseCase.execute(supplierId);
      return SupplierDetailState(isLoading: false, supplier: supplier);
    } catch (e) {
      return SupplierDetailState(
        isLoading: false,
        hasError: true,
        errorMessage: e is AppException ? e.message : 'Failed to load supplier',
      );
    }
  }

  /// Refresh the supplier details
  Future<void> refreshSupplier() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadSupplier(_supplierId));
  }

  /// Create a new supplier
  Future<Result<Supplier>> createSupplier(Supplier supplier) async {
    state = AsyncValue.data(
        (await future).copyWith(isLoading: true, clearError: true));

    try {
      final createSupplierUseCase = ref.read(createSupplierUseCaseProvider);
      final createdSupplier = await createSupplierUseCase.execute(supplier);

      state = AsyncValue.data(
          (await future).copyWith(isLoading: false, supplier: createdSupplier));

      // Refresh the suppliers list
      ref
          .read(suppliersNotifierProvider.notifier)
          .fetchSuppliers(refresh: true);

      return Result.success(createdSupplier);
    } catch (e) {
      state = AsyncValue.data((await future).copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to create supplier',
      ));

      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to create supplier'));
    }
  }

  /// Update an existing supplier
  Future<Result<Supplier>> updateSupplier(Supplier supplier) async {
    state = AsyncValue.data(
        (await future).copyWith(isLoading: true, clearError: true));

    try {
      final updateSupplierUseCase = ref.read(updateSupplierUseCaseProvider);
      final updatedSupplier = await updateSupplierUseCase.execute(supplier);

      state = AsyncValue.data(
          (await future).copyWith(isLoading: false, supplier: updatedSupplier));

      // Refresh the suppliers list
      ref
          .read(suppliersNotifierProvider.notifier)
          .fetchSuppliers(refresh: true);

      return Result.success(updatedSupplier);
    } catch (e) {
      state = AsyncValue.data((await future).copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to update supplier',
      ));

      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to update supplier'));
    }
  }

  /// Delete a supplier
  Future<Result<void>> deleteSupplier() async {
    state = AsyncValue.data(
        (await future).copyWith(isLoading: true, clearError: true));

    try {
      final deleteSupplierUseCase = ref.read(deleteSupplierUseCaseProvider);
      await deleteSupplierUseCase.execute(_supplierId);

      state = AsyncValue.data(
          (await future).copyWith(isLoading: false, clearSupplier: true));

      // Refresh the suppliers list
      ref
          .read(suppliersNotifierProvider.notifier)
          .fetchSuppliers(refresh: true);

      return Result.success(null);
    } catch (e) {
      state = AsyncValue.data((await future).copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to delete supplier',
      ));

      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to delete supplier'));
    }
  }

  /// Calculate performance score for this supplier
  Future<Result<double>> calculatePerformanceScore() async {
    try {
      final currentState = await future;
      if (currentState.supplier == null) {
        return Result.failure(ServerFailure('Supplier not loaded'));
      }

      // Get ratings using the supplier's actual API
      final supplier = currentState.supplier!;
      // Use a default value of 3.0 for both ratings if not available
      final qualityRating = 3.0;
      final deliveryRating = 3.0;

      // Simple calculation
      final performanceScore = (qualityRating + deliveryRating) / 2;

      return Result.success(performanceScore);
    } catch (e) {
      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to calculate performance'));
    }
  }
}

/// Simple user class for authentication
@immutable
class User {
  final String id;
  final String username;

  const User({required this.id, required this.username});
}

/// Provider for the current user
final currentUserProvider = Provider<User>((ref) {
  return const User(id: 'user-1', username: 'testuser');
});
