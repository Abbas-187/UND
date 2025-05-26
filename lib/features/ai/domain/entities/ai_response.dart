class AIResponse {
  final String requestId;
  final String provider;
  final bool isSuccess;
  final String? content;
  final String? error;
  final double? confidence;
  final Duration? processingTime;
  final List<String>? suggestions;
  final Map<String, dynamic> metadata;

  AIResponse({
    required this.requestId,
    required this.provider,
    required this.isSuccess,
    this.content,
    this.error,
    this.confidence,
    this.processingTime,
    this.suggestions,
    this.metadata = const {},
  });

  factory AIResponse.success({
    required String requestId,
    required String content,
    required String provider,
    double? confidence,
    Duration? processingTime,
    List<String>? suggestions,
    Map<String, dynamic> metadata = const {},
  }) {
    return AIResponse(
      requestId: requestId,
      provider: provider,
      isSuccess: true,
      content: content,
      confidence: confidence,
      processingTime: processingTime,
      suggestions: suggestions,
      metadata: metadata,
    );
  }

  factory AIResponse.error({
    required String requestId,
    required String provider,
    required String error,
    Duration? processingTime,
  }) {
    return AIResponse(
      requestId: requestId,
      provider: provider,
      isSuccess: false,
      error: error,
      processingTime: processingTime,
    );
  }
}
