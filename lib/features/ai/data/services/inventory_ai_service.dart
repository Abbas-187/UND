import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'universal_ai_service.dart';
import '../../domain/entities/ai_response.dart';

class InventoryAIService {
  final UniversalAIService _universalAIService;
  final String _moduleName = 'inventory';

  InventoryAIService(this._universalAIService);

  Future<List<String>> getStockLevelInsights(Map<String, dynamic> inventoryData,
      {String? userId}) async {
    return await _universalAIService.generateInsights(
      module: _moduleName,
      data: {...inventoryData, 'analysis_type': 'stock_level_review'},
      userId: userId,
    );
  }

  Future<List<String>> getReorderRecommendations(Map<String, dynamic> itemData,
      {String? userId}) async {
    return await _universalAIService.generateRecommendations(
      module: _moduleName,
      action: 'reorder_recommendation',
      data: itemData,
      userId: userId,
    );
  }

  Future<Map<String, dynamic>> predictDemand(
      Map<String, dynamic> historicalSales, int daysAhead,
      {String? userId}) async {
    return await _universalAIService.predictTrends(
      module: _moduleName,
      historicalData: historicalSales,
      daysAhead: daysAhead,
      userId: userId,
    );
  }

  // Add more inventory-specific AI methods as needed
}

final inventoryAIServiceProvider = Provider<InventoryAIService>((ref) {
  final universalAIService = ref.watch(universalAIServiceProvider);
  return InventoryAIService(universalAIService);
});
