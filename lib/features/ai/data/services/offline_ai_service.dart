import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../providers/local_ai_provider.dart'; // Offline service will heavily rely on local AI

class OfflineAIService {
  final LocalAIProvider _localAIProvider;
  bool _isOfflineModeEnabled = false; // Could be managed by a settings provider

  OfflineAIService({required LocalAIProvider localAIProvider})
      : _localAIProvider = localAIProvider;

  void enableOfflineMode(bool enable) {
    _isOfflineModeEnabled = enable;
  }

  bool get isOfflineModeActive =>
      _isOfflineModeEnabled && _localAIProvider.isAvailable;

  /// Attempts to process an AI request using only offline capabilities.
  ///
  /// [request] The AI request.
  /// Returns an [AIResponse] if successful, or an error response if offline processing is not possible or fails.
  Future<AIResponse> processOffline(AIRequest request) async {
    if (!isOfflineModeActive) {
      return AIResponse.error(
        requestId: request.id,
        provider: _localAIProvider.name,
        error: 'Offline mode is not active or local AI is unavailable.',
      );
    }

    if (!_localAIProvider.capabilities.supports(request.capability)) {
      return AIResponse.error(
        requestId: request.id,
        provider: _localAIProvider.name,
        error:
            'Requested capability (${request.capability.name}) not supported offline.',
      );
    }

    // Delegate to the local AI provider
    return await _localAIProvider
        .generateText(request); // Or a more specific method
  }
}
