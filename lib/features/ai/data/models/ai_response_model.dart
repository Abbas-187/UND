import '../../domain/entities/ai_response.dart';

// This model is primarily for serialization/deserialization if responses are stored
// or transmitted (e.g., for logging, caching).
class AIResponseModel extends AIResponse {
  AIResponseModel({
    required String requestId,
    required String provider,
    required bool isSuccess,
    String? content,
    String? error,
    double? confidence,
    Duration? processingTime,
    List<String>? suggestions,
    Map<String, dynamic> metadata = const {},
  }) : super(
          requestId: requestId,
          provider: provider,
          isSuccess: isSuccess,
          content: content,
          error: error,
          confidence: confidence,
          processingTime: processingTime,
          suggestions: suggestions,
          metadata: metadata,
        );

  factory AIResponseModel.fromDomain(AIResponse entity) {
    return AIResponseModel(
      requestId: entity.requestId,
      provider: entity.provider,
      isSuccess: entity.isSuccess,
      content: entity.content,
      error: entity.error,
      confidence: entity.confidence,
      processingTime: entity.processingTime,
      suggestions: entity.suggestions,
      metadata: entity.metadata,
    );
  }

  factory AIResponseModel.fromJson(Map<String, dynamic> json) {
    return AIResponseModel(
      requestId: json['requestId'],
      provider: json['provider'],
      isSuccess: json['isSuccess'],
      content: json['content'],
      error: json['error'],
      confidence: json['confidence']?.toDouble(),
      processingTime: json['processingTimeMillis'] != null
          ? Duration(milliseconds: json['processingTimeMillis'])
          : null,
      suggestions: json['suggestions'] != null
          ? List<String>.from(json['suggestions'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'provider': provider,
      'isSuccess': isSuccess,
      'content': content,
      'error': error,
      'confidence': confidence,
      'processingTimeMillis': processingTime?.inMilliseconds,
      'suggestions': suggestions,
      'metadata': metadata,
    };
  }
}
