import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'universal_ai_service.dart';
import '../../domain/entities/ai_response.dart';

class MilkReceptionAIService {
  final UniversalAIService _universalAIService;
  final String _moduleName = 'milk_reception';

  MilkReceptionAIService(this._universalAIService);

  Future<List<String>> analyzeReceptionQuality(
      Map<String, dynamic> receptionData,
      {String? userId}) async {
    return await _universalAIService.generateInsights(
      module: _moduleName,
      data: {...receptionData, 'analysis_type': 'quality_assessment'},
      userId: userId,
    );
  }

  Future<List<String>> getSupplierPerformanceInsights(
      Map<String, dynamic> supplierReceptionHistory,
      {String? userId}) async {
    return await _universalAIService.generateInsights(
      module: _moduleName,
      data: {
        ...supplierReceptionHistory,
        'analysis_type': 'supplier_performance'
      },
      userId: userId,
    );
  }

  Future<Map<String, dynamic>> predictIncomingVolume(
      Map<String, dynamic> historicalReceptionData, int daysAhead,
      {String? userId}) async {
    return await _universalAIService.predictTrends(
      module: _moduleName,
      historicalData: historicalReceptionData,
      daysAhead: daysAhead,
      userId: userId,
    );
  }
}

final milkReceptionAIServiceProvider = Provider<MilkReceptionAIService>((ref) {
  final universalAIService = ref.watch(universalAIServiceProvider);
  return MilkReceptionAIService(universalAIService);
});
