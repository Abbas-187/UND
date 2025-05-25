import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../procurement/domain/repositories/procurement_repository.dart';
import '../../../factory/production/domain/repositories/production_repository.dart';
import '../../../sales/domain/repositories/sales_repository.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../../domain/repositories/bom_repository.dart';
import '../../domain/usecases/bom_integration_usecase.dart';
import '../../data/repositories/bom_repository_impl.dart';

// Repository Providers
final bomRepositoryProvider = Provider<BomRepository>((ref) {
  return BomRepositoryImpl(FirebaseFirestore.instance);
});

// Use Case Providers
final bomIntegrationUseCaseProvider = Provider<BomIntegrationUseCase>((ref) {
  return BomIntegrationUseCase(
    bomRepository: ref.watch(bomRepositoryProvider),
    inventoryRepository: ref.watch(inventoryRepositoryProvider),
    procurementRepository: ref.watch(procurementRepositoryProvider),
    productionRepository: ref.watch(productionRepositoryProvider),
    salesRepository: ref.watch(salesRepositoryProvider),
  );
});

// Data Providers
final allBomsProvider = FutureProvider<List<BillOfMaterials>>((ref) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getAllBoms();
});

final bomByIdProvider =
    FutureProvider.family<BillOfMaterials?, String>((ref, id) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getBomById(id);
});

final bomItemsProvider =
    FutureProvider.family<List<BomItem>, String>((ref, bomId) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getBomItems(bomId);
});

final bomsByStatusProvider =
    FutureProvider.family<List<BillOfMaterials>, BomStatus>(
        (ref, status) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getBomsByStatus(status);
});

final bomsByTypeProvider =
    FutureProvider.family<List<BillOfMaterials>, BomType>((ref, type) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getBomsByType(type);
});

// Analytics Providers
final bomStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(bomRepositoryProvider);
  final boms = await repository.getAllBoms();

  final totalBoms = boms.length;
  final activeBoms = boms.where((b) => b.status == BomStatus.active).length;
  final draftBoms = boms.where((b) => b.status == BomStatus.draft).length;
  final approvedBoms = boms.where((b) => b.status == BomStatus.approved).length;
  final inactiveBoms = boms.where((b) => b.status == BomStatus.inactive).length;

  final averageCost = boms.isEmpty
      ? 0.0
      : boms.map((b) => b.totalCost).reduce((a, b) => a + b) / boms.length;

  final totalValue = boms.map((b) => b.totalCost).fold(0.0, (a, b) => a + b);

  return {
    'totalBoms': totalBoms,
    'activeBoms': activeBoms,
    'draftBoms': draftBoms,
    'approvedBoms': approvedBoms,
    'inactiveBoms': inactiveBoms,
    'averageCost': averageCost,
    'totalValue': totalValue,
  };
});

final bomStatusDistributionProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(bomRepositoryProvider);
  final boms = await repository.getAllBoms();

  final distribution = <String, int>{};
  for (final bom in boms) {
    final status = bom.status.name;
    distribution[status] = (distribution[status] ?? 0) + 1;
  }

  return distribution;
});

final integrationStatusProvider =
    FutureProvider<Map<String, bool>>((ref) async {
  // Mock integration status - in real implementation, this would check actual integration health
  return {
    'inventory': true,
    'production': true,
    'procurement': false,
    'sales': true,
    'quality': false,
  };
});

final bomAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(bomRepositoryProvider);
  final boms = await repository.getAllBoms();

  // Calculate cost trends (mock data for now)
  final costTrend = List.generate(
      12,
      (index) => boms.isEmpty
          ? 0.0
          : boms.map((b) => b.totalCost).reduce((a, b) => a + b) / boms.length +
              (index * 10));

  // Calculate complexity metrics
  final avgItemsPerBom = boms.isEmpty
      ? 0.0
      : boms.map((b) => b.items.length).reduce((a, b) => a + b) / boms.length;

  return {
    'costTrend': costTrend,
    'averageItemsPerBom': avgItemsPerBom,
    'totalItems': boms.fold(0, (sum, bom) => sum + bom.items.length),
    'mostComplexBom': boms.isEmpty
        ? null
        : boms
            .reduce((a, b) => a.items.length > b.items.length ? a : b)
            .bomCode,
  };
});

// Stream Providers for real-time updates
final watchAllBomsProvider = StreamProvider<List<BillOfMaterials>>((ref) {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.watchAllBoms();
});

final watchBomProvider =
    StreamProvider.family<BillOfMaterials, String>((ref, id) {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.watchBom(id);
});

final watchBomItemsProvider =
    StreamProvider.family<List<BomItem>, String>((ref, bomId) {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.watchBomItems(bomId);
});

// Search and Filter Providers
final bomSearchProvider =
    FutureProvider.family<List<BillOfMaterials>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(bomRepositoryProvider);
  return repository.searchBoms(query);
});

final bomFilterProvider =
    FutureProvider.family<List<BillOfMaterials>, Map<String, dynamic>>(
        (ref, filters) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.filterBoms(
    type: filters['type'] as BomType?,
    status: filters['status'] as BomStatus?,
    productCode: filters['productCode'] as String?,
    createdAfter: filters['createdAfter'] as DateTime?,
    createdBefore: filters['createdBefore'] as DateTime?,
  );
});

// Validation Providers
final bomValidationProvider =
    FutureProvider.family<List<String>, String>((ref, bomId) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.validateBom(bomId);
});

final bomIntegrityProvider =
    FutureProvider.family<bool, String>((ref, bomId) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.checkBomIntegrity(bomId);
});

// Cost Calculation Providers
final bomCostProvider =
    FutureProvider.family<Map<String, double>, Map<String, dynamic>>(
        (ref, params) async {
  final repository = ref.watch(bomRepositoryProvider);
  final bomId = params['bomId'] as String;
  final batchSize = params['batchSize'] as double;
  return repository.calculateBomCost(bomId, batchSize);
});

final bomCostBreakdownProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, bomId) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getBomCostBreakdown(bomId);
});

// Template Providers
final bomTemplatesProvider = FutureProvider<List<BillOfMaterials>>((ref) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getBomTemplates();
});

// Version Management Providers
final bomVersionsProvider =
    FutureProvider.family<List<BillOfMaterials>, String>(
        (ref, productId) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getBomVersions(productId);
});

final activeBomForProductProvider =
    FutureProvider.family<BillOfMaterials?, String>((ref, productId) async {
  final repository = ref.watch(bomRepositoryProvider);
  return repository.getActiveBomForProduct(productId);
});

// Placeholder providers for missing repository dependencies
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  throw UnimplementedError('InventoryRepository not implemented yet');
});

final procurementRepositoryProvider = Provider<ProcurementRepository>((ref) {
  throw UnimplementedError('ProcurementRepository not implemented yet');
});

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  throw UnimplementedError('ProductionRepository not implemented yet');
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  throw UnimplementedError('SalesRepository not implemented yet');
});
