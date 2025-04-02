import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaterialRequisitionNotifier extends StateNotifier<String?> {
  MaterialRequisitionNotifier() : super(null);

  // Creates a material requisition and returns its identifier.
  Future<String> createMaterialRequisition({
    required String productionOrderId,
    required DateTime scheduledDate,
    required List<dynamic>? materials,
    required Map<String, List<Map<String, dynamic>>> pickingLocations,
  }) async {
    // Stub implementation: return a dummy requisition ID.
    return 'dummy_requisition_id';
  }
}

final materialRequisitionProvider =
    StateNotifierProvider<MaterialRequisitionNotifier, String?>((ref) {
  return MaterialRequisitionNotifier();
});
