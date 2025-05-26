import 'dart:io';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_request.dart';
import 'universal_ai_service.dart'; // Assuming a central AI service

class DocumentAnalysisService {
  final UniversalAIService _aiService;

  DocumentAnalysisService({required UniversalAIService aiService})
      : _aiService = aiService;

  /// Analyzes the content of a given document file.
  ///
  /// [file] The document file to analyze.
  /// [analysisType] Optional: specific type of analysis (e.g., "summary", "sentiment", "topic_extraction").
  /// Returns an [AIResponse] containing the analysis results.
  Future<AIResponse> analyzeDocument(File file, {String? analysisType}) async {
    // In a real implementation, you would read the file content,
    // potentially convert it to a suitable format (e.g., plain text),
    // and then send it to the AI service.
    final documentContent = await file.readAsString(); // Simplified

    final request = AIRequest(
      prompt: 'Analyze the following document: $documentContent',
      data: {
        'document_name': file.path.split('/').last,
        'analysis_type': analysisType ?? 'general',
      },
      module: 'document_analysis',
      action: analysisType ?? 'analyze',
    );

    return await _aiService.processRequest(request);
  }

  /// Extracts key information or entities from a document.
  Future<AIResponse> extractInformation(File file,
      {List<String>? entitiesToExtract}) async {
    final documentContent = await file.readAsString();
    final request = AIRequest(
        prompt:
            'Extract the following entities: ${entitiesToExtract?.join(", ")}. Document: $documentContent',
        module: 'document_analysis',
        action: 'extract_information');
    return await _aiService.processRequest(request);
  }
}
