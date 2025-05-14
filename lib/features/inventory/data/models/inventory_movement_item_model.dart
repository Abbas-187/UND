import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_movement_item_model.freezed.dart';
part 'inventory_movement_item_model.g.dart';

/// Model representing an inventory movement item (line item in a movement)
@freezed
abstract class InventoryMovementItemModel with _$InventoryMovementItemModel {
  const InventoryMovementItemModel._(); // Added for custom methods

  const factory InventoryMovementItemModel({
    String? id,
    required String itemId,
    required String itemCode,
    required String itemName,
    required String uom,
    required double quantity,
    double? costAtTransaction,
    String? batchLotNumber,
    DateTime? expirationDate,
    DateTime? productionDate,

    // new optional properties
    Map<String, dynamic>? customAttributes,
    String? warehouseId,
    String? status,
    String? qualityStatus,
    String? notes,
  }) = _InventoryMovementItemModel;

  /// Creates an InventoryMovementItemModel from JSON
  factory InventoryMovementItemModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementItemModelFromJson(json);

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime objects to Timestamp for Firestore
    if (expirationDate != null) {
      json['expirationDate'] = Timestamp.fromDate(expirationDate!);
    }

    if (productionDate != null) {
      json['productionDate'] = Timestamp.fromDate(productionDate!);
    }

    return json;
  }

  /// Validates if the model has required batch and expiry information
  /// for perishable or tracked items
  bool hasRequiredBatchInfo(bool isPerishable, bool requiresBatchTracking) {
    if (isPerishable) {
      return batchLotNumber != null && expirationDate != null;
    }

    if (requiresBatchTracking) {
      return batchLotNumber != null;
    }

    return true; // No batch tracking required for this item
  }

  // Calculate total value of the item
  double get totalValue => (costAtTransaction ?? 0) * quantity.abs();

  // Computed getters to match UI and domain naming
  String get productId => itemId;
  String get productName => itemName;
  String get unitOfMeasurement => uom;

  /// Alias for warehouseId to match expected property
  String? get locationId => warehouseId;

  /// Alias for warehouseId as location name where applicable
  String? get locationName => warehouseId;
}
