import '../../domain/entities/ai_context.dart';

// This model is for serializing/deserializing AIContext, especially if it's stored
// in Firebase or transmitted.
class AIContextModel extends AIContext {
  AIContextModel({
    required String id,
    required String module,
    required String action,
    required Map<String, dynamic> data,
    String? userId,
    required DateTime timestamp,
    List<AIContextModel> historicalContext =
        const [], // Use AIContextModel here
  }) : super(
          id: id,
          module: module,
          action: action,
          data: data,
          userId: userId,
          timestamp: timestamp,
          historicalContext:
              historicalContext, // Super constructor expects List<AIContext>
        );

  factory AIContextModel.fromDomain(AIContext entity) {
    return AIContextModel(
      id: entity.id,
      module: entity.module,
      action: entity.action,
      data: entity.data,
      userId: entity.userId,
      timestamp: entity.timestamp,
      historicalContext: entity.historicalContext
          .map((hc) => AIContextModel.fromDomain(hc))
          .toList(),
    );
  }

  factory AIContextModel.fromJson(Map<String, dynamic> json) {
    return AIContextModel(
      id: json['id'],
      module: json['module'],
      action: json['action'],
      data: Map<String, dynamic>.from(json['data']),
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      historicalContext: (json['historicalContext'] as List<dynamic>?)
              ?.map((hcJson) =>
                  AIContextModel.fromJson(hcJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module,
      'action': action,
      'data': data,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'historicalContext': historicalContext
          .map((hc) => (hc as AIContextModel).toJson())
          .toList(),
    };
  }
}
