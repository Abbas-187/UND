enum AICapability {
  textGeneration,
  dataAnalysis,
  imageAnalysis,
  documentProcessing,
  predictiveAnalytics,
  conversationalAI,
  codeGeneration,
  languageTranslation,
  sentimentAnalysis,
  anomalyDetection,
  patternRecognition,
  optimization,
}

extension AICapabilityExtension on AICapability {
  String get name {
    switch (this) {
      case AICapability.textGeneration:
        return 'Text Generation';
      case AICapability.dataAnalysis:
        return 'Data Analysis';
      case AICapability.imageAnalysis:
        return 'Image Analysis';
      case AICapability.documentProcessing:
        return 'Document Processing';
      case AICapability.predictiveAnalytics:
        return 'Predictive Analytics';
      case AICapability.conversationalAI:
        return 'Conversational AI';
      case AICapability.codeGeneration:
        return 'Code Generation';
      case AICapability.languageTranslation:
        return 'Language Translation';
      case AICapability.sentimentAnalysis:
        return 'Sentiment Analysis';
      case AICapability.anomalyDetection:
        return 'Anomaly Detection';
      case AICapability.patternRecognition:
        return 'Pattern Recognition';
      case AICapability.optimization:
        return 'Optimization';
    }
  }

  String get description {
    switch (this) {
      case AICapability.textGeneration:
        return 'Generate human-like text content and responses';
      case AICapability.dataAnalysis:
        return 'Analyze and interpret complex data patterns';
      case AICapability.imageAnalysis:
        return 'Process and analyze visual content';
      case AICapability.documentProcessing:
        return 'Extract and process document information';
      case AICapability.predictiveAnalytics:
        return 'Predict future trends and outcomes';
      case AICapability.conversationalAI:
        return 'Engage in natural language conversations';
      case AICapability.codeGeneration:
        return 'Generate and review code implementations';
      case AICapability.languageTranslation:
        return 'Translate content between languages';
      case AICapability.sentimentAnalysis:
        return 'Analyze emotional tone and sentiment';
      case AICapability.anomalyDetection:
        return 'Detect unusual patterns and outliers';
      case AICapability.patternRecognition:
        return 'Identify recurring patterns in data';
      case AICapability.optimization:
        return 'Optimize processes and resource allocation';
    }
  }

  double get complexityScore {
    switch (this) {
      case AICapability.textGeneration:
        return 0.6;
      case AICapability.conversationalAI:
        return 0.7;
      case AICapability.dataAnalysis:
        return 0.8;
      case AICapability.predictiveAnalytics:
        return 0.9;
      case AICapability.optimization:
        return 0.95;
      case AICapability.anomalyDetection:
        return 0.85;
      case AICapability.patternRecognition:
        return 0.8;
      case AICapability.sentimentAnalysis:
        return 0.7;
      case AICapability.documentProcessing:
        return 0.75;
      case AICapability.imageAnalysis:
        return 0.9;
      case AICapability.codeGeneration:
        return 0.85;
      case AICapability.languageTranslation:
        return 0.8;
    }
  }
}

class AICapabilitySet {
  final Set<AICapability> _capabilities;

  const AICapabilitySet(this._capabilities);

  factory AICapabilitySet.all() => AICapabilitySet(AICapability.values.toSet());

  factory AICapabilitySet.geminiPro() => AICapabilitySet({
        AICapability.textGeneration,
        AICapability.dataAnalysis,
        AICapability.conversationalAI,
        AICapability.documentProcessing,
        AICapability.predictiveAnalytics,
        AICapability.sentimentAnalysis,
        AICapability.patternRecognition,
        AICapability.optimization,
      });

  factory AICapabilitySet.openAI() => AICapabilitySet({
        AICapability.textGeneration,
        AICapability.conversationalAI,
        AICapability.codeGeneration,
        AICapability.dataAnalysis,
        AICapability.sentimentAnalysis,
        AICapability.languageTranslation,
      });

  factory AICapabilitySet.basic() => AICapabilitySet({
        AICapability.textGeneration,
        AICapability.conversationalAI,
      });

  bool supports(AICapability capability) => _capabilities.contains(capability);

  List<AICapability> get capabilities => _capabilities.toList();

  bool get isEmpty => _capabilities.isEmpty;
  bool get isNotEmpty => _capabilities.isNotEmpty;

  double get averageComplexity {
    if (_capabilities.isEmpty) return 0.0;
    return _capabilities.map((c) => c.complexityScore).reduce((a, b) => a + b) /
        _capabilities.length;
  }

  AICapabilitySet intersection(AICapabilitySet other) {
    return AICapabilitySet(_capabilities.intersection(other._capabilities));
  }

  AICapabilitySet union(AICapabilitySet other) {
    return AICapabilitySet(_capabilities.union(other._capabilities));
  }
}
