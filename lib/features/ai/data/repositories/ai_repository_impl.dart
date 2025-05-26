import '../../domain/entities/ai_capability.dart';
import '../../domain/entities/ai_context.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/repositories/ai_context_repository.dart';
import '../../domain/repositories/ai_learning_repository.dart';
import '../../domain/repositories/ai_provider_repository.dart';
import '../datasources/firebase_ai_datasource.dart';
// Import specific provider datasources if needed for direct interaction,
// though usually providers themselves encapsulate their datasource logic.

// This is a combined repository implementation for simplicity in this phase.
// In a larger system, these might be separate repository implementations.
class AIRepositoryImpl
    implements AIProviderRepository, AIContextRepository, AILearningRepository {
  final FirebaseAIDataSource _firebaseDataSource;
  // Potentially other datasources like a local cache datasource

  // In a real app, the list of providers would likely be managed by a service or injected.
  // For now, this is a placeholder. The AIProviderRegistry will handle this.
  final List<AIProvider> _registeredProviders = [];

  AIRepositoryImpl({required FirebaseAIDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  // --- AIProviderRepository ---
  @override
  Future<List<AIProvider>> getAllProviders() async =>
      List.unmodifiable(_registeredProviders);

  @override
  Future<AIProvider?> getProviderByName(String name) async {
    try {
      return _registeredProviders.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AIProvider>> getProvidersByCapability(
      AICapability capability) async {
    return _registeredProviders
        .where((p) => p.capabilities.supports(capability))
        .toList();
  }

  @override
  Future<void> registerProvider(AIProvider provider) async {
    if (!_registeredProviders.any((p) => p.name == provider.name)) {
      _registeredProviders.add(provider);
    }
  }

  @override
  Future<void> unregisterProvider(String name) async {
    _registeredProviders.removeWhere((p) => p.name == name);
  }

  @override
  Future<AIProvider?> selectOptimalProvider(AIRequest request) async {
    // Basic selection: first available provider that supports the capability.
    // The ProviderSelectionService will have more sophisticated logic.
    final candidates = await getProvidersByCapability(request.capability);
    return candidates.firstWhere((p) => p.isAvailable, orElse: () => null);
  }

  @override
  Future<Map<String, bool>> checkProvidersHealth() async {
    Map<String, bool> healthStatus = {};
    for (var provider in _registeredProviders) {
      healthStatus[provider.name] = await provider.healthCheck();
    }
    return healthStatus;
  }

  // --- AIContextRepository ---
  @override
  Future<void> saveContext(AIContext context) =>
      _firebaseDataSource.saveAIContext(context);
  @override
  Future<AIContext?> getContext(String id) =>
      _firebaseDataSource.getAIContext(id);
  @override
  Future<List<AIContext>> getHistoricalContext(
          {required String module,
          String? action,
          String? userId,
          int limit = 10}) =>
      _firebaseDataSource.getHistoricalAIContexts(
          module: module, action: action, userId: userId, limit: limit);

  // --- AILearningRepository ---
  @override
  Future<void> storeInteraction(AIRequest request, AIResponse response) =>
      _firebaseDataSource.storeInteraction(request, response);
  @override
  Future<void> recordFeedback(
          {required String interactionId,
          required bool isPositive,
          String? comments}) =>
      _firebaseDataSource.recordFeedback(interactionId, isPositive, comments);
}
