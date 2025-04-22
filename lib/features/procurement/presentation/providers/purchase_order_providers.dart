import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/usecases/purchase_order_usecases.dart'
    hide PurchaseOrderRepository;
import '../../data/providers/mock_procurement_provider.dart';
import '../../data/repositories/purchase_order_repository_impl.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';

part 'purchase_order_providers.g.dart';

// States

/// Represents the state of a purchase order list
@immutable
class PurchaseOrdersState {
  const PurchaseOrdersState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.purchaseOrders = const [],
    this.hasMore = true,
    this.supplierId,
    this.selectedStatus,
    this.fromDate,
    this.toDate,
    this.searchQuery,
    this.sortBy = SortOption.dateDesc,
  });
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<PurchaseOrder> purchaseOrders;
  final bool hasMore;
  final String? supplierId;
  final PurchaseOrderStatus? selectedStatus;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? searchQuery;
  final SortOption sortBy;

  PurchaseOrdersState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<PurchaseOrder>? purchaseOrders,
    bool? hasMore,
    String? supplierId,
    PurchaseOrderStatus? selectedStatus,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
    SortOption? sortBy,
    bool clearError = false,
    bool clearSupplierId = false,
    bool clearSelectedStatus = false,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearSearchQuery = false,
  }) {
    return PurchaseOrdersState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      hasMore: hasMore ?? this.hasMore,
      supplierId: clearSupplierId ? null : (supplierId ?? this.supplierId),
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Represents the state of a purchase order detail
@immutable
class PurchaseOrderDetailState {
  const PurchaseOrderDetailState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.purchaseOrder,
  });
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final PurchaseOrder? purchaseOrder;

  PurchaseOrderDetailState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    PurchaseOrder? purchaseOrder,
    bool clearError = false,
    bool clearPurchaseOrder = false,
  }) {
    return PurchaseOrderDetailState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      purchaseOrder:
          clearPurchaseOrder ? null : (purchaseOrder ?? this.purchaseOrder),
    );
  }
}

/// Enum for sorting options
enum SortOption {
  dateAsc('Date (Oldest first)'),
  dateDesc('Date (Newest first)'),
  valueAsc('Value (Lowest first)'),
  valueDesc('Value (Highest first)'),
  alphabetical('Name (A-Z)'),
  supplierName('Supplier name');

  final String label;
  const SortOption(this.label);
}

// Providers

/// Provider for the GetPurchaseOrdersUseCase
@riverpod
GetPurchaseOrdersUseCase getPurchaseOrdersUseCase(
    GetPurchaseOrdersUseCaseRef ref) {
  final repository = ref.watch(purchaseOrderRepositoryProvider);
  return GetPurchaseOrdersUseCase(repository);
}

/// Provider for the GetPurchaseOrderByIdUseCase
@riverpod
GetPurchaseOrderByIdUseCase getPurchaseOrderByIdUseCase(
    GetPurchaseOrderByIdUseCaseRef ref) {
  final repository = ref.watch(purchaseOrderRepositoryProvider);
  return GetPurchaseOrderByIdUseCase(repository);
}

/// Provider for the CreatePurchaseOrderUseCase
@riverpod
CreatePurchaseOrderUseCase createPurchaseOrderUseCase(
    CreatePurchaseOrderUseCaseRef ref) {
  final repository = ref.watch(purchaseOrderRepositoryProvider);
  return CreatePurchaseOrderUseCase(repository);
}

/// Provider for the UpdatePurchaseOrderUseCase
@riverpod
UpdatePurchaseOrderUseCase updatePurchaseOrderUseCase(
    UpdatePurchaseOrderUseCaseRef ref) {
  final repository = ref.watch(purchaseOrderRepositoryProvider);
  return UpdatePurchaseOrderUseCase(repository);
}

/// Provider for the UpdatePurchaseOrderStatusUseCase
@riverpod
UpdatePurchaseOrderStatusUseCase updatePurchaseOrderStatusUseCase(
    UpdatePurchaseOrderStatusUseCaseRef ref) {
  final repository = ref.watch(purchaseOrderRepositoryProvider);
  return UpdatePurchaseOrderStatusUseCase(repository);
}

/// Provider for the DeletePurchaseOrderUseCase
@riverpod
DeletePurchaseOrderUseCase deletePurchaseOrderUseCase(
    DeletePurchaseOrderUseCaseRef ref) {
  final repository = ref.watch(purchaseOrderRepositoryProvider);
  return DeletePurchaseOrderUseCase(repository);
}

/// Provider for purchase order repository (to be implemented in the data layer)
@riverpod
PurchaseOrderRepository purchaseOrderRepository(
    PurchaseOrderRepositoryRef ref) {
  // Use the mock procurement provider for mock data
  final mockProvider = ref.watch(mockProcurementProvider);
  final supplierRepository = ref.watch(supplierRepositoryProvider);
  return PurchaseOrderRepositoryImpl.fromMock(mockProvider, supplierRepository);
}

