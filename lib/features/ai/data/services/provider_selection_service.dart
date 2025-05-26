import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_request.dart';
import 'ai_provider_registry.dart';
import 'ai_performance_monitor.dart'; // Assuming this service exists
import 'cost_optimization_service.dart'; // Assuming this service exists
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderSelectionService {
  final AIProviderRegistry _registry;
  final AIPerformanceMonitor _performanceMonitor;
  final CostOptimizationService _costOptimizationService;

  ProviderSelectionService({
    required AIProviderRegistry registry,
    required AIPerformanceMonitor performanceMonitor,
    required CostOptimizationService costOptimizationService,
  })  : _registry = registry,
        _performanceMonitor = performanceMonitor,
        _costOptimizationService = costOptimizationService;

  Future<AIProvider?> selectOptimalProvider(AIRequest request) async {
    final candidates = _registry.getByCapability(request.capability);
    if (candidates.isEmpty) return null;

    // Filter for available providers
    final availableCandidates = candidates.where((p) => p.isAvailable).toList();
    if (availableCandidates.isEmpty) return null;

    // Calculate scores based on performance, cost, and provider's own logic
    final providerScores = <AIProvider, double>{};
    for (final provider in availableCandidates) {
      final performanceMetrics =
          await _performanceMonitor.getProviderMetrics(provider.name);
      final estimatedCost =
          _costOptimizationService.estimateRequestCost(provider, request);
      final score =
          provider.calculateScore(request); // Provider's internal scoring

      // Combine scores (weights can be adjusted)
      providerScores[provider] = (score * 0.5) +
          (performanceMetrics['overall_score'] ?? 0.0 * 0.3) +
          (1.0 - (estimatedCost / 100.0) * 0.2); // Simplified weighting
    }

    if (providerScores.isEmpty) return null;

    // Return provider with the highest combined score
    return providerScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

// Riverpod provider for the selection service
final providerSelectionServiceProvider =
    Provider<ProviderSelectionService>((ref) {
  return ProviderSelectionService(
    registry: ref.read(aiProviderRegistryProvider),
    performanceMonitor:
        ref.read(aiPerformanceMonitorProvider), // Assuming this provider exists
    costOptimizationService: ref
        .read(costOptimizationServiceProvider), // Assuming this provider exists
  );
});
