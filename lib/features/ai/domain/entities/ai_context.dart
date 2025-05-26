import 'package:uuid/uuid.dart';
import 'ai_capability.dart'; // Assuming AICapability is in the same directory or imported

class AIContext {
  final String id;
  final String module;
  final String action;
  final Map<String, dynamic> data;
  final String? userId;
  final DateTime timestamp;
  final List<AIContext> historicalContext; // For enriched context

  AIContext({
    String? id,
    required this.module,
    required this.action,
    required this.data,
    this.userId,
    DateTime? timestamp,
    this.historicalContext = const [],
  })  : id = id ?? Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory AIContext.forModule({
    required String module,
    required String action,
    required Map<String, dynamic> data,
    String? userId,
  }) {
    return AIContext(
      module: module,
      action: action,
      data: data,
      userId: userId,
    );
  }

  factory AIContext.fromData(Map<String, dynamic> data, {String? userId}) {
    return AIContext(
      module: data['module'] ?? 'general',
      action: data['action'] ?? 'analyze',
      data: data,
      userId: userId,
    );
  }

  AIContext enrichWith(List<AIContext> history) {
    return AIContext(
      id: id,
      module: module,
      action: action,
      data: data,
      userId: userId,
      timestamp: timestamp,
      historicalContext: List.from(historicalContext)..addAll(history),
    );
  }

  // This is a placeholder. Actual prompt generation would be more complex.
  String toPrompt() {
    final historyPrompts = historicalContext
        .map((hc) =>
            "Previous ${hc.action} in ${hc.module}: ${hc.data.toString()}")
        .join("\n");
    return "Module: $module, Action: $action, Data: ${data.toString()}" +
        (historyPrompts.isNotEmpty
            ? "\nHistorical Context:\n$historyPrompts"
            : "");
  }

  // This is a placeholder. Capability determination would be more sophisticated.
  AICapability determineCapability() {
    if (action.contains('insight') || action.contains('analyze'))
      return AICapability.dataAnalysis;
    if (action.contains('recommend'))
      return AICapability
          .textGeneration; // Or a specific recommendation capability
    if (action.contains('predict')) return AICapability.predictiveAnalytics;
    if (action.contains('chat')) return AICapability.conversationalAI;
    return AICapability.textGeneration; // Default
  }
}