/// Notifier for purchase orders list
@riverpod
class PurchaseOrdersNotifier extends _$PurchaseOrdersNotifier {
  static const int _pageSize = 20;

  @override
  PurchaseOrdersState build() {
    return const PurchaseOrdersState();
  }

  /// Sort the current list of purchase orders
  List<PurchaseOrder> _sortPurchaseOrders(
      List<PurchaseOrder> orders, SortOption sortOption) {
    final sortedList = List<PurchaseOrder>.from(orders);

    switch (sortOption) {
      case SortOption.dateAsc:
        sortedList.sort((a, b) => a.requestDate.compareTo(b.requestDate));
        break;
      case SortOption.dateDesc:
        sortedList.sort((a, b) => b.requestDate.compareTo(a.requestDate));
        break;
      case SortOption.valueAsc:
        sortedList.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case SortOption.valueDesc:
        sortedList.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case SortOption.alphabetical:
        sortedList.sort((a, b) => a.poNumber.compareTo(b.poNumber));
        break;
      case SortOption.supplierName:
        sortedList.sort(
            (a, b) => (a.supplierName ?? '').compareTo(b.supplierName ?? ''));
        break;
    }

    return sortedList;
  }

  /// Fetch purchase orders with optional filters
  Future<void> fetchPurchaseOrders({
    String? supplierId,
    PurchaseOrderStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
    SortOption? sortBy,
    bool refresh = false,
  }) async {
    // If refreshing, reset state but keep filters
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        purchaseOrders: const [],
        hasMore: true,
        clearError: true,
        supplierId: supplierId ?? state.supplierId,
        selectedStatus: status ?? state.selectedStatus,
        fromDate: fromDate ?? state.fromDate,
        toDate: toDate ?? state.toDate,
        searchQuery: searchQuery ?? state.searchQuery,
        sortBy: sortBy ?? state.sortBy,
      );
    } else if (state.isLoading) {
      // Don't do anything if already loading
      return;
    } else {
      // Otherwise just set loading
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        supplierId: supplierId ?? state.supplierId,
        selectedStatus: status ?? state.selectedStatus,
        fromDate: fromDate ?? state.fromDate,
        toDate: toDate ?? state.toDate,
        searchQuery: searchQuery ?? state.searchQuery,
        sortBy: sortBy ?? state.sortBy,
      );
    }

    try {
      final getPurchaseOrdersUseCase =
          ref.read(getPurchaseOrdersUseCaseProvider);
      final purchaseOrders = await getPurchaseOrdersUseCase.execute(
        supplierId: state.supplierId,
        status: state.selectedStatus,
        fromDate: state.fromDate,
        toDate: state.toDate,
        searchQuery: state.searchQuery,
      );

      // Sort the results according to selected sort option
      final sortedOrders = _sortPurchaseOrders(purchaseOrders, state.sortBy);

      state = state.copyWith(
        isLoading: false,
        purchaseOrders: sortedOrders,
        hasMore: purchaseOrders.length >= _pageSize, // Simple pagination logic
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to fetch purchase orders',
      );
    }
  }

  /// Load more purchase orders for pagination
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final getPurchaseOrdersUseCase =
          ref.read(getPurchaseOrdersUseCaseProvider);
      final currentOrders = state.purchaseOrders;

      // In a real implementation, you would pass offset/limit or cursor
      // For now we're just simulating pagination
      final moreOrders = await getPurchaseOrdersUseCase.execute(
        supplierId: state.supplierId,
        status: state.selectedStatus,
        fromDate: state.fromDate,
        toDate: state.toDate,
        searchQuery: state.searchQuery,
      );

      // Sort and combine with existing orders
      final allOrders = [...currentOrders, ...moreOrders];
      final sortedOrders = _sortPurchaseOrders(allOrders, state.sortBy);

      state = state.copyWith(
        isLoading: false,
        purchaseOrders: sortedOrders,
        hasMore: moreOrders.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e is AppException
            ? e.message
            : 'Failed to load more purchase orders',
      );
    }
  }

  /// Update the filter for supplier ID
  void updateSupplierFilter(String? supplierId) {
    if (supplierId == state.supplierId) {
      // Toggle off if already selected
      state = state.copyWith(clearSupplierId: true);
    } else {
      state = state.copyWith(supplierId: supplierId);
    }
    fetchPurchaseOrders(refresh: true);
  }

  /// Update the filter for purchase order status
  void updateStatusFilter(PurchaseOrderStatus? status) {
    if (status == state.selectedStatus) {
      // Toggle off if already selected
      state = state.copyWith(clearSelectedStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
    fetchPurchaseOrders(refresh: true);
  }

  /// Update the date range filter
  void updateDateRangeFilter(DateTime? fromDate, DateTime? toDate) {
    state = state.copyWith(
      fromDate: fromDate,
      toDate: toDate,
      clearFromDate: fromDate == null,
      clearToDate: toDate == null,
    );
    fetchPurchaseOrders(refresh: true);
  }

  /// Update the search query
  void updateSearchQuery(String query) {
    if (query.isEmpty) {
      state = state.copyWith(clearSearchQuery: true);
    } else {
      state = state.copyWith(searchQuery: query);
    }
    fetchPurchaseOrders(refresh: true);
  }

  /// Update the sort option
  void updateSortOption(SortOption sortOption) {
    if (sortOption == state.sortBy) {
      return; // Already using this sort option
    }

    // First update the state with the new sort option
    state = state.copyWith(sortBy: sortOption);

    // Then resort the current list without fetching again if we have items
    if (state.purchaseOrders.isNotEmpty) {
      final resortedOrders =
          _sortPurchaseOrders(state.purchaseOrders, sortOption);
      state = state.copyWith(purchaseOrders: resortedOrders);
    } else {
      // If we don't have items yet, fetch with the new sort option
      fetchPurchaseOrders(refresh: true);
    }
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      clearSupplierId: true,
      clearSelectedStatus: true,
      clearFromDate: true,
      clearToDate: true,
      clearSearchQuery: true,
      sortBy: SortOption.dateDesc, // Reset to default sort
    );
    fetchPurchaseOrders(refresh: true);
  }
}

