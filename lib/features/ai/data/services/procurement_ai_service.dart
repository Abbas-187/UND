import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'universal_ai_service.dart';
import '../../domain/entities/ai_response.dart';

class ProcurementAIService {
  final UniversalAIService _universalAIService;
  final String _moduleName = 'procurement';

  ProcurementAIService(this._universalAIService);

  Future<List<String>> analyzeSupplierProposals(
      List<Map<String, dynamic>> proposals,
      {String? userId}) async {
    return await _universalAIService.generateInsights(
      module: _moduleName,
      data: {'proposals': proposals, 'analysis_type': 'proposal_comparison'},
      userId: userId,
    );
  }

  Future<List<String>> recommendSuppliers(Map<String, dynamic> requirements,
      List<Map<String, dynamic>> availableSuppliers,
      {String? userId}) async {
    return await _universalAIService.generateRecommendations(
      module: _moduleName,
      action: 'supplier_recommendation',
      data: {
        'requirements': requirements,
        'available_suppliers': availableSuppliers
      },
      userId: userId,
    );
  }

  Future<Map<String, dynamic>> optimizeProcurementStrategy(
      Map<String, dynamic> currentStrategy,
      Map<String, dynamic> marketConditions,
      {String? userId}) async {
    return await _universalAIService.optimizeProcess(
      module: _moduleName,
      processType: 'strategy_optimization',
      currentState: currentStrategy,
      constraints:
          marketConditions, // Market conditions can act as constraints or inputs
      userId: userId,
    );
  }
}

final procurementAIServiceProvider = Provider<ProcurementAIService>((ref) {
  final universalAIService = ref.watch(universalAIServiceProvider);
  return ProcurementAIService(universalAIService);
});
