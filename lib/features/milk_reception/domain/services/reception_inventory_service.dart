import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/milk_reception_model.dart';
import '../repositories/milk_reception_repository.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';

/// Service to handle operations between milk reception and inventory
class ReceptionInventoryService {
  final MilkReceptionRepository receptionRepository;
  final InventoryRepository inventoryRepository;
  final FirebaseFirestore firestore;

  ReceptionInventoryService({
    required this.receptionRepository,
    required this.inventoryRepository,
    required this.firestore,
  });

  /// Stream of completed milk receptions
  Stream<List<MilkReceptionModel>> get completedReceptions =>
      receptionRepository.getCompletedReceptions();

  /// Creates an inventory entry from a milk reception
  Future<String> createInventoryFromReception(String receptionId) async {
    // Get reception details
    final reception = await receptionRepository.getReceptionById(receptionId);

    if (reception == null) {
      throw Exception('Reception not found');
    }

    if (reception.status != 'completed') {
      throw Exception('Cannot create inventory for uncompleted reception');
    }

    // Create inventory item from reception
    final inventoryId = await inventoryRepository.createInventoryItem({
      'productType': 'raw_milk',
      'quantity': reception.quantityLiters,
      'unit': 'liters',
      'location': reception.receptionCenter,
      'timestamp': DateTime.now().toIso8601String(),
      'quality': {
        'fatContent': reception.fatContent,
        'proteinContent': reception.proteinContent,
        'temperature': reception.temperature,
      },
      'additionalAttributes': {
        'receptionId': receptionId,
        'supplierId': reception.supplierId,
        'milkType': reception.milkType,
      }
    });

    // Update reception with inventory reference
    await receptionRepository.updateReception(receptionId,
        {'inventoryItemId': inventoryId, 'inventoryProcessed': true});

    return inventoryId;
  }

  /// Checks if inventory entry exists for a reception
  Future<bool> hasInventoryEntry(String receptionId) async {
    final result = await firestore
        .collection('inventory')
        .where('additionalAttributes.receptionId', isEqualTo: receptionId)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }
}
