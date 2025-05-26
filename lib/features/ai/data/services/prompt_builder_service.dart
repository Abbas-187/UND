import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_context.dart';

class PromptBuilderService {
  String buildPrompt(AIRequest request) {
    StringBuffer promptBuffer = StringBuffer();

    // Start with the main prompt from the request
    promptBuffer.writeln(request.prompt);

    // Add context information if available
    if (request.context != null) {
      promptBuffer.writeln("\n--- Context ---");
      promptBuffer.writeln("Module: ${request.context!.module}");
      promptBuffer.writeln("Action: ${request.context!.action}");
      if (request.context!.data.isNotEmpty) {
        promptBuffer.writeln("Data: ${request.context!.data.toString()}");
      }
      // Add historical context if present (simplified)
      if (request.context!.historicalContext.isNotEmpty) {
        promptBuffer.writeln(
            "Historical Interactions: ${request.context!.historicalContext.length} previous relevant actions.");
      }
    }
    // You can add more sophisticated logic here, like system messages, role definitions, etc.
    return promptBuffer.toString();
  }

  String buildRecommendationPrompt(AIContext context) {
    return "Based on the following context:\nModule: ${context.module}\nAction: ${context.action}\nData: ${context.data.toString()}\nPlease provide specific recommendations.";
  }

  String buildPredictionPrompt(AIContext context) {
    return "Analyze the following context for trends and make predictions:\nModule: ${context.module}\nAction: ${context.action}\nData: ${context.data.toString()}\nFocus on future outcomes.";
  }
}
