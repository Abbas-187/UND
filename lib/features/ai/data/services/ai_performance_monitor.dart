import '../../domain/entities/ai_capability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Assuming FirebaseAIDataSource or a similar mechanism for logging performance
import '../datasources/firebase_ai_datasource.dart';

class AIPerformanceMonitor {
  // In a real app, these metrics would be stored persistently (e.g., Firebase, local DB)
  // and aggregated over time. For simplicity, we'll keep some in-memory for now.
  final Map<String, List<Duration>> _responseTimesByProvider = {};
  final Map<String, List<double>> _confidenceScoresByProvider = {};
  final Map<String, int> _successCountByProvider = {};
  final Map<String, int> _totalRequestsByProvider = {};

  final FirebaseAIDataSource?
      _firebaseDataSource; // Optional: for persistent logging

  AIPerformanceMonitor({FirebaseAIDataSource? firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  Future<void> recordInteraction({
    required String provider,
    required AICapability capability,
    required Duration processingTime,
    required bool success,
    double? confidence,
  }) async {
    _responseTimesByProvider
        .putIfAbsent(provider, () => [])
        .add(processingTime);
    if (confidence != null) {
      _confidenceScoresByProvider
          .putIfAbsent(provider, () => [])
          .add(confidence);
    }
    _totalRequestsByProvider[provider] =
        (_totalRequestsByProvider[provider] ?? 0) + 1;
    if (success) {
      _successCountByProvider[provider] =
          (_successCountByProvider[provider] ?? 0) + 1;
    }

    // Optionally log to a persistent store
    await _firebaseDataSource?.logPerformanceMetric({
      'provider': provider,
      'capability': capability.name,
      'processingTimeMs': processingTime.inMilliseconds,
      'success': success,
      'confidence': confidence,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> getProviderMetrics(String providerName) async {
    final responseTimes = _responseTimesByProvider[providerName] ?? [];
    final confidences = _confidenceScoresByProvider[providerName] ?? [];

    return {
      'average_response_time_ms': responseTimes.isNotEmpty
          ? responseTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) /
              responseTimes.length
          : 0.0,
      'average_confidence': confidences.isNotEmpty
          ? confidences.reduce((a, b) => a + b) / confidences.length
          : 0.0,
      'success_rate': (_totalRequestsByProvider[providerName] ?? 0) == 0
          ? 0.0
          : (_successCountByProvider[providerName] ?? 0) /
              (_totalRequestsByProvider[providerName]!),
      'total_requests': _totalRequestsByProvider[providerName] ?? 0,
    };
  }

  Future<Map<String, dynamic>> getSystemMetrics() async {
    // Aggregate metrics across all providers or system-wide stats
    // For now, just return a placeholder
    return {
      'overall_health': 'good',
      'total_system_requests':
          _totalRequestsByProvider.values.fold(0, (sum, item) => sum + item),
    };
  }
}

final aiPerformanceMonitorProvider = Provider<AIPerformanceMonitor>((ref) {
  // Optionally inject FirebaseAIDataSource if you have it set up
  // final firebaseDataSource = ref.watch(firebaseAIDataSource);
  return AIPerformanceMonitor(
      firebaseDataSource: null); // Pass null if not using Firebase for this yet
});
