import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

// Repository provider
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  throw UnimplementedError('Repository implementation not provided');
});

// State providers
final allSuppliersProvider = StreamProvider<List<Supplier>>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.watchAllSuppliers();
});

final supplierProvider = StreamProvider.family<Supplier, String>((ref, id) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.watchSupplier(id);
});

// Filter class
class SupplierFilter {

  const SupplierFilter({
    this.searchQuery = '',
    this.isActive,
    this.minRating,
    this.selectedCategories,
    this.availableCategories = const [],
  });
  final String searchQuery;
  final bool? isActive;
  final double? minRating;
  final List<String>? selectedCategories;
  final List<String> availableCategories;

  SupplierFilter copyWith({
    String? searchQuery,
    bool? isActive,
    double? minRating,
    List<String>? selectedCategories,
    List<String>? availableCategories,
  }) {
    return SupplierFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      isActive: isActive,
      minRating: minRating,
      selectedCategories: selectedCategories,
      availableCategories: availableCategories ?? this.availableCategories,
    );
  }
}

// Filter provider
final supplierFilterProvider = StateProvider<SupplierFilter>((ref) {
  return const SupplierFilter();
});

// Filtered suppliers provider
final filteredSuppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final filter = ref.watch(supplierFilterProvider);

  if (filter.searchQuery.isNotEmpty) {
    return repository.searchSuppliers(filter.searchQuery);
  } else {
    return repository.filterSuppliers(
      isActive: filter.isActive,
      minRating: filter.minRating,
      categories: filter.selectedCategories,
    );
  }
});

// Analytics providers
final suppliersCountByCategoryProvider =
    FutureProvider<Map<String, int>>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.getSuppliersCountByCategory();
});

final topRatedSuppliersProvider = FutureProvider<List<Supplier>>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.getTopRatedSuppliers(5);
});

final recentlyUpdatedSuppliersProvider = FutureProvider<List<Supplier>>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.getRecentlyUpdatedSuppliers(5);
});
