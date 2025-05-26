import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_capability.dart';
import '../../domain/entities/ai_context.dart';
import 'ai_context_model.dart'; // Assuming AIContextModel for serialization

// This model is primarily for serialization/deserialization if requests are stored
// or transmitted (e.g., for logging, caching, or distributed processing).
class AIRequestModel extends AIRequest {
  AIRequestModel({
    required String id,
    required String prompt,
    required AICapability capability,
    AIContextModel? context, // Use AIContextModel for serialization
    String? userId,
    String? sessionId,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic> metadata = const {},
  }) : super(
          id: id,
          prompt: prompt,
          capability: capability,
          context: context,
          userId: userId,
          sessionId: sessionId,
          temperature: temperature,
          maxTokens: maxTokens,
          metadata: metadata,
        );

  factory AIRequestModel.fromDomain(AIRequest entity) {
    return AIRequestModel(
      id: entity.id,
      prompt: entity.prompt,
      capability: entity.capability,
      context: entity.context != null
          ? AIContextModel.fromDomain(entity.context!)
          : null,
      userId: entity.userId,
      sessionId: entity.sessionId,
      temperature: entity.temperature,
      maxTokens: entity.maxTokens,
      metadata: entity.metadata,
    );
  }

  factory AIRequestModel.fromJson(Map<String, dynamic> json) {
    return AIRequestModel(
      id: json['id'],
      prompt: json['prompt'],
      capability: AICapability.values.byName(json['capability']),
      context: json['context'] != null
          ? AIContextModel.fromJson(json['context'])
          : null,
      userId: json['userId'],
      sessionId: json['sessionId'],
      temperature: json['temperature']?.toDouble(),
      maxTokens: json['maxTokens']?.toInt(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'capability': capability.name,
      'context':
          (context as AIContextModel?)?.toJson(), // Cast to AIContextModel
      'userId': userId,
      'sessionId': sessionId,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'metadata': metadata,
    };
  }
}
