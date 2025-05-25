import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/domain/providers/inventory_provider.dart';
import '../domain/eo_stock_usecase.dart';
import '../domain/inventory_aging_usecase.dart';
import '../domain/stockout_rate_usecase.dart';
import '../domain/supplier_performance_usecase.dart';
import '../domain/traceability_report_usecase.dart';
import '../domain/turnover_rate_usecase.dart';

final turnoverRateProvider =
    FutureProvider.family<double, TurnoverRateParams>((ref, params) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final useCase = TurnoverRateUseCase(repo);
  return useCase.execute(params);
});

final stockoutRateProvider =
    FutureProvider.family<double, StockoutRateParams>((ref, params) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final useCase = StockoutRateUseCase(repo);
  return useCase.execute(params);
});

final eoStockProvider =
    FutureProvider.family<double, EOStockParams>((ref, params) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final useCase = EOStockUseCase(repo);
  return useCase.execute(params);
});

final inventoryAgingProvider =
    FutureProvider.family<Map<int, double>, InventoryAgingParams>(
        (ref, params) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final useCase = InventoryAgingUseCase(repo);
  return useCase.execute(params);
});

final traceabilityReportProvider =
    FutureProvider.family<TraceabilityReportResult, TraceabilityReportParams>(
        (ref, params) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final useCase = TraceabilityReportUseCase(repo);
  return useCase.execute(params);
});

final supplierPerformanceProvider =
    FutureProvider.family<SupplierPerformanceResult, SupplierPerformanceParams>(
        (ref, params) async {
  final useCase = SupplierPerformanceUseCase();
  return useCase.execute(params);
});
