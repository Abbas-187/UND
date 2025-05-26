import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'universal_ai_service.dart';
import '../../domain/entities/ai_response.dart';

class ProductionAIService {
  final UniversalAIService _universalAIService;
  final String _moduleName = 'production';

  ProductionAIService(this._universalAIService);

  Future<List<String>> getEfficiencyInsights(
      Map<String, dynamic> productionData,
      {String? userId}) async {
    return await _universalAIService.generateInsights(
      module: _moduleName,
      data: {...productionData, 'analysis_type': 'efficiency_analysis'},
      userId: userId,
    );
  }

  Future<Map<String, dynamic>> optimizeProductionSchedule(
      Map<String, dynamic> currentState, Map<String, dynamic> constraints,
      {String? userId}) async {
    return await _universalAIService.optimizeProcess(
      module: _moduleName,
      processType: 'scheduling',
      currentState: currentState,
      constraints: constraints,
      userId: userId,
    );
  }

  Future<List<Map<String, dynamic>>> detectProductionAnomalies(
      Map<String, dynamic> currentMetrics, Map<String, dynamic> baselineMetrics,
      {String? userId}) async {
    return await _universalAIService.detectAnomalies(
      module: _moduleName,
      currentData: currentMetrics,
      baselineData: baselineMetrics,
      userId: userId,
    );
  }
  // Add more production-specific AI methods as needed
}

final productionAIServiceProvider = Provider<ProductionAIService>((ref) {
  final universalAIService = ref.watch(universalAIServiceProvider);
  return ProductionAIService(universalAIService);
});
