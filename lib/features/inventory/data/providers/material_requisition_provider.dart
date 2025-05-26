import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../factory/data/models/material_requisition_item_model.dart';
import '../../../factory/data/models/material_requisition_model.dart'
    as factory_model;
import '../../domain/providers/inventory_provider.dart';
import '../models/material_requisition_model.dart';

class MaterialRequisitionProvider
    extends StateNotifier<List<MaterialRequisitionModel>> {
  MaterialRequisitionProvider(this._ref)
      : _firestore = FirebaseFirestore.instance,
        super([]) {
    _loadMaterialRequisitions();
  }
  final FirebaseFirestore _firestore;
  final Ref _ref;

  /// Load all material requisitions
  Future<void> _loadMaterialRequisitions() async {
    try {
      final snapshot =
          await _firestore.collection('material_requisitions').get();
      final requisitions = snapshot.docs.map((doc) {
        final data = doc.data();
        return MaterialRequisitionModel(
          id: doc.id,
          productionOrderId: data['productionOrderId'] as String,
          scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
          materials: (data['materials'] as List<dynamic>)
              .map((e) => MaterialRequisitionItemModel.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
        );
      }).toList();
      state = requisitions;
    } catch (e) {
      // Remove print statements from production code
      // Future improvement: add proper logging
    }
  }

  /// Create a new material requisition
  Future<String> createMaterialRequisition({
    required String productionOrderId,
    required DateTime scheduledDate,
    required List<MaterialRequisitionItemModel> materials,
    required Map<String, List<Map<String, dynamic>>> pickingLocations,
    BuildContext? context, // Pass context for localization
  }) async {
    try {
      // Use provided requisition items directly
      final items = materials;

      // Create the requisition in factory module format
      final factoryRequisition = factory_model.MaterialRequisitionModel(
        id: const Uuid().v4(),
        productionOrderId: productionOrderId,
        items: items,
        status: factory_model.MaterialRequisitionStatus.pending,
        createdAt: DateTime.now(),
        notes: context != null
            ? (AppLocalizations.of(context)?.createdFromInventoryNote != null
                ? AppLocalizations.of(context)!
                    .createdFromInventoryNote(productionOrderId)
                : 'Created from inventory module for production order $productionOrderId')
            : 'Created from inventory module for production order $productionOrderId',
      );

      // Save to Firestore
      await _firestore
          .collection('material_requisitions')
          .doc(factoryRequisition.id)
          .set({
        'id': factoryRequisition.id,
        'productionOrderId': productionOrderId,
        'scheduledDate': Timestamp.fromDate(scheduledDate),
        'materials': items.map((m) => m.toJson()).toList(),
        'pickingLocations': pickingLocations,
        'status': factory_model.MaterialRequisitionStatus.pending
            .toString()
            .split('.')
            .last,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also save to factory collection for integration
      await _firestore
          .collection('factory_material_requisitions')
          .doc(factoryRequisition.id)
          .set(factoryRequisition.toJson());

      // Refresh the list
      await _loadMaterialRequisitions();

      return factoryRequisition.id;
    } catch (e) {
      // Remove print statements from production code
      // Future improvement: add proper logging
      rethrow;
    }
  }

  /// Update a material requisition's status
  Future<void> updateRequisitionStatus(
    String requisitionId,
    factory_model.MaterialRequisitionStatus status,
  ) async {
    try {
      await _firestore
          .collection('material_requisitions')
          .doc(requisitionId)
          .update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update in factory collection
      await _firestore
          .collection('factory_material_requisitions')
          .doc(requisitionId)
          .update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadMaterialRequisitions();
    } catch (e) {
      // Remove print statements from production code
      // Future improvement: add proper logging
      rethrow;
    }
  }

  /// Process and fulfill a material requisition
  Future<void> fulfillRequisition(String requisitionId,
      {BuildContext? context}) async {
    try {
      // Get the requisition
      final docSnapshot = await _firestore
          .collection('material_requisitions')
          .doc(requisitionId)
          .get();
      if (!docSnapshot.exists) {
        throw Exception(context != null
            ? (AppLocalizations.of(context)?.materialRequisitionNotFound ??
                'Material requisition not found')
            : 'Material requisition not found');
      }

      final data = docSnapshot.data()!;
      final materials = (data['materials'] as List<dynamic>)
          .map((e) =>
              MaterialRequisitionItemModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final pickingLocations = Map<String, List<Map<String, dynamic>>>.from(
          data['pickingLocations'] as Map<String, dynamic>);

      // Store any localized strings before async operations to avoid context usage across async gaps
      final String reasonText = context != null
          ? (AppLocalizations.of(context)?.materialRequisitionReason != null
              ? AppLocalizations.of(context)!
                  .materialRequisitionReason(requisitionId)
              : 'Material requisition: $requisitionId')
          : 'Material requisition: $requisitionId';

      // Decrease inventory for each material
      final inventoryNotifier = _ref.read(inventoryProvider.notifier);

      for (final material in materials) {
        final locations = pickingLocations[material.materialId] ?? [];

        if (locations.isEmpty) {
          // If no specific locations, just decrease from available stock
          await inventoryNotifier.decreaseStock(
            itemId: material.materialId,
            quantity: material.quantity,
            reason: reasonText,
            referenceId: requisitionId,
          );
        } else {
          // Otherwise decrease from specific locations
          for (final location in locations) {
            await inventoryNotifier.decreaseStock(
              itemId: material.materialId,
              quantity: (location['quantity'] as num).toDouble(),
              locationId: location['locationId'] as String,
              reason: reasonText,
              referenceId: requisitionId,
              batchNumber: location['batchNumber'] as String?,
            );
          }
        }
      }

      // Update requisition status
      await updateRequisitionStatus(
          requisitionId, factory_model.MaterialRequisitionStatus.completed);
    } catch (e) {
      // Remove print statements from production code
      // Future improvement: add proper logging
      rethrow;
    }
  }

  /// Get requisition by ID
  Future<MaterialRequisitionModel?> getRequisitionById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection('material_requisitions').doc(id).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data()!;
      return MaterialRequisitionModel(
        id: docSnapshot.id,
        productionOrderId: data['productionOrderId'] as String,
        scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
        materials: (data['materials'] as List<dynamic>)
            .map((e) => MaterialRequisitionItemModel.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      // Remove print statements from production code
      // Future improvement: add proper logging
      return null;
    }
  }

  /// Get requisitions by production order ID
  Future<List<MaterialRequisitionModel>> getRequisitionsByProductionOrder(
      String productionOrderId) async {
    try {
      final snapshot = await _firestore
          .collection('material_requisitions')
          .where('productionOrderId', isEqualTo: productionOrderId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MaterialRequisitionModel(
          id: doc.id,
          productionOrderId: data['productionOrderId'] as String,
          scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
          materials: (data['materials'] as List<dynamic>)
              .map((e) => MaterialRequisitionItemModel.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
        );
      }).toList();
    } catch (e) {
      // Remove print statements from production code
      // Future improvement: add proper logging
      return [];
    }
  }
}

// Provider for material requisition
final materialRequisitionProvider = StateNotifierProvider<
    MaterialRequisitionProvider, List<MaterialRequisitionModel>>((ref) {
  return MaterialRequisitionProvider(ref);
});
