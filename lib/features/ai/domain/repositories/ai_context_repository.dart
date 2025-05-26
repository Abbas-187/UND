import '../entities/ai_context.dart';

abstract class AIContextRepository {
  Future<void> saveContext(AIContext context);
  Future<AIContext?> getContext(String id);
  Future<List<AIContext>> getHistoricalContext({
    required String module,
    String? action,
    String? userId,
    int limit = 10,
  });
}