/// Notifier for purchase order details
@riverpod
class PurchaseOrderDetailNotifier extends _$PurchaseOrderDetailNotifier {
  @override
  PurchaseOrderDetailState build(String purchaseOrderId) {
    // Load purchase order when the provider is first created
    _loadPurchaseOrder(purchaseOrderId);
    return const PurchaseOrderDetailState(isLoading: true);
  }

  Future<void> _loadPurchaseOrder(String purchaseOrderId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final getPurchaseOrderByIdUseCase =
          ref.read(getPurchaseOrderByIdUseCaseProvider);
      final purchaseOrder =
          await getPurchaseOrderByIdUseCase.execute(purchaseOrderId);
      state = state.copyWith(isLoading: false, purchaseOrder: purchaseOrder);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to load purchase order',
      );
    }
  }

  /// Refresh the purchase order details
  Future<void> refreshPurchaseOrder() async {
    await _loadPurchaseOrder(purchaseOrderId);
  }

  /// Create a new purchase order
  Future<Result<PurchaseOrder>> createPurchaseOrder(
      PurchaseOrder purchaseOrder) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final createPurchaseOrderUseCase =
          ref.read(createPurchaseOrderUseCaseProvider);
      final createdOrder =
          await createPurchaseOrderUseCase.execute(purchaseOrder);
      state = state.copyWith(isLoading: false, purchaseOrder: createdOrder);

      // Refresh the purchase orders list
      ref
          .read(purchaseOrdersNotifierProvider.notifier)
          .fetchPurchaseOrders(refresh: true);

      return Result.success(createdOrder);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to create purchase order',
      );
      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to create purchase order'));
    }
  }

  /// Update an existing purchase order
  Future<Result<PurchaseOrder>> updatePurchaseOrder(
      PurchaseOrder purchaseOrder) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatePurchaseOrderUseCase =
          ref.read(updatePurchaseOrderUseCaseProvider);
      final updatedOrder =
          await updatePurchaseOrderUseCase.execute(purchaseOrder);
      state = state.copyWith(isLoading: false, purchaseOrder: updatedOrder);

      // Refresh the purchase orders list
      ref
          .read(purchaseOrdersNotifierProvider.notifier)
          .fetchPurchaseOrders(refresh: true);

      return Result.success(updatedOrder);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to update purchase order',
      );
      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to update purchase order'));
    }
  }

  /// Update the status of a purchase order
  Future<Result<PurchaseOrder>> updateStatus(
      PurchaseOrderStatus newStatus) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updateStatusUseCase =
          ref.read(updatePurchaseOrderStatusUseCaseProvider);
      final updatedOrder =
          await updateStatusUseCase.execute(purchaseOrderId, newStatus);
      state = state.copyWith(isLoading: false, purchaseOrder: updatedOrder);

      // Refresh the purchase orders list
      ref
          .read(purchaseOrdersNotifierProvider.notifier)
          .fetchPurchaseOrders(refresh: true);

      return Result.success(updatedOrder);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e is AppException
            ? e.message
            : 'Failed to update purchase order status',
      );
      return Result.failure(ServerFailure(e is AppException
          ? e.message
          : 'Failed to update purchase order status'));
    }
  }

  /// Delete a purchase order
  Future<Result<void>> deletePurchaseOrder() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final deletePurchaseOrderUseCase =
          ref.read(deletePurchaseOrderUseCaseProvider);
      await deletePurchaseOrderUseCase.execute(purchaseOrderId);
      state = state.copyWith(isLoading: false, clearPurchaseOrder: true);

      // Refresh the purchase orders list
      ref
          .read(purchaseOrdersNotifierProvider.notifier)
          .fetchPurchaseOrders(refresh: true);

      return Result.success(null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            e is AppException ? e.message : 'Failed to delete purchase order',
      );
      return Result.failure(ServerFailure(
          e is AppException ? e.message : 'Failed to delete purchase order'));
    }
  }
}
