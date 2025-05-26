import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CostOptimizationService {
  // This service can hold logic for cost tracking, reporting,
  // and potentially influencing provider selection based on cost constraints.

  double estimateRequestCost(AIProvider provider, AIRequest request) {
    // Delegate cost estimation to the provider itself
    return provider.estimateCost(request);
  }

  // Future methods could include:
  // - getCostReportForPeriod()
  // - setCostBudget()
  // - recommendCostSavingProvider(AIRequest request)
}

// Riverpod provider for the cost optimization service
final costOptimizationServiceProvider =
    Provider<CostOptimizationService>((ref) {
  return CostOptimizationService();
});
