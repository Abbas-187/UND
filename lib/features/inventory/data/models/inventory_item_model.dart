import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/inventory_item.dart';

part 'inventory_item_model.freezed.dart';
part 'inventory_item_model.g.dart';

/// Model representing an inventory item with freezed
@freezed
abstract class InventoryItemModel with _$InventoryItemModel {
  const InventoryItemModel._(); // Added for custom methods

  const factory InventoryItemModel({
    String? id,
    required String appItemId,
    @Default('') String sapCode,
    required String name,
    required String category,
    @Default('') String subCategory,
    required String unit,
    required double quantity,
    required double minimumQuantity,
    required double reorderPoint,
    required String location,
    required DateTime lastUpdated,
    String? batchNumber,
    DateTime? expiryDate,
    Map<String, dynamic>? additionalAttributes,
    double? cost,
    @Default(5) int lowStockThreshold,
    String? supplier,
  }) = _InventoryItemModel;

  /// Create from JSON
  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemModelFromJson(json);

  /// Convert from Firestore document
  factory InventoryItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Convert Firestore Timestamps to DateTime
    DateTime? lastUpdated;
    if (data['lastUpdated'] is Timestamp) {
      lastUpdated = (data['lastUpdated'] as Timestamp).toDate();
    } else if (data['lastUpdated'] != null) {
      lastUpdated = DateTime.parse(data['lastUpdated'].toString());
    }

    DateTime? expiryDate;
    if (data['expiryDate'] is Timestamp) {
      expiryDate = (data['expiryDate'] as Timestamp).toDate();
    } else if (data['expiryDate'] != null) {
      expiryDate = DateTime.parse(data['expiryDate'].toString());
    }

    return InventoryItemModel(
      id: doc.id,
      appItemId: data['appItemId'] ?? '',
      sapCode: data['sapCode'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      unit: data['unit'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      minimumQuantity: (data['minimumQuantity'] ?? 0).toDouble(),
      reorderPoint: (data['reorderPoint'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      lastUpdated: lastUpdated ?? DateTime.now(),
      batchNumber: data['batchNumber'],
      expiryDate: expiryDate,
      additionalAttributes: data['additionalAttributes'],
      cost: data['cost']?.toDouble(),
      lowStockThreshold: data['lowStockThreshold'] ?? 5,
      supplier: data['supplier'],
    );
  }

  /// Create from domain entity
  factory InventoryItemModel.fromDomain(InventoryItem item) =>
      InventoryItemModel(
        id: item.id,
        appItemId: item.appItemId,
        sapCode: item.sapCode,
        name: item.name,
        category: item.category,
        subCategory: item.subCategory,
        unit: item.unit,
        quantity: item.quantity,
        minimumQuantity: item.minimumQuantity,
        reorderPoint: item.reorderPoint,
        location: item.location,
        lastUpdated: item.lastUpdated,
        batchNumber: item.batchNumber,
        expiryDate: item.expiryDate,
        additionalAttributes: item.additionalAttributes,
        cost: item.cost,
        lowStockThreshold: item.lowStockThreshold,
        supplier: item.supplier,
      );

  /// Convert to domain entity
  InventoryItem toDomain() => InventoryItem(
        id: id ?? '',
        appItemId: appItemId,
        sapCode: sapCode,
        name: name,
        category: category,
        subCategory: subCategory,
        unit: unit,
        quantity: quantity,
        minimumQuantity: minimumQuantity,
        reorderPoint: reorderPoint,
        location: location,
        lastUpdated: lastUpdated,
        batchNumber: batchNumber,
        expiryDate: expiryDate,
        additionalAttributes: additionalAttributes,
        cost: cost,
        lowStockThreshold: lowStockThreshold,
        supplier: supplier,
      );

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson(); // Convert DateTime to Timestamp for Firestore
    json['lastUpdated'] = Timestamp.fromDate(lastUpdated);

    if (expiryDate != null) {
      json['expiryDate'] = Timestamp.fromDate(expiryDate!);
    }

    return json;
  }
}
