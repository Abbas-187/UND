import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/supplier_model.dart';
import '../../data/models/supplier_quality_log_model.dart';
import '../../data/repositories/supplier_repository.dart';

part 'supplier_provider.g.dart';

// Repository provider
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository();
});

// Filter class for suppliers
class SupplierFilter {
  const SupplierFilter({
    this.searchQuery,
    this.supplierType,
    this.isActive,
    this.minQualityRating,
    this.minDeliveryRating,
    this.certifications,
  });
  final String? searchQuery;
  final SupplierType? supplierType;
  final bool? isActive;
  final double? minQualityRating;
  final double? minDeliveryRating;
  final List<String>? certifications;

  SupplierFilter copyWith({
    String? searchQuery,
    SupplierType? supplierType,
    bool? isActive,
    double? minQualityRating,
    double? minDeliveryRating,
    List<String>? certifications,
  }) {
    return SupplierFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      supplierType: supplierType ?? this.supplierType,
      isActive: isActive ?? this.isActive,
      minQualityRating: minQualityRating ?? this.minQualityRating,
      minDeliveryRating: minDeliveryRating ?? this.minDeliveryRating,
      certifications: certifications ?? this.certifications,
    );
  }
}

// Supplier filter state provider
final supplierFilterProvider = StateProvider<SupplierFilter>((ref) {
  return const SupplierFilter();
});

@riverpod
class SupplierListProvider extends _$SupplierListProvider {
  @override
  Future<List<Supplier>> build() async {
    final filter = ref.watch(supplierFilterProvider);
    return _getFilteredSuppliers(filter);
  }

  Future<List<Supplier>> _getFilteredSuppliers(SupplierFilter filter) async {
    final repository = ref.read(supplierRepositoryProvider);
    List<Supplier> suppliers = [];

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      // Convert the stream to a list of suppliers
      final snapshot =
          await repository.filterSuppliersByName(filter.searchQuery!).first;
      suppliers =
          snapshot.docs.map((doc) => Supplier.fromJson(doc.data())).toList();
    } else {
      // Get all suppliers and convert to a list
      final snapshot = await repository.getAllSuppliers().first;
      suppliers =
          snapshot.docs.map((doc) => Supplier.fromJson(doc.data())).toList();
    }

    // Apply other filters
    return suppliers.where((supplier) {
      bool match = true;

      if (filter.supplierType != null) {
        match = match && supplier.supplierType == filter.supplierType;
      }

      if (filter.isActive != null) {
        match = match && supplier.isActive == filter.isActive;
      }

      if (filter.minQualityRating != null) {
        match = match && supplier.qualityRating >= filter.minQualityRating!;
      }

      if (filter.minDeliveryRating != null) {
        match = match && supplier.deliveryRating >= filter.minDeliveryRating!;
      }

      if (filter.certifications != null && filter.certifications!.isNotEmpty) {
        match = match &&
            filter.certifications!
                .every((cert) => supplier.certifications.contains(cert));
      }

      return match;
    }).toList();
  }

  // CRUD operations
  Future<void> addSupplier(Map<String, dynamic> supplierData) async {
    final repository = ref.read(supplierRepositoryProvider);
    await repository.createSupplier(supplierData);
    ref.invalidateSelf();
  }

  Future<void> updateSupplier(
      String supplierId, Map<String, dynamic> supplierData) async {
    final repository = ref.read(supplierRepositoryProvider);
    await repository.updateSupplier(supplierId, supplierData);
    ref.invalidateSelf();
  }

  Future<void> deleteSupplier(String supplierId) async {
    final repository = ref.read(supplierRepositoryProvider);
    await repository.deleteSupplier(supplierId);
    ref.invalidateSelf();
  }

  // Quality tracking integration
  Future<void> addQualityLog(SupplierQualityLog qualityLog) async {
    // Implement integration with quality tracking
    // This would need a separate repository for quality logs
    // For now we'll assume it's part of the supplier repository

    // Add quality log implementation
    // This would update the supplier's quality rating based on the new log

    // After adding quality log, we should update the supplier's quality metrics
    updateSupplierQualityMetrics(qualityLog.supplierId);

    ref.invalidateSelf();
  }

  Future<void> updateSupplierQualityMetrics(String supplierId) async {
    // Calculate new quality metrics based on recent quality logs
    // This would update the supplier's ratings in the database

    // Invalidate cache to reflect updated metrics
    ref.invalidateSelf();
  }

  // Performance calculations
  Future<double> calculateSupplierPerformanceScore(String supplierId) async {
    // Implement performance calculation logic
    // This might include delivery reliability, quality consistency, etc.
    final repository = ref.read(supplierRepositoryProvider);
    final supplier = await repository.getSupplier(supplierId);

    // Example simple calculation
    final performanceScore =
        (supplier['qualityRating'] + supplier['deliveryRating']) / 2;
    return performanceScore;
  }
}

// Single supplier provider
final supplierProvider =
    FutureProvider.family<Supplier, String>((ref, supplierId) async {
  final repository = ref.read(supplierRepositoryProvider);
  final supplierDoc = await repository.getSupplier(supplierId);
  return Supplier.fromJson(supplierDoc.data() as Map<String, dynamic>);
}, dependencies: [supplierRepositoryProvider]);

// Quality logs for a specific supplier
final supplierQualityLogsProvider =
    StreamProvider.family<List<SupplierQualityLog>, String>((ref, supplierId) {
  // Implement stream of quality logs
  // This would need to be implemented in the repository
  return Stream.value([]); // Placeholder
});
