import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import 'universal_ai_service.dart'; // Assuming a central AI service
import '../providers/local_ai_provider.dart'; // May use local provider directly for some tasks

class EdgeComputingService {
  final UniversalAIService _aiService;
  final LocalAIProvider?
      _localAIProvider; // Optional direct access to local provider

  EdgeComputingService({
    required UniversalAIService aiService,
    LocalAIProvider? localAIProvider,
  })  : _aiService = aiService,
        _localAIProvider = localAIProvider;

  /// Processes an AI request prioritizing on-device (edge) execution if suitable.
  ///
  /// [request] The AI request to process.
  /// [preferLocal] If true, attempts to use local AI even if cloud options are available and potentially better.
  /// Returns an [AIResponse] from either local or cloud AI.
  Future<AIResponse> processOnEdge(AIRequest request,
      {bool preferLocal = false}) async {
    // Logic to determine if the request can/should be handled by local AI
    // This could be based on request.capability, data size, privacy needs, network status etc.
    bool canRunLocally = _localAIProvider?.isAvailable ?? false;

    if (canRunLocally && (preferLocal || _shouldRunLocally(request))) {
      if (_localAIProvider != null &&
          _localAIProvider!.capabilities.supports(request.capability)) {
        // Potentially adapt request for local provider if needed
        return await _localAIProvider!
            .generateText(request); // Or a more specific method
      }
    }
    // Fallback to universal AI service (which might then choose another provider or cloud)
    return await _aiService.processRequest(request);
  }

  /// Determines if a request is suitable for local processing.
  bool _shouldRunLocally(AIRequest request) {
    // Example criteria:
    // - Task is simple (e.g., basic sentiment analysis)
    // - Data is sensitive and privacy is paramount
    // - Network connectivity is poor or unavailable
    // - Low latency is critical and local model is fast enough
    return request.capability.complexityScore < 0.5 ||
        (request.data?['privacy_sensitive'] == true);
  }
}
