import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';

// A simple in-memory cache for demonstration purposes.
// In a real application, this could use a more persistent cache like Hive, Moor, or shared_preferences.
class AICacheService {
  final Map<String, AIResponse> _cache = {};
  final Duration _cacheDuration;

  AICacheService({Duration? cacheDuration})
      : _cacheDuration = cacheDuration ?? const Duration(minutes: 10);

  String _generateCacheKey(AIRequest request) {
    // A simple key based on prompt and capability.
    // More sophisticated key generation might be needed (e.g., hashing the full request).
    return "${request.prompt}_${request.capability.name}_${request.userId ?? ''}";
  }

  Future<AIResponse?> get(AIRequest request) async {
    final key = _generateCacheKey(request);
    // TODO: Add logic to check cache entry expiration based on _cacheDuration
    return _cache[key];
  }

  Future<void> store(AIRequest request, AIResponse response) async {
    final key = _generateCacheKey(request);
    _cache[key] = response;
    // TODO: Store timestamp for expiration
  }

  Future<void> invalidate(AIRequest request) async {
    final key = _generateCacheKey(request);
    _cache.remove(key);
  }

  Future<void> clear() async {
    _cache.clear();
  }
}
