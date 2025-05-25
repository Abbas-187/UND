// UseCase: Calculates supplier performance metrics (OTIF, lead time variance, quality rejections).
abstract class AnalyticsUseCase<T, P> {
  Future<T> execute(P params);
}

class SupplierPerformanceParams {
  SupplierPerformanceParams({
    required this.supplierId,
    required this.startDate,
    required this.endDate,
  });
  final String supplierId;
  final DateTime startDate;
  final DateTime endDate;
}

class SupplierPerformanceResult {
  SupplierPerformanceResult({
    required this.otif,
    required this.leadTimeVariance,
    required this.qualityRejectionRate,
  });
  final double otif;
  final double leadTimeVariance;
  final double qualityRejectionRate;
}

// NOTE: This is a stub. Real implementation would require procurement/order repositories.
class SupplierPerformanceUseCase extends AnalyticsUseCase<
    SupplierPerformanceResult, SupplierPerformanceParams> {
  SupplierPerformanceUseCase();

  @override
  Future<SupplierPerformanceResult> execute(
      SupplierPerformanceParams params) async {
    // TODO: Integrate with procurement/order repositories for real data
    // For now, return dummy values
    return SupplierPerformanceResult(
      otif: 0.95, // On-Time In-Full
      leadTimeVariance: 2.0, // days
      qualityRejectionRate: 0.01, // 1%
    );
  }
}
