import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/universal_ai_service.dart';
import '../../data/services/inventory_ai_service.dart';
import '../../data/services/production_ai_service.dart';
import '../../data/services/milk_reception_ai_service.dart';
import '../../data/services/crm_ai_service.dart';
import '../../data/services/procurement_ai_service.dart';
import '../../data/services/quality_ai_service.dart';

// This provider will expose the UniversalAIService and potentially
// the module-specific AI services for easy access in the UI layer.

// Exposing the main UniversalAIService (already defined in its own file)
// final universalAIServiceProvider = Provider<UniversalAIService>((ref) => ...);

// Exposing module-specific services
final inventoryAIServiceProvider = Provider<InventoryAIService>((ref) {
  return InventoryAIService(ref.watch(universalAIServiceProvider));
});

final productionAIServiceProvider = Provider<ProductionAIService>((ref) {
  return ProductionAIService(ref.watch(universalAIServiceProvider));
});

final milkReceptionAIServiceProvider = Provider<MilkReceptionAIService>((ref) {
  return MilkReceptionAIService(ref.watch(universalAIServiceProvider));
});

final crmAIServiceProvider = Provider<CRMAIService>((ref) {
  return CRMAIService(ref.watch(universalAIServiceProvider));
});

final procurementAIServiceProvider = Provider<ProcurementAIService>((ref) {
  return ProcurementAIService(ref.watch(universalAIServiceProvider));
});

final qualityAIServiceProvider = Provider<QualityAIService>((ref) {
  return QualityAIService(ref.watch(universalAIServiceProvider));
});

// You might also create a combined provider if that simplifies access,
// though individual providers are often preferred for granularity.
