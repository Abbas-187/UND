import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_capability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIProviderRegistry {
  final List<AIProvider> _providers = [];

  void registerProvider(AIProvider provider) {
    if (!_providers.any((p) => p.name == provider.name)) {
      _providers.add(provider);
      // Optional: Initialize the provider upon registration
      // provider.initialize();
    }
  }

  void unregisterProvider(String name) {
    _providers.removeWhere((p) => p.name == name);
    // Optional: Dispose the provider upon unregistration
    // final provider = _providers.firstWhereOrNull((p) => p.name == name);
    // provider?.dispose();
  }

  List<AIProvider> getAll() {
    return List.unmodifiable(_providers);
  }

  AIProvider? getByName(String name) {
    try {
      return _providers.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }

  List<AIProvider> getByCapability(AICapability capability) {
    return _providers
        .where((p) => p.capabilities.supports(capability))
        .toList();
  }
}

// Riverpod provider for the registry
final aiProviderRegistryProvider = Provider<AIProviderRegistry>((ref) {
  // In a real app, you would initialize and register providers here
  // For now, it's an empty registry. Providers will be registered elsewhere (e.g., app startup).
  return AIProviderRegistry();
});
