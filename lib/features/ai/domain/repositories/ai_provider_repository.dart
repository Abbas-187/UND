import '../entities/ai_provider.dart';
import '../entities/ai_request.dart';
import '../entities/ai_capability.dart';

abstract class AIProviderRepository {
  Future<List<AIProvider>> getAllProviders();
  Future<AIProvider?> getProviderByName(String name);
  Future<List<AIProvider>> getProvidersByCapability(AICapability capability);
  Future<void> registerProvider(AIProvider provider);
  Future<void> unregisterProvider(String name);
  Future<AIProvider?> selectOptimalProvider(AIRequest request);
  Future<Map<String, bool>> checkProvidersHealth();
}
