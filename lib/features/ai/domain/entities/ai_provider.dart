import 'ai_request.dart';
import 'ai_response.dart';
import 'ai_context.dart';
import 'ai_capability.dart';

abstract class AIProvider {
  String get name;
  String get version;
  AICapabilitySet get capabilities;
  bool get isAvailable;
  Map<String, dynamic> get configuration;

  Future<bool> initialize();
  Future<void> dispose();
  Future<bool> healthCheck();

  Future<AIResponse> generateText(AIRequest request);

  // Optional, more specific methods that can be implemented by providers
  // These could also be handled via generateText with a specific capability in AIRequest
  Future<AIResponse> analyzeData(Map<String, dynamic> data) async {
    throw UnimplementedError(
        '$name does not support analyzeData directly. Use generateText with DataAnalysis capability.');
  }

  Future<AIResponse> generateInsights(AIContext context) async {
    throw UnimplementedError(
        '$name does not support generateInsights directly. Use generateText with appropriate capability.');
  }

  Future<List<String>> generateRecommendations(AIContext context) async {
    throw UnimplementedError(
        '$name does not support generateRecommendations directly. Use generateText with appropriate capability.');
  }

  Future<Map<String, dynamic>> predictTrends(AIContext context) async {
    throw UnimplementedError(
        '$name does not support predictTrends directly. Use generateText with PredictiveAnalytics capability.');
  }

  double calculateScore(AIRequest request);
  double estimateCost(AIRequest request);
  Map<String, dynamic> getUsageStats();
  Future<Map<String, dynamic>> getPerformanceMetrics();
}
