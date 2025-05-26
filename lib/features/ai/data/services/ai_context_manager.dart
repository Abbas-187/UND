import '../../domain/entities/ai_context.dart';
import '../../domain/repositories/ai_context_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIContextManager {
  final AIContextRepository _contextRepository;

  AIContextManager({required AIContextRepository contextRepository})
      : _contextRepository = contextRepository;

  Future<void> saveContext(AIContext context) async {
    await _contextRepository.saveContext(context);
  }

  Future<AIContext?> getContext(String id) async {
    return await _contextRepository.getContext(id);
  }

  Future<List<AIContext>> getHistoricalContext({
    required String module,
    String? action,
    String? userId,
    int limit = 10,
  }) async {
    return await _contextRepository.getHistoricalContext(
      module: module,
      action: action,
      userId: userId,
      limit: limit,
    );
  }
}

final aiContextManagerProvider = Provider<AIContextManager>((ref) {
  // This assumes AIRepositoryImpl implements AIContextRepository and is provided
  final contextRepository =
      ref.watch(aiRepositoryProvider); // Placeholder for actual provider
  return AIContextManager(contextRepository: contextRepository);
});

// Placeholder for the actual repository provider
final aiRepositoryProvider = Provider<AIContextRepository>((ref) {
  throw UnimplementedError(
      "AIContextRepository provider not implemented yet. This typically would be your AIRepositoryImpl.");
});
