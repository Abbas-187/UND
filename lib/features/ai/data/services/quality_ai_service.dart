import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'universal_ai_service.dart';
import '../../domain/entities/ai_response.dart';

class QualityAIService {
  final UniversalAIService _universalAIService;
  final String _moduleName = 'quality_assurance';

  QualityAIService(this._universalAIService);

  Future<List<String>> analyzeQualityTestData(Map<String, dynamic> testResults,
      {String? userId}) async {
    return await _universalAIService.generateInsights(
      module: _moduleName,
      data: {...testResults, 'analysis_type': 'quality_data_review'},
      userId: userId,
    );
  }

  Future<List<Map<String, dynamic>>> detectQualityAnomalies(
      Map<String, dynamic> currentBatchData,
      Map<String, dynamic> qualityStandards,
      {String? userId}) async {
    return await _universalAIService.detectAnomalies(
      module: _moduleName,
      currentData: currentBatchData,
      baselineData: qualityStandards, // Quality standards act as a baseline
      userId: userId,
    );
  }

  Future<List<String>> recommendCorrectiveActions(
      Map<String, dynamic> qualityIssue,
      {String? userId}) async {
    return await _universalAIService.generateRecommendations(
      module: _moduleName,
      action: 'corrective_action_recommendation',
      data: qualityIssue,
      userId: userId,
    );
  }
}

final qualityAIServiceProvider = Provider<QualityAIService>((ref) {
  final universalAIService = ref.watch(universalAIServiceProvider);
  return QualityAIService(universalAIService);
});
