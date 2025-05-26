import 'package:uuid/uuid.dart';
import 'ai_capability.dart';
import 'ai_context.dart';

class AIRequest {
  final String id;
  final String prompt;
  final AICapability capability;
  final AIContext? context;
  final String? userId;
  final String? sessionId;
  final double? temperature;
  final int? maxTokens;
  final Map<String, dynamic> metadata;

  AIRequest({
    String? id,
    required this.prompt,
    required this.capability,
    this.context,
    this.userId,
    this.sessionId,
    this.temperature,
    this.maxTokens,
    this.metadata = const {},
  }) : id = id ?? Uuid().v4();

  factory AIRequest.simple({
    required String prompt,
    required AICapability capability,
    String? userId,
  }) {
    return AIRequest(
      prompt: prompt,
      capability: capability,
      userId: userId,
    );
  }

  factory AIRequest.fromContext(AIContext context) {
    return AIRequest(
      prompt: context.toPrompt(), // Assuming AIContext has a toPrompt method
      capability: context
          .determineCapability(), // Assuming AIContext can determine capability
      context: context,
      userId: context.userId,
      metadata: {'source_context_id': context.id},
    );
  }

  AIRequest copyWith({
    String? id,
    String? prompt,
    AICapability? capability,
    AIContext? context,
    String? userId,
    String? sessionId,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? metadata,
  }) {
    return AIRequest(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      capability: capability ?? this.capability,
      context: context ?? this.context,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      metadata: metadata ?? this.metadata,
    );
  }
}
